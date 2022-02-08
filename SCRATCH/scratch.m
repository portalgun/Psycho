P.addParameter('bRandomize',1,@isbinary);
P.addParameter('seed',666,@isnumeric);
P.addParameter('secondaries',[],@(x) ischar(x) | iscell(x) | isempty(x));
obj.p.bRandomize        = out.bRandomize;
obj.p.masterSeed        = out.seed;
obj.p.secondaries       = out.secondaries;
% PARSE

    function obj=parse_Opts(obj,Opts);
        fldsI={'disp','exp','keys','stm','ui','bg','ch','win'};
        OPTparse(Opts,fldsI);

        for i = 1:length(fldsI)
            fld=fldsI{i};

            meth=['parse_defs_' fld ];
            P=obj.(meth)();

            Opts=parseObj([],Opts(fld),P);
            obj.(fld)=Opts;
            meth=['parse_finalize_' fld];
            if ismethod(obj,meth)
                obj.(meth)();
            end
        end

    end

    function obj=parse_finalize_win(obj)
        if isempty obj.win.dskDmRCT
            obj.win.dskDmRCT=zeros(numel(obj.stm.PszRCT));
        end
        if isempty obj.win.rmpDmRCT
            obj.win.rmpDmRCT=numel(obj.stm.PszRCT);
        end
    end
    function obj=parse_finalize_ui(obj)
        if isempty(obj.bShowInfo) && obj.bTest
            obj.bShowInfo=1;
        elseif isempty(obj.bShowInfo)
            obj.bShowInfo=0;
        end
    end

    function obj=parse_finalize_disp(obj)

        if isempty(obj.bSkipSyncTest) && ismac
            obj.bSkipSyncTest=1;
        elseif isempty(obj.bSkipSyncTest)
            obj.bSkipSyncTest=0;
        end

        if isempty(obj.disp.display)
            obj.disp.display=strrep(hostname,'jburge-','');
        end
        if ~startsWith(obj.disp.display,'display_')
            obj.disp.display=['display_' obj.disp.display];
        end

        if isempty(obj.disp.textFont) && ismac
            obj.disp.textFont='Anadale Mono';
        elseif isempty(disp.textFont) && Sys.islinux
            obj.disp.textFont='-misc-dejavu sans mono-bold-o-normal--0-0-0-0-m-0-ascii-0';
        end

        if isempty(obj.disp.stereomode)
            obj.disp.stereomode=obj.disp.display.defaultStereoMode;
        end

    end
% INIT
% toggle
    function obj=toggle(obj,varargin)
        if length(varargin) > 1
            obj.(varargin{1})=structToggle(obj.(varargin{1}),obj.varargin{2:end});
        elseif length(varargin) == 1
            obj.(varargin{1}) = ~obj.(varargin{1});
        end
    end
    function obj=go_menu_toggle(obj)
        if strcmp(obj.menu,'go')
            obj.menu='';
        else
            obj.menu='go';
        end
    end
    function obj=help_menu_toggle(obj)
        if strcmp(obj.menu,'help')
            obj.menu='';
        else
            obj.menu='help';
        end
    end
    function obj=cmd_menu_toggle(obj)
        if strcmp(obj.menu,'cmd')
            obj.menu=''
        else
            obj.menu='cmd';
        end
    end
    function obj=ch_menu_toggle(obj)
        if strcmp(obj.menu,'ch')
            obj.menu=''
        else
            obj.menu='ch';
        end
    end
    function obj=plate_menu_toggle(obj)
        if strcmp(obj.menu,'plate')
            obj.menu=''
        else
            obj.menu='plate';
        end
    end
    function obj=mask_menu_toggle(obj)
        if strcmp(obj.menu,'mask')
            obj.menu=''
        else
            obj.menu='mask';
        end
    end
    function obj=debug_menu_toggle(obj)
        if strcmp(obj.menu,'debug')
            obj.menu=''
        else
            obj.menu='debug';
        end
    end
    function obj=quit_menu_toggle(obj)
        if strcmp(obj.menu,'quit')
            obj.menu=''
        else
            obj.menu='quit';
        end
    end
    function obj=bg_menu_toggle(obj)
        if strcmp(obj.menu,'bg')
            obj.menu=''
        else
            obj.menu='bg';
        end
    end
    function obj=info_toggle(obj)
        if obj.ui.bShowInfo
            obj.ui.bShowInfo=0;
        else
            obj.ui.bShowInfo=1;
        end
    end
    function obj=ch_toggle(obj)
        if obj.bUseCH
            obj.bUseCH=0;
        else
            obj.bUseCH=1;
        end
    end
    function obj=debug_toggle(obj)
        if obj.bDebug
            obj.bTest=0;
        else
            obj.bTest=1;
        end
    end
    function obj=flag_show_toggle(obj)
        if obj.bFlaggedOnly
            obj.bFlaggedOnly=0;
        else
            obj.bFlaggedOnly=1;
        end
    end
    function obj=flag_toggle(obj)
        % XXX
    end
    function obj=exp_toggle(obj)
        % XXX
        if ~strcmp(obj.expType,'demo')
            obj.expTypeSaved=obj.expType;
            obj.expType='demo';
        elseif isempty(obj.expTypeSaved);
            obj.exp_menu();
        else
            obj.expType=obj.expTypeSaved;
        end
    end
%% BG
    function obj=Bg_cascade(obj)
        obj.get_Bg();
        obj.get_Bg_tex();
        obj.draw_Bg();
    end

    function obj=get_Bg(obj)
        % XXX add array functionality
        % XXX Opts=structIndSelect(C,length(obj.indTrl),ind,1);
        if ~obj.Bg.bUpdate || ~obj.Bg.bUse
            return
        end
        switch obj.Bg.type
        case {'1/f','1oF','1of'}
            obj.Bg.Bg=Noise.img(obj.ptb.display.scrnXYpix,-1);
            RMS=sqrt(mean(obj.Bg.Bg(:).^2));
            obj.Bg.Bg=obj.Bg.Bg./RMS.*obj.stm.RMSfix;
            obj.Bg.bTex=1;
        case 'gry'
            obj.Bg.Bg=obj.ptb.gry;
            obj.Bg.bTex=0;
        case 'blk'
            obj.Bg.Bg=obj.ptb.blk;
            obj.Bg.bTex=0;
        case 'wht'
            obj.Bg.Bg=obj.ptb.wht;
            obj.Bg.bTex=0;
        end
    end
    function obj=get_Bg_tex(obj)
        if ~obj.Bg.bUse || ~obj.Bg.bUpdate || ~obj.Bg.bTex
            return
        end
        obj.Bg.tex=Screen('MakeTexture',obj.ptb.wdwPtr,obj.Bg.Bg,[],[],2);
        obj.Bg.bUpdate=0;
    end
    function obj=draw_Bg(obj)
        if ~obj.Bg.bUse
            return
        end
        X=obj.ptb.display.scrnXYpix(1);
        Y=obj.ptb.display.scrnXYpix(2);
        rect=[0,0,X,Y];
        for k = 0:obj.ptb.bStereo
            Screen('SelectStereoDrawBuffer', obj.ptb.wdwPtr, k);
            if obj.Bg.bTex
                Screen('DrawTexture',obj.ptb.wdwPtr,obj.Bg.tex,[],rect);
            else
                Screen('FillRect',obj.ptb.wdwPtr,obj.Bg.Bg,rect);
            end
        end
    end
%% PLATE
    function obj=plate_cascade(obj)
        get_plate_rect();
        draw_plate();
    end
    function rect=get_plate_rect(obj)
        WH=obj.Bg.plateRadiusXYdeg .* obj.ptb.display.pixPerDegXY;
        W=WH(1);
        H=WH(2);
        X=obj.ptb.display.scrnCtr(1);
        Y=obj.ptb.display.scrnCtr(2);
        A=X-W/2;
        B=Y-H/2;
        C=X+W/2;
        D=Y+H/2;
        rect=[A B C D];
    end
    function obj=draw_plate(obj)
        if ~obj.Bg.bPlate
            return
        end
        rect=obj.get_plate_rect();

        for k = 0:obj.ptb.bStereo
            Screen('SelectStereoDrawBuffer', obj.ptb.wdwPtr, k);
            switch obj.Bg.plateShape
            case 'rect'
                Screen('FillRect',obj.ptb.wdwPtr,obj.Bg.plateColor,rect);
            case {'circle','circ','oval'}
                Screen('FillOval',obj.ptb.wdwPtr,obj.Bg.plateColor,rect);
            end
        end
    end
% Ch
    function obj=Ch_cascade(obj,ind)
        if ~obj.Ch.bUse
            return
        end
        if ~exist('ind','var') || isempty(ind)
            ind=obj.t;
        end
        obj.get_Ch(ind);
        obj.draw_Ch();
    end

    function obj=get_Ch(obj,ind)
        %obj.Ch.Ch.ch{:}
        % params, full ch, ind ch

        if ~exist('ind','var') || isempty(ind)
            ind=obj.t;
        end
        if ~obj.Ch.bUse || (isfield(obj.Ch,'Ch') && obj.Ch.bUniform)
            return
        elseif isfield(obj.Ch,'Ch')
            C=rmfield(struct(obj.Ch),Ch);
        else
            C=obj.Ch;
        end
        [Opts,cnt]=structSelect(C,length(obj.indTrl),ind,1,0);
        if ~isfield(obj.Ch,'bUniform') && cnt == 0
            obj.Ch.bUniform=1;
        elseif ~isfield(obj.Ch,'bUniform') && cnt > 0
            obj.Ch.bUniform=0;
        end
        obj.Ch.Ch=ch_all(Opts,obj.ptb.display);
    end

    function obj=draw_Ch(obj)
        if ~obj.Ch.bUse
            return
        end
        obj.Ch.Ch.draw(obj.ptb);
    end

%%%%%%
