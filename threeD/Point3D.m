classdef Point3D < handle & Common3D
% all about getting central object point
%
% conversions
% set 1, set them all
% no ptb stuff
%
% options:
% posXYZmDep
%   OR
% vrs & vrg
%   OR
% posXYpixDep
%   OR
% posXYpixRawDep & something else?
%   OR
% los & depthC [trgtXYZ, guide_Point3D, LorR]
properties(Dependent)
    % VDisp

    posXYZm
    posXYpix %CPs

    posXYpixRaw % if point had no depth

    vrgXY
    vrsXY

    los
    dist

end
properties(Hidden)
    posXYZmDep
    posXYpixDep %CPs

    posXYpixRawDep % if point had no depth

    vrgXYDep
    vrsXYDep

    losDep
    distDep

    LExyz
    RExyz
    IppZm
end
properties(Hidden = true)
    bPointNeedsInit=1;
    Los

    % auto

    Toggler
    LExyzSet
    RExyzSet

    bInit=true
end
properties(Access=private)
    Initiated=[];
    bCacheArgs=true
end
methods(Static)
    function P=getP()
        P ={...
            'VDisp',       [], '',1;
            ...
            'posXYZm',     [], '',2;
            'vrgXY',       [], '',3;
            'vrsXY',       [], '',3;
            'posXYpix',    [], '',4;
            'posXYpixRaw', [], '',5;
            'los',         [], '',0; % XXX
            'dist',        [], '',6;
            'IppZm',       [], '',0;
            'LExyz',       [], '',0;
            'RExyz',       [], '',0;
        };

    end
end
methods
    function out=copy(obj)

        flds={'posXYZmDep','posXYpixDep','posXYpixRawDep', 'vrgXYDep', 'vrsXYDep', 'losDep', 'distDep', 'LExyz', 'RExyz', 'IppZm'};
        if isa(obj,'Win3D')
            flds=[flds 'WHmDep','WHpixDep','WHdegDep','WHdegRawDep','shape','rect','relRec','relPosPRC'];
            out=Win3D();
        else
            out=Point3D();
        end

        out.VDisp=obj.VDisp;
        out.Los=obj.Los.copy();

        for i = 1:length(flds)
            out.(flds{i})=obj.(flds{i});
        end

    end
    function set(obj,fld,varargin)
        obj.(['set_' fld])(varargin{:});
    end
    function obj=Point3D(varargin)
        % p
        if nargin < 1
            return
        end
        p={'VDisp','varargin'};
        [opts]=Args.group(p,varargin);

        p=obj.getP();

        obj.bInit=true;
        if obj.bCacheArgs
            global POINT3D_ARGS;
            if isempty(POINT3D_ARGS);
                [~,~,~,POINT3D_ARGS]=Args.parse(obj,obj.getP,opts);
            else
                POINT3D_ARGS.parse(obj,opts);
            end

        else
            Args.parse(obj,obj.getP,opts);
        end
        %[~,~,obj.Toggler]=Args.parse(obj,obj.getP,opts);
        obj.bInit=false;

        obj.init_point();
    end
    function obj=clear_point(obj)
        obj.vrsXDep=[];
        obj.vrgXYDep=[];
        obj.posXYZmDep=[];
        obj.posXYpixRawDep=[];
        obj.posXYpixDep=[];
        obj.bPointNeedsInit=1;
        %if isprop(obj,'ELIND') && isa(obj.ELIND,'elInd')
            %obj.ELIND.update_point_status(obj.t,obj.i,-1);
        %end
    end
    function obj=init_point(obj)
        obj.Los=Los(obj.VDisp);

        bVs=~isempty(obj.vrsXYDep);
        bVr=~isempty(obj.vrgXYDep);
        bM=~isempty(obj.posXYZmDep);
        bR=~isempty(obj.posXYpixRawDep);
        bP=~isempty(obj.posXYpixDep);


        if ~bVs && ~bVr && ~bM  && ~bR && bP
            obj.posXYpix=[];
        elseif bVs && bVr && ~bM && ~bM && ~bR && ~bP
            obj.vrsXY=[];;
        elseif ~bVs && ~bVr &&  bM  && ~bR && ~bP
            obj.posXYZm=[];
        elseif ~bVs && ~bVr && ~bM  && bR && ~bP
            obj.posXYZmDep=[0 0 obj.VDisp.Zm];
            obj.posXYpixRaw=[];
        elseif ~bVs && ~bVr && ~bM  && ~bR && bP
            error('Unhandled combination')
        else
            error('unhanled Point3D combination. write code?');
        end
        obj.bPointNeedsInit=0;
        %if isprop(obj,'ELIND') && isa(obj.ELIND,'elInd')
        %    obj.ELIND.update_point_status(obj.t,obj.i,1);
        %end
    end
    function xyz_to_raw_pix(obj)
        % XXX?
        xyz=[obj.posXYZmDep(1:2),0];

        [L,R]=XYZ.back_project(obj.LExyz, ...
                               obj.RExyz, ...
                               obj.posXYZmDep,...
                               obj.VDisp.PP.C.Xm, ...
                               obj.VDisp.PP.C.Ym, ...
                               obj.IppZm, ...
                               obj.VDisp.PP.Xpix, ...
                               obj.VDisp.PP.Ypix);
        obj.posXYpixRawDep=flip(mean([L; R],1),2);
    end
    function raw_pix_to_xyz(obj)

        scrnCtr=(flip(obj.VDisp.XYpix,2)./2);
        posXYZmDepRaw=XYZ.forward_project(obj.LExyz,...
                                       obj.RExyz,...
                                       obj.posXYpixRawDep{1}-scrnCtr,...
                                       obj.posXYpixRawDep{2}-scrnCtr,...
                                       obj.VDisp.PP.C.Xm,...
                                       obj.VDisp.PP.C.Ym,...
                                       obj.IppZm,...
                                       obj.VDisp.PP.Xpix,...
                                       obj.VDisp.PP.Ypix);

        obj.posXYZmDep=[poxXYZmRaw(1:2) obj.posXYZmDep(3)];
    end
%%
    function pix_to_xyz(obj)
        obj.posXYZmDep=XYZ.forward_project(obj.LExyz, ...
                                        obj.RExyz,...
                                        obj.posXYpixDep{1},...
                                        obj.posXYpixDep{2},...
                                        obj.VDisp.PP.C.Xm,...
                                        obj.VDisp.PP.C.Ym,...
                                        obj.IppZm,...
                                        obj.VDisp.PP.Xpix,...
                                        obj.VDisp.PP.Ypix);
    end
    function obj=xyz_to_pix(obj)
        [L,R]=XYZ.back_project(obj.LExyz,...
                               obj.RExyz, ...
                               obj.posXYZmDep, ...
                               obj.VDisp.PP.C.Xm, ...
                               obj.VDisp.PP.C.Ym, ...
                               obj.IppZm, ...
                               obj.VDisp.PP.Xpix, ...
                               obj.VDisp.PP.Ypix);

        %[L,R]=obj.VDisp.PP.back_project(obj.posXYZmDep);
        obj.posXYpixDep{1}=flip(L,2);
        obj.posXYpixDep{2}=flip(R,2);
    end
    function obj=xyz_to_vrg_vrs(obj)
        [obj.vrgXYDep,obj.vrsXYDep]=XYZ.toVrgAngle(obj.posXYZmDep,obj.LExyz,obj.RExyz);
    end
    function obj=vrg_vrs_to_xyz(obj)
        %obj.posXYZmDep=XYZ.get_vrg_vrs(obj.vrgXYDep,obj.vrsXYDep,obj.VDisp.SubjInfo.LExyz,obj.VDisp.SubjInfo.RExyz);
        %% XXX

    end

%% GET
    function out=get.LExyz(obj)
        if isempty(obj.LExyz)
            out=obj.VDisp.SubjInfo.LExyz;
        else
            out=obj.LExyz;
        end
    end
    function out=get.RExyz(obj)
        if isempty(obj.RExyz)
            out=obj.VDisp.SubjInfo.RExyz;
        else
            out=obj.RExyz;
        end
    end
    function out=get.IppZm(obj)
        if isempty(obj.IppZm)
            out=obj.VDisp.Zm;
        else
            out=obj.IppZm;
        end
    end
    function out=get.vrsXY(obj)
        out=obj.vrsXYDep;
    end
    function out=get.vrgXY(obj)
        out=obj.vrgXYDep;
    end
    function out=get.posXYZm(obj)
        out=obj.posXYZmDep;
    end
    function out=get.posXYpix(obj)
        out=obj.posXYpixDep;
    end
    function out=get.posXYpixRaw(obj)
        out=obj.posXYpixRawDep;
    end
    function out=get.los(obj)
        out=obj.losDep;
    end
    function out=get.dist(obj)
        out=obj.distDep;
    end
%% SET
    function set.vrsXY(obj,val) %vrs
        if obj.bInit;
            obj.vrsXYDep=val;
            return;
        end
        if nargin>=2 && ~isempty(val)
            obj.vrsXYDep=val;
        end

        obj.vrg_vrs_to_xyz();
        obj.xyz_to_pix();
        obj.xyz_to_raw_pix();
        obj.distDep=norm(obj.posXYZmDep);
    end
    function set.vrgXY(obj,val) %vrg
        if obj.bInit;
            obj.vrgXYDep=val;
            return;
        end
        if nargin >= 2 && ~isempty(val)
            obj.vrgXYDep=val;
        end

        obj.vrg_vrs_to_xyz();
        obj.xyz_to_pix();
        obj.xyz_to_raw_pix();
        obj.distDep=norm(obj.posXYZmDep);
    end
    function set.posXYZm(obj,val)
        if obj.bInit
            obj.posXYZmDep=val;
            return
        end
        if nargin >= 2 && ~isempty(val)
            obj.posXYZmDep=val;
        end

        obj.xyz_to_vrg_vrs();
        obj.xyz_to_pix();
        obj.xyz_to_raw_pix();
        obj.distDep=norm(obj.posXYZmDep);
    end
    function set.posXYpixRaw(obj,val)
        if obj.bInit
            obj.posXYpixRawDep=val;
            return
        end
        if nargin >=2 && ~isempty(val)
            obj.posXYpixRawDep=val;
        end

        obj.raw_pix_to_xyz();
        obj.xyz_to_pix();
        obj.xyz_to_vrg_vrs();
        obj.distDep=norm(obj.posXYZmDep);
    end
    function set.posXYpix(obj,valL,valR)
        % XXX LSOW
        if nargin >=2 && ~isempty(valL)
            if isnumeric(valL)
                obj.posXYpixDep{1}=valL;
            elseif iscell(valL)
                obj.posXYpixDep{1}=valL{1};
            end
        end
        if nargin >=3 && ~isempty(valR)
            obj.posXYpixDep{2}=valR;
        elseif iscell(valL) && numel(valL) == 2
            obj.posXYpixDep{2}=valL{2};
        end
        if obj.bInit; return; end

        obj.pix_to_xyz();
        obj.xyz_to_vrg_vrs();
        obj.xyz_to_raw_pix();
        obj.distDep=norm(obj.posXYZmDep);
    end
    function set.los(obj,los,dist,varargin)
        obj.losDep=los;
        if obj.bInit; return; end

        if nargin < 2 || isempty(los)
            dist=obj.dist;
        end
        %varargin trgtXYZ, guide_Point3D, LorR
        obj.Los.getXYZ(los,dist,varargin{:});
        obj.posXYZmDep=obj.Los.posXYZm;

        obj.set.posXYZm(obj.posXYZmDep);
    end
    function set.dist(obj,dist,los,varargin)
        obj.distDep=dist;
        if obj.bInit; return; end

        if nargin < 2 || isempty(los)
            los=obj.losDep;
        else
            obj.losDep=los;
        end
        %varargin trgtXYZ, guide_Point3D, LorR
        obj.Los.getXYZ(los,dist,varargin{:});
        obj.posXYZmDep=obj.Los.posXYZm;

        obj.set.posXYZm(obj.posXYZmDep);
    end
%%
end
methods(Static = true)
    function out=listParams()
        out={'vrsXYDep','vrgXYDep','posXYZmDep','posXYpixRawDep','posXYpixDep'};
    end
    %function out=input_parser_all(Opts)
    %    p=Common3D.getP();
    %    [OptsC,OptsP]=structSplit(Opts,p(:,1));
    %    outC=Args.parse([],p,OptsC);

    %    outP=Point3D.input_parser(OptsP);
    %    out=structMerge(outP,outS);
    %end
    function out=input_parser(Opts)
        p=Point3D.getP;
        out=Args.parse([],p,Opts);
        bXYZ=~isempty(out.posXYZmDep);
        bVrs=~isempty(out.vrsXYDep);
        bVrg=~isempty(out.vrgXYDep);
        bPix=~isempty(out.posXYpixDep);
        bRaw=~isempty(out.posXYpixRawDep);

        modes=bXYZ + bVrg + bPix;
        if sum(modes) > 1
            error('Only one pos of xyz, vrg, or, pix can be defined');
        end
        if bRaw & bXYZ
            error('Only one pos of xyz or raw can be defined');
        end
        if bRaw & bVrg & bVrs
            error('When using raw, only one of vrg or vrs may be used');
        end
    end
end
end
