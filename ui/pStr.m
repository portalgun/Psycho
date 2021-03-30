classdef pStr < handle & Cursor
% TODO
% show limited text x and y
%       vstart vwidth
% hide, restor , for entering new values
properties
    text

    font
    fontSize
    fgColor
    bgColor
    padXY
    rectRaw
    rect

    offrect
    xAdvance

    lineSpacing
    borderColor
    borderWidth
    borderPad
    borderFill

    xRel
    yRel
    x
    y

    % THESE 2
    relPosHW % TODO
    relXYctr
    % OR
    relRec

    relPosPRC
    bHidden=0
end
properties(Hidden=true)
    TEXT

    nlines
    lineh % height of individual line
    start % where in Y to start drawing multiple
    borderRect % width of
    fullWidth % width of multiple line box
    Y %ystart of line
    X %xstart of line
    W %width of lines
    H %height of lines
    RECT

    wdwPtr
    sStereo
    scrnXYpix

    oldFont
    oldFontSize

    bFont
    bSize
    exitflag
end
methods
    function obj=pStr(Opts,ptb,text)
        if ~exist('Opts','var')
            Opts=struct();
        end
        if exist('text','var') && ~isempty(text)
            obj.text=text;
        end
        obj.parser(Opts,ptb);
        obj.update_ptb(ptb);
    end
    function obj=parser(obj,Opts,ptb)
        fg=ptb.wht;
        bg=ptb.blk;
        g=ptb.gry;
        names={...
               'bHidden',0,'isbinary';...
               'relRec',[0 0 ptb.display.scrnXYpix],'isnumeric';...
               'relPosPRC','IBR','ischar';...
               'relPosHW',[],'isnumeric'; ...
               'relXYctr',[],'isnumeric';...
               'fgColor',fg,'isnumeric';...
               'bgColor',bg,'isnumeric';...
               'font',ptb.textFont,'ischar';...
               'fontSize',ptb.textSize,'isnumeric';...
               'padXY',[10 10],'isnumeric';...
               'lineSpacing',5,'isnumeric';...
               'borderColor',[],'isnumeric';...
               'borderWidth',1,'isnumeric';...
               'borderPad',10,'isnumeric';...
               'borderFill',[],'isnumeric';...
               'bActive',0,'isbinary';...
               'bActivateable',1,'isbinary'; ...
               'cursorLineColor',fg,'isnumeric'; ...
               'cursorFillColor',g,'isnumeric'; ...
               'cursorStyle','box','ischar'; ...
               'cursorLineWidth',1,'isnumeric'; ...
        };
        obj=parse(obj,Opts,names);

        if ~isempty(obj.relXYctr) &&~isempty(obj.relPosHW) && isempty(obj.relRec)
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
    function obj=update_ptb(obj,ptb)
        obj.scrnXYpix=ptb.display.scrnXYpix;
        obj.wdwPtr=ptb.wdwPtr;
        obj.sStereo=double(ptb.bStereo);
    end
    function obj=init(obj)
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
        obj.TEXT=strsplit(obj.text,newline);
        obj.nlines=numel(obj.TEXT);
        obj.get_rect_raw();
        obj.get_xy_rel();
        obj.get_rect();
        obj.get_border_rect();
    end
    function obj=get_rect_raw(obj)
        for i = 1:obj.nlines
            R=Screen('TextBounds',obj.wdwPtr,obj.TEXT{i},0,0);
            obj.H(i,1)=R(4)-R(2)+obj.lineSpacing;
            obj.W(i,1)=R(3)-R(1);
        end
        obj.rectRaw=[0 0 max(obj.W) sum(obj.H)];
    end
    function obj=get_xy_rel(obj)
        [obj.xRel,obj.yRel]=Shape3D.getXYrel(obj.relRec,obj.relPosPRC,obj.rectRaw,obj.padXY);
    end
    function obj=get_rect(obj)
        obj.rect=[obj.xRel obj.yRel obj.xRel+max(obj.W) obj.yRel+sum(obj.H)];
        obj.RECT=repmat(obj.rect,obj.nlines,1);
        H2=cumsum(obj.H(1:end));
        H1=[0; H2(1:end-1)];
        W1=zeros(obj.nlines,1);
        W2=obj.W;
        obj.RECT=obj.RECT + [ W1 H1 W2 H2 ];
    end
    function obj=get_border_rect(obj)
        obj.borderRect=obj.rect+[-obj.borderPad -obj.borderPad obj.borderPad obj.borderPad];
    end
    function obj=draw(obj)
        obj.init();
        if obj.exitflag
            return
        end

        obj.draw_bg();
        obj.draw_text();
        obj.draw_frame();
        obj.run_cursor();

    end
    function obj=draw_bg(obj)
        if ~isempty(obj.borderFill)
            for s = 0:obj.sStereo
                Screen('SelectStereoDrawBuffer', obj.wdwPtr, s);
                Screen('FillRect', obj.wdwPtr, obj.borderFill, obj.borderRect);
            end
        end
    end
    function obj=draw_frame(obj)
        if ~isempty(obj.borderWidth) && ~isempty(obj.borderColor) && obj.borderWidth > 0
            for s = 0:obj.sStereo
                Screen('SelectStereoDrawBuffer', obj.wdwPtr, s);
                Screen('FrameRect', obj.wdwPtr, obj.borderColor, obj.borderRect, obj.borderWidth);
            end
        end
    end
    function obj=draw_text(obj)
    % L T R B
    %
        obj.change_font();

        obj.RECT;
        for i = 1:obj.nlines
        for s = 0:obj.sStereo
            Screen('SelectStereoDrawBuffer', obj.wdwPtr, s);
            Screen('DrawText',obj.wdwPtr,obj.TEXT{i},obj.RECT(i,1),obj.RECT(i,2),obj.fgColor,obj.bgColor);
        end
        end
        obj.restore_font();
    end
    function obj=change_font(obj)
        curFont=Screen('TextFont',obj.wdwPtr);
        curSize=Screen('TextSize',obj.wdwPtr);
        obj.bFont=0;
        if strcmp(obj.font,curFont)
            obj.oldFont=curFont;
            Screen('TextFont',obj.wdwPtr,obj.font);
            obj.bFont=1;
        end

        obj.bSize=0;
        if ~isequal(obj.fontSize,curSize)
            obj.oldFontSize=curSize;
            Screen('TextSize',obj.wdwPtr,obj.fontSize);
            obj.bSize=1;
        end
    end
    function obj=restore_font(obj)
        if obj.bFont
            Screen('TextFont',obj.wdwPtr,obj.oldFont);
            obj.oldFont=[];
        end
        if obj.bSize
            Screen('TextSize',obj.wdwPtr,obj.oldFontSize);
            obj.oldFontSize=[];
        end
    end
    function obj=clear_text(obj)
        obj.text=[];
        obj.achar=1;
        obj.aline=1;
    end
end
end
