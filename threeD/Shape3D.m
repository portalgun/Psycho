classdef Shape3D < handle & Common3D & Point3D
% all about getting object dimensions around point
properties

    WHm
    WHpix
    WHdegRaw % assuming cnetered
    WHdeg    % vergence proper

    % T for set time in shape4D

    shape
    rect
    relRec
    relPosPRC

%% POINT3D
    %posXYZm
    %posXYpix %CPs
    %posXYpixRaw % if point had no depth

    %vrgXY
    %vrsXY
    %

end
properties(Dependent)
    WHbase
end
properties(Hidden = true)
    bShapeNeedsInit=1;
end
methods
    function obj=Shape3D(ptbORdisp,Opts)
        if ~exist('ptbORdisp','var') && ~exist('Opts','var')
            return
        end
        if ~exist('Opts','var') || isempty(Opts)
            Opts=struct();
        end

        obj=obj.input_parser_Shape3D(Opts);
        obj.update_display(ptbORdisp);
        obj.init_shape();
    end
    function input_parser_Shape3D(obj,Opts)
        p=[Point3D.get_parseOpts();...
           Shape3D.get_parseOpts()];
        obj=Args.parse(obj,p,Opts);
    end
    function obj=init_shape(obj)
        bR=~isempty(obj.WHdegRaw);
        bD=~isempty(obj.WHdeg);
        bM=~isempty(obj.WHm);
        bP=~isempty(obj.WHpix);
        if ~bR && ~bD && ~bM && ~bP
            return
        elseif bR && ~bD && ~bM && ~bP
            obj.set_WHdegRaw();
        elseif  ~bR && ~bD && bM && ~bP
            obj.set_WHm();
        elseif ~bR && ~bD && ~bM && bP
            obj.set_WHpix();
        elseif ~bR && bD && ~bM && ~bP
            obj.set_WHdeg();
        else
            error('unhanled Point3D combination. write code?');
        end
        obj.bShapeNeedsInit=0;
        %if isprop(obj,'ELIND') && isa(obj.ELIND,'elInd')
        %    obj.ELIND.update_shape_status(obj.t,obj.i,1);
        %end
    end
    function obj=clear_shape(obj)
        obj.points=[]; % used for construction, not Point3D
        obj.shape=[];

        obj.WHdegRaw=[]; % assuming cnetered
        obj.WHdeg=[];
        obj.WHm=[];
        obj.WHpix=[];

        obj.bShapeNeedsInit=1;
        %if isprop(obj,'ELIND') && isa(obj.ELIND,'elInd')
        %    obj.ELIND.update_shape_status(obj.t,obj.i,-1);
        %end
    end
% SET
    function update_WHm_from_WHdegRaw(obj)
        obj.WHm=obj.deg2m(obj.WHdegRaw); % obj.WHm
    end
    function obj=update_WHm_from_WHpix(obj)
        obj.WHm=obj.pix2m(obj.WHpix);
    end
%%
    function obj=update_WHpix_from_WHm(obj)
        obj.WHpix=obj.m2pix(obj.WHm); % obj.WHpix
    end
    function obj=update_WHdeg_from_WHm(obj)
        % XXX
        %obj.Whdeg=vrsZW2arc(obj.vrsXY{3},obj.posXYZm(3),obj.WHm); %obj.WHdeg =
    end
    function obj=update_WHdegRaw_from_WHm(obj)
        obj.WHdegRaw=obj.m2pix(obj.WHm);
    end
%%
    function obj=update_WHdegRaw_from_WHdeg(obj)
        % XXX
        error('write code');
        %obj.WHdegRaw =  % TODO, really hard
        %TODO really hard
    end
%%
    function obj=set_WHdegRaw(obj,val)
        if exist('val','var') && ~isempty(val)
            obj.WHdegRaw=val;
        if isequal(val,obj.WHdegRaw)
            return
        end
        end
        obj.update_WHm_from_WHdegRaw();
        obj.update_WHpix_from_WHm();
        %obj.update_WHdeg_from_WHm(obj);
    end
    function obj=set_WHm(obj,val)
        if exist('val','var') && ~isempty(val)
            obj.WHm=val;
        if isequal(val,obj.WHm)
            return
        end
        end
        obj.update_WHpix_from_WHm();
        obj.update_WHdeg_from_WHm();
        obj.update_WHdegRaw_from_WHm();

    end
    function obj=set_WHpix(obj,val)
        if exist('val','var') && ~isempty(val)
            obj.WHpix=val;
        if isequal(val,obj.WHpix)
            return
        end
        end
        obj.update_WHm_from_WHpix();
        obj.update_WHdeg_from_WHm();
        obj.update_WHdegRaw_from_WHm();
    end

    function obj=set_WHdeg(obj,val)
        if exist('val','var') && ~isempty(val)
            obj.WHdeg=val;
        if isequal(val,obj.WHdeg)
            return
        end
        end

        obj.update_WHdegRaw_from_WHdeg();
        obj.update_WHm_from_WHdegRaw();
        obj.update_WHpix_from_WHm();
    end
%%
% RELATIVE RECT
    function obj=get_xy_rel(obj)
        [obj.x,obj.y]=Shape3D.getXYrel(obj.relRec,obj.relPosPRC,obj.rect,obj.padXY);
    end

end
methods(Static = true)
    function obj=get(primitive)
        switch primitive
            case 'rect'
                obj=rect3D();
            case 'line'
                obj=line3D();
        end
    end
    function out=listParams()
        out={'WHdegRaw','WHdeg','WHm','WHpix'};
    end
%

    function rect=ctr2rect(posXYctr,width,height)
        x1=posXYctr(1)-width/2;
        x2=posXYctr(1)+width/2;
        y1=posXYctr(2)-height/2;
        y2=posXYctr(2)+height/2;
        rect=[x1 y1 x2 y2];
    end

% RELATIVE RECTS
    function [x,y]=getXYrel(relRec,relPosPRC,rect,padXYpix)
        % I/O -- 1
        if relPosPRC(1)=='I'
            [x,y]=Shape3D.getXYrelIn(relRec,relPosPRC(2:end),rect,padXYpix);
        elseif relPosPRC(1)=='O'
            [x,y]=Shape3D.getXYrelOut(relRec,relPosPRC(2:end),rect,padXYpix);
        end
    end
    function [x,y]=getXYrelIn(relRec,relPosRC,rect,padXYpix)
        % L T R B
        if relPosRC(1)=='T'
            y=relRec(2)+padXYpix(2);
        elseif relPosRC(1)=='B'
            y=relRec(4)-padXYpix(2)-rect(4);
        elseif relPosRC(1)=='M'
            y=relRec(2)+(relRec(4)-relRec(2))/2-rect(4)/2;
        end
        if relPosRC(2)=='L'
            x=relRec(1)+padXYpix(1);
        elseif relPosRC(2)=='R'
            x=relRec(3)-padXYpix(1)-rect(3);
        elseif relPosRC(2)=='M'
            x=relRec(1)+(relRec(3)-relRec(1))/2-rect(3)/2;
        end
    end
    function [x,y]=getXYrelOut(relRec,relPosRC,rect,padXYpix)
        % L T R B
        if relPosRC(1)=='T'
            y=relRec(2)-rect(4)-padXYpix(2);
        elseif relPosRC(1)=='B'
            y=relRec(4)+padXYpix(2);
        elseif relPosRC(1)=='M'
            y=relRec(2)+(relRec(4)-relRec(2))/2-rect(4)/2;
        end
        if relPosRC(2)=='L'
            x=relRec(1)-padXYpix(1)-rect(3);
        elseif relPosRC(2)=='R'
            x=relRec(3)+padXYpix(1);
        elseif relPosRC(2)=='M' || relPosRC(2)=='C'
            x=relRec(1)+(relRec(3)-relRec(1))/2-rect(3)/2;
        elseif relPosRC(2)=='B' %Right justified
            Wrel=(relRec(3)-relRec(1));
            W=(rect(3)-rect(1));
            x=relRec(1)-W+Wrel;
        end
    end
    %function out=input_parser(Opts)
    %    p=Shape3D.get_parseOpts();
    %    out=Args.parse([],p,Opts);

    %    out=Args.parse([],p,Opts);
    %    bXYZ=~isempty(out.WHm);
    %    bPix=~isempty(out.WHpix);
    %    bRaw=~isempty(out.WHdegRaw);
    %    bDeg=~isempty(out.WHdeg);

    %    modes = bXYZ + bDeg + bPix;
    %    if sum(modes) > 1
    %        error('Only one WH of xyz, vrg, or, pix can be defined');
    %    end
    %    if bRaw & bXYZ
    %        error('Only one WH of xyz or raw can be defined');
    %    end
    %end
    function p=get_parseOpts()
        p={...
               'WHdegRaw',[],...
               ;'WHdeg',[],...
               ;'WHm',[], ...
               ;'WHpix',[],...
               %;'anglesDeg',0,...
          };
    end
end
end
