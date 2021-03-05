classdef PointDispWin3D < handle
%
properties
    pointD % point3D relative to window
    pointW % point3D relative to display
    win    % Win3D
end
methods
    function obj=PointDispWin3D(ptbORdisp,winORwinOpts,pointORpointOpts,dispORwin)
      % winORwinOpts and pointORpointOpts are independent objects
      % winORwinOpts has its own point
        if isa(winORwinOpts,'Win3D')
            obj.win=winORwinOpts;
        else
            obj.win=Win3D(ptbORdisp,winORwinOpts);
        end
        if isa(pointORpointOpts,'Point3D') && strcmp(dispORwin,'disp')
            obj.pointD=pointORpointOpts;
        elseif isa(pointORpointOpts,'Point3D') && strcmp(dispORwin,'win')

            obj.pointW=pointORpointOpts;
        elseif strcmp(dispORwin,'disp')
            obj.pointD=Point3D(ptbORdisp, pointORpointOpts);
        elseif strcmp(dispORwin,'win')

            z=obj.win.posXYZm(3);

            pointORpointOpts.IppZm=ret(ptbORdisp.CppZm)-z;

            LExyz=obj.win.LExyz;
            RExyz=obj.win.RExyz;
            LExyz(3)=LExyz(3)-z;
            RExyz(3)=RExyz(3)-z;
            pointORpointOpts.LExyz=LExyz;
            pointORpointOpts.RExyz=RExyz;

            obj.pointW=Point3D(ptbORdisp, pointORpointOpts);
        end

        if strcmp(dispORwin,'win')
            obj.pointD=copyObj(obj.pointW);

            obj.win_to_disp();
        elseif  strcmp(dispORwin,'disp')
            obj.pointW=copyObj(obj.pointD);

            z=obj.win.posXYZm(3);

            obj.pointW.IppZm=ret(obj.pointW.IppZm)-z;

            LExyz=obj.pointW.LExyz;
            RExyz=obj.pointW.RExyz;
            LExyz(3)=LExyz(3)-z;
            RExyz(3)=RExyz(3)-z;
            obj.pointW.LExyz=LExyz;
            obj.pointW.RExyz=RExyz;

            obj.disp_to_win();
        end
    end
%% WIN to DSP
    function obj=win_to_disp(obj)
        obj.pointD.set_posXYZm(obj.pointW.posXYZm + obj.win.posXYZm);
    end
    function set_win_vrsXY(obj,val)
        obj.pointW.set_vrsXY(val);
        obj.win_to_disp();
    end
    function set_win_vrgXY(obj,val)
        obj.pointW.set_vrgXY(val);
        obj.win_to_disp();
    end
    function set_win_posXYZm(obj,val)
        obj.pointW.set_posXYZm(val);
        obj.win_to_disp();
    end
    function set_win_posXYpixRaw(obj,val)
        obj.pointW.set_posXYpixRaw(val);
        obj.win_to_disp();
    end
    function set_win_posXYpix(obj,val)
        obj.pointW.set_posXYpix(val);
        obj.win_to_disp();
    end
%% DISP to WIN
    function obj=disp_to_win(obj)
        obj.pointW.set_posXYZm(obj.pointD.posXYZm - obj.win.posXYZm);
    end
    function set_disp_vrsXY(obj,val)
        obj.pointD.set_vrsXY(val);
        obj.disp_to_win();
    end
    function set_disp_vrgXY(obj,val)
        obj.pointD.set_vrgXY(val);
        obj.disp_to_win();
    end
    function set_disp_posXYZm(obj,val)
        obj.pointD.set_posXYZm(val);
        obj.disp_to_win();
    end
    function set_disp_posXYpixRaw(obj,val)
        obj.pointD.set_posXYpixRaw(val);
        obj.disp_to_win();
    end
    function set_disp_posXYpix(obj,val)
        obj.pointD.set_posXYpix(val);
        obj.disp_to_win();
    end
end
end
