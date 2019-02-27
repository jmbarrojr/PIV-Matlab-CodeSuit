function [Xc,Yc,Zc,Uavg,Vavg,Wavg,Lciavg,Wxavg,Wyavg,Wzavg,CHCavg] = ensembleAverage_V3V(pathDir,CompVecList,cores)
% Read all the velocity data of a V3V experiment inside the current folder
% and calculate the emsemble averages of the velocities.
%
% Author: Julio Barros
% University of Illinois at Urbana-Champaign
% 2013

if ispc == 1
    slash = '\';
else
    slash = '/';
end

% Opens the First VecFile to set the common grid
VecList = CompVecList{1};
vecfile = [pathDir slash VecList(1).name];
[~,I,J,K,~,~,~,X,Y,Z,~,~,~,~] = matrixV3V(vecfile);
% Get the min and max for all Axis based on the first vecfile
x_min = min(X(:));
x_max = max(X(:));
y_min = min(Y(:));
y_max = max(Y(:));
z_min = min(Z(:));
z_max = max(Z(:));

% Create a common grid for all vecfiles
x = linspace(x_min,x_max,I);
y = linspace(y_min,y_max,J);
z = linspace(z_min,z_max,K);
[Xc,Yc,Zc] = meshgrid(x,y,z);

% Start the parallel Processing
spmd
    
    for n=1:length(CompVecList)
        
        vecfile = [pathDir slash CompVecList(n).name];
        [~,~,~,~,~,~,~,X,Y,Z,U,V,W,CHC] = matrixV3V(vecfile);
        
        if n == 1
            % Initialize the Ensemble average matrices
            Uavg_p = zeros(J,I,K);
            Vavg_p = zeros(J,I,K);
            Wavg_p = zeros(J,I,K);
            Lci_p = zeros(J,I,K);
            CHC_p = zeros(J,I,K);
            Wx_p = zeros(J,I,K);
            Wy_p = zeros(J,I,K);
            Wz_p = zeros(J,I,K);
        end
        
        % Interpolate the Velocity into the common grid
        U = interp3(X,Y,Z,U,Xc,Yc,Zc,'cubic');
        V = interp3(X,Y,Z,V,Xc,Yc,Zc,'cubic');
        W = interp3(X,Y,Z,W,Xc,Yc,Zc,'cubic');
        CHC = interp3(X,Y,Z,CHC,Xc,Yc,Zc,'nearest');
        
        % Make the CHC 0's and 1's
        CHC = double(CHC > 0);
        %test = CHC; %DEBUG PURPOSE
        
        % Multiply the remaining outliers by CHC normalized
        U = U.*CHC;
        V = V.*CHC;
        W = W.*CHC;
        
        [Lci,Wx,Wy,Wz] = SwirlingStrength3D(Xc,Yc,Zc,U,V,W);
        
        Uavg_p = Uavg_p + U;
        Vavg_p = Vavg_p + V;
        Wavg_p = Wavg_p + W;
        CHC_p = CHC_p + CHC;
        Lci_p = Lci_p + Lci;
        Wx_p = Wx_p + Wx;
        Wy_p = Wy_p + Wy;
        Wz_p = Wz_p + Wz;
        
        % Save the Instantaneous Fields w/ Lci and Vorticity
        data = mixing3D(I,J,K,Xc,Yc,Zc,U,V,W,Wx,Wy,Wz,Lci,CHC);
        data = dealNaN(data);
        data = sortrows(data,[3,2,1]);
        
        TecplotHeader = ['VARIABLES="X", "Y", "Z", "U", "V", "W", '...
            '"Wx", "Wy", "Wz", "Lci", "CHC", '...
            'ZONE I=' num2str(I) ', J=' num2str(J) ', K=' num2str(K) ', F=POINT'];
        
        savename = [CompVecList(n).name(1:end-4) '.dat'];
        saver([pathDir slash 'Instantaneous' slash],savename,TecplotHeader,data);
        
    end
    
end

% Adding all the cores matrices
for i=1:cores
   
    if i == 1
        Uavg = zeros(J,I,K);
        Vavg = Uavg;
        Wavg = Uavg;
        Lciavg = Uavg;
        Wxavg = Uavg;
        Wyavg = Uavg;
        Wzavg = Uavg;
        CHCavg = Uavg;
    end
    
    Uavg = Uavg_p{i} + Uavg;
    Vavg = Vavg_p{i} + Vavg;
    Wavg = Wavg_p{i} + Wavg;
    Lciavg = Lci_p{i} + Lciavg;
    Wxavg = Wx_p{i} + Wxavg;
    Wyavg = Wy_p{i} + Wyavg;
    Wzavg = Wz_p{i} + Wzavg;
    CHCavg = CHC_p{i} + CHCavg;

end

% Calculating the final Ensemble Averages
Uavg = Uavg ./ CHCavg;
Vavg = Vavg ./ CHCavg;
Wavg = Wavg ./ CHCavg;
Wxavg = Wxavg ./ CHCavg;
Wyavg = Wyavg ./ CHCavg;
Wzavg = Wzavg ./ CHCavg;
Lciavg = Lciavg ./ CHCavg;