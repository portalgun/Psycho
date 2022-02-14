classdef Psycho < handle & Psycho_hooks
properties
    D
    initflag=-1 % -1 not yet, 0 initializing, 1 initialized

end
properties(Hidden=true)
    ptch
    bInc
end
%properties(Access=?PtchsViewer)
properties
    A % NAME, NUM,

    ptbOpts
    PTB
    bPTB=0
    nBuff
    buffs % zero-indexing

    names
    nums
    priority
    bUpdatePriority=true
end
properties(Access=private)
    PsyInt
    Viewer
end
methods(Static)
    function alias=getAlias()
        alias=getenv('PSY_ALIAS');
    end
    function Opts=readConfig(alias)
        if nargin < 1
            alias=Psycho.getAlias();
        end
        Opts=Cfg.read(['D_viewer_' alias '.cfg']);
        %Opts=Cfg.read(['D_' alias '.cfg']);
    end
end
methods
    function obj = Psycho(viewer,allOpts);
        if nargin >= 1 && ~isempty(viewer)
            obj.Viewer=viewer;
            S=obj.Viewer.Ptchs;
        else
            viewer=[];
            S=struct();
        end
        if nargin < 2 || isempty(allOpts);
            allOpts=dict();
        end
        obj.parse(allOpts);
    end
    function obj=set.PTB(obj,PTB)
        obj.dispSep('PTB');
        obj.PTB=PTB;
        obj.nBuff=double(obj.PTB.bStereo>0)+1;
        obj.buffs=0:obj.nBuff-1;
    end
%% INIT
    function obj=parse(obj,allOpts)
        flds=fieldnames(allOpts);
        opts=struct;
        for i = 1:length(flds)
            fld=flds{i};
            if strcmp(fld,'ptb')
                obj.ptbOpts=allOpts{'ptb'};
                continue
            end

            % GET NAME AND NUM
            mtch=regexp(fld,'(^[a-zA-Z0-9_]+)\.([0-9])$','tokens','once');

            if ~isempty(mtch)
                name=mtch{1};
                num=str2double(mtch{2});
                if ~isfield(bA,(name))
                    bA.(name)=true;
                end
            else
                name=fld;
                bA.(name)=true;
                num=1;
            end

            % INTI PSYEL
            if ~isfield(obj.A,name)
                obj.A.(name)=cell(0,1);
            end
            obj.A.(name){num,1}=PsyEl(obj.Viewer,allOpts{fld},name,num);
        end
        obj.names=fieldnames(bA);
        obj.nums=structfun(@numel,obj.A);
    end
%% INIT
    function init_aux(obj)
        obj.dispSep('AUX');
        for i = 1:length(obj.names)
            name=obj.names{i};
            n=obj.nums(ismember(obj.names,name));
            for iA = 1:n
                obj.A.(name){iA}.init();
            end
        end
        obj.dispSep('AUX_END');
    end
    function val=get_rect(obj,name,num)
        if ~ismember(name,fieldnames(obj.Viewer.Psy.A))
            error([ 'PsyEl ' name ' not yet initialized']);
        end
        if isempty(num)
            num=1;
        end
        O=obj.A.(name){num}.Obj;
        if ~isempty(O)
            if isprop(O,'prect')
                val=obj.Viewer.Psy.A.(name){num}.Obj.prect;
            elseif isprop(O,'rect')
                val=obj.Viewer.Psy.A.(name){num}.Obj.rect;
            end
        else
            val=obj.A.(name){num}.rect;
        end
    end
    function update_im(obj,name,num,im)
        if isempty(num)
            num=1;
        end
        obj.A.(name){num}.im=im;
    end
    function update_geom(obj,name,num,XYpix,WHpix)
        if isempty(num)
            num=1;
        end
        if ~iscell(XYpix) && numel(XYpix)==2
            XYpix={XYpix XYpix};
        end
        obj.A.(name){num}.XYpix=XYpix;
        obj.A.(name){num}.WHpix=WHpix;
    end
    function update_duration(obj,name,num,duration)
        if isempty(num)
            num=1;
        end
        obj.A.(name){num}.duration=duration;
    end
    function update_priority(obj,name,num,priority)
        if isempty(num)
            num=1;
        end
        if ~isequal(obj.A.(name){num}.priority,priority)
            obj.A.(name){num}.priority=priority;
            obj.bUpdatePriority=true;
        end
    end
    function lists=apply_infos(obj)
        for i = 1:length(obj.names)
            name=obj.names{i};
            n=obj.nums(ismember(obj.names,name));
            for iA = 1:n
                opts=obj.A.(name){iA}.stringOpts;
                if ~isempty(opts.list)
                    txt=obj.Viewer.Info.format(opts.list, opts);
                    obj.A.(name){iA}.Obj.text=txt{1};
                    obj.A.(name){iA}.bRectUpdate=true;
                end
            end
        end
    end
%% DRAW
    function draw(obj,opts)
        if obj.bUpdatePriority
            obj.get_priorities();
            obj.bUpdatePriority=false;
        end
        obj.subInt_fun(opts,'reset');
        obj.subInt_fun(opts,'draw');
        obj.PTB.flip();
        obj.subInt_fun(opts,'close');
    end
    function P=get_priorities(obj)
        P=cell(sum(obj.nums),3);
        c=0;
        for i = 1:length(obj.names)
            name=obj.names{i};
            n=obj.nums(ismember(obj.names,name));
            for iA = 1:n
                c=c+1;
                P(c,:)={obj.A.(name){iA}.priority, name, iA};
            end
        end
        zind=vertcat(P{:,1})==0;
        P0=P(zind,:);
        P=P(~zind,:);
        [~,ind]=sort(vertcat(P{:,1}));
        P=[P(ind,:); P0];
        obj.priority=P(:,2:end);
    end
    function subInt_fun(obj,opts,prp)
        for i = 1:size(obj.priority,1)
            name=obj.priority{i,1};
            num= obj.priority{i,2};
            if ismember(name,opts.(prp)) %% Slowish
                obj.A.(name){num}.(prp)();
            end
        end
    end
    %function subInt_fun(obj,opts,prp,P)
    %    for i = 1:length(opts.(prp))
    %        name=opts.(prp){i};
    %        n=obj.nums(ismember(name,obj.names));
    %        for iA = 1:n
    %            obj.A.(name){iA}.(prp)();
    %        end
    %    end
    %end
%% UTIL
end
methods(Static)
    function dispSep(name)
        l=76-length(name);
        txt=[name repmat('-',1,l)];
        disp(txt);
    end
end
end

