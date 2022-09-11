% script for reading a pointing model table in a .mat file, as generated
%  by Astropack/ pipeline.last.pointingModel, using the columns
%  [M_JRA, M_JDEC, DiffHA, DiffDec] (J2000 coordinates).
% If the .mat files contains data for more than one telescope (tables
%  R1...R4), the data for all of them is averaged. In that case it
%  is checked that M_JRA and M_JDEC are the same for all sets (it should,
%  as for this data is put together now). If they are not, proper averaging
%  will be devised in future.
% This script asks for user input as for the .mat file name, and for the
%  label of the resulting .create.yml file
tablename=input('file with the table written by pipeline.last.pointingModel?\n','s');

try
    load(tablename);
catch
    fprintf('file "%s" not found, aborting\n',tablename)
    return
end

rmodel=[exist('R1','var'),exist('R2','var'),...
        exist('R3','var'),exist('R4','var')];
if ~any(rmodel)
    fprintf('file "%s" doesn''t contain any R variable\n',tablename)
    return
end

for i=1:4
    if rmodel(i)
        
    end
end