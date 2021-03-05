classdef Stack < handle
% XXX UPDATE STATUS ECT
%%
% SELECT OPT
% CREATE STM
% MOVES STM TO BUFFER/ STACK
properties
    IND
    Opts
    OBJ
    className

    % STACK
    Buffer
    BufferInd
    Stack
    StackInd

    ti_inds
    n_inds

    bStack
    bCopy
    bMove
    bBuffer
    bClose
    bRm
    bPatch
    bUpdate
end
properties(Hidden=true)
    tmp
end
methods
    function obj=Stack(PAR,Rules,Opts,className)
        if ~exist('initOpts','var')
            initOpts=[];
        end

        initOpt=obj.OPTS.get(t,int,n);

        obj.IND=psyInd(PAR.EXP,Rules)
        obj.Opts=Opts;

        % XXX get first t int n
        initOpt=obj.Opts{t,int,n};
        obj.OBJ=eval([className '(initOpts);']);
        obj.className=className;
    end
%% ADD
    function obj=add_to_buffer(obj,n,ti)
        obj.Buffer{end+1}=obj.STM;
        obj.StackInd(end+1,:)=[ti n];
    end
    function obj=add_to_stack(obj,n,ti)
        obj.Stack{end+1}=obj.STM;
        obj.StackInd(end+1,:)=[ti n];
    end
%% RM
    function obj=rm_from_buffer(obj,n,ti)
        ind=obj.BufferInd(:,1)==ti & obj.BufferInd(:,2)==ti;
        obj.Buffer(ind)=[];
        obj.BufferInd(ind)=[];
    end
    function obj=rm_from_stack(obj,n,ti)
        ind=obj.StackInd(:,1)==ti & obj.StackInd(:,2)==ti;
        obj.Stack(ind)=[];
        obj.StackInd(ind)=[];
    end
%% GET
    function obj=get_from_stack(obj,n,ti)
        obj.tmp=obj.Stack(obj.StackInd(:,1)==ti & obj.StackInd(:,2)==ti);
    end
    function obj=get_from_buffer(obj,n,ti)
        obj.tmp=obj.Buffer(obj.BufferInd(:,1)==ti & obj.BufferInd(:,2)==ti);
    end
    function obj=close_in_stack(obj,n,ti)
        ind=obj.StackInd(:,1)==ti & obj.StackInd(:,2)==ti;
        obj.Stack(ind).close;
    end
%% POP
    function obj=pop_from_buffer(obj,n,ti)
        ind=obj.BufferInd(:,1)==ti & obj.BufferInd(:,2)==ti;
        obj.tmp=obj.Buffer(ind);
        obj.Buffer(ind)=[];
        obj.BufferInd(ind)=[];
    end
    function obj=pop_from_stack(obj,n,ti)
        ind=obj.StackInd(:,1)==ti & obj.StackInd(:,2)==ti;
        obj.tmp=obj.Stack(ind);
        obj.Stack(ind)=[];
        obj.StackInd(ind)=[];
    end
%% MOVE
    function obj=move_to_stack(obj,n,ti)
        obj.pop_from_buffer(n,ti);
        obj.Stack{end+1}=obj.tmp;
        obj.StackInd(end+1,:)=[ti n];
        obj.tmp=[];
    end
    function obj=move_to_buffer(obj,n,ti)
        obj.pop_from_stack(n,ti);
        obj.Buffer{end+1}=obj.tmp;
        obj.BufferInd(end+1,:)=[ti n];
        obj.tmp=[];
    end
%% COPY
    function obj=copy_to_stack(obj,n,ti)
        obj.get_from_buffer(n,ti);
        obj.Stack{end+1}=obj.tmp;
        obj.StackInd(end+1,:)=[ti n];
        obj.tmp=[];
    end
    function obj=copy_to_buffer(obj,n,ti)
        obj.get_from_stack(n,ti);
        obj.Buffer{end+1}=obj.tmp;
        obj.BufferInd(end+1,:)=[ti n];
        obj.tmp=[];
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
        obj.IND.check(obj.t,int); %
    end
    function obj=update(obj,int)
        for ind=1:obj.IND.ti_inds; % NOTE
            n=obj.IND.n_inds(ind); % NOTE
            ti=obj.IND.ti(ind);
            obj.update_ind(int,ti,n,ind);
        end
    end
    function obj=update_ind(obj,int,ti,n)
        if obj.IND.bUpdate(ind)
            opt=obj.OPTS.get(obj.t,int,n);
            obj.OBJ.update_Opts(opts);
        end

        if obj.IND.bBuffer(ind)
            obj.add_to_buffer(n,ti);
        end
        if obj.IND.bMove(ind)
            obj.move_to_stack(n,ti);
        end
        if obj.IND.bCopy(ind)
            obj.copy_to_stack(n,ti);
        end
        if obj.IND.bStack(ind)
            obj.add_to_stack(n,ti);
        end
    end
    function obj=draw(obj)
        for i = 1:length(obj.Stack)
            obj.Stack{i}.draw();;
        end
    end
    function obj=close(obj)
        for ind = 1:length(obj.INDS.ti_inds)

            n=obj.IND.n_inds(ind) % NOTE
            ti=obj.IND.ti(ind)

            if obj.IND.bClose(ind)
                obj.close_in_stack(n,ti);
            end
            if obj.STMLIIIND.bRm(ind)
                obj.rm_from_stack(n,ti);
            end

        end
    end
end
end
