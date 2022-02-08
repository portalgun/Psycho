classdef Ch < handle
% large shapes first, then small shapes, then reticles
properties
    parts
    % '+','X','o','O'
    % 's' - small square
    % 'S' = large square
    % 'o' - small circle
    % 'O' = large circle
    % '+' = cardinal crosshair
    % 'x' = ordninal crosshair
    % 'xr' = ordninal crosshair at rect corners
    % '#' = birect
    % '\' = bars, how many you want

    posXY
    plateRadius
    plateShape
    bgColor

    retLength
    retWidth
    retColor

    outRadius
    outWidth
    outColor

    inRadius
    inWidth
    inColor


    prect
    units
    % TODO
    % units
    % shape3D
    % point3D
    % expand opts? -> combine each of color width and radius
end
properties(Hidden=true)
    pixPerDegXY
    wdwPtr
    wdwXYpix
    bStereo

    nbars
    bPlate=0;
    children
%POINTS
    % CARDINAL
    iU
    iD
    iL
    iR

    oU
    oD
    oL
    oR

    % ORDINALS
    irUL
    irUR
    irDL
    irDR

    orUL
    orUR
    orDL
    orDR

    icUL
    icUR
    icDL
    icDR

    ocUL
    ocUR
    ocDL
    ocDR

% LINES
    %CARDINAL
    lU
    lD
    lL
    lR

    %ORDINAL
    lcUR
    lcUL
    lcDR
    lcDL

    lrUR
    lrUL
    lrDR
    lrDL
% RECTS
    irect
    orect

end
properties(Hidden)
    Ptb
    Viewer
end
methods
    function [obj]  = Ch(Opts,ptb,Viewer)
        if nargin >= 3
            obj.Viewer=Viewer;
        end
        obj.update_ptb(ptb);
        obj.parse_Opts(Opts);
        obj.init();
    end
    function obj=init(obj)
        obj.apply_units();
        obj.proc_colors();
        obj.get_parts();
        obj.get_children();
    end
    function obj=update_ptb(obj,ptb)
        obj.Ptb=ptb;
        obj.wdwXYpix=obj.Ptb.VDisp.WHpix;
        obj.wdwPtr=obj.Ptb.wdwPtr;
        obj.pixPerDegXY=obj.Ptb.VDisp.pixPerDegXY;
        obj.bStereo=double(ptb.bStereo);
    end
    function parse_Opts(obj,Opts)
        posXYdef=obj.Ptb.VDisp.WHpix/2;
        def=repmat(obj.Ptb.wht,1,3);
        defbg=repmat(obj.Ptb.gry,1,3);
        names={...
            'units','deg','ischar';...
            'posXY',posXYdef,'Num.is';...
            'parts',{'+','x','o','O'},[];... % XXX
            'bgColor',defbg,'Num.is'; ...

            'plateRadius',[6 6],'Num.is'; ...
            'plateShape','rect','ischar'; ...

            'retLength',4,'Num.is'; ... % XXX
            'retWidth',.15,'Num.is'; ...
            'retColor',def,'Num.is'; ...

            'outRadius',[4 4],'Num.is'; ...
            'outWidth',.25,'Num.is'; ...
            'outColor',def,'Num.is';...

            'inRadius',[3 3],'Num.is'; ...
            'inWidth',.25,'Num.is'; ...
            'inColor',def,'Num.is'...
        };
        obj=Args.parse(obj,names,Opts);
        if all(obj.plateRadius > 0)
            obj.bPlate=1;
        end
    end
    function obj=apply_units(obj)
        if strcmp(obj.units,'deg')
            val=1.*obj.pixPerDegXY;
        elseif strcmp(obj.units,'arcmin')
            val=60.*(obj.pixPerDegXY);
        elseif strcmp(obj.units,'pixels')
            val=1;
        end
        flds={'plateRadius','retLength','retWidth','outRadius','outWidth','inRadius','inWidth'};
        for i = 1:length(flds)
            fld=flds{i};
            if numel(obj.(fld))==1
                obj.(fld)=repmat(obj.(fld),1,2);
            end
            obj.(fld)=obj.(fld).*val;
        end
    end
    function obj=proc_colors(obj)
        flds={'bgColor','retColor','outColor','inColor'};
        for i = 1:length(flds)
            fld=flds{i};
            if numel(obj.(fld))==1
                obj.(fld)=repmat(obj.(fld),1,3);
            end
        end
    end
    function obj=get_parts(obj)
        obj.get_points();
        obj.get_lines();
        obj.get_rects();
    end
    function [obj]  = get_children(obj)
        obj.children={{1,'plate',obj.plateShape,obj.bgColor,obj.prect}};
        if isempty(obj.parts) || ischar(obj.parts) && strcmp(obj.parts,'none')
            return
        end
        obj.nbars=sum(ismember(obj.parts,'|'));
        for i = 1:length(obj.parts)
            %opts=obj.childOpts{i}
            type=obj.parts{i};
            if length(obj.parts)==1
                Opts=struct(obj);
                if iscell(Opts.parts)
                    Opts.parts=Opts.parts{1};
                end
            else
                Opts=structSelect(obj,length(obj.parts),i,1);
            end
            %opts=rmfield(Opts,'ch');
            switch type
            case {'s'}
                out=obj.get_inner_square(i);
            case {'S'}
                out=obj.get_outer_square(i);
            case {'o'}
                out=obj.get_inner_circle(i);
            case {'O'}
                out=obj.get_outer_circle(i);
            case {'+'}
                out=obj.get_reticles_cross(i);
            case {'x'}
                out=obj.get_reticles_x(i);
            case {'xr'}
                out=obj.get_reticles_x_rect(i);
            case {'#'}
                out=out.obj.get_reticles_biRect(i);
            otherwise
                if all(ismember(type,'|'))
                    obj.nbars=sum(ismember(type,'|'));
                    out=obj.get_bars(obj.nbars);
                else
                    error(['Undefined cross type ' type])
                end
            end


            out=transpose(out);
            obj.children=[obj.children; out];
        end
    end
    function obj=draw(obj,~)
        for k = 1:length(obj.children)
            c=obj.children{k};
            switch c{3}
            case 'line'
                obj.draw_line(c{4},c{5});
            case 'oval'
                obj.draw_oval(c{4},c{5});
            case {'rect','rect','sq','square'}
                obj.draw_rect(c{4},c{5});
            otherwise
                error(['Unhandled shape ' c{3} ]);
            end
        end
    end
end
methods(Access = private)
    function out=get_inner_square(obj,i)
    % L T R B
        W=obj.inWidth/2;
        rect=obj.irect;
        out{1}={i,'s','rect',obj.inColor,obj.rect_out(rect,W)};
        out{2}={i,'s','rect',obj.bgColor,obj.rect_in(rect,W)};
    end
    function out=get_outer_square(obj,i)
        W=obj.outWidth/2;
        rect=obj.orect;
        out{1}={i,'S','rect',obj.outColor,obj.rect_out(rect,W)};
        out{2}={i,'S','rect',obj.bgColor,obj.rect_in(rect,W)};
    end
    function out=get_inner_circle(obj,i)
        W=obj.inWidth/2;
        rect=obj.irect;
        out{1}={i,'o','oval',obj.inColor,obj.rect_out(rect,W)};
        out{2}={i,'o','oval',obj.bgColor,obj.rect_in(rect,W)};
    end
    function out=get_outer_circle(obj,i)
        W=obj.outWidth/2;
        rect=obj.orect;

        out{1}={i,'O','oval',obj.outColor, obj.rect_out(rect,W)};
        out{2}={i,'O','oval',obj.bgColor  ,obj.rect_in(rect,W)};
    end
    function out=get_reticles_cross(obj,i)
        r1=[obj.lU obj.retWidth(1)];
        r2=[obj.lD obj.retWidth(1)];
        r3=[obj.lL obj.retWidth(2)];
        r4=[obj.lR obj.retWidth(2)];

        out{1}={i,'+','line',obj.retColor,r1};
        out{2}={i,'+','line',obj.retColor,r2};
        out{3}={i,'+','line',obj.retColor,r3};
        out{4}={i,'+','line',obj.retColor,r4};
    end
    function out=get_reticles_x(obj,i)
        W=sqrt(sum(obj.retWidth.^2));
        r1=[obj.lcUR  W];
        r2=[obj.lcUL  W];
        r3=[obj.lcDR  W];
        r4=[obj.lcDL  W];

        out{1}={i,'x','line',obj.retColor,r1};
        out{2}={i,'x','line',obj.retColor,r2};
        out{3}={i,'x','line',obj.retColor,r3};
        out{4}={i,'x','line',obj.retColor,r4};
    end
    function out=get_reticles_x_rect(obj,i)
        r1=[obj.lrUR obj.retWidth(1)];
        r2=[obj.lrUL obj.retWidth(1)];
        r3=[obj.lrDR obj.retWidth(1)];
        r4=[obj.lrDL obj.retWidth(1)];

        out{1}={i,'xr','line',obj.retColor,r1}; % XXX
        out{2}={i,'xr','line',obj.retColor,r2};
        out{3}={i,'xr','line',obj.retColor,r3};
        out{4}={i,'xr','line',obj.retColor,r4};
    end
    function obj=get_reticles_biRect(obj)
        % TODO
    end
    function obj=get_bars(obj)
        % TODO
    end
%% points
    function obj=get_points(obj)
        get_inner_cardinals_points(obj);
        get_outer_cardinals_points(obj);
        get_inner_ordinals_rec_points(obj);
        get_outer_ordinals_rec_points(obj);
        get_inner_ordinals_circ_points(obj);
        get_outer_ordinals_circ_points(obj);
    end
    function obj=get_inner_cardinals_points(obj)
        [obj.iU,obj.iD,obj.iL,obj.iR]=Rec.cardinals(obj.posXY(1),obj.posXY(2),obj.inRadius(1),obj.inRadius(2));
    end
    function obj=get_outer_cardinals_points(obj)
        [obj.oU,obj.oD,obj.oL,obj.oR]=Rec.cardinals(obj.posXY(1),obj.posXY(2),obj.outRadius(1),obj.outRadius(2));
    end
    function obj=get_inner_ordinals_rec_points(obj)
        [obj.irUR,obj.irUL,obj.irDL,obj.irDR]=Rec.ordinals(obj.posXY(1),obj.posXY(2),obj.inRadius(1),obj.inRadius(2));
    end
    function obj=get_outer_ordinals_rec_points(obj)

        [obj.orUR,obj.orUL,obj.orDL,obj.orDR]=Rec.ordinals(obj.posXY(1),obj.posXY(2),obj.outRadius(1),obj.outRadius(2));

    end
    function obj=get_inner_ordinals_circ_points(obj)
        [obj.icUR,obj.icUL,obj.icDL,obj.icDR]=Circ.ordinals(obj.posXY(1),obj.posXY(2),obj.inRadius(1),obj.inRadius(2));
    end
    function obj=get_outer_ordinals_circ_points(obj)
        [obj.ocUR,obj.ocUL,obj.ocDL,obj.ocDR]=Circ.ordinals(obj.posXY(1),obj.posXY(2),obj.outRadius(1),obj.outRadius(2));
    end
%% lines
    function obj=get_lines(obj)
        % X1 Y1 X2 Y2 W & cell so line{:}
        obj.get_cardinal_lines();
        obj.get_ordinal_lines_circ();
        obj.get_ordinal_lines_rect();
    end
    function obj=get_cardinal_lines(obj)
        obj.lU=num2cell([obj.iU obj.oU]);
        obj.lD=num2cell([obj.iD obj.oD]);
        obj.lL=num2cell([obj.iL obj.oL]);
        obj.lR=num2cell([obj.iR obj.oR]);
    end
    function obj=get_ordinal_lines_circ(obj)
        obj.lcUR=num2cell([obj.icUR obj.ocUR]);
        obj.lcUL=num2cell([obj.icUL obj.ocUL]);
        obj.lcDR=num2cell([obj.icDR obj.ocDR]);
        obj.lcDL=num2cell([obj.icDL obj.ocDL]);
    end
    function obj=get_ordinal_lines_rect(obj)
        obj.lrUR=num2cell([obj.irUR obj.orUR]);
        obj.lrUL=num2cell([obj.irUL obj.orUL]);
        obj.lrDR=num2cell([obj.irDR obj.orDR]);
        obj.lrDL=num2cell([obj.irDL obj.orDL]);
    end

%% %rect
    function obj = get_rects(obj)
        % L T R B
        obj.get_inner_rect();
        obj.get_outer_rect();
        if obj.bPlate
            obj.get_plate_rect();
        end
    end
    function obj = get_inner_rect(obj)
        obj.irect=obj.psyRect(fliplr(obj.posXY),obj.inRadius(2),obj.inRadius(1));
    end
    function obj = get_outer_rect(obj)
        obj.orect=obj.psyRect(fliplr(obj.posXY),obj.outRadius(2),obj.outRadius(1));
    end
    function obj= get_plate_rect(obj)
        obj.prect=obj.psyRect(fliplr(obj.posXY),obj.plateRadius(2),obj.plateRadius(1));
    end
%% draw
    function obj=draw_rect(obj,color,rect)
        for s = 0:obj.bStereo
            Screen('SelectStereoDrawBuffer', obj.wdwPtr, s);
            Screen('FillRect',obj.wdwPtr,color,rect);
        end
    end
    function obj=draw_oval(obj,color,rect)
        for s = 0:obj.bStereo
            Screen('SelectStereoDrawBuffer', obj.wdwPtr, s);
            Screen('FillOval',obj.wdwPtr,color,rect);
        end
    end
    function obj=draw_line(obj,color,line)
        for s = 0:obj.bStereo
            Screen('SelectStereoDrawBuffer', obj.wdwPtr, s);
            Screen('DrawLine',obj.wdwPtr,color,line{:});
        end
    end

    function rect=psyRect(obj,ImCtrRC,h,w)
        t=ImCtrRC(:,1)-h;
        b=ImCtrRC(:,1)+h;
        r=ImCtrRC(:,2)+w;
        l=ImCtrRC(:,2)-w;
        rect=[l,t,r,b];
    end
    function out=rect_in(obj,rect,W)
        out=[rect(1)+W(1), rect(2)+W(2) rect(3)-W(1) rect(4)-W(2)];
    end
    function out=rect_out(obj,rect,W)
        out=[rect(1)-W(1), rect(2)-W(2) rect(3)+W(1) rect(4)+W(2)];
    end
end
end
