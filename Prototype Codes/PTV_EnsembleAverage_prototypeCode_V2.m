clear
clc

path = 'D:\Experiments11\Turbulence in Soap Film\March2016B_full\Analysis';

files = dir([path filesep '*.LA.par']);
N = length(files);

sx = 768; sy = sx;

for n=1:2000
    
    if n == 1
        % Xm = zeros(sy,sx);
        % Ym = zeros(sy,sx);
        Um = zeros(sy,sx);
        Vm = zeros(sy,sx);
        CHCm = zeros(sy,sx);
    end
    
    filename = [path filesep files(n).name];
    [X,Y,U,V,CHC,~,~] = openPTVfile(filename,sy,sx);
    
    % Global filter
    Urange = [-1 1];
    Vrange = [-10 0];
    nstd = 7;
    [Uf,Vf,CHCf] = GlobalFilter(U,V,CHC,Urange,Vrange,nstd);
    
%     figure(1),quiver(X,Y,U,V,50,'k'),axis equal tight
%     title(files(n).name), hold on
%     figure(1),quiver(X,Y,Uf,Vf,50,'r'),axis equal tight
%     drawnow
    
    %Xm = Xm + X;
    %Ym = Ym + Y;
    Um = Um + Uf;
    Vm = Vm + Vf;
    CHCm = CHCm + CHC;
    
end

% Xm = Xm ./ CHCm;
% Ym = Ym ./ CHCm;
Um = Um ./ CHCm;
Vm = Vm ./ CHCm;

Um(CHCm == 0) = 0;
Vm(CHCm == 0) = 0;

figure(2),quiver(X,Y,Um,Vm,10),axis equal tight
figure(3),contourf(X,Y,Vm),axis equal tight




