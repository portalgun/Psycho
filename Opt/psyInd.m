classdef psyInd < handle
% TODO int8
properties
    Rules
    trlInds
    %   interval index
    %   [nTrl x 1 + nIntrvl + 1]
    %     init
    %     close
    %        (fld)
    trlIndex % [ni*nt ]
%% listening
    eIndexChanged
end
properties(Hidden=true)
    t
    i
    i_p
    % t=0  start -> 1
    % t=-1 end   -> ni+1

    ti

    nt
    ni
    nti
end
methods
    function obj=psyInd(EXP,Rules)
        obj.nt=EXP.nTrial;
        obj.ni=EXP.nInterval;
        obj.nti=obj.nt*obj.ni;
        obj.trlIndex=EXP.trlIndexPrivate;

        obj.Rules=Opts.Rules;
        obj.init_trlInds();

        eIndexChanged=obj.addlistener(EXP,'IndexChanged',@(src,data) update_trlIndex(obj,src,data));
        % eRulesChanged=obj.addlistener(TODO,'RulesChanged',@(src,data) update_trlIndex(obj,src,data));
    end
    function obj=update_trlIndex(obj,~,trlIndexPrivate)
        obj.trlIndex=trlIndexPrivate;
        obj.init();
    end
    function obj=update_Rules(obj,~,Rules)
        obj.Rules=Rules;
        obj.init();
    end
    function obj=init(obj)
        % XXX
    end
    function obj=init_trlInd(obj,iORc,fld)
        % XXX
        rule=obj.Rules.(iORc).(fld);
        if isnumeric(rule)
            obj.init_every_n_trials(iORc,fld);
            return
        end
        switch rule
            case 'none'
                return
            case 'all'
                obj.init_inds_all(iORc,fld);
            case 'by_interval'
                obj.init_inds_by_interval(iORc,fld);
            case 'by_trial'
                obj.init_inds_by_trial(iORc,fld);
    end
    function obj=init_inds_every_n_trials(obj,iORc,fld)
        % XXX apply trlIndex
        e=obj.Rules.(iORc).(fld);
        z=zeros(obj.nt,1);
        E=e*obj.ni;
        T=obj.nt*obj.ni;
        T=ceil(T/E)*E;

        A=1:E:T;
        A=arrayfun(@(x) x:(x+E-1),A,UO,false)';
        A=[A repmat({[]},size(A,1),e-1)]';
        A=A(:);
        A=A(1:obj.nt)
        A(end)={A{end}(A{end} <= obj.nt*obj.ni)}
        C=num2cell(repmat(z,1,obj.ni+1));
        obj.trlInds.(iORc).(fld)=[A C]
    end
    function obj=init_inds_all(obj,iORc,fld)
        obj.trlInds.(iORc).(fld)=num2cell(zeros(obj.nt,obj.ni+2));
        obj.trlInds.(iORc).(fld){1}=1:obj.nt.*obj.ni;
    end
    function obj=init_inds_by_interval(obj,iORc,fld)
        A=reshape(obj.trlIndex,obj.ni,obj.nt)';
        z=zeros(obj.nt,1);
        B=[z A z];
        B=num2cell(B);
        obj.trlInds.(iORc).(fld)=B;

    end
    function obj=init_inds_by_trial(obj,iORc,fld)
        A=reshape(trlIndex,obj.ni,obj.nt)'
        z=zeros(obj.nt,1);
        B=num2cell(A,2);
        C=num2cell(repmat(z,1,obj.ni+1));
        B=[B C];
        obj.trlInds.(iORc).(fld)=B;
    end
%% UPDATE TI
    function obj=update_ti(t,i)
        obj.t=t;
        obj.i=i;
        if obj.i_p == -1
            obj.i_p=obj.ni+1;
        else
            obj.i_p==obj.i+1;
        end
        obj.ti=sub2ind([obj.ni obj.nt],obj.i,obj.t)
        obj.ti_p=sub2ind([obj.ni+2 obj.nt],obj.i_p,obj.t)
        obj.get_unqInd();
    end
end
end
