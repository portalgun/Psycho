classdef Rgba < handle
properties
    fg
    bg
    fgColor
    bgColor
    fgAlpha=1;
    bgAlpha=1;
end
properties(Hidden=true)
    gry=[.5 .5 .5];
    wht=[1 1 1];
    blk=[0 0 0];
end

methods
    function obj=Rgba(ptb,color1,alpha1,color2,alpha2)
        if exist('color1','var')  && ~isempty(color1)
            obj.process_color(color1,1);
        end
        if exist('color2','var')  && ~isempty(color2)
            process_color(color1,2);
        end
        if exist('alpha1','var')  && ~isempty(alpha)
            obj.fgAlpha=obj.process_alpha(alpha1,1)
        end
        if exist('alpha2','var')  && ~isempty(alpha2)
            obj.bgAlpha=obj.process_alpha(alpha2,2)
        end
        if isempty(obj.fg)
            obj.fg=[obj.fgColor obj.fgAlpha];
        end
        if isempty(obj.bg)
            obj.bg=[obj.bgColor obj.bgAlpha];
        end
    end
    function color=process_color(obj,color,num)
        bHex=0;
        if ischar(color) && strcmp(color,'wht')
            color=obj.wht;
            return
        elseif ischar(color) && strcmp(color,'gry')
            color=obj.gry;
            return
        elseif ischar(color) && strcmp(color,'blk')
            color=obj.blk;
            return
        elseif ischar(color) && startsWith(color,'#')
            bHex=1;
        end

        if any(color > 1)
            color=round(color);
            color=color./256;
        end

        bBoth=0;
        color=rowVec(color);
        if bHex
            error('write hex code');
        elseif numel(color) == 1
            color=repmat(color,1,3);
        elseif numel(color) == 4
            bBoth=1;
        elseif numel(color) ~= 3
            error('Invalid color size');
        end

        if num==1
            fld='fgColor';
            fld1='fg';
            fld2='fgAlpha'
        elseif num==2;
            fld='bgColor';
            fld1='fg';
            fld2='bgAlpha';
        end
        if bBoth
            obj.(fld1)=color;
            obj.(fld)=color(1:3);
            obj.(fld2)=color(end);
        else
            obj.(fld)=color;
        end
    end
    function alpha=process_alpha(obj,alpha,num)
        if numel(alpha) > 1
            error('Alpha must be one element')
        end

        if any(alpha > 1)
            color=round(color);
            color=color./256;
        end
    end
end
methods(Static=true)
    function [fg,bg]=get(ptb,color1,alpha1,color2,alpha2)
        obj=Rgba(ptb,color1,alpha1,color2,alpha2);
        fg=obj.fg;
        bg=obj.bg;
    end
end
end
