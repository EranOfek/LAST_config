% script for reading a pointing model table in a .mat file, as generated
%  by Astropack/ pipeline.last.pointingModel, using the columns
%  [M_JHA, M_JDEC, DiffHA, DiffDec] (J2000 coordinates).
% If the .mat files contains data for more than one telescope (tables
%  R1...R4), the data for all of them is averaged. In that case it
%  is checked that M_JHA and M_JDEC are the same for all sets (it should,
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

var=strcat('R',num2str(find(rmodel)'));
hadec={};
delta={};
for i=1:size(var,1)
    tab=eval(var(i,:));
    if isa(tab,'table')
        hadec{i}=[tab.M_JHA,tab.M_JDEC];
        for j=1:i-1
            if hadec{i} ~= hadec{j}
                fprintf('table %s has different M_JHA and M_JDEC than its predecessors!\n',var(i,:))
                fprintf('this case is not yet handled\n')
                return
            end
        end
        delta=[tab.DiffHA,tab.DiffDec];
    else
        fprintf('variable %s is not a table!\n',var(i))
    end
end

deltaHA=mean(delta{:}(:,1),1); %fixme
deltaDec=mean(delta{:}(:,2),1); %fixme

configname=input('which label to assign to the configuration file?\n','s');

fid=fopen(['obs.pointingModel.' configname '.create.yml'],'w');
fprintf(fid,'# pointing model interpolation data\n');
fprintf(fid,'# NaNs removed,  otherwise they are read as strings!\n\n');
fprintf(fid,'# format:       [HA,  Dec,  offsetHA,  offsetDec]\n\n');
fprintf(fid,'PointingData : [\n');
for k=1:size(hadec{1},1)
    if ~isnan(deltaHA(k)) && ~isnan(deltaDec(k))
        fprintf('              [%f, %f, %f, %f]\n',hadec{1}(k,1),...
                hadec{1}(k,2),deltaHA(k),deltaDec(k));
    end
end
fprintf(fid,'               ]\n');


clear R1 R2 R3 R4 i j k tablename var hadec delta tab
