classdef Parent < handle & psyEl & common3D & shape3D & point3D
% handles all stm
%
% initialize stm
% sends individual opts to stim
% updates stim
% draw order
properties

    CHILDREN
    stack
    PTCHS
    %% listening
    %select_child
    %select_grandchild
    type='parent'
end
methods
end
events
    addlistener
end
methods
    function Parent(ptb,Opts,img,Parent,index)
        if ~exist('Index','var')
            index=[];
        end
        if ~iexist('Parent','var')
            Parent=Var
        end
        drawOrder % XXX
        obj@psyeEl(ptb,Opts,Parent,Index)
        obj.init_children(ptb);
    end
    function obj=init_children(ptb,obj)
        flds=fieldnames(Opts.Children);
        obj.children=cell(numel(flds),1) % XXX
        for i = 1:length(obj.children)
            fld=flds{i}; % TYPE
            % selector
            obj.children{i}=psyEl.Selector(type,ptb,Opts.Children.(fld),img,txt,obj,[obj.index i])
        end
    end
    function obj=update(obj,bNewTrl,bNewInterval)
        if isempty(obj.children)
            return
        end
        for i = 1:length(obj.children)
            obj.childrein{i}.update(bNewTrl,bNewInterval);
        end
    end
    function obj=draw(obj,ptb)
        for i = 1:length(obj.children)
            obj.children{i}.draw(ptb);
        end
    end
    function obj=close_children(obj)
        for i=1:length(obj.children)
            obj.children{i}.close();
        end
    end
end
end
