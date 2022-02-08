classdef psyElComp < handle & psyEl
properties
    ELIND
    index
end
properties(Hidden = true)
    nt
    ni
    t
    i
    bDraw
    bCloseTEx
    bUpdateShape
    bUpdateTex
end
methods
    function obj=psyElComp(ptb,Opts,Parent,index)
        %% ELind
        if isifield(Opts,'Ind')
            if ~isempty(Opts.Ind)
                obj.ind=Opts.Ind;
            end
            Opts=rmfield(Opts,'Ind');
        end
    end
    function obj=close(obj)
        if obj.ELIND.bCloseShape
            obj.close_shape(); % TODO multi
        end
        if obj.ELIND.bClosePoint
            obj.close_point();
        end
        if obj.ELIND.bCloseText
            obj.T
            obj.ELIND.update_text_status(obj.t,obj.i,-1);   % TODO multi
        end
        if obj.ELIND.bCloseTex
            obj.img.close(); % XXX
            obj.ELIND.update_tex_status(obj.t,obj.i,-1);    % TODO multi
        end
    end

    function obj=draw(obj,f)
        if ~exist('var','f')
            f=[];
        end
        for s = 0:obj.bStereo
            i=s+1;
            Screen('SelectStereoDrawBuffer', obj.wdwPtr, s);

            if obj.ELIND.bDrawShape
                obj.draw_shape(s);
                obj.ELIND.update_shape_status(obj.t,obj.i,2); % TODO multi
            end
            if obj.ELIND.bDrawText
                obj.draw_shape(s);
                obj.ELIND.update_text_status(obj.t,obj.i,2); % TODO multi
            end
            if obj.ELIND.bDrawText
                obj.text.draw(obj.wdwPtr,s);
                obj.ELIND.update_tex_status(obj.t,obj.i,2);  % TODO multi
            end
            % DRAW TEXT
            obj.bDrawn(s)=1;
        end
    end
    function obj=check(obj,int)
        obj.ELIND(obj.t,int);
    end
    function obj=update(obj)

        % INIT POINT
        if obj.ELIND.bInitPoint
            obj.init_points():
        end
        if obj.ELIND.bInitPoint
            error('Points cannot initialize')
        end

        % INIT SHAPE
        if obj.ELIND.bInitShape
            obj.init_shape();
        end
        if obj.ELIND.bInitShape
            error('Shape cannot initialize')
        end

        % INIT_IMG
        if obj.ELIND.bInitImg
            obj.init_image(); % XXX?
        end
        if obj.ELIND.bInitImg
            error('Image cannot initialize')
        end

        % INIT_TEX
        if obj.ELIND.bInitTex
            obj.init_tex(); % XXX?
        end
        if obj.ELIND.bInitTex
            error('Tex cannot initialize')
        end

    end
end
methods (Static=true)
    function OUT=selector(type,ptb,Opts,Parent,index)
        if ~exist('Opts','var')
            Opts=[];
        end
        if ~exist('Parent','var')
            Parent=[];
        end
        if ~exist('index','var')
            index=[]'
        end
        if ~isubclass(type,'psyEl')
            error(['Class ' type ' is not subclass of psyEl']);
        end
        str=[type '(ptb,Opts,Parent,index);']
        OUT=eval(str);
    end
end
end
