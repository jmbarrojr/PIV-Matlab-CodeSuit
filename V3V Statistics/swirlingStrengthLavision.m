function [Lambda,Vorticity] = swirlingStrengthLavision(X,Y,U,V,type)
% Function to calculate the "Stereo" Swirling Strength. It takes the
% Velocity Gradient Tensor for each grid point and find the imaginary
% part of the eigenvalues of the local Velocity Gradient Tensor (Zhou et al
% 1999)
%
% OBS:
% U and V should be the in-plane Velocity
% dU/dx should be varing in the vertical direction (across row)
% dU/dy should be varing in the horizontal direction (across colunms)
%
% Outputs:
% Lambda = Signed imaginary part of the eigenvalues of the local Velocity
% Gradient Tensor
%
% Author: Julio Barros
% University of Illinois at Urbana-Champaign

% Find the Gradients using Matlab function
dx = abs(X(1,2) - X(1,1)) / 1000;
dy = abs(Y(2,1) - Y(1,1)) / 1000;
if dx == 0
    dx = abs(X(2,1) - X(1,1)) / 1000;
    dy = abs(Y(1,2) - Y(1,1)) / 1000;
end

if type == 1
    
    [dUdx, dUdy] = gradient(U,dx,dy);
    [dVdx, dVdy] = gradient(V,dx,dy);
    
elseif type == 2
    [dUdy, dUdx] = gradient(U,dx,dy);
    [dVdy, dVdx] = gradient(V,dx,dy);
    
else
    disp('Fuck you')
end

dUdx = dealNaN(dUdx);
dUdy = dealNaN(dUdy);
dVdx = dealNaN(dVdx);
dVdy = dealNaN(dVdy);

% Initialize the lambda matrix
lambda = zeros(size(U));
for i=1:size(U,1)
    for j=1:size(U,2)
        Vel_tensor = [dUdx(i,j) dVdx(i,j);...
                      dUdy(i,j) dVdy(i,j)];
        d = eig(Vel_tensor);
        lambda(i,j) = abs(imag(d(2,1)));
    end
end

Vorticity = dVdx - dUdy;
Lambda = lambda.*(Vorticity./abs(Vorticity));