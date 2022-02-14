classdef  PsyEl < handle
properties
    name
    num

    bFlip
    when=[]

    bHidden
    bHold
    bRectUpdate=true
    bTexUpdate=true
    status= '' % init draw, tex, close, done
    class
    priority

    tex
    rect

    nFrames
    bStatic

    Obj
    objOpts=struct
    stringOpts

    im
    XYpix
    WHpix
    duration

    floatPrecision=0

    list
    bTex
end
properties(Hidden)
    nBuff
    buffs
end
properties(Access=private)
    Viewer
    PTB
end
methods
    function obj=PsyEl(Viewer,opts,name,num)
        obj.Viewer=Viewer;

        obj.name=name;
        obj.num=num;
        obj.parse(opts);
    end
    function parse(obj,opts)
        P=obj.getP();
        try
            [~,UM]=Args.parseLoose(obj,P,opts);
        catch ME
            rethrow(ME);
        end

        P=obj.Viewer.Info.getP;
        obj.stringOpts=Args.parse(struct(),P,obj.stringOpts);

        if ~ismember(obj.class,{'stm'})
            str=[obj.class '.getP();'];
            try
                P=eval(str);
            catch
                P=[];
            end
            if ~isempty(P)
                obj.objOpts=Args.parse(struct(),P,UM);
            else
                obj.objOpts=UM;
            end
        end
    end
    function init(obj)
        obj.PTB=obj.Viewer.PTB;
        obj.disp_sep();
        obj.init_tex();

        if ~isempty(obj.class) && ~ismember(obj.class,{'stm'})
            str=[ obj.class '(obj.objOpts, obj.PTB, obj.Viewer);'];
            try
                obj.Obj=eval(str);
            catch ME
                disp(str);
                rethrow(ME);
            end
        end
        obj.status='init';
    end
%% main
    function reset(obj,f)
        if nargin < 2; f=1; end
        obj.get_rect(f);
        obj.get_tex(f);
    end
    function get_tex(obj,f)
        if nargin < 2; f=1; end

        if ~obj.bTexUpdate(f)
            ;
        elseif ~isempty(obj.Obj)
            obj.Obj.get_tex(f);
        else
            for s = obj.buffs
                i=s+1;
                obj.tex{i}{f}  = Screen('MakeTexture', obj.PTB.wdwPtr, obj.im{i}(:,:,f),[],[],obj.floatPrecision);
            end
        end
        obj.bTexUpdate(f)=false;
        obj.status='tex';
    end
    function get_rect(obj,f)
        if nargin < 2; f=1; end


        if ~obj.bRectUpdate(f)
            ;
        elseif ~isempty(obj.Obj)
            try
                obj.Obj.get_rect(f);
            catch ME
                obj.Viewer.error(['GetRect -- '  obj.name ' ' num2str(obj.num) ' of ' obj.class ]);
                rethrow(ME);
            end
        else
            X=[obj.XYpix{1}(1) obj.XYpix{2}(1)];
            Y=[obj.XYpix{1}(2) obj.XYpix{2}(2)];
            for s=obj.buffs
                i=s+1;
                obj.rect{i}{f}=obj.getRect(X(i),Y(i),obj.WHpix);
            end
        end
        obj.status='rect';
        obj.bRectUpdate(f)=false;
    end
    function draw(obj,f)
        if nargin < 2; f=1; end
        if obj.bHidden
            ;
        elseif ~isempty(obj.Obj)
            try
                obj.Obj.draw(f);
            catch ME
                obj.Viewer.error(['Drawing -- '  obj.name ' ' num2str(obj.num) ' of ' obj.class ]);
                rethrow(ME);
            end
        else
            for s = obj.buffs
                i=s+1;
                Screen('SelectStereoDrawBuffer', obj.PTB.wdwPtr, s);
                Screen('DrawTexture', obj.PTB.wdwPtr, obj.tex{i}{f}, [], obj.rect{i}{f});
            end
        end
        obj.status='draw';
    end
    function obj=close(obj,f)
        if nargin < 2; f=1; end
        if obj.bHold
            ;
        elseif ~isempty(obj.Obj)
            obj.Obj.close(f);
        else
            for s = obj.buffs
                i=s+1;
                if ~isempty(obj.tex{i})
                    Screen('Close', obj.tex{i}{f});
                end
            end
        end
        obj.status='close';
    end
    function flip(obj)
        if ~obj.bFlip
            ;
        else
            %Screen('DrawingFinished', obj.PTB.wdwPtr,true); XXX ?
            Screen('Flip', obj.PTB.wdwPtr,obj.when,true);
        end
        obj.status='hold';
    end
%% SET
    function set.im(obj,im)
        obj.im=im;
        obj.init_bTexUpdate();
    end
    function set.WHpix(obj,WHpix)
        if isequal(WHpix,obj.WHpix)
            return
        end
        obj.WHpix=WHpix;
        obj.init_bRectUpdate();
    end
    function set.XYpix(obj,XYpix)
        if isequal(XYpix,obj.XYpix)
            return
        end
        obj.XYpix=XYpix;
        obj.init_bRectUpdate();
    end
    function set.duration(obj,duration)
        if isequal(obj.duration,duration)
            return
        end
        obj.duration=duration;
        if isempty(obj.PTB)
            return
        end
        obj.nFrames = round((duration)./obj.PTB.ifi);
        obj.init_tex();
    end
%% TEX
    function init_tex(obj)
        obj.nBuff=double(obj.PTB.bStereo>0)+1;
        obj.buffs=0:obj.nBuff-1;
        obj.tex=cell(obj.nBuff,1);
        obj.rect=cell(obj.nBuff,1);
        for i = obj.nBuff
            if obj.bStatic
                obj.tex{i}=cell(1);
                obj.rect{i}=cell(1);
            else
                obj.tex{i}=cell(obj.nFrames,1);
                obj.rect{i}=cell(obj.nFrames,1);
            end
        end
        obj.init_bRectUpdate();
        obj.init_bTexUpdate();
    end
    function init_bRectUpdate(obj)
        if obj.bStatic
            obj.bRectUpdate=true;
        else
            obj.bRectUpdate=true(obj.nFrames,1);
        end
    end
    function init_bTexUpdate(obj)
        if obj.bStatic
            obj.bTexUpdate=true;
        else
            obj.bTexUpdate=true(obj.nFrames,1);
        end
    end

%% UITL
    function obj=disp_sep(obj)
        name=[obj.name '.' num2str(obj.num)];
        obj.dispSep(name);
    end
    function new=rect_to_sbs(obj,name,Yadd)
        % XXX
        if ~exist('Yadd','var') || isempty(Yadd)
            Yadd=0;
        end
        rect=obj.rect.(name);
        new=cell(1,2);
        for i = 1:2
            w=rect{i}(3)-rect{i}(1);
            H=rect{i}(4)-rect{i}(2);

            x1=rect{i}(1)-w/2;
            x2=x1+w*2;
            y1=rect{1}(2)-(Yadd*H);
            y2=rect{1}(4)-(Yadd*H);
            new{i}=[x1 y1 x2 y2];
        end
    end
end
methods(Static)
    function dispSep(name)
        l=73-length(name);
        txt=['---' name repmat('-',1,l)];
        disp(txt);
    end
    function rec=getRect(X,Y,WH)
        h=WH(2);
        w=WH(1);

        l=X-w/2;
        t=Y-h/2;
        r=X+w/2;
        b=Y+h/2;

        rec=[l t r b];
    end
    function P=getP()
        P={...
           'priority',0,'Num.is';...
           'class','','ischar_e';...
           'floatPrecision',2,'Num.is';...
           'duration',0,'isbinary';...
           'stringOpts',struct(),'isoptions_e';...
           'bStatic',true,'isbinary';...
           'bTex',0,'isbinary'; ...
           'bFlip',0,'isbinary'; ...
           'bHidden',0,'isbinary'; ...
        };
    end
end
end
