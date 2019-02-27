function [uu,uv,uw,vv,vw,ww,CHC] = ReynoldsStress_V3V(pathDir,CompVecList,cores,Xc,Yc,Zc,Uavg,Vavg,Wavg,flucask)

if ispc == 1
    slash = '\';
else
    slash = '/';
end

% Retrive the common grid I,J,K
[J,I,K] = size(Xc);

spmd
    for n=1:length(CompVecList)
        
        vecfile = [pathDir slash CompVecList(n).name];
        [~,~,~,~,~,~,~,X,Y,Z,U,V,W,CHC] = matrixV3V(vecfile);
        
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
        
        % Compute the Instantaneous Fluctuation Fields
        u = U - Uavg;
        v = V - Vavg;
        w = W - Wavg;
        
        % Smooth to calculate the Lci and Vorticity
        Us = smooth3(U,'gaussian',[3 3 3],1);
        Vs = smooth3(V,'gaussian',[3 3 3],1);
        Ws = smooth3(W,'guassian',[3 3 3],1);
        [Lci,Wx,Wy,Wz] = SwirlingStrength3D(Xc,Yc,Zc,Us,Vs,Ws);
        
        if flucask == 1
        % Saving Fluctuation data
            TKE = 0.5*(u.^2 + v.^2 + w.^2);
            uv = u.*w;
            Wm = sqrt(Wx.^2 + Wy.^2 + Wz.^2);
            data = mixing3D(I,J,K,Xc,Yc,Zc,U,V,W,u,v,w,TKE,uv,Wx,Wy,Wz,Wm,Lci,CHC);
            data = dealNaN(data);
            data = sortrows(data,[3,2,1]);
            
            TecplotHeader = ['VARIABLES="X", "Y", "Z", "U", "V", "W", '...
                '"up", "vp", "wp", "TKE", "uv", "Wx", "Wy", "Wz", "Wmag", "Lci", "CHC", '...
                'ZONE I=' num2str(I) ', J=' num2str(J) ', K=' num2str(K) ', F=POINT'];
            
            savename = [CompVecList(n).name(1:end-4) '.dat'];
            saver([pathDir slash 'Fluctuations' slash],savename,TecplotHeader,data);
        end
        
        % Ensemble Average the Reynolds Stresses
        if n == 1
            uu_p = zeros(J,I,K);
            uv_p = zeros(J,I,K);
            uw_p = zeros(J,I,K);
            vv_p = zeros(J,I,K);
            vw_p = zeros(J,I,K);
            ww_p = zeros(J,I,K);
            CHC_p = zeros(J,I,K);
        end
        
        uu_p = uu_p + u.*u;
        uv_p = uv_p + u.*v;
        uw_p = uw_p + u.*w;
        vv_p = vv_p + v.*v;
        vw_p = vw_p + v.*w;
        ww_p = ww_p + w.*w;
        CHC_p = CHC_p + CHC;
        
    end
    
end

% Initializing the final matricies
uu = zeros(size(uu_p{1}));
vv = uu;
ww = uu;
uv = uu;
uw = uu;
vw = uu;
CHC = uu;

for c=1:cores
    
    if c == 1
        uu = zeros(J,I,K);
        uv = zeros(J,I,K);
        uw = zeros(J,I,K);
        vv = zeros(J,I,K);
        vw = zeros(J,I,K);
        ww = zeros(J,I,K);
        CHC = zeros(J,I,K);
    end
    
    uu = uu_p{c} + uu;
    vv = vv_p{c} + vv;
    ww = ww_p{c} + ww;
    uv = uv_p{c} + uv;
    uw = uw_p{c} + uw;
    vw = vw_p{c} + vw;
    CHC = CHC_p{c} + CHC;
end

uu = uu./CHC;
vv = vv./CHC;
ww = ww./CHC;
uv = uv./CHC;
uw = uw./CHC;
vw = vw./CHC;
CHC = CHC./CHC;