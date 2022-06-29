classdef CursorEl < handle
properties
    rect
    line

    fillColor
    style
    lineWidth
    lineColor

    %nchar

    Parent
    Ptb
end
methods
    function obj=CursorEl(Parent)
        obj.Parent=Parent;
        obj.Ptb=Parent.Ptb;
    end
    function draw(obj,rect,style)
        obj.rect=rect;
        if nargin < 3 || isempty(style)
            style=obj.style;
        end
        %obj.nchar=cellfun(@numel,obj.TEXT);
        switch style
        case 'box'
            obj.draw_boxed();
        case 'bar'
            obj.draw_barred();
        case 'underline'
            obj.draw_underlined();
        end
    end
end
methods(Access=private)
    function draw_underlined(obj)
        obj.line={obj.rect(1) obj.rect(2) obj.rect(3) obj.rect(2) obj.lineWidth};
        for s = 0:1 %XXX
            Screen('SelectStereoDrawBuffer', obj.Ptb.wdwPtr, s);
            Screen('DrawLine',obj.Ptb.wdwPtr,obj.lineColor,obj.line{:});
        end
    end
    function draw_barred(obj)
        rect=obj.rect;
        rect(1)=rect(1)*obj.Parent.wPerChar;
        obj.line={rect(1) rect(2) rect(1) rect(4) obj.lineWidth};
        for s = 0:1 % XXX
            Screen('SelectStereoDrawBuffer', obj.Ptb.wdwPtr, s);
            Screen('DrawLine',obj.Ptb.wdwPtr,obj.lineColor,obj.line{:});
        end
    end
    function draw_boxed(obj)

        for s = 0:1 % XXX
            Screen('SelectStereoDrawBuffer', obj.Ptb.wdwPtr, s);
            %Screen('FillRect', obj.Ptb.wdwPtr, obj.fillColor, obj.rect);
            Screen('FrameRect', obj.Ptb.wdwPtr, obj.lineColor, obj.rect, obj.lineWidth);
        end
    end
end
end
