classdef pStr < handle & PsyElObj
% TODO
% show limited text x and y
%       vstart vwidth
% hide, restor , for entering new values
properties
    bActive=0
    bActivateable
    bRect=0
    bInit=1
    sep=0
    aline=1;

    posRel=1          %rel position from substr start (2x rel)
    %posRelStr         %position from start of string
    %posRelStrSubStart %

    subStr
    rectSubStr    % absolute
    rectCursor
    wPerChar

    %nCharStr
    %nCharSubStr
    %wStr
    %wSubStr

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

    Cursor
    KeyStr
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

        fg=obj.Ptb.wht;
        bg=obj.Ptb.blk;
        g=obj.Ptb.gry;

        [~,cOptsRaw]=Args.parseLoose(obj,obj.getP,Opts);
        cOptsRaw=Args.parse([],obj.getPCursor,cOptsRaw);
        if isempty(cOptsRaw.cursorLineColor)
            cOptsRaw.cursorLineColor=fg;
        end
        if isempty(cOptsRaw.cursorFillColor)
            cOptsRaw.cursorFillColor=g;
        end

        obj.Cursor=CursorEl(obj);
        flds=fieldnames(cOptsRaw);
        for i = 1:length(flds)
            fld=regexprep(flds{i},'^cursor','');
            fld(1)=lower(fld(1));
            obj.Cursor.(fld)=cOptsRaw.(flds{i});
        end

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
            %obj.text=regexprep(obj.text,['[^\s]' newline],[' ' newline]);
            if ~endsWith(obj.text,' ')
                obj.text=[obj.text ' ' ];
            end
        elseif isempty(obj.text)
            obj.exitflag=1;
            return
        end
        % L T R B
        obj.TEXT=strsplit(obj.text,newline,'CollapseDelimiters',false);
        if obj.bActive
            if isempty(obj.KeyStr)
                obj.bInit=true;
                obj.get_substr;
            end
            obj.apply_substr();
        end
        obj.nlines=numel(obj.TEXT);

        obj.change_font();

        obj.get_rect_raw();
        obj.get_xy_rel(); % SHAPE3D
        get_rect@PsyElObj(obj);
        obj.get_RECT();
        obj.get_border_rect();
        if obj.bActive
            obj.get_substr;
        end

        obj.restore_font();
    end
    function draw(obj,~)
        obj.change_font();
        if isempty(obj.RECT)
            return
        end
        for s = 0:obj.sStereo
            obj.select_stereo_buffer(s);
            obj.draw_bg();
            obj.draw_text();
            obj.draw_frame();
        end
        if obj.bActive
            if obj.sep == 1
                obj.Cursor.draw(obj.rectCursor);
            end
            if obj.bRect
%                obj.rectCursor
%                obj.rectSubStr
                obj.Cursor.draw(obj.rectSubStr,'box');
            end
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
        x=obj.rect(1)-obj.Ptb.cText.WSpc/2;
        %y=obj.rect(2);
        y=obj.rect(2)+obj.Ptb.cText.HTail;
        rect=[x y obj.rect(3) obj.rect(4)];
        obj.RECT=repmat(rect,obj.nlines,1);
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
        obj.posRel=1;
        obj.aline=1;
    end
    function activate(obj)
        if obj.bActivateable
            obj.bActive=1;
        end
    end
    function deactivate(obj)
        if obj.bActivateable
            obj.bActive=0;
        end
    end
    function inc_line(obj)
        last=obj.aline;
        while true
            obj.select_line(obj.aline+1);
            if contains(obj.TEXT{obj.aline},':') || last==obj.aline
                break
            end
            last=obj.aline;
        end
    end
%% SELECT
    function dec_line(obj)
        last=obj.aline;
        while true
            obj.select_line(obj.aline-1);
            if contains(obj.TEXT{obj.aline},':') || last==obj.aline
                break
            end
            last=obj.aline;
        end
    end
    function select_line(obj,aline)
        lastAline=obj.aline;
        obj.aline=aline;
        %str=obj.TEXT{obj.line};
        %if ischar(str)
        %    txt=strsplit(str,newline);
        %elseif iscell(str)
        %    txt=str;
        %end
        %len=length(txt);
        len=length(obj.TEXT);
        if obj.aline > len
            obj.aline=len;
        elseif obj.aline < 1
            obj.aline=1;
        end
        if obj.aline ~= lastAline
            obj.bInit=true;
            obj.get_substr();
        end
    end
%% SUBSTR
    function get_substr(obj)
        if isempty(obj.sep) || obj.sep==0
            obj.subStr=txt;
            obj.posRelStrSubStart=1;
            return
        end

        TXT=obj.TEXT{obj.aline};
        re=': *';
        spl=strsplit(strtrim(TXT),re,'DelimiterType','RegularExpression');

        N=cellfun(@length,spl);
        lenSeps=cellfun(@numel,regexp(TXT,re,'match'));
        if numel(lenSeps) < numel(N)
            lenSeps=[lenSeps 0];
        end
        lenFlds=N+lenSeps;

        if obj.sep==1
            s=1;
            pre='';
        else
            s=sum(lenFlds(1:obj.sep-1))+1;
            pre=TXT(1:s-1);
        end
        e=sum(lenFlds(1:obj.sep));
        cur=TXT(s:e);

        if length(lenFlds) > obj.sep
            post=TXT(e+1:end);
        else
            post='';
        end

        bCurs=obj.sep > 1; % XXX
        if obj.bInit
            width=e-s+1;
            width=e-s+1;
            if obj.sep==length(N)
                width=width+max(cellfun(@numel,obj.TEXT))-sum(lenFlds(1:end))-1;
            end
            obj.bInit=false;
            pos=length(cur)+1;
            obj.KeyStr=KeyStr('str',cur,pos,width-bCurs,pre,post);
            obj.wPerChar=obj.Wind(obj.aline)/length(TXT);
            obj.subStr=obj.KeyStr.get_str(true,bCurs);
            %disp('---')
            %disp([pre ':'])
            %disp([cur ':'])
            %disp([post ':'])
            %disp(obj.subStr)
        else
            obj.subStr=obj.KeyStr.get_str(true,bCurs);
        end
        obj.TEXT{obj.aline}=obj.subStr;

        posRelStr=s+obj.posRel-1;
        wSubStr=length(obj.subStr)*obj.wPerChar;

        %wStr=obj.Wind(obj.aline);
        %
        %nCharStr=length(obj.TEXT{obj.aline});

        x=obj.RECT(obj.aline,1);
        y=obj.RECT(obj.aline,2);
        h=obj.Hind(obj.aline);

        xRect=x+((s-1)          *obj.wPerChar);
        xCurs=x+((posRelStr-1)  *obj.wPerChar);
        obj.rectSubStr=[xRect, y, xRect+wSubStr, y+h];

        %obj.rectCursor=[xCurs, y, xCurs+obj.wPerChar, y+h];

        y1=y+h/3;
        y2=y+2*h/3;
        w=y2-y1;
        obj.rectCursor=[xCurs, y1, x+w, y2];
    end
    function apply_substr(obj)
        %obj.TEXT{obj.aline}=obj.subStr;
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
        };
        P=[P; PE];
    end
    function P=getPCursor()
        P={ ...
           'cursorLineColor',[],'isnumeric_e'; ...
           'cursorFillColor',[],'isnumeric_e'; ...
           'cursorStyle','box','ischar'; ...
           'cursorLineWidth',1,'isnumeric'; ...
        };
    end

end
end
