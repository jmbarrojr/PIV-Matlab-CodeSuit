clear
clc

% path = 'D:\Experiments11\Turbulence in Soap Film\March2016B_full\Analysis';
% path = 'D:\Experiments11\Turbulence in Soap Film\Synthetic_reflection_5000particles_19Feb2019_x=17cm_w=2cm_06mlps\Analysis';

path = uigetdir('D:\Experiments11\',...
                'Select the Analyis folder of the Run to be Analyzed');
            
pathImg = strrep(path,'Analysis','RawData');

files = dir([path filesep '*.LA.par']);
filesImg = dir([pathImg filesep '*.tif']);

N = length(files);

Img = imread([pathImg filesep filesImg(1).name]);
[sy,sx] = size(Img);
%sx = 200; sy = 220;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Global filter PARAMETERS
Urange = [-0.1 0.1];
Vrange = [-30 0];
nstd = 100;
%%%%%%%%%%%%%%%%%%%%%%%%%%

%% INITIALIZATION
[X,Y,~,~,~,~,~] = openPTVfile([path filesep files(1).name],sy,sx);
% Xm = zeros(sy,sx);
% Ym = zeros(sy,sx);
Um = zeros(sy,sx);
Vm = zeros(sy,sx);
CHCm = zeros(sy,sx);
        
%% ENSEMBLE AVEGARE
parfor n=N-195:N
    
    filename = [path filesep files(n).name];
    [~,~,U,V,CHC,~,~] = openPTVfile(filename,sy,sx);
    
    [Uf,Vf,CHCf] = GlobalFilter(U,V,CHC,Urange,Vrange,nstd);
    
%     figure(1),quiver(X,Y,U,V,50,'k'),axis equal tight
%     title(files(n).name), hold on
%     figure(1),quiver(X,Y,Uf,Vf,50,'r'),axis equal tight
%     drawnow
    
    CHC = double(CHC>0);
    
    %Xm = Xm + X;
    %Ym = Ym + Y;
    Um = Um + Uf;
    Vm = Vm + Vf;
    CHCm = CHCm + CHCf;
    
end

% Xm = Xm ./ CHCm;
% Ym = Ym ./ CHCm;
Um = Um ./ CHCm;
Vm = Vm ./ CHCm;

Um(CHCm == 0) = NaN;
Vm(CHCm == 0) = NaN;

%% FIGURES
% Mean Vector Field
figure(2),quiver(X,Y,Um,Vm,10),axis equal tight

% Mean Streamwise Velocity field
figure(3),contourf(X,Y,Vm),axis equal tight

% Mean velocity profile 
y = Y(:,1);
x = X(1,:);

U_profile = nanmean(Vm(355:450,:),1);
%U_profile = nanmean(Um(:,95:105),2);
figure(4),plot(x,U_profile)

