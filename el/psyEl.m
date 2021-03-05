classdef psyEl < handle & common3D & shape3D & point3D
% abstract superclass
% obj=ppsyEl(ptb,Opts,img,txt,Parent,index)sy_el(Opts,ptb,img,txt)
%
% get point
% get shape
% handle children
%
% add update to subclass constructor
%
properties
    IMG
    TXT

    rgba
    wdwPtr

% Lisening
    ePtbUpdated % TODO what needs to be updated here?
end
properties(Hidden)
    Opts
    bImg
    bTxt
methods
    %obj@psyEl
    function obj=psyEl(ptb,Opts)
        if ~exist('Opts','var') || isempty(Opts)
            Opts=struct();
        end
        if is~isfield(PAR,PTB) || isempty(PAR.PTB)
            ptb=struct();
        end

        % INIT SUPERCLASSES
        [pointOpts,Opts]=structSplit(Opts,point3D.listParams);
        [shapeOpts,Opts]=structSplit(Opts,shape3D.listParams);
        obj@point3D(ptb,pointOpts); %handles all common3D and point3D
        obj@shape3D(shapeOpts);

        obj.sort_Opts();
        obj.init_nested(ptb);

        obj.update_wdwPtr(ptb);
        obj.PtbUpdated     =addlistener(ptb,'ptbUpdated',@(src,data) update_wdwPtr(obj,ptb));

    end
    function Opts=sort_Opts(obj,Opts)
        %% IMAGE
        if isfield(Opts,'Img')
            if isa(Otps.Img,'lib.pointer')
                obj.IMG=Opts.IMG;
            elseif ~isempty(Opts.Img)
                obj.IMG=libpointer('doublePtr',Opts.Img);
            end
            Opts=rmfield(Opts,'Img');
            bImg=1;
        end

        %% TEXT
        if isfield(Opts,'Txt')
            if ~isempty(Opts.Txt)
                obj.TXT=Opts.Txt;
            end
            Opts=rmfield(Opts,'Txt');
            bTxt=1;
        end

        %% RGBA
        if isfield(Opts,'Rgba')
            if ~isempty(Opts.Rgba)
                obj.rgba=Opts.rgba;
            end
            Opts=rmfield(Opts,'rgba');
        end


        obj.Opts=Opts;
    end
    function Otps=init_nested(obj,ptb)
        [rgba{1},rgba{2}]=Rgba.get(ptb,obj.RGBA.color1, obj.RGBA.alpha1, obj.RGBA.color2,colorOpts.alpha2);


        % parse TXT TODO
        % parse img TODO
    end

%% INDS
    % SHAPE
%%
    function obj=update_ptb(obj,ptb)
        obj.update_wdwPtr(ptb);
    end
    function obj=update_Opts(obj,Opts)
        % TODO
    end
%% MAIN CALLS
    
    function obj=call_trial(obj,t)
        obj.i=0;
        obj.t=t;

        obj.check(0);
        obj.update();
        obj.draw();
        obj.close();
    end
    function obj=call_end_trial(obj,t)
        obj.t=t;
        obj.i=0;

        obj.check(-1);
        obj.update();
        obj.draw();
        obj.close();
    end
    function obj=call_interval(obj,t,i)
        obj.t=t;
        obj.i=i;

        obj.check(obj.i);
        obj.update();
        obj.draw();
        obj.close();
    end
%% UPDATE
    function obj=check(i)
        % NOTE
    end
    function obj=update(obj)
        % NOTE
    end
    function obj=draw_shape(obj,s)
        if ~exist('s','var')
            s=1;
        end
        switch obj.primitive
            case 'rect'
                Screen('FillRect',obj.wdwPtr,obj.rgba{i}.self.,obj,shape{s});
            case 'oval'
                Screen('FillOval',obj.wdwPtr,obj.rgba{i}.self,obj.shape{s});
            case 'line'
                Screen('DrawLine',obj.wdwPtr,obj.rgba{i}.self,obj.shape{s}{:});
        end
    end
    function obj=draw(obj,f)
        if ~exist('var','f')
            f=[];
        end
        for s = 0:obj.bStereo
            i=s+1;
            Screen('SelectStereoDrawBuffer', obj.wdwPtr, s);

            obj.draw_shape(s);
            if obj.bTxt
                obj.TXT.draw(obj.wdwPtr,s);
            end
            if obj.bImg
                obj.IMG.draw();
            end
        end
    end
    function obj=close(obj)
        if bImg
            obj.IMG.close(); % XXX
        end
    end
    function obj=clear(obj)
        obj.clear_shape();
        obj.clear_point();
        if obj.bTxt
            obj.TXT.clear
        end
    end
%%%
end
end
