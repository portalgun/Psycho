classdef PsyElObj < handle
properties
    W
    H
    X
    Y

    rectRaw % [ 0 0 W H ]
    rect
    relRec    % position relative to another rect (not rectRaw)

%- RELREC
%Options
    bRelXYWH
    bHRel
    bWRel
    relPosPRC % In/Out Top/Bottom/Middle L/R/M

    relPosHW
    relXYctr

    % rel src dimensions
    xRel
    yRel
    wRel
    hRel
end
properties(Hidden)
    relName
    sStereo
    Viewer
    Ptb
end
methods(Abstract)
    draw(obj,f)
end
methods
    function obj=update_ptb(obj,ptb)
        obj.Ptb=ptb;
        obj.sStereo=double(obj.Ptb.bStereo);
    end
%% MAIN
    function get_tex(obj,~)
    end
    function close(obj,~)
    end
    function obj=get_rect(obj)
        if ~isempty(obj.X)
            x=obj.X;
        else
            x=obj.xRel;
        end
        if ~isempty(obj.Y)
            y=obj.Y;
        else
            y=obj.yRel;
        end
        if obj.bHRel
            h=obj.hRel;
        elseif ~isempty(obj.H)
            h=obj.H;
        end
        if obj.bWRel
            w=obj.wRel;
        elseif ~isempty(obj.W)
            w=obj.W;
        end
        obj.rect=[x y x+w y+h];
    end
%% UTIL
    function select_stereo_buffer(obj,s)
        Screen('SelectStereoDrawBuffer', obj.Ptb.wdwPtr, s);
    end
%% REL REC
    function val=apply_prect(obj)
        if ischar(obj.relRec)
            obj.relName=obj.relRec;
        end
        out=regexp(obj.relName,'([a-zA-Z]+)([0-9]*)','tokens','once');
        name=out{1};
        num=out{2};
        if ismember(name,{'display','VDisp','screen'})
            val=obj.Ptb.wdwXYpix;
        else
            val=obj.Viewer.Psy.get_rect(name,num);
        end
        obj.relRec=val;
    end

    function obj=get_xy_rel(obj)
        obj.apply_prect();
        [obj.xRel,obj.yRel]=Shape3D.getXYrel(obj.relRec,obj.relPosPRC,obj.rectRaw,obj.padXY);
        % L T R B
        obj.hRel=obj.relRec(4)-obj.relRec(2);
        obj.wRel=obj.relRec(3)-obj.relRec(1);
    end
end
methods(Static)
    function P =getP()
        P={...
               'H',[],'isnumeric_e';
               'W',[],'isnumeric_e';
               'X',[],'isnumeric_e';
               'Y',[],'isnumeric_e';
               'bHRel',0,'isbinary_e';...
               'bWRel',0,'isbinary_e';...
               'bRelXYWH',[],'@(x) true';
               'relRec',[],'@(x) true';...
               'relPosPRC','IBR','ischar';...
               'relPosHW',[],'isnumeric'; ...
               'relXYctr',[],'isnumeric';...
        };
    end
end
end
