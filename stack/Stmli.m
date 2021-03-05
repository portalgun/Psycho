classdef Stmli < handle
properties
    PTCHS
    BACKDROP
end
methods
    function obj=Stack(obj,PAR)
        obj.STMLIIND=stmliInd
        obj.STMLIOPTS=stmliOpts

        obj.PTCHS=ptchs(Opts.Ptchs);
        obj.BACKDROP=backdrop();
        obj.PTCHS=patches();

        obj.STM=Stm(Opts);
    end
    function ELIND=init_elInd
        % XXX
    end
    function STMIND=init_stmInd
        % XXX

    end
    function obj=init_stmliInd
        % XXX
        obj.STMLIIND=stmliInd();
    end
    function obj=init_stm
    end
%% CALL
    function obj=call_trial(obj,t)
        obj.i=0;
        obj.t=t;

        obj.check(0);
        obj.update(0);
        obj.draw();
        obj.close();
    end
    function obj=call_end_trial(obj,t)
        obj.t=t;
        obj.i=0;

        obj.check(-1);
        obj.update(-1);
        obj.draw();
        obj.close();
    end
    function obj=call_interval(obj,t,i)
        obj.t=t;
        obj.i=i;

        obj.check(obj.i);
        obj.update(obj.i);
        obj.draw();
        obj.close();
    end
%%
    function obj=check(obj,int)
        % for all n
        obj.STMLIIND.check(obj.t,int); %
        obj.BGIND.check(obj.t,int)
    end
    function obj=update(obj,int)
        for ind=1:obj.STMLIIND.ti_inds; % NOTE
            n=obj.STMLIIND.n_inds(ind); % NOTE
            ti=obj.STMLIIND.ti(ind);
            obj.update_ind(int,ti,n,ind);
        end
    end
    function obj=update_ind(obj,int,ti,n)
        if obj.STMLIIND.bPatch(ind)
            Ptch=obj.PTCHS.get(obj.t,int,n)
            obj.STM.update_patch(Ptch);
        end
        if obj.STMLIIND.bOpt(ind)
            Opt=obj.STMLIOPTS.get(obj.t,int,n);
            obj.STM.update_Opts(Ptch,Opt);
        end

        if obj.STMLIIND.bBuffer(ind)
            obj.add_to_buffer(n,ti);
        end
        if obj.STMLIIND.bMove(ind)
            obj.move_to_stack(n,ti);
        end
        if obj.STMLIIND.bCopy(ind)
            obj.copy_to_stack(n,ti);
        end
        if obj.STMLIIND.bStack(ind)
            obj.add_to_stack(n,ti);
        end
    end
end
end
