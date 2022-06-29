classdef SelBox < handle & PsyElObj
properties
    Sel
    colorS=[1 1 1];
    colorA=[0 0 0];
    width=5;
    bActive=false
end
methods
    function obj=SelBox(opts,ptb,viewer)
        obj.Ptb=ptb;
        obj.Viewer=viewer;
    end
    function draw(obj,f)
        if isempty(obj.Sel)
            return
        end
        if obj.bActive
            color=obj.colorA;
        else
            color=obj.colorS;
        end
        for s = 0:1 % XXX
            obj.select_stereo_buffer(s);
            Screen('FrameRect',obj.Ptb.wdwPtr, color, obj.rect{s+1}{f}, obj.width);
        end
    end
    function get_rect(obj,f)
        if isempty(obj.Sel)
            return
        end
        rect=obj.Viewer.Psy.get_rect(obj.Sel.name,obj.Sel.num); %X1 Y1 X2 Y2
        for i = 1:2
            obj.rect{i}{f}=rect{i}{f}+([-1 -1 1 1].*repmat(obj.width/2,1,4));
        end
    end
end
end
