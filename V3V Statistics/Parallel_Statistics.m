% Parallel_Statistics
% Function to compute the all Single Point Statistics
%
% Usage Parallel_Statistics('*.vec','2D')
% ext = file extension ('*.vec';'*.v3d';'*.gv3d')
% type = '2D' or 'Stereo' or '3D'
% Author: Julio Barros - UIUC 2011
% version: 1.2
%
% History V1.2.1
% add user interface and avoid setting the path directory to be able to see
% the other fucntions
% Ask if the user wants to save the fluc vecfiles

clear all
close all
clc

%%%%%%%%%%%%%
% USER INPUTS
%%%%%%%%%%%%%

%ext = input('Type, the extention of the files to be processed (eg: *.vec): ','s');
type = input('Type if it is 2D, Stereo, 3D: ','s');

if strcmp(type,'2D')==1
    ext = '*.vec';
elseif strcmp(type,'Stereo')==1
    ext = '*.v3d';
elseif strcmp(type,'3D')==1
    ext = '*.v3v';
else
    disp('You did not choose the correct option')
    break
end

if ispc == 1
    slash = '\';
else
    slash = '/';
end

pathDir = uigetdir('','Select the dir which has the files to be processed');
files = dir(strcat(pathDir,slash,ext));
ResultsFol = strcat(pathDir,slash,'Results',slash);
%files = files(1:54); %DEBUG PURPOSE


disp('Do you want to specify a Region of interest?');
ROI = input('y , n?: ','s');
if strcmp(ROI,'y')==1 || strcmp(ROI,'Y')==1
    disp('Format: [left right top bottom]')
    crop = input('Type the ROI: ');
else
    crop = [1 1 1 1];
end

disp('Do you want to save the Fluctuation files?')
flucask = input('y or n?: ','s');

% Close if there is any open pool
if matlabpool('size') > 0;
    matlabpool close force local
end
% Start the Parallel pools
matlabpool open
cores = matlabpool('size'); % Number of cores availabe in the computer

tstart_p = tic; % Start computing Time

% Split the list of the files into the number of cores
[CompVecList] = DistVecContent(cores,files);

%%%%%%%%%%%%%%%%%%%%
% 2D PIV - STILL NEEDS TO BE UPDATED
%%%%%%%%%%%%%%%%%%%%
if strcmp(type,'2D') == 1
    % 2D PIV
    %Computes the Ensemble Average of the velocity Fields
    disp('Calculating the Ensemble Average')
    [X,Y,Uavg,Vavg,CHC] = ensemble2dPIV(CompVecList,cores,crop);
    
    disp('')
    disp('Calculating the Reynolds Stresses')
    [uu,vv,uv] = ReynoldsStress2dPIV(CompVecList,cores,Uavg,Vavg,crop);
    
    % Reshape the matrix
    I = size(uu,1);
    J = size(uu,2);
    vel = mixing(I,J,X,Y,Uavg,Vavg,uu,vv,uv,CHC);
    
    TecplotHeader = ['VARIABLES="X", "Y", "Uavg", "Vavg", "u^2", "v^2", "uv", "CHC",' ...
        'ZONE I=' num2str(I) ', J=' num2str(J) ', K=1, F=POINT'];
    saver(ResultsFol,'ensembleAverage.dat',TecplotHeader,vel);
    
    % Making the profiles
    [U_l,V_l,u_l,v_l,uv_l] = lineAverage(Uavg,Vavg,uu,vv,uv,1);
    profile = mixing(1,J,X(1,:)',Y(1,:)',U_l,V_l,u_l,v_l,uv_l);
    TecplotHeader2 = ['VARIABLES="X", "Y", "U", "V", "u^2", "v^2", "uv",' ...
        'ZONE I=' num2str(1) ', J=' num2str(J) ', K=1, F=POINT'];
    saver(ResultsFol,'profile_XDirection.dat',TecplotHeader2,profile);
    
    [U_l,V_l,u_l,v_l,uv_l] = lineAverage(Uavg,Vavg,uu,vv,uv,2);
    profile = mixing(I,1,X(:,1),Y(:,1),U_l,V_l,u_l,v_l,uv_l);
    TecplotHeader3 = ['VARIABLES="X", "Y", "U", "V", "u^2", "v^2", "uv",' ...
        'ZONE I=' num2str(1) ', J=' num2str(I) ', K=1, F=POINT'];
    saver(ResultsFol,'profile_Ydirection.dat',TecplotHeader3,profile);
    
%%%%%%%%%%%%%%%%%%%%
% Stereo PIV - UPDATED VERSION
%%%%%%%%%%%%%%%%%%%%
elseif strcmp(type,'Stereo')
    % Stereo PIV
    disp('Calculating the Ensemble Average')
    [X,Y,Z,Uavg,Vavg,Wavg,Lciavg,CHC] = ensembleAverage_Stereo(CompVecList,cores,crop,pathDir);
    
    disp('')
    disp('Calculating the Reynolds Stresses')
    [uu,vv,ww,uv,uw,vw,lci] = ReynoldsStress_Stereo(CompVecList,cores,Uavg,Vavg,Wavg,Lciavg,crop,pathDir,flucask);
    
    I = size(Uavg,1);
    J = size(Uavg,2);
    
    vel = mixing(I,J,X,Y,Z,Uavg,Vavg,Wavg,Lciavg,uu,vv,ww,uv,uw,vw,lci,CHC);
    
    [vel] = dealNaN(vel);
    
    TecplotHeader = ['VARIABLES="x", "y", "z",'...
        '"<math>a</math>U<math>q</math>", '...
        '"<math>a</math>V<math>q</math>", '...
        '"<math>a</math>W<math>q</math>", '...
        '"<math>a</math>Lci<math>q</math>", '...
        '"<math>a<math>u<sup>2</sup><math>q</math>", '...
        '"<math>a</math>v<sup>2</sup><math>q</math>", '...
        '"<math>a</math>w<sup>2</sup><math>q</math>", '...
        '"<math>a</math>uv<math>q</math>", '...
        '"<math>a</math>uw<math>q</math>", '...
        '"<math>a</math>vw<math>q</math>", '...
        '"<math>a</math>lcip<math>q</math>", '...
        '"CHC" ' ...
        'ZONE I=' num2str(I) ', J=' num2str(J) ', K=1, F=POINT'];
    saver(ResultsFol,'ensembleAverage.dat',TecplotHeader,vel);

    
elseif strcmp(type,'3D')
    % V3V Ensemble and Reynolds Calculations
    
    ask = input('Horn1, Horn2, Center, Smooth ?: ','s');
    % Computes the Ensemble Average of the velocity Fields
    disp('Calculating the Ensemble Average')
    [X,Y,Z,Uavg,Vavg,Wavg,CHCavg] = ensembleAverage_V3V_data(CompVecList,cores,ask);
        
    % Dealing with NaN
    Uavg = NaNfillZero(Uavg);
    Vavg = NaNfillZero(Vavg);
    Wavg = NaNfillZero(Wavg);
    
    % Making the Velocity profiles
    Up = nanmean(Uavg,1);Up = nanmean(Up,3);
    Vp = nanmean(Vavg,1);Vp = nanmean(Vp,3);
    Wp = nanmean(Wavg,1);Wp = nanmean(Wp,3);
    
    % Computes the Reynolds Stresses of the velocity Fields
    disp('')
    disp('Calculating the Reynolds Stresses')
    [uu,vv,ww,uv,uw,vw,CHC_r] = ReynoldsStress3dPIV(CompVecList,cores,Up,Vp,Wp,ask);
    
    % Dealing with NaN
    uu = NaNfillZero(uu);
    vv = NaNfillZero(vv);
    ww = NaNfillZero(ww);
    uv = NaNfillZero(uv);
    uw = NaNfillZero(uw);
    vw = NaNfillZero(vw);
    
    % Making the profiles (line averaged)
    uup = nanmedian(uu,3);uup = nanmedian(uup,1);
    vvp = nanmedian(vv,3);vvp = nanmedian(vvp,1);
    wwp = nanmedian(ww,3);wwp = nanmedian(wwp,1);
    uvp = nanmedian(uv,3);uvp = nanmedian(uvp,1);
    uwp = nanmedian(uw,3);uwp = nanmedian(uwp,1);
    vwp = nanmedian(vw,3);vwp = nanmedian(vwp,1);
    
    % Getting the final Matrices size
    I = size(Uavg,1);
    J = size(Uavg,2);
    K = size(Uavg,3);
    
    vel = mixing3D(I,J,K,X,Y,Z,Uavg,Vavg,Wavg,CHCavg,uu,vv,ww,uv,uw,vw);
    
    % Preparing to save the file
    TecplotHeader = ['TITLE     = "", '...
        'VARIABLES = "X", '...
        '"Y", '...
        '"Z", '...
        '"U", '...
        '"V", '...
        '"W", '...
        '"CHC", '...
        '"uu", '...
        '"vv", '...
        '"ww", '...
        '"uv", '...
        '"uw", '...
        '"vw", '...
        'DATASETAUXDATA DataType="V", '...
        'DATASETAUXDATA Dimension="3", '...
        'DATASETAUXDATA ExtraDataNumber="0", '...
        'DATASETAUXDATA FirstNodeX="-9.625", '...
        'DATASETAUXDATA FirstNodeY="2.625", '...
        'DATASETAUXDATA FirstNodeZ="-2.625", '...
        'DATASETAUXDATA GridSpacingX="1.75", '...
        'DATASETAUXDATA GridSpacingY="1.75", '...
        'DATASETAUXDATA GridSpacingZ="1.75", '...
        'DATASETAUXDATA HasVelocity="Y", '...
        'ZONE T="T1", '...
        ' STRANDID=0, SOLUTIONTIME=0, '...
        ' I=' num2str(I) ', J=' num2str(J) ', K=' num2str(K) ', ZONETYPE=Ordered', ...
        ' DATAPACKING=POINT, '...
        ' DT=(SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE SINGLE )'];
    saver(ResultsFol,'ensembleAverage_3d.dat',TecplotHeader,vel);
    
    profile = [Y(1,:,1)',Up',Vp',Wp',uup',vvp',wwp',uvp',uwp',vwp'];
    TecplotHeader3 = ['VARIABLES="Y", "U", "V", "W", "u^2", "v^2", "w^2",' ...
        ' "-uv", "uw", "vw", ZONE I=' num2str(1) ', J=' num2str(J) ', K=1, F=POINT'];
    saver(ResultsFol,'profiles.dat',TecplotHeader3,profile);
    
else
    error('Undefined Type');
end

tstop_p = toc(tstart_p);

disp('DONE')
disp([num2str(tstop_p/60) ' minutes taken'])

% Close Matlab Pool
matlabpool close