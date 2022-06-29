classdef Win3D < handle & Common3D & Point3D
% all about getting object dimensions around point
properties
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

end
properties(Dependent)
    WHm
    WHpix
    WHdeg    % vergence proper
    WHAM
    WHdegRaw % assuming cnetered
    WHAMRaw
end
properties(Hidden)
    Wm
    Hm

    Wpix
    Hpix

    Wdeg
    Hdeg

    WdegRaw
    HdegRaw

    WHmDep
    WHpixDep
    WHdegDep
    WHdegRawDep
end
properties(Hidden = true)
    bShapeNeedsInit=1;
    bCacheArgs=true
end
methods(Static)
    function P=getP_Win3D()
        P={...
            'WHm',       [], 'Num.is',   7;
            'WHpix',     [], 'Num.is',   8;
            'WHdeg',     [], 'Num.is',    9;
            'WHdegRaw',  [], 'Num.is', 10;
            'Wm',      [], [0,0.1,2000],11;
            'Hm',      [], [0,0.1,2000],11;
            'Wpix',      [], [0,0.1,2000],12;
            'Hpix',      [], [0,0.1,2000],12;

            'Wdeg',      [], [0,0.1,2000],13;
            'Hdeg',      [], [0,0.1,2000],13;

            'WdegRaw',      [], [0,0.1,2000],14;
            'HdegRaw',      [], [0,0.1,2000],14;

            ...
            'relRec',    [], 'Num.is_e', 0;
            'relPosPRC', [], 'ischar_e', 0;
        };
    end
    function P=getP()
        P1=Point3D.getP();
        P2=Win3D.getP_Win3D;
        P=[P1; P2];
    end
end
methods
    function obj=Win3D(varargin)
        if nargin < 1
            return
        end
        obj.bInit=true;
        %p={'VDisp','varargin'};
        p={'VDisp','varargin'};
        opts=Args.group(p,varargin);

        p=obj.getP();

        if obj.bCacheArgs
            global WIN3D_ARGS;
            if isempty(WIN3D_ARGS);
                [~,~,~,WIN3D_ARGS]=Args.parse(obj,p,opts);
            else
                WIN3D_ARGS.parse(obj,opts);
            end

        else
            Args.parse(obj,p,opts);
        end
        obj.bInit=false;
        obj.init_point();
        obj.init_shape();
    end
    function obj=init_shape(obj)
        bR=~isempty(obj.WHdegRaw);
        bD=~isempty(obj.WHdeg);
        bM=~isempty(obj.WHm);
        bP=~isempty(obj.WHpix);
        if ~bR && ~bD && ~bM && ~bP
            return
        elseif bR && ~bD && ~bM && ~bP
            obj.WHdegRaw=[];
        elseif  ~bR && ~bD && bM && ~bP
            obj.WHm=[];
        elseif ~bR && ~bD && ~bM && bP
            obj.WHpix=[];
        elseif ~bR && bD && ~bM && ~bP
            obj.WHdeg=[];
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
%% UPDATE
    % M
    function update_WHm_from_WHdegRaw(obj)
        obj.WHmDep=obj.deg2m(obj.WHdegRawDep); % obj.WHm
    end
    function obj=update_WHm_from_WHpix(obj)
        obj.WHmDep=obj.pix2m(obj.WHpixDep);
    end
    % PIX
    function obj=update_WHpix_from_WHm(obj)
        obj.WHpixDep=obj.m2pix(obj.WHmDep); % obj.WHpix
    end
    % RAW
    function obj=update_WHdegRaw_from_WHpix(obj)
        obj.WHdegRawDep=obj.pix2deg(obj.WHpix);
    end
    function obj=update_WHdegRaw_from_WHm(obj)
        obj.WHdegRawDep=obj.m2pix(obj.WHmDep);
    end

    % DEG
    function obj=update_WHdeg_from_WHm(obj)
        %obj.WHdegRawDep=obj.m2deg(obj.WHmDep); % obj.WHm
        % XXX
        %obj.WHdeg=vrsAndDistToVrg(obj.vrsXY,obj.posXYZm(3))
        %obj.Whdeg=vrsZW2arc(obj.vrsXY{3},obj.posXYZm(3),obj.WHm); %obj.WHdeg =
    end
    function obj=update_WHdegRaw_from_WHdeg(obj)
        % XXX
        error('write code');
        %obj.WHdegRaw =  % TODO, really hard
        %TODO really hard
    end
%%
% RELATIVE RECT
    function obj=get_xy_rel(obj)
        [obj.x,obj.y]=Shape3D.getXYrel(obj.relRec,obj.relPosPRC,obj.rect,obj.padXY);
    end

%% DEPS
    function out=get.WHpix(obj)
        out=obj.WHpixDep;
    end
    %%
    function out=get.WHdeg(obj)
        out=obj.WHdegDep;
    end
    function out=get.WHAM(obj)
        out=obj.WHdegDep*60;
    end
    %%
    function out=get.WHm(obj)
        out=obj.WHmDep;
    end
    %%
    function out=get.WHdegRaw(obj)
        out=obj.WHdegRawDep;
    end
    function out=get.WHAMRaw(obj)
        out=obj.WHdegRaw*60;
    end

%SET
    %%
    function set.WHpix(obj,val)
        if obj.bInit || nargin>=2
            if isnumeric(val)
                obj.WHpixDep=val;
            elseif ischar(val) && strcmp('@VDisp')
                obj.WHpixDep=obj.VDisp.WHpix;
            end
            return
        elseif nargin >=2 && ~isempty(val)
            if isnumeric(val)
                obj.WHpixDep=val;
            elseif ischar(val) && strcmp('@VDisp')
                obj.WHpixDep=obj.VDisp.WHpix;
            end
        end

        obj.update_WHm_from_WHpix();
        obj.update_WHdeg_from_WHm();
        obj.update_WHdegRaw_from_WHm();
    end

    function set.WHdeg(obj,val)
        if obj.bInit || (nargin >=2 && ~isempty(val))
            if ischar(val) && strcmp('@VDisp')
                val=obj.VDisp.WHpix./VDidsp.pixPerDegXY;
            end
            obj.WHdegDep=val;
            return
        end

        obj.update_WHdegRaw_from_WHdeg();
        obj.update_WHm_from_WHdegRaw();
        obj.update_WHpix_from_WHm();
    end
    function set.WHAM(obj,val)
        if nargin>=2 && ischar(val) && strcmp('@VDisp')
            val=obj.VDisp.WHpix./VDidsp.pixPerDegXY;
        end
        if nargin >=2 && ~isempty(val)
            obj.WHdegDep=val./60;
        end
        if obj.bInit; return; end

        obj.update_WHdegRaw_from_WHdeg();
        obj.update_WHm_from_WHdegRaw();
        obj.update_WHpix_from_WHm();
    end
    %%
    function set.WHm(obj,val)
        if nargin >=2 && ~isempty(val)
            obj.WHmDep=val;
        end
        if nargin >=2 && ischar(val) && strcmp('@VDisp')
            val=obj.VDisp.WHpix./obj.VDisp.pixPerMxy;
        end
        if obj.bInit; return; end

        obj.update_WHpix_from_WHm();
        obj.update_WHdegRaw_from_WHpix();
        %obj.update_WHdeg_from_WHpix(); XXX
    end
    %%
    function set.WHdegRaw(obj,val)
        if nargin >= 2 && ischar(val) && strcmp('@VDisp')
            val=obj.VDisp.WHpix./obj.VDisp.pixPerDeg;
        end
        if nargin >=2 && ~isempty(val)
            obj.WHdegRawDep=val;
        end
        if obj.bInit; return; end

        obj.update_WHm_from_WHdegRaw();
        obj.update_WHpix_from_WHm();
        %obj.update_WHdeg_from_WHm(obj); % XXX
    end
    function set.WHAMRaw(obj,val)
        if isempty(val); return; end
        if ischar(val) && strcmp('@VDisp')
            val=obj.VDisp.WHpix./obj.VDisp.pixPerDeg;
        end
        if nargin >=2 && ~isempty(val)
            obj.WHdegRawDep=val./60;
        end
        if obj.bInit; return; end

        obj.update_WHm_from_WHdegRaw();
        obj.update_WHpix_from_WHm();
        %obj.update_WHdeg_from_WHm(obj); % XXX
    end

end
methods(Static = true)
    function F=getPtch2WinInterp(winWHPix,PszRC,res)
    % ptch pix to win pix
        X=linspace(0,PszRC(2),res);
        Y=linspace(0,PszRC(1),res);
        Vx=linspace(0,winWHpix(1),res);
        Vy=linspace(0,winWHpix(2),res);
        F{1}=griddedInterpolant(X,Vx,'linear');
        F{2}=griddedInterpolant(Y,VY,'linear');
    end
    function F=getWin2PtchInterp(winWHPix,PszRC,res)
    % Win pix to patch pix
        X=linspace(0,winWHPix(1),res);
        Y=linspace(0,winWHPix(2),res);
        Vx=linspace(0,PszRC(2),res);
        Vy=linspace(0,PszRC(1),res);
        F{1}=griddedInterpolant(X,Vx,'linear');
        F{2}=griddedInterpolant(Y,Vy,'linear');
    end
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
end
end
