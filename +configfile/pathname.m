function Path=pathname
% Return path name in which the configuration files resides

functionpath=fileparts(mfilename('fullpath'));

% for now the configuration files are in a subdir of LAST_config, %  but it
%  may be sensible to move them to a global common directory
Path=fullfile(functionpath,'..','config');