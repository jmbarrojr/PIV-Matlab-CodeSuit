clear all
close all
clc

if ispc == 1
    slash = '\';
else
    slash = '/';
end

pathDir = 'I:\Experiments_Julio_Insight\WindTunnel_FullRoughness_10000images\30Hz_Full\Analysis\Results';
vecfile = 'EnsembleAverage_v2_30HzFull_10000.dat';

pathvecfile = strcat(pathDir,slash,vecfile);
[~,I,J,Dx,Dy,X,Y,Z,U,V,W,CHC] = matrix(pathvecfile);

index = CHC == 0;
CHC = double(CHC>0);

U(index) = NaN;
V(index) = NaN;
W(index) = NaN;

Um = nanmean(U,2);
Vm = nanmean(V,2);
Uaavg = nanmean(U(:));
Vaavg = nanmean(V(:));

for i=1:I
    if i == 1
        u = zeros(J,I);
        v = zeros(J,I);
    end
    u(:,i) = U(:,i) - Um;
    v(:,i) = V(:,i) - Vm;
end

Ua = U-Uaavg;
Va = V-Vaavg;

%Grid spacing in meters
dz = Dx/1000; % Should be scaled properly (m)
dy = Dy/1000; % Should be scaled properly (m)

% Calculate the Swirling Strength
u = dealNaN(u);
v = dealNaN(v);
[Lambda,Vort] = swirlingStrength(Dx,Dy,u,v);

% Save the fluctuation field
data = mixing(I,J,X,Y,Z,u,v,W,Lambda,Vort,CHC);
data = dealNaN(data);
data = sortrows(data,[2,1]);
TecplotHeader = ['VARIABLES="X", "Y", "Z", "U", "V", "W", "Lci", "Omega", "CHC" '...
    'ZONE I=' num2str(I) ', J=' num2str(J) ', K=1, F=POINT'];
flucfile = [vecfile(1:end-4) '_SwirlVort_Prof_avg.dat'];
saver([pathDir slash],flucfile,TecplotHeader,data);

% Calculate the Swirling Strength
Ua = dealNaN(Ua);
Va = dealNaN(Va);
[Lambda,Vort] = swirlingStrength(Dx,Dy,Ua,Va);

% Save the fluctuation field
data = mixing(I,J,X,Y,Z,Ua,Va,W,Lambda,Vort,CHC);
data = dealNaN(data);
data = sortrows(data,[2,1]);
TecplotHeader = ['VARIABLES="X", "Y", "Z", "U", "V", "W", "Lci", "Omega", "CHC" '...
    'ZONE I=' num2str(I) ', J=' num2str(J) ', K=1, F=POINT'];
flucfile = [vecfile(1:end-4) '_SwirlVort_Area_avg.dat'];
saver([pathDir slash],flucfile,TecplotHeader,data);

%%
figure(1),
contourf(X,Y,W,11),axis equal,hold on
quiver(X,Y,u,v,50,'k')

figure(2),
contourf(X,Y,W,11),axis equal,hold on
quiver(X,Y,Ua,Va,50,'k')

figure(3),
contourf(X,Y,W,11),axis equal,hold on
quiver(X,Y,U,V,50,'k')