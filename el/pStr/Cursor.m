classdef Cursor < handle
properties
    bActive=0
    bActivateable
    achar=1
    aline=1;
    cursorFillColor
    cursorRect
    cursorStyle
    cursorLineWidth
    cursorLineColor
    nchar
end
methods
    function obj=run_cursor(obj)
        obj.nchar=cellfun(@numel,obj.TEXT);
        if obj.bActive

            obj.get_cursor_rect();
            switch obj.cursorStyle
            case 'box'
                obj.draw_cursor_boxed();
            case 'bar'
                obj.draw_cursor_barred();
            case 'underline'
                obj.draw_cursor_underlined();
            end
        end
    end
    function obj=get_cursor_rect(obj)
        i=obj.aline;
        c=obj.achar;

        X=obj.RECT(i,1);
        W=obj.W(i);
        w=numel(obj.TEXT{i})/W;
        h=obj.H(i);

        y1=obj.RECT(i,2);
        y2=y1+h;
        x1=X+(w*c-1);
        x2=x1+w;

        obj.cursorRect=[x1 y1 x2 y2];
    end
    function obj=draw_cursor_underlined(obj)
        line=obj.cursorRect;
        line={line(1) line(2) line(3) line(2) obj.cursorLineWidth};
        for s = 0:obj.sStereo
            Screen('SelectStereoDrawBuffer', obj.wdwPtr, s);
            Screen('DrawLine',obj.wdwPtr,obj.cursorLineColor,line{:});
        end
    end
    function obj=draw_cursor_barred(obj)
        line=obj.cursorRect;
        line={line(1) line(2) line(1) line(4) obj.cursorLineWidth};
        for s = 0:obj.sStereo
            Screen('SelectStereoDrawBuffer', obj.wdwPtr, s);
            Screen('DrawLine',obj.wdwPtr,obj.cursorLineColor,line{:});
        end
    end
    function obj=draw_cursor_boxed(obj)
        for s = 0:obj.sStereo
            Screen('SelectStereoDrawBuffer', obj.wdwPtr, s);
            Screen('FillRect', obj.wdwPtr, obj.cursorFillColor, obj.cursorRect);
            Screen('FrameRect', obj.wdwPtr, obj.cursorLineColor, obj.cursorRect, obj.cursorLineWidth);
        end
    end
    function obj=activate(obj)
        if obj.bActivateable
            obj.bActive=1;
        end
    end
    function obj=deactivate(obj)
        if obj.bActivateable
            obj.bActive=0;
        end
    end
%% MODIFY STR
    function obj=update_str(obj,text,pos)
        obj.text=text;
        obj.achar=pos+1;
    end
    %function obj=change_cursor_line(obj,lineNo)
    %    nlines=max([numel(obj.TEXT),1]);
    %    if lineNo > nlines
    %        lineNo=nlines;
    %    end
    %    if lineNo < 1
    %        lineNo=1;
    %    end
    %    obj.aline=lineNo;
    %end
    %function obj=change_cursor_charNo(obj,charNo)
    %    if ischar(charNo)
    %        charNo=num2str(charNo);
    %    end
    %    if isempty(obj.nchar)
    %        return
    %    end

    %    if charNo > obj.nchar(obj.aline)
    %        charNo=obj.nchar(obj.aline);
    %    end
    %    if charNo < 1
    %        charNo=1;
    %    end
    %    obj.achar=charNo;
    %end
    %function obj=change_char(obj,newChar)
    %    obj.TEXT{obj.aline}(obj.achar)=newChar;
    %end
    %function obj=insert_char(obj,newChar)
    %    s=obj.TEXT{obj.aline}(1:obj.achar-1);
    %    e=obj.TEXT{obj.aline}(obj.achar:end);
    %    obj.TEXT{obj.aline}=[s newChar e];
    %    obj.achar=obj.achar+1;
    %    obj.achar

    %end
    %function obj=insert_forward_char(obj,newChar)
    %    s=obj.TEXT{obj.aline}(1:obj.achar);
    %    e=obj.TEXT{obj.aline}(obj.achar+1:end);
    %    obj.TEXT{obj.aline}=[s newChar e];
    %end
    %function obj=append_char(obj,newChar)
    %    obj.TEXT{obj.aline}=[obj.TEXT{obj.aline} newChar];
    %end
    %function obj=delete_back_char(obj)
    %    if obj.achar==1
    %        return
    %    elseif obj.achar==2
    %        s=[];
    %    else
    %        s=1:obj.achar-2;
    %    end
    %    e=obj.achar:obj.nchar(obj.aline);
    %    line=obj.TEXT{obj.aline};
    %    obj.TEXT{obj.aline}=[line(s) line(e)];
    %end
    %function obj=delete_char(obj)
    %    n=obj.nchar(obj.aline);
    %    line=obj.TEXT{obj.aline};
    %    if obj.achar==1
    %        s=[];
    %    else
    %        s=line(1:obj.achar-1);
    %    end
    %    if obj.achar==n
    %        e=[];
    %    else
    %        e=line(obj.achar+1:n);
    %    end
    %    obj.TEXT{obj.aline}=[s e];
    %end
    %function obj=delete_line(obj)
    %    obj.TEXT(obj.aline)=[];
    %end
    %function obj=insert_line(obj,text)
    %    if obj.aline==1
    %        s=[];
    %    else
    %        s=obj.TEXT(1:obj.aline-1);
    %    end
    %    if obj.aline==obj.nlines
    %        e=[];
    %    else
    %        e=TEXT(obj.aline:obj.nlines);
    %    end
    %    obj.TEXT=[s; text; e];
    %end
end
end
