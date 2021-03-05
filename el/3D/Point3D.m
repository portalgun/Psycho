classdef Point3D < handle & Common3D
% all about getting central object point
%
% conversions
% set 1, set them all
% no ptb stuff
%
% options:
% posXYZm
%   OR
% vrs & vrg
%   OR
% posXYpix
%   OR
% posXYpixRaw & something else?
properties

    posXYZm
    posXYpix %CPs
    posXYpixRaw % if point had no depth

    vrgXY
    vrsXY

%% COMMON3D
    %LExyz=-0.065/2
    %RExyz=0.065/2
    %IPDm=0.065
    %IppXm
    %IppYm
    %IppZm
    %IppXpix
    %IppYpix

    %wdwXYpix
    %scrnCtr
    %bStereo

    %pixPerDeg
    %pixPerM
    %MperDeg

end
properties(Hidden = true)
    bPointNeedsInit=1;
end
methods
    function obj=Point3D(ptbORdisp,Opts)
        if ~exist('ptbORdisp','var') && ~exist('Opts','var')
            return
        end

        if ~exist('Opts','var') || isempty(Opts)
            Opts=struct();
        end

        obj.update_display(ptbORdisp);
        obj=obj.input_parser_Point3D_p(Opts);
        obj.init_point();
    end
    function obj=input_parser_Point3D_p(obj,Opts)
        out=Point3D.input_parser(Opts);
        flds=fieldnames(out);
        for i = 1:length(flds)
            fld=flds{i};
            if ~isempty(out.(fld))
                obj.(fld)=out.(fld);
            end
        end
    end
    function obj=clear_point(obj)
        obj.vrsX=[];
        obj.vrgX=[];
        obj.posXYZ=[];
        obj.posXYpixRaw=[];
        obj.posXYpix=[];
        obj.bPointNeedsInit=1;
        if isprop(obj,'ELIND') && isa(obj.ELIND,'elInd')
            obj.ELIND.update_point_status(obj.t,obj.i,-1);
        end
    end
    function obj=init_point(obj)
        bVs=~isempty(obj.vrsXY);
        bVr=~isempty(obj.vrgXY);
        bM=~isempty(obj.posXYZm);
        bR=~isempty(obj.posXYpixRaw);
        bP=~isempty(obj.posXYpix);


        if ~bVs & ~bVr & ~bM  & ~bR & bP
            return
        elseif bVs & bVr & ~bM & ~bM & ~bR & ~bP
            obj.set_vrsXY();
        elseif ~bVs & ~bVr &  bM  & ~bR & ~bP
            obj.set_posXYZm();
        elseif ~bVs & ~bVr & ~bM  & bR & ~bP
            obj.posXYZm=[0 0 obj.IppZm];
            obj.set_posXYpixRaw();
        elseif ~bVs & ~bVr & ~bM  & ~bR & bP
            obj.set_posXYpix();
        else
            error('unhanled Point3D combination. write code?');
        end
        obj.bPointNeedsInit=0;
        if isprop(obj,'ELIND') && isa(obj.ELIND,'elInd')
            obj.ELIND.update_point_status(obj.t,obj.i,1);
        end
    end
%%
   function obj=xyz_to_raw_pix(obj)
        xyz=[obj.posXYZm(1:2),0];

        [IppXm,IppYm,IppZm]=obj.get_pp();
        [IppXpix,IppYpix]=obj.get_pp_pix();
        [obj.posXYpixRaw]=XYZ.back_project(obj.LExyz,obj.RExyz,obj.posXYZm,IppXm,IppYm,IppZm,IppXpix,IppYpix);
   end
   function obj=raw_pix_to_xyz(obj)
        [IppXm,IppYm,IppZm]=obj.get_pp();
        [IppXpix,IppYpix]=obj.get_pp_pix();
        posXYZmRaw=forward(obj.LExyz,obj.RExyz,posPixRaw,posPixRaw,IppXm,IppYm,IppZm,IppXpix,IppYpix);
        obj.posXYZm=[poxXYZmRaw(1:2) obj.posXYZm(3)];
    end
%%
    function obj=pix_to_xyz(obj)
        [IppXm,IppYm,IppZm]=obj.get_pp();
        [IppXpix,IppYpix]=obj.get_pp_pix();
        obj.posXYZm=forward_project(obj.LExyz,obj.RExyz,obj.posPix{1},posPix{2},IppXm,IppYm,IppZm,IppXpix,IppYpix);
    end
    function obj=xyz_to_pix(obj)
        [IppXm,IppYm,IppZm]=obj.get_pp();
        [IppXpix,IppYpix]=obj.get_pp_pix();
        [obj.posXYpix{1},obj.posXYpix{2}] =XYZ.back_project(obj.LExyz,obj.RExyz,obj.posXYZm,IppXm,IppYm,IppZm,IppXpix,IppYpix);
    end
    function obj=xyz_to_vrg_vrs(obj)
        [obj.vrgXY,obj.vrsXY]=XYZ.get_vrg_vrs_map(obj.posXYZm,obj.LExyz,obj.RExyz);
    end
    function obj=vrg_vrs_to_xyz(obj)
        obj.posXYZm=XYZ.get_vrg_vrs_map(obj.vrgXY,obj.vrsXY,obj.LExyz,obj.RExyz);

    end

%%
%% SET
    function obj=set_vrsXY(obj,val) %vrs
        if exist('val','var') && ~isempty(val)
            obj.vrsXY=val;
        end

        obj.vrg_vrs_to_xyz();
        obj.xyz_to_pix();
        obj.xyz_to_raw_pix();
    end
    function obj=set_vrgXY(obj,val) %vrg
        if exist('val','var') && ~isempty(val)
            obj.vrgXY=val;
        end

        obj.vrg_vrs_to_xyz();
        obj.xyz_to_pix();
        obj.xyz_to_raw_pix();
    end
    function obj=set_posXYZm(obj,val)
        if exist('val','var') && ~isempty(val)
            obj.posXYZm=val;
        end

        obj.xyz_to_vrg_vrs();
        obj.xyz_to_pix();
        obj.xyz_to_raw_pix();
    end
    function obj=set_posXYpixRaw(obj,val)
        if exist('val','var') && ~isempty(val)
            obj.posXYpixRaw=val;
        end
        obj.raw_to_xyz();
        obj.xyz_to_pix();
        obj.xyz_to_vrg_vrs_to();
    end
    function obj=set_posXYpix(obj,valL,valR)
        if exist('valL','var') && ~isempty(valL)
            obj.posXYpix{1}=valL;
        end
        if exist('valR','var') && ~isempty(valR)
            obj.posXYpix{2}=valR;
        end

        obj.pix_to_xyz();
        obj.xyz_to_vrg_vrs();
        obj.xyz_to_raw_pix();
    end
%%
end
methods(Static = true)
    function out=listParams()
        out={'vrsXY','vrgXY','posXYZm','posXYpixRaw','posXYpix'};
    end
    function out=input_parser_all(Opts)
        p=Common3D.get_parseOpts();
        [OptsC,OptsP]=structSplit(Opts,p(:,1));
        outC=parse([],OptsC,p);

        outP=Point3D.input_parser(OptsP);
        out=structMerge(outP,outS);
    end
    function out=input_parser(Opts)
        p=Point3D.get_parseOpts;
        out=parse([],Opts,p);
        bXYZ=~isempty(out.posXYZm);
        bVrs=~isempty(out.vrsXY);
        bVrg=~isempty(out.vrgXY);
        bPix=~isempty(out.posXYpix);
        bRaw=~isempty(out.posXYpixRaw);

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
    function p=get_parseOpts()
        p={...
               'vrsXY', [] ...
              ;'vrgXY', [] ...
              ;'posXYZm', [] ...
              ;'posXYpixRaw', [] ...
              ;'posXYpix', [] ...
              ;'IppZm',[] ...
              ;'LExyz',[] ...
              ;'RExyz',[] ...
          };
    end
end
end
