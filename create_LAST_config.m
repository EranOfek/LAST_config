function create_LAST_config(Node, Mount, Args)
    % example:
    % create_LAST_config(1,7,'ConfigDir','LAST_config/config','CameraPhysicalID',{'111111','22222'})

    
    arguments
        Node    = 1;
        Mount   = 71;
        Args.ConfigDir = '/home/ocs/matlab/LAST/LAST_config/config';
        Args.FilesTemplate = '*#TEMPLATE*.yml';
        Args.Dirs = {'inst.IndoorSensors',...
                     'inst.OutdoorMeteoSensors',...
                     'inst.QHYccd',...
                     'inst.tinycontrolIPpowerSocket',...
                     'inst.XerxesMount',...
                     'obs.camera',...
                     'obs.focuser',...
                     'obs.mount',...
                     'obs.unitCS',...
                     'obs.util.SpawnedMatlab'};
                    
        % need to provide these args:
        Args.CameraPhysicalID          = {};
        Args.MotorID                   = 'RADEC11111';
        Args.MountAddress              = '/USBFORMOUNT'    % USB physical port
        Args.MountLon                  = 35.0407331;
        Args.MountLat                  = 30.0529838;
        Args.MountHeight               = 415.4;
        Args.FilterName                = 'clear';
        
        Args.N_SwitchPerMount          = 2;
        Args.Ncam                      = 4;
    end
    
    % primary computer used for mount control
    PrimaryComputer = sprintf('last%2de',Mount);
    PrimaryDiskName = 'data1';
    
    MountStr = sprintf('%02d',Mount);
    
    % calc mount coordinates
    MountLon    = Args.MountLon;
    MountLat    = Args.MountLat;
    MountHeight = Args.MountHeight;
    
    if isempty(Args.CameraPhysicalID)
        PhysicalCameraList = readcell('cameras_PhysicalAddress.txt');
        MountList = cell2mat(PhysicalCameraList(:,1));
        CamList   = cell2mat(PhysicalCameraList(:,2));
        
        Flag = MountList == Mount;
        CameraPhysicalID = PhysicalCameraList(Flag);
       
    else
        CameraPhysicalID = Args.CameraPhysicalID;
    end
    FocuserAddress = {'foc1','foc2','foc3','foc4'}; %% cell with 4 entries - USB names
    
    IndoorSensorPhysicalAddress = '/dev/ttyUSB0';
    
    TelescopeOffset = [1.1, 1.65; ...
                       1.1, -1.65; ...
                       -1.1,-1.65; ...
                       -1.1, 1.65];
    
    NcamPhys = numel(CameraPhysicalID);
    
    
    PWD = pwd;
    cd(Args.ConfigDir);
    
    % RESTRICTED WORDS - in file names:
    % CAMERA_ID    - replace with camera ID (qhy serial number)
    % CAMERA_NUM   - replace with camera number (1..4)
    % TEMPLATE_    - replace with ''
    % MOUNTID      - %02d (1..12)
    % SWITCHID     - %d (1..2)
    % MOTORID      - %s    e.g., RAD60_003-930215931_DecD33Dual_003-930216476
    % SLAVEID      - 1..4
    
    % RESTRICTED WORDS - in file content
    % MOUNTID
    % SWITCH_IP        - 10.23.1.#     (50..)  # = 50 + (MOUNTID-1)*2 + SWITCHID
    % CAMERA_ID        - replace with camera ID
    % CAMERA_NUM       - 1..4
    % CAMERA_POS       - 1-NE; 2-SE; 3-SW; 4-NW
    % COMPUTER_NAME    - e.g., 'last02e'
    % DISK_NAME        - e.g., 'data1'
    % FILTER_NAME      - e.g., 'clear'
    % TELESCOPE_OFFSET - e.g., [1.1, 1.65]
    % FOCUSER_ADDRESS  - e.g., pci-0000:48:00.0-usb-0:2:1.0
    % MOUNT_ADDRESS    - e.g., pci-0000:48:00.0-usb-0:4:1.0
    % MOUNT_LON        - 35.0407331
    % MOUNT_LAT        - 30.0529838
    % MOUNT_HEIGHT     - 415.4
    
    % LAST1 equipment:
    
    
    
    Ndirs = numel(Args.Dirs);
    for Idirs=1:1:Ndirs
        Args.Dirs{Idirs}
        
        cd(Args.Dirs{Idirs});
        Files = dir(Args.FilesTemplate);
        NfileTemp = numel(Files);
                
        switch Args.Dirs{Idirs}
            case 'inst.QHYccd'
                % create a file for each physical camera
                
                if NfileTemp~=1
                    error('Number of template files in inst.QHYccd must be 1');
                end
                
                for Icam=1:1:NcamPhys
                    NewFileName = constructFileNames(Files(1).name, 'CAMERA_ID',CameraPhysicalID{Icam});
                    copyfile(Files(1).name, NewFileName);
                end
                
                
            case 'inst.tinycontrolIPpowerSocket'
                for Ifiles=1:1:NfileTemp
                    for Iswitch=1:1:Args.N_SwitchPerMount
                        SwitchIP = sprintf('10.23.1.%d',50 + (Mount-1).*2 + Iswitch);
                        
                        NewFileName = constructFileNames(Files(Ifiles).name, 'MOUNTID',MountStr,...
                                                                             'SWITCHID',sprintf('%d',Iswitch),...
                                                                             'MOTORID',Args.MotorID);
                        
                        % read template file
                        FileContent = io.files.file2str(Files(Ifiles).name);
                        FileContent = replaceFileContentSave(FileContent, NewFileName, 'SWITCH_IP',SwitchIP);
                    end
                end
            case {'inst.XerxesMount','obs.mount'}
                % simple directories
                for Ifiles=1:1:NfileTemp
                    NewFileName = constructFileNames(Files(Ifiles).name, 'MOUNTID',MountStr, 'MOTORID',Args.MotorID);

                    MountLonStr    = sprintf('%11.7f',MountLon);
                    MountLatStr    = sprintf('%11.7f',MountLat);
                    MontHeightStr  = sprintf('%8.1f',MountHeight);
                    
                    % read template file
                    FileContent = io.files.file2str(Files(Ifiles).name);
                    FileContent = replaceFileContentSave(FileContent, NewFileName,...
                                                         'SWITCH_IP',SwitchIP,...
                                                         'MOUNT_ADDRESS',Args.MountAddress,...
                                                         'MOUNT_LON',MountLonStr,...
                                                         'MOUNT_LAT',MountLatStr,...
                                                         'MOUNT_HEIGHT',MontHeightStr,...
                                                         'COMPUTER_NAME',PrimaryComputer,...
                                                         'DISK_NAME',PrimaryDiskName);
                                                         
                end
                
            case {'obs.unitCS','obs.util.SpawnedMatlab','obs.focuser','obs.camera'}
                % given a single template file - generate 4 copies, one per
                % camera
                
                if NfileTemp~=1
                    error('Number of template files in inst.QHYccd must be 1');
                end
                
                Ifiles = 1;
                
                for Icam=1:1:Args.Ncam
                    CamNum = sprintf('%d',Icam);
                    
                    ComputerIndex = Mount;
                    switch Icam
                        case 1
                            ComputerSide  = 'e';
                            ComputerDisk  = 'data1';
                            CameraPos     = 'NE';
                        case 2
                            ComputerSide  = 'e';
                            ComputerDisk  = 'data2';
                            CameraPos     = 'SE';
                        case 3
                            ComputerSide  = 'w';
                            ComputerDisk  = 'data1';
                            CameraPos     = 'SW';
                        case 4
                            ComputerSide  = 'w';
                            ComputerDisk  = 'data2';
                            CameraPos     = 'NW';
                        otherwise
                            error('Unsuported camera number');
                    end
                            
                    
                    ComputerName  = sprintf('last%02d%s', ComputerIndex, ComputerSide);
                    
                    NewFileName = constructFileNames(Files(Ifiles).name, 'MOUNTID',MountStr, 'CAMERA_NUM',CamNum);
                    
                    FileContent = io.files.file2str(Files(Ifiles).name);
                    
                    FileContent = replaceFileContentSave(FileContent, NewFileName,...
                                                         'MOUNTID',MountStr,...
                                                         'CAMERA_NUM',CamNum,...
                                                         'COMPUTER_NAME',ComputerName,...
                                                         'DISK_NAME',ComputerDisk,...
                                                         'FOCUSER_ADDRESS',FocuserAddress{Icam},...
                                                         'FILTER_NAME',Args.FilterName,...
                                                         'CAMERA_POS',CameraPos,...
                                                         'CAMERA_ID',CameraPhysicalID{Icam},...
                                                         'TELESCOPE_OFFSET',sprintf('[%7.4f, %7.4f]',TelescopeOffset(Icam,:)));
                                                         
                end
                   
            otherwise
                fprintf('%s was ignored - set it manually if needed\n',Args.Dirs{Idirs});
                
        end
        
        cd ..
    end
    
    cd(PWD);
end

% Aux functions
function TempFileName = constructFileNames(TempFileName, Args)
    % construct file names
    % replace substrings 
    
    arguments
        TempFileName
        Args.CAMERA_ID    = NaN;
        Args.CAMERA_NUM   = NaN;
        Args.TEMPLATE     = '#TEMPLATE';
        Args.MOUNTID      = NaN;
        Args.SWITCHID     = NaN;
        Args.MOTORID      = NaN;
    end
    
    FN  = fieldnames(Args);
    Nfn = numel(FN);
    for Ifn=1:1:Nfn
        if isempty(Args.(FN{Ifn}))
            TempFileName = strrep(TempFileName, FN{Ifn}, Args.(FN{Ifn}));
        else
            if ~isnan(Args.(FN{Ifn}))
                TempFileName = strrep(TempFileName, Args.TEMPLATE, Args.(FN{Ifn}));
            end
        end
    end
    
    % RESTRICTED WORDS - in file names:
    % CAMERA_ID    - replace with camera ID
    % CAMERA_NUM   - replace with camera number (1..4)
    % TEMPLATE_    - replace with ''
    % MOUNTID      - %02d (1..12)
    % SWITCHID     - %d (1..2)
    % MOTORID      - %s    e.g., RAD60_003-930215931_DecD33Dual_003-930216476
end


function FileContent = replaceFileContentSave(FileContent, NewFileName, Args)
    %
    
    arguments
        FileContent
        NewFileName
        Args.SWITCH_IP       = NaN;
        Args.MOUNTID         = NaN;
        Args.MOUNT_ADDRESS   = NaN;
        Args.MOUNT_LON       = NaN;
        Args.MOUNT_LAT       = NaN;
        Args.MOUNT_HEIGHT    = NaN;
        Args.CAMERA_ID       = NaN;
        Args.CAMERA_NUM      = NaN;
        Args.CAMERA_POS      = NaN;
        Args.FOCUSER_ADDRESS = NaN;
        Args.FILTER_NAME     = NaN;
        Args.COMPUTER_NAME   = NaN;
        Args.DISK_NAME       = NaN;
        Args.TELESCOPE_OFFSET= NaN;
        
    end
   
    FN  = fieldnames(Args);
    Nfn = numel(FN);
    for Ifn=1:1:Nfn
        if ~isnan(Args.(FN{Ifn}))
            FileContent = strrep(FileContent, FN{Ifn}, Args.(FN{Ifn}));
        end
    end
    
    % save file content
    FID = fopen(NewFileName,'w');
    fprintf(FID, '%s',FileContent);
    fclose(FID);
end
