classdef Time < handle
properties
    % param
    recOnKeyInt % on which intervals to record by key
    % based on duration
    % keys

    nTrial
    nInterval
    trial% Start end
    interval% start end

    curIntTime
    curTrlTime

    intLimit
    intervalExitflag
    trlLimt
    trialExitflag

    key
    t
    i
% listening
    %eKeyPressed
end
methods(Hidden=true)
    intDuration=inf; %trlint
    trlDuration=inf; %trlint
end
methods
    function obj=Time(PAR)
        Opts=PAR.Opts.Time
        flds=fieldnames(Opts)
        for i = 1:lenght(flds)
            fld=flds{i};
            obj.(fld)=Opts.(fld);
        end

        obj.nTrial=PAR.EXP.nTrial;
        obj.nInterval=Par.EXP.nInterval
        obj.trial=zeros(obj.nTrial,2);
        obj.interval=zeros(obj.nTrial,obj.nInterval,2);
        %addListener(PAR.KEY, 'KeyPressed', @(src,data) get_time_key(obj,src,data));

        obj.trlInt_init(PAR);

        recOnKeyInt=PAR.STM.duration==0; % XXX
    end
    function obj=update(obj,t,i)
        update@trlInt(obj,t,i);
    end
    function obj=get_time_trial_start(t,trlLimit)
        if ~exist('trlLimit','var')
            trlLimit=obj.intDuration;
        end
        obj.trialExistflag=0;
        obj.trial(t,2)=0;
        obj.trial(t,1)=GetSecs;
    end
    function obj=get_time_interval_start(t,i,intLimit)
        if ~exist('intLimit','var')
            intLimit=obj.intDuration;
        end
        obj.t=t;
        obj.i=i;
        obj.intervalExitflag=0;
        obj.intLimit=intLimit;
        obj.interval(t,i,2)=0;
        obj.interval(t,i,1)=GetSecs;
    end
    function obj=get_time(obj)
        T=GetSecs;
        obj.curIntTime=T-obj.interval(t,i,1);
        obj.curTrlTime=T-obj.trial(t,i,1);
        if t > obj.intLimit
            obj.intervalExitflag=1;
            obj.interval(obj.ti,obj.i,2)=obj.curIntTime;
        end
        if t > obj.trlLimit
            obj.trialExitflag=1;
            obj.interval(obj.ti,obj.i,2)=obj.curIntTime;
        end
    end
    function obj=get_time_key(obj,src,~);
        if obj.recOnKeyInt(obj.t,obj.i) && obj.bRecord
            obj.interval(t,i,2)=obj.src.time;
        end
    end

end
end
