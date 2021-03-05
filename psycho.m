classdef psycho < handle
properties
    status

    META
    PARSER
    Opts % initial options
    OUT

    EXP
    RSP
    TIME

    BACKDROP
    STMLI
    INSTR
    INTRO
    BREAK
    FIN

    PTB

    KEY

    INFO
        %counter
        %selected
        %messages
    MENU
    %    COUNTER

    selected % name, index XXX
    callOrder % XXX

    t
    i
    bTest=0;
    exitflag=0;
%% LISTENING
    % XXX subscribe to all events
    eNextTrial_EXP
    eExpComplete_EXP % XXX
    eTrialStart_EXP % XXX
    eIntervalStart_EXP % XXX
end
events
end
methods
    function obj=psycho(E,metaFname,paramFname,bTest,bJustInitialize)
        % XXX E
        if exist('bTest','var') && isempty(bTest) && isbinary(bTest)
            obj.bTest=bTest
        else
            obj.bTest=0;
        end
        if ~exist('bJustInitizlize','var') || isempty(bJustInitialize)
            obj.bJustInitialize=0;
        end

        % PARAMS
        obj.META=meta_param(metaFname,'|',obj);
        obj.PARSER=parser(paramFname);
        obj.Opts=obj.PARSER.OUT;

        % PTB
        PTB=ptb_session([],obj.Opts.ptb); % XXX add delayed response

        % KEY
        KEY(obj,PAR)

        %% EXP
        obj.EXP=Exp(obj);
        obj.RSP=Rsp(obj);

        % TODO v.2
        % OTHER EVENTS
        %obj.INSTR=Instr(obj); %
        %obj.INTRO=Intro(obj); %
        %obj.BREAK=Break(obj); %
        %obj.BLANK=Blank(obj); %

        obj.STMLI=Stmli(obj); % XXX
        %% OBJECTS
        %obj.MENU=Menu(obj); % XXX

        obj.META.finalize(obj);

        if ~bJustInitialize
            obj.PTB.start(); % XXX add delayed response
            obj.run();
        end
    end
    function obj=subscribe(obj)
        % XXX BREAK

        obj.eExpComplete_EXP   =addlistener(obj.EXP,'ExpComplete',@(src,data) exit(obj,src,data));
        obj.eTrialStart_EXP    =addlistener(obj.EXP,'TrialStart',@(src,data) run_trail(obj,src,data));
        obj.eTrialComplete_EXP =addlistener(obj.EXP,'TrialComplete',@(src,data) start_end(obj,src,data));
        obj.eIntervalStart_EXP =addlistener(obj.EXP,'IntervalStart',@(src,data) run_interval(obj,src,data));

    end
    function obj=set_cmd(obj,src,data)
        set(obj.(src.target{1}),src.target{2},src.toset);
    end
    function obj=run_cmd(obj,src,data)
        if ismember(src.target{1},{'PAR','par','psycho','PSYCHO'})
            obj.(src.target{2}).(src.command)(src.value{:});
        else
            obj.(src.target{1}).(src.target{2}).(src.command)(src.value{:});
        end
    end
    function obj=run(obj)
        obj.INSTR.run();
        obj.INTRO.run();
        obj.EXP.nextTrial():
    end
    function obj=read(obj)
        obj.KEY.read;
        if ~obj.KEY.status
            return
        end

        obj.status=0;
        code=obj.KEY.package{3};
        if code > 0
            obj.set_status(code)
        end
        if obj.status < 10
            obj.cmd_do
        end
    end
    function obj=cmd_do(obj)
        if obj.KEY.status==0 || obj.status==1;
            return
        elseif obj.KEY.status == 1
            obj.cmd_set(obj);
        elseif obj.KEY.status == 2
            obj.cmd_run(obj):
        end
        obj.KEY.status=0;
    end
    function obj=cmd_set(obj)
    end
    function obj=cmd_run(obj)
    end
    function obj=set_status(obj,code)
        obj.status=code;
    end
    function obj=run_trial(obj,src,data)
        % CALLED BY EXP
        obj.t=obj.src.t
        obj.STMLI.call_trail();
        obj.TIME.get_time_trial_start(obj.t);
    end
    function obj=run_interval(obj,src,data)
        % CALLED BY EXP
        obj.i=obj.src.i

        obj.KEY.upate(obj.t,obj.i);
        obj.TIME.update(obj.t,obj.i);
        obj.RSP.update(obj.t,obj.i);

        obj.STMLI.start_interval(obj.t,obj.i);
        obj.TIME.get_time_interval_start(obj.t,obj.i,duration);
        while true
            obj.STMLI.continue_interval();
            obj.TIME.get_time_interval_current;
            if obj.TIME.intervalExitflag==1
                break
            elseif obj.Time.trlExitflag==1
                obj.status=11;
                break
            end
            obj.read();
            if obj.status==1
                obj.RSP.run(t,i,obj.KEY.package{2});
            end
            if obj.status > 0
                break
            end
        end
        obj.STMLI.end_interval(); % XXX MAKE
        obj.parse_status(obj)
    end
    function obj=parse_status(obj)
        bCmd=1;
        if obj.status==1      %rsp recorded
            obj.set_status(0);
            obj.EXP.next_interval():
            return
        elseif obj.status>=20 %exit psycho
            obj.set_status(0);
            obj.STMLI.end_Trial();
            obj.exit();
            return
        elseif obj.status==10 || obj.status==11 % trial timeout, exit trial
            obj.set_status(0);
            obj.STMLI.end_Trial();
            obj.next_trial();
            return
        elseif obj.status < 20 && obj.status >= 10
            obj.STMLI.end_Trial();
        end
        obj.set_status(0);
        obj.cmd_do;
    end
    function obj=start_end(obj,~,~)
        % reset anything
        obj.STMLI.end_Trial();
        obj.Exp.next_trial();
    end
    function obj=end_end(obj,src,data)
        obj.STMLI.end_Trial();
        obj.status=20;
        obj.exit;
    end
    function obj=exit(obj,~,~)
        if obj.status==21
            % XXX prompt exit
            % XXX prompt save
            if %return flag
                return
            end
        elseif obj.status==20
            obj.get_out_complete();
        elseif obj.status>20
            obj.get_out_incomplete;
        end
    end
    function OUT=get_out_complete(obj)
        OUT.RSP=obj.RSP.return_OUT;
        OUT.PTCH=obj.PTCH;
        % XXX return DEF
        % Make DEF file from values
        % seeds from exp
        % indexPrivate
        % calculate relative times
    end
    function OUT=get_out_incomplete(obj)
        % XXX
    end
end
end
