clc
clear

if ispc == 1
    slash = '\';
else
    slash = '/';
end

originPath = 'D:\Experiments11\Turbulence in Soap Film\March2016B_full\RawData';
copyPath = 'D:\Experiments11\Turbulence in Soap Film\March2016_Skip\RawData';

files = dir([originPath slash '*.tif']);
N = length(files);

skip = 4;
c = 0;
for n=1:skip:N
    
    % files(n+c).name
    % files(n+c+skip).name
    
    % LA
    savename = sprintf('TestSkip%06d.T000.D000.P000.H001.LA.tif',c);
    command = ['copy "' originPath slash files(n+c).name '" "' copyPath slash savename '"'];
    dos(command);
    
    % LB
    savename = sprintf('TestSkip%06d.T000.D000.P000.H001.LB.tif',c);
    command = ['copy "' originPath slash files(n+c+skip).name '" "' copyPath slash savename '"'];
    dos(command);
    
    c = c +1;
end
