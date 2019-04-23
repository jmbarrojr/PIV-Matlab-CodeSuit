function [X,Y,U,V,CHC,X_list,Y_list] = openPTVfile(filename,sy,sx)

A = importdata(filename);
%A.data = sortrows(A.data,[2,1]);
X_list = round(A.data(:,1));
Y_list = round(A.data(:,2));
U_list = A.data(:,3);
V_list = A.data(:,4);
CHC_list = A.data(:,5);


% X = zeros(sy,sx);
% Y = zeros(sy,sx);
U = zeros(sy,sx);
V = zeros(sy,sx);
CHC = zeros(sy,sx);


x = linspace(1,sx,sx);
y = linspace(1,sy,sy);
[X,Y] = meshgrid(y,x);

N = length(X_list);
for n=1:N
        
    % X( Y_list(n), X_list(n) ) = X_list(n);
    % Y( Y_list(n), X_list(n) ) = Y_list(n);
    U( Y_list(n), X_list(n) ) = U_list(n);
    V( Y_list(n), X_list(n) ) = V_list(n);
    CHC( Y_list(n), X_list(n) ) = CHC_list(n);
    
end
