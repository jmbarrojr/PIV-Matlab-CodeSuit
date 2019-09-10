function [NVar,I,J,K,VARIABLES,InsightHeader] = openPIVasciiVec(file)
%OPENPIVAVEC
% This function opens ASCII vector files on the new Insight V11
% 
% Output variables sequence is similar to MATRIX function for usability
% Author: Julio Barros
%         OIST - 2019
%
% VERSION 1.0
%
% See also: matrix

% Main function was prototyped for readbility
[NVar,I,J,K,VARIABLES,InsightHeader] = readTecplotASCII(file);

end

%%%%%%%%%%%%%%%
% Main Function
%%%%%%%%%%%%%%%
function [NVar,I,J,K,VARIABLES,InsightHeader] = readTecplotASCII(file)

vel = importdata(file);
%vel.source = fname;

InsightHeader = vel.textdata{:};
res = regexp(InsightHeader,'VARIABLES *= *(?<vars>.*) *', 'names');
if ~isempty(res)
    res = regexp([res(1).vars ','],'[" ]*(?<name>[^,]*?)[" ]*,', 'tokens');
    for ii = 1:length(res)
        
        %oname{ii} = res{ii}{1};
        vname{ii} = regexprep(res{ii}{1},'[W]+','_'); %#ok<AGROW>
        
        if ~isempty(strfind(vname{ii},'CHC'))
            break
        end
        
    end
    vel.vars = vname;
end
NVar = length(vname);

% Read Zone header
res = regexp(InsightHeader,'I=(?<I>[^"]+), J=(?<J>[^"]+), K=(?<K>[^"]+), F=(?<F>[^"]+)', 'names');
I = str2double(res.I);
J = str2double(res.J);
K = str2double(res.K);

VARIABLES = cell(Nvar,3);
for nv = 1 : NVar

    VARIABLES{nv,2} = reshape(vel.data(I*J*K,nv),I,J,K)';

end

end