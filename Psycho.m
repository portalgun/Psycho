classdef Psycho < handle & Psycho_hooks
% TODO sort by depenency
properties
    D
    initflag=-1 % -1 not yet, 0 initializing, 1 initialized

end
properties(Hidden=true)
    ptch
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
            n=obj.nums(ismember(name,obj.names));
            for iA = 1:n
                obj.A.(name){iA}.init();
            end
        end
        obj.dispSep('AUX_END');
    end
    function get_rect(obj,name,num)
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
        obj.A.(name){num}.XYpix=XYpix;
        obj.A.(name){num}.WHpix=WHpix;
    end
    function update_duration(obj,name,num,duration)
        if isempty(num)
            num=1;
        end
        obj.A.(name){num}.duration=duration;
    end
    function lists=apply_infos(obj)
        for i = 1:length(obj.names)
            name=obj.names{i};
            n=obj.nums(ismember(name,obj.names));
            for iA = 1:n
                opts=obj.A.(name){iA}.stringOpts;
                if ~isempty(opts.list)
                    txt=obj.Viewer.Info.format(opts.list, opts);
                    obj.A.(name){i}.Obj.TEXT=txt;
                end
            end
        end
    end
%% DRAW
    function draw_subInt(obj,opts)
        obj.subInt_fun(opts,'reset');
        obj.subInt_fun(opts,'draw');
        obj.subInt_fun(opts,'close');
    end
    function subInt_fun(obj,opts,prp)
        for i = 1:length(opts.(prp))
            name=opts.(prp){i};
            n=obj.nums(ismember(name,obj.names));
            for iA = 1:n
                obj.A.(name){iA}.(prp)();
            end
        end
    end
%%
%% FLIP
    function obj=draw_complete(obj)
        Screen('DrawingFinished', obj.PTB.wdwPtr,false);
    end
    function obj=draw_complete_inc(obj)
        Screen('DrawingFinished', obj.PTB.wdwPtr,true);
    end
    function flip(obj,when)
        if nargin < 1; when=[]; end
        Screen('Flip', obj.PTB.wdwPtr,when,false);
    end
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

