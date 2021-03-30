classdef Win3D < handle & Rect3D
properties
    CppXm
    CppYm
    CppZm

    CppXpix
    CppYpix


%% SHAPE3D
    %shape

    %WHm
    %WHpix
    %WHdeg
    %WHdegRaw % assuming cnetered

    %% T for set time in shape4D

    %rect
    %relRec
    %relPosPRC


%% POINT3D
    %posXYZm
    %posXYpix %CPs
    %posXYpixRaw % if point had no depth

    %vrgXY
    %vrsXY
    %

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
methods
    function obj=Win3D(ptbORdisp,Opts)
        if ~exist('Opts','var') || isempty(Opts)
            Opts=struct();
        end
        obj=obj.input_parser_win3D(Opts);
        obj.update_display(ptbORdisp);
        obj.init_point();
        obj.init_shape();
        obj.get_proj_plane();
        obj.get_grid();

    end
    function obj=input_parser_win3D(obj,Opts)
        out=Win3D.input_parser_all(Opts);
        flds=fieldnames(out);
        for i = 1:length(flds)
            fld=flds{i};
            if ~isempty(out.(fld))
                obj.(fld)=out.(fld);
            end
        end
    end
    function obj=get_proj_plane(obj)
        [obj.CppXm,obj.CppYm,obj.CppZm]=DISPLAY.proj_plane(obj.IPDm,obj.WHpix,obj.WHm*1000,obj.posXYZm(3)*1000,'C',1,1);
    end
    function obj=get_grid(obj)
        [obj.CppXpix,obj.CppYpix]=meshgrid(1:obj.WHpix(1),1:obj.WHpix(2));
    end
end
methods(Static=true)
    %function out=input_parser_point_shape(obj,Opts)
    %    p=win3D.opts();
    %    [pointOpts,Opts]=struct_split(Opts,p,[]);
    %    out1=point3D.input_parser(pointOpts);

    %    p=win3D.opts();
    %    [shapeOpts,Opts]=struct_split(Opts,p,[]);
    %    out2=shape3D.input_parser(shapeOpts);
    %    out=structMerge(out1,out2);
    %end
    function out=input_parser_all(Opts)
        p=Common3D.get_parseOpts();
        [OptsC,Opts]=structSplit(Opts,p(:,1));
        outC=parse([],OptsC,p);

        p=Point3D.get_parseOpts();
        [OptsP,Opts]=structSplit(Opts,p(:,1));
        outP=Point3D.input_parser(OptsP);

        p=Shape3D.get_parseOpts();
        [OptsS,Opts]=structSplit(Opts,p(:,1));
        outS=Shape3D.input_parser(OptsS);

        outW=struct();

        out=structMerge(outC,outP,outS);

    end
    function out=get_parseOpts()
    end
end
end
