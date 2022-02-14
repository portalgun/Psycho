classdef pStr < handle & PsyElObj & Cursor
% TODO
% show limited text x and y
%       vstart vwidth
% hide, restor , for entering new values
properties
    text

    font
    fontSize
    bMonoSpace

    % TEXT
    fgColor
    bgColor
    padXY
    lineSpacing

    % BOX
    borderColor  % outer box
    borderFill   % inner box
    borderWidth  %
    borderPadXY    %inner border XY


    %- psyElObj
end
properties(Hidden=true)
    setH
    setW
    setX
    setY

    TEXT='' % FINAL
    RECT    % FINAL

    nlines
    borderRect % width of
    Wind %width of lines
    Hind %height of lines

    exitflag
end
methods
    function obj=pStr(Opts,ptb,Viewer,text)
        if nargin < 1 || isempty(Opts)
            Opts=struct();
        end
        if nargin >= 3
            obj.Viewer=Viewer;
        end
        if nargin >= 4
            obj.text=text;
        end
        obj.update_ptb(ptb);
        obj.parser(Opts);
    end
    function obj=parser(obj,Opts)
        P=obj.getP();

        fg=obj.Ptb.wht;
        bg=obj.Ptb.blk;
        g=obj.Ptb.gry;

        obj=Args.parse(obj,P,Opts);
        obj.setX=obj.X;
        obj.setY=obj.Y;
        obj.setW=obj.W;
        obj.setH=obj.H;

        if isempty(obj.relRec)
            obj.relRec=[0 0 obj.Ptb.VDisp.WHpix];
        end
        if isempty(obj.fgColor)
            obj.fgColor=fg;
        end
        if isempty(obj.bgColor)
            obj.bgColor=bg;
        end
        if isempty(obj.cursorLineColor)
            obj.cursorLineColor=fg;
        end
        if isempty(obj.cursorFillColor)
            obj.cursorFillColor=g;
        end

        %FONT
        if isempty(obj.font)
            obj.font=obj.Ptb.textFont;
        end
        if isempty(obj.fontSize)
            obj.fontSize=obj.Ptb.textSize;
        end
        obj.bMonoSpace=strcmp(obj.font,'Monospace');

        if ischar(obj.relRec)
            obj.apply_prect();
        elseif ~isempty(obj.relXYctr) &&~isempty(obj.relPosHW) && isempty(obj.relRec)
            obj.relRec=Shape3D.ctr2rect(obj.relXYctr,obj.relPosHW(2),obj.relPosHW(1));
        end

        if ~startsWith(obj.relPosPRC,'I') && ~startsWith(obj.relPosPRC,'O')
            error('relPosPRC must start with ''I'' or O''')
        end

        if numel(obj.fgColor) < 1
            obj.fgColor=repmat(obj.fgColor,1,3);
        end
        if numel(obj.bgColor) < 1
            obj.bgColor=repmat(obj.bgColor,1,3);
        end
        if ~isempty(obj.borderColor) &&  numel(obj.bgColor) < 1
            obj.borderColor=repmat(obj.borderColor,1,3);
        end
    end
%% MAIN
    function get_rect(obj,~)
        obj.exitflag=0;
        if isempty(obj.text) && obj.bActive
            obj.text= ' ';
        elseif obj.bActive
            obj.text=sed('s',obj.text,['[^\s]' newline],[' ' newline]);
            if ~endsWith(obj.text,' ')
                obj.text=[obj.text ' ' ];
            end
        elseif isempty(obj.text)
            obj.exitflag=1;
            return
        end
        % L T R B
        obj.TEXT=strsplit(obj.text,newline,'CollapseDelimiters',false);
        obj.nlines=numel(obj.TEXT);

        obj.change_font();

        obj.get_rect_raw();
        obj.get_xy_rel();
        get_rect@PsyElObj(obj);
        obj.get_RECT();
        obj.get_border_rect();

        obj.restore_font();
    end
    function draw(obj,~)
        obj.change_font();
        for s = 0:obj.sStereo
            obj.select_stereo_buffer(s);
            obj.draw_bg();
            obj.draw_text();
            obj.draw_frame();
            obj.run_cursor();
        end
        obj.restore_font();
    end
%% RECT
    function obj=get_rect_raw(obj)
        % H
        if isempty(obj.lineSpacing)
            vSpace=obj.Ptb.cText.H*0.3;
        else
            vSpace=obj.lineSpacing;
        end
        obj.Hind=ones(obj.nlines,1)*(obj.Ptb.cText.H+vSpace);

        if obj.bMonoSpace
            nChar=cellfun(@length,obj.TEXT)';
            obj.Wind=(obj.Ptb.cText.W.*nChar)+(obj.Ptb.cText.WSpc.*(nChar-1));
        else
            obj.Wind=zeros(obj.nlines,1);
            for i = 1:obj.nlines
                if isempty(obj.TEXT{i})
                    obj.Wind(i,1)=1;
                    continue
                end

                R=Screen('TextBounds',obj.Ptb.wdwPtr,obj.TEXT{i},0,0);
                obj.Wind(i,1)=R(3)-R(1);
            end
        end
        obj.W=max(obj.Wind);
        obj.H=sum(obj.Hind);
        obj.rectRaw=[0 0 max(obj.Wind) sum(obj.Hind)];
    end
    function get_RECT(obj);
        obj.RECT=repmat(obj.rect,obj.nlines,1);
        H2=cumsum(obj.Hind(1:end));
        H1=[0; H2(1:end-1)];
        W1=zeros(obj.nlines,1);
        W2=obj.Wind;
        obj.RECT=obj.RECT + [ W1 H1 W2 H2 ];
    end
    function obj=get_border_rect(obj)
        obj.borderRect=obj.rect+[-obj.borderPadXY -obj.borderPadXY obj.borderPadXY obj.borderPadXY];
    end
%% DRAW
    function obj=draw_bg(obj)
        if ~isempty(obj.borderFill)
            Screen('FillRect', obj.Ptb.wdwPtr, obj.borderFill, obj.borderRect);
        end
    end
    function obj=draw_frame(obj)
        if obj.borderWidth > 0
            Screen('FrameRect', obj.Ptb.wdwPtr, obj.borderColor, obj.borderRect, obj.borderWidth);
        end
    end
    function rect=get_rect_for_other(obj)
        rect=obj.rect;
       % obj.borderWidth
       % obj.lineSpacing
       %obj.padXY
       %obj.borderWidth
       %obj.lineSpacing
       %obj.borderPadXY
        %rect(1:2)=Rec.rect(1:2)
    end
    function obj=draw_text(obj)
        % NOTE, Drawformattedtext is just a wrapper
        % ASCI 10-13 do not work for newline
        for i = 1:obj.nlines
            Screen('DrawText',obj.Ptb.wdwPtr,obj.TEXT{i},obj.RECT(i,1),obj.RECT(i,2),obj.fgColor,obj.bgColor);
        end
    end
%% FONT
    function obj=change_font(obj)
        obj.Ptb.change_font(obj.font, obj.fontSize);
    end
    function obj=restore_font(obj)
        obj.Ptb.restore_font();
    end
%% CLEAR
    function obj=clear_text(obj)
        obj.text=[];
        obj.achar=1;
        obj.aline=1;
    end
end
methods(Static)
    function P =getP()
        PE=PsyElObj.getP();
        P={...
               'fgColor',[],'isnumeric_e';...
               'bgColor',[],'isnumeric_e';...
               'lineSpacing',[],'isnumeric';...
               'font',[],'ischar_e';...
               'fontSize',[],'isnumeric_e';...
                ...
               'padXY',[10 10],'isnumeric';...
                ...
               'borderPadXY',10,'isnumeric';...
               'borderColor',[],'isnumeric';...
               'borderWidth',1,'isnumeric';...
               'borderFill',1,'isnumeric';...
                ...
               'bActive',0,'isbinary';...
               'bActivateable',1,'isbinary'; ...
                ...
               'cursorLineColor',[],'isnumeric_e'; ...
               'cursorFillColor',[],'isnumeric_e'; ...
               'cursorStyle','box','ischar'; ...
               'cursorLineWidth',1,'isnumeric'; ...
        };
        P=[P; PE];
    end
end
end
