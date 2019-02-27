% Parallel_Statistics_V3V
% Function to compute the all Single Point Statistics on V3V data
%
% Author: Julio Barros - UIUC 2013
% version: 1.0

clear
close all
clc

if ispc == 1
    slash = '\';
else
    slash = '/';
end

%%%%%%%%%%%%%
% USER INPUTS
%%%%%%%%%%%%%

pathDir = uigetdir('C:\','Select the dir which has the files to be processed');
ext = '*.GV3D';
files = dir([pathDir slash ext]);
if isempty(files) == 1
    ext = '*.gv3d';
    files = dir([pathDir slash ext]);
end

ResultsFol = [pathDir slash 'Results' slash];
%files = files(1:54); %DEBUG PURPOSE

%disp('Do you want to specify a Region of interest?');
%ROI = input('y , n?: ','s');
%if strcmp(ROI,'y')==1 || strcmp(ROI,'Y')==1
%    disp('Format: [left right top bottom]')
%    crop = input('Type the ROI: ');
%else
%    crop = [1 1 1 1];
%end

disp('Do you want to save the Fluctuation files?')
disp('Yes = 1 ; No = 0;')
flucask = input('?: ');

% Start Matlabpool
poolobj = gcp('nocreate'); % If no pool, do not create new one.
if isempty(poolobj)
    poolobj = parpool;
    cores = poolobj.NumWorkers;
else
    cores = poolobj.NumWorkers;
end

tstart_p = tic; % Start computing Time

% Split the list of the files into the number of cores
[CompVecList] = DistVecContent(cores,files);

% Computes the Ensemble Average of the velocity Fields
disp('Calculating the Ensemble Average')
[X,Y,Z,Uavg,Vavg,Wavg,Lciavg,Wxavg,Wyavg,Wzavg,CHCavg] = ensembleAverage_V3V(pathDir,CompVecList,cores);

% Computes the Reynolds Stresses of the velocity Fields
disp('Calculating the Reynolds Stresses')
[uu,uv,uw,vv,vw,ww,CHC_r] = ReynoldsStress_V3V(pathDir,CompVecList,cores,X,Y,Z,Uavg,Vavg,Wavg,flucask);

% Getting the final Matrices size
I = size(Uavg,2);
J = size(Uavg,1);
K = size(Uavg,3);

vel = mixing3D(I,J,K,X,Y,Z,Uavg,Vavg,Wavg,uu,uv,uw,vv,vw,ww,Wxavg,Wyavg,Wzavg,Lciavg,CHCavg);
vel = dealNaN(vel);
vel = sortrows(vel,[3,2,1]);

% Preparing to save the file
TecplotHeader = ['VARIABLES="X", "Y", "Z", "U", "V", "W", '...
        '"uu", "uv", "uw", "vv", "vw", "ww", '...
        '"Omegax", "Omegay", "Omegaz", "Lci", "CHC"'...
        'ZONE I=' num2str(I) ', J=' num2str(J) ', K=' num2str(K) ', F=POINT'];
    
saver(ResultsFol,'ensembleAverage_V3V.dat',TecplotHeader,vel);

tstop_p = toc(tstart_p);
disp('DONE')
disp([num2str(tstop_p/60) ' minutes taken'])

% Close Matlab Pool
% matlabpool close