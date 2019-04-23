clear
close all
clc

path = 'X:\Yuna\Air Drag\20February2019\20February2019_w=2cm_02mlps';

files = dir([path filesep '*.tif']);
N = length(files);
N = 1000;

% Start on Image #2
skip = 1;

% Approx. location where the film resides in the image
x_start = 57;
% Size of the correlation template in the x-direction 
sx = 16;

c = 1;
for n=1+skip:2:N
    
    A = imread([path filesep files(n).name]);
    %B = imread([path filesep files(n+1).name]);
    
    % Possible user pick UI
%     if c == 1
%         figure(1), colormap gray
%         imagesc(A), axis equal
%         [x,~] = ginput(1);
%     end
    
    % Smooth the image a bit 
    As = imgaussfilt(A,2);
    
    %% Correlation method
    template = As(1:150,x_start:x_start + sx-1);
    template = fliplr(template);
    Corr = normxcorr2(template,As(1:150,1:x_start));
    
    % figure(2), surf(Corr), shading flat
    % drawnow
    
    [~, xpeak(c)] = find(Corr==max(Corr(:)));
    figure(2)
    plot(c,xpeak(c),'ko'),hold on
    drawnow
    
    %% Derivative method
    % h = fspecial('gaussian',[30 30],15);
    % As = imfilter(A,h);
    
%     As = imgaussfilt(A,5);
%     [dAdx, dAdy] = gradient(double(As));
%     
%     figure(3), colormap gray
%     imagesc(dAdx>0),axis equal
%     drawnow
    
    %% 1D Symmetry function
    [J,I] = size(A);
    for j=1:J
        
        fx  = double(As(j,x_start:x_start+sx-1));
        %fx_m = mean(fx);
        fx_m = double(As(j,x_start-sx+1:x_start));
        %f_mx_m = mean(fx_m);
        
        %[Cfx(j,:),rx] = xcorr(f_x , f_mx);
        %Cfx(j,:) = Cfx(j,:) ./ trapz(f_x.^2);
        
        fx_s =  (fx + fx_m)/2;
        fx_as = (fx - fx_m)/2;
        Cfx(j,:) = (abs(fx_s).^2 - abs(fx_as).^2)./(abs(fx_s).^2 + abs(fx_as).^2);
        
%         figure(4)
%         subplot(2,1,1),plot(f_x),hold on,plot(f_mx),hold off
%         subplot(2,1,2),plot(rx,Cfx(j,:)), drawnow
    end
    
    % figure(5)
    % imagesc(Cfx),axis equal
    
    Cfx_m = mean(Cfx,1);
    [ypeak, xpeak_Cfx(c)] = find(Cfx_m==max(Cfx_m(:)));
    
    figure(6)
    plot(xpeak_Cfx,'ko')
    
    c = c + 1;
end
hold off

figure,hist(xpeak)