function [Uf,Vf,CHCf] = GlobalFilter(U,V,CHC,Urange,Vrange,nstd)
%GLOBALFILTER
% Inputs:
%        U & V = matrix containing velocities(displacement) in the horizontal
%        direction and vertical direction, respectively;
%        CHC = matrix containing tags for valid velocities
%        Urange & Vrange = vector containing 2 values (E.g.: [-2 10])
%        nstd = value for the standard deviation filter
%
% Author: Julio Barros
% OIST - 2019

%% CHC Filter
CHC(CHC<0) = 0;    
Uf = U .* CHC;
Vf = V .* CHC;
CHCf = CHC;

%% Global Range Filter
indU = U < Urange(1) | U > Urange(2);
indV = V < Vrange(1) | V > Vrange(2);
CHCf(indU | indV) = 0;

Uf = Uf .* CHCf;
Vf = Vf .* CHCf;

%% Global std Filter
indU = Uf < -nstd*std(Uf(Uf~=0)) | Uf > nstd*std(Uf(Uf~=0));
indV = Vf < -nstd*std(Vf(Vf~=0)) | Vf > nstd*std(Vf(Vf~=0));
CHCf(indU | indV) = 0;

Uf = Uf .* CHCf;
Vf = Vf .* CHCf;
