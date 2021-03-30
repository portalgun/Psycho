classdef DISPLAY < handle
% TODO min max values for points and display
properties(Abstract = true)
    %DEFINED
    scrnZmm
    scrnXYmm
    gamFncExponent
    comp
    wdwXYpix
    hostname
    scrnXYpix
    scrnHz
    gammaCorrectionType
    calName
    bPreScript
end
properties
    %CONSTRUCTED
    bitsOut
    scrnXYdeg
    sid
    pixPerDegXY
    pixPerMmXY
    pixPerMxy
    degPerMxy
    scrnCtr

    CppXm
    CppYm
    CppZm

    CppXpix
    CppYpix

    CppXdeg
    CppYdeg
    PPxyz
    IPDm
    LExyz
    CExyz
    RExyz
    vrgArcMinF

    bSetCalFname
    bCalInit
    calNum
    calDir
    calFname
    cal
    cals
    gamPix
    gamFnc
    gamInv

    bAlphaBlending=0

    d %secondary attributes - changing/arbitrary

    % XXX
    %D.durationMs=60;
    %D.numFrm   = round((D.durationMs./1000)./D.ifi); % num frames computed via desired duration
end
methods
    function obj=DISPLAY(name)
        obj.get_dims();
        obj.get_eyes;
        obj.get_default_proj_plane();
        obj.get_pixel_grid();
    end
    function obj=prescript(obj)
        if obj.bPreScript
            monitor1();
        end
    end
    function obj=postscript(obj)
        if obj.bPreScript();
            rd();
        end
    end
    function obj=init(obj,ptb)
        %Somewhat dependent on psych toolbox
        %obj.prescript();
        obj.get_sid(ptb);
        obj.get_res(ptb);
        obj.get_rate(ptb);
        obj.get_bits(ptb);
    end

    function obj=get_res(obj,ptb)
        if ~isempty(obj.scrnXYpix)
            return
        elseif exist('ptb','var')
            a = Screen('Resolution',obj.sid);
            obj.scrnXYpix(1)=a.width;
            obj.scrnXYpix(2)=a.height;
        elseif islinux
            [~,scrn]=system('xrandr -q | sed ''s/primary //g'' | grep " connected" | awk ''{print $3}'' | grep "[0-9]" | sed ''s/\(x\|+\)/ /g''');
        elseif ismac
            [~,scrn]=system('system_profiler SPDisplaysDataType | grep Resolution | awk ''{print $2 " " $4}''');
        elseif ispc
            [~,scrn]=system('wmic desktopmonitor get ScreenHeight, screenwidth');
        end

        try
            scrn=strsplit(scrn,newline);
            scrn=scrn(~cellfun(@isempty, scrn));
            scrn=reshape(scrn,size(scrn,2),1);
            for i = 1:size(scrn,1)
                obj.scrnXYpix(i,:)=strsplit(scrn{i});
            end
        end
    end

    function obj=get_bits(obj,ptb)
        obj.bitsOut = Screen('PixelSize',obj.sid)./3;
    end

    function obj=get_sid(obj,ptb)
        screens=Screen('Screens');
        wh=zeros(length(screens),2);
        for i = 1:length(screens)
            j=screens(i);
            [wh(i,1) wh(i,2)]=Screen('DisplaySize',j);
        end
        [ind]=ismember(wh,obj.displaySize,'rows');
        ind=find(ind);
        obj.sid=screens(ind);
        if isempty(obj.sid);
            obj.sid=0;
        end
    end

    function obj=get_rate(obj,ptb)
        if ~isempty(obj.scrnHz)
            return
        end
        if exist('ptb','var')
            scrnHz=Screen('FrameRate',obj.sid);
        elseif ismac
            [~,scrnHz]=system('system_profiler SPDisplaysDataType | grep Resolution | awk ''{print $6}''');
        else
            % XXX
            obj.scrnHz=[];
        end
        for i = 1:size(obj.scrnHz,1)
            tmp=splitlines(obj.scrnHz);
            tmp(strcmp(tmp,''))=[];
            obj.scrnHz=transpose(str2double(tmp));
        end
    end

    function obj=get_dims(obj)
        obj.scrnXYdeg   = 2.*atan2d(0.5.*obj.scrnXYmm,obj.scrnZmm);
        obj.pixPerDegXY = obj.scrnXYpix(1:2)./obj.scrnXYdeg;
        obj.pixPerMmXY  = obj.scrnXYpix(1:2)./obj.scrnXYmm;
        obj.pixPerMxy=obj.scrnXYpix./obj.scrnXYmm*1000;
        obj.degPerMxy=obj.pixPerMxy./obj.pixPerDegXY;
        obj.scrnCtr=round(obj.scrnXYpix./2);
    end
    function obj=get_default_proj_plane(obj)
        [obj.CppXm,obj.CppYm,obj.CppZm,obj.CppXdeg,obj.CppYdeg] = obj.get_proj_plane('C');
        obj.vrgArcMinF=60*2*atand(obj.IPDm/(2*obj.scrnZmm/1000));
    end
    function [IppXm,IppYm,IppZm,IppXdeg,IppYdeg] =get_proj_plane(obj,LorRorC,multFactor,dnK)
        if ~exist('LorORorC','var')
            LorRorC='C';
        end
        if ~exist('dnK','var')
            dnK=1;
        end
        if ~exist('multFactor','var')
            multFactor=1;
        end
        [IppXm,IppYm,IppZm,IppXdeg,IppYdeg]= DISPLAY.proj_plane(obj.IPDm,obj.scrnXYpix,obj.scrnXYmm,obj.scrnZmm,LorRorC,multFactor,dnK);

    end
    function obj=get_pixel_grid(obj)
        [obj.CppXpix,obj.CppYpix]=meshgrid(1:obj.scrnXYpix(1),1:obj.scrnXYpix(2));
    end
    function obj=get_eyes(obj)
        obj.PPxyz  =[-1, 0, obj.scrnZmm/1000;  1, 0, obj.scrnZmm/1000];
        obj.IPDm=0.065;
        obj.LExyz  =[-obj.IPDm/2, 0, 0];
        obj.CExyz  =[          0, 0, 0];
        obj.RExyz  =[ obj.IPDm/2, 0, 0];
    end

    function obj=load_cal(obj)
        if isempty(obj.calName)
            return
        end
        obj=obj.get_cal_file;
        S=load([obj.calDir obj.calFname]);
        if ~isfield(S,'cal') && ~isempty(obj.calNum)
            S.cal=S.cals{obj.calNum};
        elseif ~isfield(S,'cal')
            S.cal=S.cals{end};
        end
        obj.cal=S.cal;
        if isfield(S,'cals')
            obj.cals=S.cals;
        end
        obj=obj.convert_cal;
        obj.bCalInit=1;
    end

    function [obj] = get_cal_file(obj)
        if isempty(obj.bCalInit) && ~isempty(obj.calFname)
            obj.bSetCalFname=1;
        end

        if ~isequal(obj.bSetCalFname,1)
            [file,fdir]=obj.get_newest_cal_file_all();
            if isempty(file)
                warning('No calibration file with specified calName.')
            end
            obj.calFname=file;
            obj.calDir=fdir;
        elseif isequal(obj.bSetCalFname,1) && ~isequal(obj.bSetCalFname,1)
            [~,obj.calDir]=lORs('cal');
            chkFile([obj.calDir obj.calFname]);
        else
            chkFile([obj.calDir obj.calFname]);
        end
    end
    function [file,fdir] = get_newest_cal_file_all(obj)
        file=[];
        fdir=[];
        fdirLoc = BLdirs('cal','loc');
        fdirSrv = BLdirs('cal','srv');
        flagLoc = chkDirAll(fdirLoc,1);
        flagSrv = chkDirAll(fdirSrv,1);
        fileSrv='';
        fileLoc='';
        datLoc='';
        datSrv='';
        if flagLoc==1
            [fileLoc,datLoc]=get_newest_cal_file(obj,fdirLoc);
        end
        if flagSrv==1
            [fileSrv,datSrv]=get_newest_cal_file(obj,fdirSrv);
        end
        fdirs={fdirLoc;fdirSrv};
        dates={datLoc;datSrv};
        if isempty(fileLoc)
            fLoc=[];
        else
            fLoc=fileLoc{1};
        end
        if isempty(fileSrv)
            fSrv=[];
        else
            fSrv=fileSrv{1};
        end

        files={fLoc;fSrv};
        if isempty(files)
            return
        end
        ind=newestDate(dates);
        file=files{ind};
        fdir=fdirs{ind};
    end
    function [file,dat]=get_newest_cal_file(obj,dir)
        FILES=regexpdir(dir,obj.calName);
        if numel(FILES)==1
            ind=1;
        elseif numel(FILES)==0
            file=[];
            dat=[];
            return
        end
        dates=strrep(FILES,obj.calName,'');
        dates=strrep(dates,'.mat','');
        dates=strrep(dates,'_',' ');
        dates=strrep(dates,'-',' ');
        dates=strtrim(dates);
        dates=strrep(dates,' ','-');
        if ~exist('ind','var')
            ind=newestDate(dates);
        end
        file=FILES(ind);
        dat=dates{ind};
    end
    function obj=convert_cal(obj)
        % CONVERT GAMMA DATA IN cal STRUCT TO STANDARD FORMAT
        obj.gamPix = obj.cal.processedData.gammaInput;
        obj.gamFnc = obj.cal.processedData.gammaTable;
        fail=0;
        for i = 1:size(obj.gamFnc,2)
            try
                obj.gamInv(:,i) = interp1(obj.gamFnc(:,i),obj.gamPix,linspace(min(obj.gamFnc(:)),max(obj.gamFnc(:)),transpose(numel(obj.gamPix))));
            catch
                obj.gamInv(:,i) = zeros(numel(obj.gamPix),1);
                fail=fail+1;
            end
        end
        obj.gamInv(1,isnan(obj.gamInv(1,:)))=0;

        if all(obj.gamInv==0)
            error('psyLoadCalibrationData: Error! Calibration data is bad, read all zeros!');
        elseif fail > 0
            fai=num2str(fail);
            tot=num2str(size(obj.gamFnc,2));
            %warning(['psyLoadCalibrationData: WARNING! ' fai ' out of ' tot ' channels are empty. This may or may not be fine']);
        end

        % WRITE TO SCREEN
        if  isempty(obj.cal)
            error(['psyLoadCalibrationData: Loaded empty calibration in ' fdir fname '.']);
        else
          disp(['psyLoadCalibrationData: Loaded calibration ' obj.calDir obj.calFname '.']);
        end
    end
end
methods(Static=true)
    function name=get_name_from_display(display)
        name=class(display);
    end
    function name=get_name_from_hostname(bVR)
        if ~exist('bVR','var') || isempty(bVR) || ~bVR
            VRstr='';
        elseif bVR
            VRstr='_VR';
        end
        name=['display_' hostname VRstr ';'];
    end
    function display=get_display_from_hostname(bVR)
        if ~exist('bVR','var') || isempty(bVR) || ~bVR
            VRstr='';
        elseif bVR
            VRstr='_VR';
        end
        display=eval(['display_' hostname VRstr ';']);
    end
    function display=get_display_from_string(str,bVR)
        if ~exist('bVR','var') || isempty(bVR) || ~bVR
            bVR=0;
            VRstr='';
        elseif bVR
            bVR=1;
            VRstr='_VR';
        end
        if isempty(str)
            display=DISPLAY.get_display_from_host(bVR);
            return
        elseif startsWith(display,'display_')
            display=eval([str VRstr ';']);
        else
            display=eval(['display_' str VRstr ';']);
        end
    end
    function [IppXm,IppYm,IppZm,IppXdeg,IppYdeg]=proj_plane(IPDm,scrnXYpix,scrnXYmm,scrnZmm,LorRorC,multFactor,dnK)

        if ~exist('LorORorC','var') || isempty(LorRorC)
            LorRorC='C';
        end
        if ~exist('dnK','var') || isempty(dnK)
            dnK=1;
        end
        if ~exist('multFactor','var') || isempty(multFactor)
            multFactor=1;
        end

        if strcmp(LorRorC,'L')
            K = +IPDm/2;
        elseif strcmp(LorRorC,'C')
            K = 0;
        elseif strcmp(LorRorC,'R')
            K = -IPDm/2;
        end

        scrnXY=scrnXYmm/1000.*multFactor;
        scrn=fliplr(round(scrnXYpix./dnK));
        I = zeros(scrn);

        IppZm    = scrnZmm/1000;

        IppXm    = K + smpPos(size(I,2)./scrnXY(1),size(I,2));
        IppYm    = fliplr(smpPos(size(I,1)./scrnXY(2),size(I,1)));
        IppXm    = IppXm + diff(IppXm(1:2))/2;
        IppYm    = IppYm - diff(IppYm(1:2))/2;
        [IppXm,IppYm] = meshgrid(IppXm,IppYm);

        IppXdeg = atand(IppXm./IppZm);
        IppYdeg = atand(IppYm./IppZm);
    end
end
end
