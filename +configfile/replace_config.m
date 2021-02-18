function replace_config(FileName,Key,Val,Units)
% Replace a keyword name in a config file
% Input  : - FileName
%          - Keyword
%          - Value.
%          - Units. Default is ''.
%
% Example: configfile.replace_config('try.txt','Long','31.0','');

if nargin<4
    Units = '';
end



Path = configfile.pathname;
PWD = pwd;
cd(Path);

Command = sprintf('sed -i "s/%s[ :].*/%s : %s : %s/" %s',Key,Key,Val,Units,FileName);
system(Command);


%cd(PWD)