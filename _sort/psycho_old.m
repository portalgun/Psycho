classdef psycho < handle
properties(Abstract=true)
    expType
end
properties
    PARSER
    META
    Opts
    Out

    EXP
    PTB

    CMD
    KEY
    STACK

    PTCHS
    BG
    PLATE
    WIN
    STM
    CH


    COUNTER
    INTRO
    INSTR
end
events
    DisableKEY
    EnableKEY
    ParamUpdated
    NewTrial
    NewFocus
    Exit
end
properties(Hidden = true)
    exitflag=0;
    indTrl
    map
    p
    t=1;
    ME
% XXX p v stm
end
methods(Abstract = true)
    init
    % initalize OUT
    % pick keys

    trial

    %RECOMMMENDED OVERRIDE
    %rest
    %parse_defs_exp
    %exp_menu
    %gen_test_data
    %rest
    %plot_fun -> to be called after everything has closed
end
methods
    function obj=psycho(patchesExp,Opts,bTest)
        if exist('patchesExp','var')
            obj.p=patchesExp;
        else
            obj.gen_test_data();
        end
        if exist('bTest','var')
            obj.bTest=bTest;
        else
            obj.bTest=0;
        end

        obj.parseOpts(Opts);

        obj.init_mode();
        obj.init_window()
        obj.init_stim();
        obj.init_keys();
        obj.init_display;
        obj.init_bg;

        obj.init();

        try
            obj.run();
            obj.exit();
        catch ME
            obj.ME=ME;
            if obj.bTest
                rethrow(obj.ME)
            end
        end
    end
    function obj=run(obj)
        obj.start();
        while obj.t <= obj.nTrls
            obj.trial();
        end
    end
%% PARSE
%% INIT
    function obj=init_mode()
        if obj.bTest
            mode='n';
        else
            mode='e';
        end
    end
    function obj=init_window(obj)
        obj.Win=wndw(obj.win);
    end
    function obj=init_keys(obj)
        obj.key=PTBkey(obj.keys.bUseCaps,obj.keys.pauseLength);
    end
    function obj=init_stim(obj)
        if ~isempty(obj.stm,type)
            obj.(['init_' obj.stm.type]);
        else
            obj.init_empty_stm(obj);
        end
    end
    function obj=init_empty_stim(obj)
        %obj.p=
    end
    function obj=init_patches(obj)
    % XXX
        if isempty(obj.p)
            error('No patches defined')
        end
        if ~isa(obj.p,'patches_exp') && isa(obj.p,'patches')
            if ~isfield(obj.p,'indTrl')
                obj.p.indTrl=1:length(obj.p.Limg);
            end
            if ~isfield(obj.p,'bRandomize')
                obj.p.bRandomize=1;
            end
            if ~isfield(obj.p,'seed')
                obj.p.masterSeed=[];
            end
            tmp=obj.p;
            obj.p=patches_exp(tmp.indTrl,tmp,[],tmp.bRandomize,tmp.seed);
        end
        obj.p.randomize();
        obj.indTrl=obj.p.indTrl;
        obj.OUT.indTrl=obj.indTrl;
    end

    function obj=init_display(obj)
        display=eval([obj.disp.display ';']);
        obj.ptb=ptb_session(display,obj.disp);
        if isempty(obj.disp.DC)
            obj.disp.DC=obj.ptb.gry;
        end
    end
    function obj=init_bg(obj)
        if isempty(obj.Bg.plateColor)
            obj.Bg.plateColor=obj.ptb.gry;
        end
        obj.Bg.bUpdate          = 1;
    end
%%
    function obj=draw_cascade_patch_intrvl(obj,intrvl)
        stdORcmp=obj.get_std_or_cmp(intrvl);
        obj.draw_cascade_patch(stdORcmp);
    end
    function obj=draw_cascade_patch(obj,stdORcmp)
        obj.get_patch_stim([],[],[],stdORcmp);
        obj.Bg_cascade();
        obj.Ch_cascade();
        obj.draw_trial_count();
        obj.draw_objs();
        obj.menu_dispatcher();
        obj.flip();
        obj.close_texs();
    end
    function obj=draw_cascade_blank(obj)
        obj.Bg_cascade();
        obj.Ch_cascade();
        obj.draw_trial_count();
        %obj.draw_info();
        obj.menu_dispatcher();
        obj.flip();
        obj.close_texs();
    end
    function obj= get_patch_stim(obj,name,order,ind,stdORcmp,stmXYdeg,pointORloc,guide,LOS)
        type='tex';
        Opts=structSelect(obj.stm,length(obj.indTrl),ind,1);
        if ~exist('ind','var') || isempty(ind)
            ind=obj.t;
        end
        if ~exist('name','var') || isempty(name)
            name=[num2str(ind) stdORcmp];
        end

        if ~exist('stdORcmp','var') || isempty(stdORcmp)
            stdORcmp='std';
        end
        if ~exist('pointORloc','var') || isempty(pointORloc)
            pointORloc=[];
        end
        if exist('stmXYdeg','var') && ~isempty(stmXYdeg)
            Opts.stmXYdeg=stmXYdeg;
        end

        if ~exist('guide','var')
            guide=[]; % XXX
        end

        if ~exist('LOS','var')
            LOS='ambig';
        end
        mp=obj.get_map(ind,stdORcmp,Opts);
        obj.add_asset_chain(name,type,order,mp,pointORloc,[],guide,LOS);
    end
    function map=get_map(obj,ind,stdORcmp,Opts)
        map=obj.p.(stdORcmp).get_lum(ind);
        if obj.stm.bRMSfix
            map.fix_contrast(Opts.RMSfix,Opts.RMSdc,Opts.RMSmonoORbino);
        end
        if strcmp(Opts.windowType,'cos')
            map.cos_window(Opts.WszRCT,Opts.dskDmRCT,Opts.rmpDmRCT);
            map.window();
        end
        map.get_psy(obj.ptb,Opts.stmXYdeg);
    end
%% FROM NESTED
    function obj=get_key(obj)
        obj.key.get_key();
    end
    function obj=flip(obj)
        obj.ptb.flip();
    end
    function obj=flip_hold(obj)
        obj.ptb.flip_hold();
    end
    function obj=refresh(obj)
        obj.ptb.refresh();
    end
    function obj=exit(obj)
        obj.ptb.sca;
        obj.ptb.display.postscript();
    end
%% HELPERS
    function ind=get_ind(obj,name)
        if isempty(obj.names)
            ind=[];
        else
            ind=find(contains(obj.names,name));
        end
    end
    function ind=get_next_ind(obj)
        ind=length(obj.names)+1;
    end
    function Exists=check_name(obj,name)
        Exists=0;
        ind=obj.get_ind(name);
        if ~isempty(ind)
            Exists=1;
        end
    end
%% ASSETS
    function [obj]=add_asset_chain(obj,name,type,order,asset,pointORloc,ind,guide,LOS)
        if ~exist('ind','var') || isempty(ind)
            ind=obj.get_next_ind();
        end
        obj.add_asset(name,type,order,asset,pointORloc,ind,guide,LOS);
        obj.get_tex_ind(ind);
        obj.get_rect_ind(ind);
    end
    function obj=add_asset(obj,name,type,order,asset,pointORloc,ind,guide,LOS)
        Exists=obj.check_name(name);
        if Exists
            error('Asset with name already exists!')
        end
        if ~exist('ind','var')
            ind=get_next_ind();
        end
        CPs=obj.get_point_or_loc(pointORloc,guide,LOS);
        obj.names{ind,1}=name;
        obj.type{ind,1}=type;
        obj.assets{ind,1}=asset; % XXX not sure if correct
        obj.points{ind,1}=CPs;   % XXX not sure if correct
        obj.bTexsDrawn(ind)=0;
    end
    function CPs=get_point_or_loc(obj,pointORloc,guide,LOS)
        if ~exist('guide','var')
            guide=[];
        end
        if ~exist('LOS','var')
            LOS='ambig';
        end
        if numel(pointORloc)==3
            CPs=get_point(LOS,guide);
        elseif numel(pointORloc)==2
            CPs=get_loc(pointORloc);
        else
            CPs=struct;
            CPs.LitpXY=obj.ptb.display.scrnCtr; % XXX
            CPs.RitpXY=obj.ptb.display.scrnCtr; % XXX
        end
    end
    function CPs=get_point(obj,LOS,guide)
        %LOS needs handle from ind and guide
        pnt=point();
        pnt.LOS=LOS;
        pnt.get.CPs(obj.ptb.display,guide);
        CPs=package_CPs(pnt.LitpXY,pnt.RitpXY);
    end
    function CPs=get_loc(obj,loc)
        CPs=obj.package_CPs(loc,loc);
    end
    function CPs=package_CPs(LitpXY,RitpXY)
        CPs=struct;
        CPs.LitpXY=LitpXY;
        CPs.RitpXY=RitpXY;
    end
    function obj=rm_assets(obj)
        obj.names={};
        obj.assets={};
        obj.texs=[];
        obj.type={};
        obj.points={};
        obj.rects={};
        obj.order=[];
        obj.bTexsDrawn=[];
    end
    function obj=rm_asset(obj,name,ind)
        if ~exist('ind','var') && exist('name','var')
            ind=obj.get_ind(name);
        end
        obj.names(ind)=[];
        obj.assets(ind)=[];
        obj.texs(ind)=[];
        obj.type(ind)=[];
        obj.points(ind)=[];
        obj.rects(ind)=[];
        obj.order(ind)=[];
        obj.bTexsDrawn(ind)=[];

    end
%% GET RECT
    function obj=get_rects(obj)
        for ind = 1:length(obj.bTexsDrawn)
            obj.get_rect_ind(ind);
        end
    end
    function obj=get_rect_ind(obj,ind)
        rect=obj.get_rect(obj.points{ind},obj.assets{ind,:});
        obj.rects{ind,1}=rect{1,1};
        obj.rects{ind,2}=rect{1,2};
    end
    function rect=get_rect(obj,point,asset)
        W=asset.plyXYpix(1);
        H=asset.plyXYpix(2);
        X=point.LitpXY(1);
        Y=point.LitpXY(2);
        A=X-W/2;
        B=Y-H/2;
        C=X+W/2;
        D=Y+H/2;
        rect{1,1}=[A B C D];

        X=point.RitpXY(1);
        Y=point.RitpXY(2);
        A=X-W/2;
        B=Y-H/2;
        C=X+W/2;
        D=Y+H/2;
        rect{1,2}=[A B C D];
    end
%% GET TEX
    function obj=get_texs(obj)
        for ind = 1:length(obj.bTexsDrawn)
            obj.get_tex_ind(ind);
        end
    end
    function obj=get_tex_ind(obj,ind)
        if ~strcmp(obj.type{ind},'tex')
            obj.texs(ind,:)=[];
            return
        end
        obj.texs(ind,:)=obj.get_tex(obj.assets{ind});
    end
    function tex=get_tex(obj,asset)
        tex(1,1)=Screen('MakeTexture',obj.ptb.wdwPtr,asset.Limg,[],[],2);
        tex(1,2)=Screen('MakeTexture',obj.ptb.wdwPtr,asset.Rimg,[],[],2);
    end

%% DRAW obj
    function obj=draw_objs(obj)
        [~,inds]=sort(obj.order);
        for ind = inds
            obj.draw_obj(ind);
        end
    end
    function obj=draw_obj(obj,ind)
        switch obj.type{ind}
        case 'tex'
            obj.draw_tex_ind(ind);
        case 'circle'
        case 'rect'
        end
    end
    function obj=draw_tex_ind(obj,ind)
        tex=obj.texs(ind,:);
        rect=obj.rects(ind,:);
        obj.draw_tex(tex,rect);
        obj.bTexsDrawn(ind)=1;
    end
    function obj=draw_circ(obj,color,rect)
        obj.draw_oval(color,rect);
    end
    function obj=draw_oval(obj,color,rect)
        for k = 0:obj.ptb.bStereo
            K=k+1;
            if iscell(rect) && size(rect,2)==2
                rect=rect{1,K};
            elseif iscell(rect)
                rect=rect{1};
            end
            if iscell(color) && size(color,2)==2
                color=color{1,K};
            elseif iscell(color)
                color=color{1};
            end
            Screen('SelectStereoDrawBuffer', obj.ptb.wdwPtr, k);
            Screen('FillOval',obj.ptb.wdwptr,color,rect);
        end
    end
    function obj=draw_rect(obj,color,rect)
        for k = 0:obj.ptb.bStereo
            K=k+1;
            if iscell(rect) && size(rect,2)==2
                rect=rect{1,K};
            elseif iscell(rect)
                rect=rect{1};
            end
            if iscell(color) && size(color,2)==2
                color=color{1,K};
            elseif iscell(color)
                color=color{1};
            end
            Screen('SelectStereoDrawBuffer', obj.ptb.wdwPtr, k);
            Screen('FillRect',obj.ptb.wdwptr,color,rect);
        end
    end
    function obj=draw_tex(obj,tex,rect)
        for k = 0:obj.ptb.bStereo
            K=k+1;
            if iscell(rect) && size(rect,2)==2
                rt=rect{1,K};
            elseif iscell(rect)
                rt=rect{1};
            end
            if size(tex,2)==2
                tx=tex(1,K);
            elseif iscell(tex)
                tx=tex(1);
            end
            Screen('SelectStereoDrawBuffer', obj.ptb.wdwPtr, k);
            Screen('DrawTexture',obj.ptb.wdwPtr,tx,[],rt);
        end
    end

% CLOSE TEX
    function obj=close_texs(obj)
        for ind = 1:length(obj.bTexsDrawn)
            obj.close_tex_ind(ind);
        end
    end
    function obj=close_tex_ind(obj,ind)
        if ~strcmp(obj.type,'tex')
            return
        end
        obj.close_tex(obj.texs(ind,:));
        obj.bTexsDrawn(ind)=0;
    end
    function obj=close_tex(obj,tex)
        Screen('Close',tex);
    end
%%% PAUSE
    function obj=pause_iii(obj)
        pause(obj.iti);
    end
    function obj=pause_stim(obj)
        pause(obj.duration);
    end
    function obj=pause_iti(obj)
        pause(obj.iti);
    end
%%% TEXT
    function obj=text_cmd_help()
        c=text_defs_cmp_help();
    end
%%% CHOOSE
    function stdORcmp=get_std_or_cmp(obj,intrvl)
        intrvl=intrvl-1;
        I=obj.p.cmpIntrvl(obj.t);
        if (I==0 && intrvl==0) || (I==1 && intrvl==1)
            stdORcmp='cmp';
        else
            stdORcmp='std';
        end
    end
    function obj=choose_RL(obj,val)
        obj.OUT.R(obj.t)=val;
        obj.get_cmp_chosen();
        obj.get_correct();
        obj.sound_correct();
        obj.next();
    end
    function obj=choose_greater(obj)
        obj.choose_RL(1);
    end
    function obj=choose_less(obj)
        obj.choose_RL(0);
    end
    function obj=choose_right(obj)
        obj.choose_RL(1);
    end
    function obj=choose_left(obj)
        obj.choose_RL(0);
    end
    function obj=get_cmp_chosen(obj)
        obj.OUT.bCmpChosen=obj.OUT.R(obj.t)==obj.p.cmpIntrvl(obj.t);
    end
    function obj=get_correct(obj)
        if strcmp(obj.magORval,'mag')
            cmpX=abs(obj.p.cmp.X);
            stdX=abs(obj.p.std.X);
        else
            cmpX=obj.p.cmp.X;
            stdX=obj.p.std.X;
        end
        cmpIntrvl=obj.p.cmpIntrvl(obj.t);
        R=obj.OUT.R(obj.t);
        if      (cmpX > stdX)
            % CMP VALUE GREATER THAN STD VALUE
            if      cmpIntrvl == 1 && R == 1, Rcorrect = 1;
            elseif  cmpIntrvl == 0 && R == 0, Rcorrect = 1;
            elseif  cmpIntrvl == 1 && R == 0, Rcorrect = 0;
            elseif  cmpIntrvl == 0 && R == 1, Rcorrect = 0;
            else    error(['psyResponseCorrect: WARNING! unhandled condition. R=' num2str(R) ', cmpIntrvl=' num2str(cmpIntrvl) '. Write code?']);
            end
        elseif  (cmpX < stdX)
            % CMP VALUE   LESS  THAN STD VALUE
            if      cmpIntrvl == 0 && R == 1, Rcorrect = 1;
            elseif  cmpIntrvl == 1 && R == 0, Rcorrect = 1;
            elseif  cmpIntrvl == 1 && R == 1, Rcorrect = 0;
            elseif  cmpIntrvl == 0 && R == 0, Rcorrect = 0;
            else    error(['psyResponseCorrect: WARNING! unhandled condition. R=' num2str(R) ', cmpIntrvl=' num2str(cmpIntrvl) '. Write code?']);
            end
        elseif  cmpX == stdX
            % ASSIGN CORRECT RANDOMLY ('correct' answer not well-defined)
            Rcorrect = rand>0.5;
        else
            error('psyResponseCorrect: WARNING! unhandled scenario. Write code?');
        end
        obj.OUT.bCorrect(obj.t)=Rcorrect;
    end
    function obj=sound(obj,bCorrect)
        if ~obj.bSoundCorrect
            return
        end
        if bCorrect
            obj.sound_correct();
        else
            obj.sound_incorrect();
        end
    end
    function obj=sound_correct(obj)
        freq = 0.73;
        sound(sin(freq.*[0:1439]).*cosWindowFlattop([1 1440],720,720,0));
    end
    function obj=sound_incorrect(obj)
        freq = 0.73/2;
        sound(sin(freq.*[0:1439]).*cosWindowFlattop([1 1440],720,720,0));
    end
%%% START
    function obj=start(obj)
        if obj.ui.bIntro
            obj.run_intro();
        end
        if ~obj.ui.bInstructions
            obj.run_instructions();
        end
    end
%%% INTRO
    function obj=run_intro(obj)
        % XXX
    end
%%% INSTRUCTIONS
    function obj=run_instructions(obj)
        % XXX
    end
%% THINGS TO BE OVERWRITTEN
    function obj=rest(obj)
        return
    end
    function obj=gen_test_data(obj)
        return
    end
    function obj=plot_fun(obj)
    end
%%% DISPATCHERS
    function obj=command_dispatcher(obj)
        m=obj.modes.(obj.mode);
        obj.cmd=m(obj.key.OUT);
        obj.(obj.cmd);
        obj.lastcmd=obj.cmd;
        obj.cmd=[];
        obj.key.clear();
    end
    function obj=menu_dispatcher(obj)
        if isempty(obj.menu)
            return
        end
        obj.([obj.menu '_draw']);
    end
    %function obj=
%% COMMANDS
    function obj=null(obj)
             ;
    end
    function obj=zoom_in_mod(obj,num)
        obj.stmSizeMult=obj.stimSizeMult+num;
        obj.stm.stmXYdeg=obj.stm.sizeMult*obj.stm.stmXYdeg;
        if any(obj.stm.stmXYdeg > obj.ui.maxSizeXYdeg)
            obj.stm.stmXYdeg=obj.ui.maxSizeXYdeg;
        end
    end
    function obj=zoom_out_mod(obj,num)
        obj.stmSizeMult=obj.stimSizeMult-num;
        obj.stm.stmXYdeg=obj.stm.sizeMult*obj.stm.stmXYdeg;
        if any(obj.stm.stmXYdeg < obj.ui.minSizeXYdeg)
            obj.stm.stmXYdeg=obj.ui.minSizeXYdeg;
        end
    end
    function obj=zoom_in(obj)
        obj.zoom_in_mod(obj.ui.zoomInc);
    end
    function obj=zoom_out(obj)
        obj.zoom_out_mod(obj.ui.zoomInc);
    end

    function obj=down_mod(obj,num)
        % XXX
    end
    function obj=up_mod(obj,num)
        % XXX
    end
    function obj=up(obj)
        obj.up_mod(1);
    end
    function obj=down(obj)
        obj.down_mod(1);
    end

    function obj=previous_mod(obj,num)
        obj.t=obj.t-num;
        if obj.t < 0
            obj.t=1;
        end
        obj.rm_assets();
    end
    function obj=next_mod(obj,num)
        obj.t=obj.t+num;
        if num==1 & obj.t > length(obj.indTrl)
            return
        elseif obj.t > length(obj.indTrl)
            obj.t=length(obj.indTrl);
        end
        obj.rm_assets();
    end
    function obj=previous(obj)
        obj.previous_mod(1);
    end
    function obj=next(obj)
        obj.next_mod(1);
    end
    function obj=go_trial(obj)
        obj.go_menu_toggle();
        while true
            obj.key.read_int()
            obj.go_draw_str(obj.key.str)
            if obj.key.exitflag==1
                break
            end
        end
        obj.t=num2str(obj.key.str);
        if obj.t < length(obj.indTrl)
            obj.t=length(obj.indTrl);
        elseif obj.t > 1
            obj.t=1;
        end
        obj.go_menu_toggle;
    end
    function obj=save(obj)
        % XXX
    end
    function obj=gen_m(obj)
        % XXX
    end
    function obj=redraw(obj)
        obj.ui.bRedrawFlag=1;
        % XXX
    end
    function obj=escape(obj)
        obj.menu='';
        obj.mode='n';
    end

    function obj=quit(obj)
        obj.ptb.sca;
    end
    %function obj=go_draw_str(obj,str)
    %    % XXX
    %end
%%% TOGGLE
%%% MENUS
    function obj=help_menu(obj);
    end
    function obj=cmd_menu(obj);
    end
    function obj=ch_menu(obj);
    end
    function obj=bg_menu(obj);
    end
    function obj=plate_menu(obj);
    end
    function obj=mask_menu(obj);
    end
    function obj=debug_menu(obj);
    end
    function obj=window_menu(obj);
    end
    function obj=exp_menu(obj);
        expTypeSaved
        bUseTrialCounter
        bInstructions
        bIntro
    end

    function obj=insert_mode(obj)
        obj.mode='i';
    end
    function obj=normal_mode(obj)
        obj.mode='n';
    end
    function obj=exp_mode(obj)
        obj.mode='e';
    end
%%% PROMPT
    function obj=quit_prompt(obj)
        % XXX
    end
    function obj=save_prompt(obj)
        % XXX
    end
    function obj=switch_prompt(obj)
        % XXX
    end
% CMD DEFS
    function obj=set_key_defs(obj,name)
        str=['[n,e,i]=key_defs_' name '();'];
        eval(str);
        obj.keys_to_mode(n,e,i);
        obj.modes.n=n;
        obj.modes.i=i;
        obj.modes.e=e;
    end
    function test_key(obj)
        while true
            %[ ~, ~, KeyCode ] = KbCheck(-1,obj.key.K);
            %keycode=find(KeyCode);
            %if ~isempty(keycode)
            %    return
            %end
            obj.key.scan2code();
            disp(obj.key.keycode)
            if ~isempty(obj.key.keycode)
                return
            end
        end
    end
    function plot_display(obj)
        % XXX
    end
%% DEF
end
end
