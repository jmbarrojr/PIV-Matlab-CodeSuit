function [Lci,Wx,Wy,Wz] = SwirlingStrength3D(X,Y,Z,U,V,W)
% This function calculates the 3D Swirling Strength together
% with the three components of the Vorticity.
% Because this function uses MATLAB's gradient function
% the X direction has to be accross columns, the Y direction
% accros rows and the Z direction on the last dimmension.
% 
% Author: Julio Barros
% UIUC - 2013

[J,I,K] = size(U);

dz = abs(Z(1,1,2)-Z(1,1,1))/1000;
dx = abs(X(1,2,1)-X(1,1,1))/1000;
dy = abs(Y(2,1,1)-Y(1,1,1))/1000;

[dUdx,dUdy,dUdz] = gradient(U,dx,dy,dz);
[dVdx,dVdy,dVdz] = gradient(V,dx,dy,dz);
[dWdx,dWdy,dWdz] = gradient(W,dx,dy,dz);

for i=1:I
    for j=1:J
        for k=1:K
            
            if i==1 && j == 1 && k == 1
                Lci = zeros(J,I,K);
            end
            
            VelGrad = [dUdx(j,i,k) dUdy(j,i,k) dUdz(j,i,k);
                       dVdx(j,i,k) dVdy(j,i,k) dVdz(j,i,k);
                       dWdx(j,i,k) dWdy(j,i,k) dWdz(j,i,k)];
            
            VelGrad = dealNaN(VelGrad);
            
            %S = 1/2*(VelGrad + VelGrad');
            %O = 1/2*(VelGrad - VelGrad');
            %On = trace(O*O')^(1/2);
            %Sn = trace(S*S')^(1/2);
            %Q(i,j,k) = 1/2*(On^2 - Sn^2);
            
            lci = eig(VelGrad);
            Lci(j,i,k) = abs(imag(lci(2,1)));
        end
    end
end

Wx = dWdy - dVdz;
Wy = dUdz - dWdx;
Wz = dVdx - dUdy;