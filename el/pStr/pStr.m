classdef pStr < handle & PsyElObj & Cursor
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


    bHRel
    bWRel

    % THESE 2
    relPosHW % TODO
    relXYctr
    % OR
    relRec %position relative to another rect (not rectRaw)

    relPosPRC % In/Out Top/Bottom/Middle L/R/M

    % COMPUTED
    xRel
    yRel
    wRel
    hRel

    x
    y
end
properties(Hidden=true)
    TEXT=''

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
properties(Hidden)
    Viewer
    Ptb
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
    function obj=parser(obj,Opts,ptb)
        P=obj.getP();

        fg=obj.Ptb.wht;
        bg=obj.Ptb.blk;
        g=obj.Ptb.gry;

        obj=Args.parse(obj,P,Opts);
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
        if isempty(obj.font)
            obj.font=obj.Ptb.textFont;
        end
        if isempty(obj.fontSize)
            obj.fontSize=obj.Ptb.textSize;
        end

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
    function val=apply_prect(obj)
        if ~ischar(obj.relRec)
            return
        end
        out=regexp(obj.relRec,'([a-zA-Z]+)([0-9]*)','tokens','once');
        name=out{1};
        num=out{2};
        if ismember(name,{'display','VDisp','screen'})
            val=obj.Ptb.VDisp.WHpix;
        else
            obj.Viewer.Psy.get_rect(name,num);
        end
    end
    function obj=update_ptb(obj,ptb)
        obj.Ptb=ptb;
        obj.scrnXYpix=obj.Ptb.VDisp.WHpix;
        obj.wdwPtr=obj.Ptb.wdwPtr;
        obj.sStereo=double(obj.Ptb.bStereo);
    end
%% MAIN
    function get_tex(obj,~)
    end
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
        obj.TEXT=strsplit(obj.text,newline);
        obj.nlines=numel(obj.TEXT);
        obj.change_font();
        obj.get_rect_raw();
        obj.get_xy_rel();
        obj.get_rect_full();
        obj.get_border_rect();
        obj.restore_font();
    end
    function draw(obj,~)
        obj.draw_bg();
        obj.draw_text();
        obj.draw_frame();
        obj.run_cursor();
    end
    function close()
    end
%%
    function obj=get_rect_raw(obj)
        obj.H=[];
        obj.W=[];
        for i = 1:obj.nlines
            if isempty(obj.TEXT{i})
                obj.H(i,1)=obj.lineSpacing;
                obj.W(i,1)=1;
                continue
            end
            R=Screen('TextBounds',obj.wdwPtr,obj.TEXT{i},0,0);
            obj.H(i,1)=R(4)-R(2)+obj.lineSpacing;
            obj.W(i,1)=R(3)-R(1);
        end
        obj.rectRaw=[0 0 max(obj.W) sum(obj.H)];
    end
    function obj=get_xy_rel(obj)
        [obj.xRel,obj.yRel]=Shape3D.getXYrel(obj.relRec,obj.relPosPRC,obj.rectRaw,obj.padXY);
        % L T R B
        obj.hRel=obj.relRec(4)-obj.relRec(2);
        obj.wRel=obj.relRec(3)-obj.relRec(1);
    end
    function obj=get_rect_full(obj)
        if obj.bHRel
            obj.H(obj.H==max(obj.H))=obj.hRel;
        end
        if obj.bWRel
            obj.W(obj.W==max(obj.W))=obj.wRel;
            %obj.W=obj.wRel;
        end
        obj.rect=[obj.xRel obj.yRel obj.xRel+max(obj.W) obj.yRel+sum(obj.H)];
        obj.RECT=repmat(obj.rect,obj.nlines,1);
        H2=cumsum(obj.H(1:end));
        H1=[0; H2(1:end-1)];
        W1=zeros(obj.nlines,1);
        W2=obj.W;
        %[size(obj.RECT) size(W1) size(H1) size(W2) size(H2)]
        obj.RECT=obj.RECT + [ W1 H1 W2 H2 ];
    end
    function obj=get_border_rect(obj)
        obj.borderRect=obj.rect+[-obj.borderPad -obj.borderPad obj.borderPad obj.borderPad];
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
    function rect=get_rect_for_other(obj)
        rect=obj.rect;
       % obj.borderWidth
       % obj.lineSpacing
       %obj.padXY
       %obj.borderWidth
       %obj.lineSpacing
       %obj.borderPad
        %rect(1:2)=Rec.rect(1:2)
    end
    function obj=draw_text(obj)
    % L T R B
    %
        obj.change_font();

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
methods(Static)
    function P =getP()
        P={...
               'bHRel',0,'isbinary';...
               'bWRel',0,'isbinary';...
               'relPosPRC','IBR','ischar';...
               'relPosHW',[],'isnumeric'; ...
               'relXYctr',[],'isnumeric';...
                ...
               'relRec',[],'@(x) true';...
               'fgColor',[],'isnumeric_e';...
               'bgColor',[],'isnumeric_e';...
               'cursorLineColor',[],'isnumeric_e'; ...
               'cursorFillColor',[],'isnumeric_e'; ...
               'font',[],'ischar_e';...
               'fontSize',[],'isnumeric_e';...
                ...
               'padXY',[10 10],'isnumeric';...
               'lineSpacing',5,'isnumeric';...
               'borderColor',[],'isnumeric';...
               'borderWidth',1,'isnumeric';...
               'borderPad',10,'isnumeric';...
               'borderFill',[],'isnumeric';...
               'bActive',0,'isbinary';...
               'bActivateable',1,'isbinary'; ...
               'cursorStyle','box','ischar'; ...
               'cursorLineWidth',1,'isnumeric'; ...
        };
    end
end
end
