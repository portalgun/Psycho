classdef PointDispWin3D < handle
%
properties
    pointD % point3D relative to display
    pointW % point3D relative to window
    pointS % point3D relative to subject/observer
    win    % Win3D rel to subj
    VDisp
end
methods
    function obj=PointDispWin3D(ptbORdisp,winORwinOpts,pointORpointOpts,dispORwin)
      % winORwinOpts and pointORpointOpts are independent objects
      % winORwinOpts has its own point
        if isa(ptbORdisp,'VDisp')
            obj.VDisp=ptbORdisp;
        elseif isa(ptbORdisp,'ptbSession')
            obj.VDisp=ptbORdisp.display;
        end

        obj.parse_win(winORwinOpts);

        if strcmp(dispORwin,'disp')
            obj.parse_pointD(pointORpointOpts);
        elseif strcmp(dispORwin,'win')
            obj.parse_pointW(pointORpointOpts);
        end

    end
%% PARSE
    function parse_win(obj,winORwinOpts)
        if isa(winORwinOpts,'Win3D')
            obj.win=winORwinOpts;
        else
            winOpts=winORwinOpts;
            obj.win=Win3D(obj.VDisp,winOpts);
        end
    end
    function obj=parse_pointW(obj,pointORpointOpts)
        if isa(pointORpointOpts,'Point3D')
            obj.pointD=pointORpointOpts;
        else
            pointOpts=pointORpointOpts;
            obj.gen_pointW(pointOpts);
        end


        % point D
        pointOpts=struct();
        pointOpts.posXYZm=obj.pointW.posXYZm;
        pointOpts.posXYZm(3)=obj.pointW.posXYZm(3) + obj.win.posXYZm(3) - obj.VDisp.Zm;
        pointOpts.IppZm=0;
        obj.gen_pointD(pointOpts);

        % point S
        pointOpts.posXYZm=obj.pointD.posXZYm;
        pointOpts.posXYZm(3)=obj.pointD.posXYZm(3) + CppZm;
        pointOpts.IppZm=obj.VDisp.Zm;
        obj.gen_pointS(pointOpts);
    end
    function obj=parse_pointD(obj,pointORpointOpts)
        if isa(pointORpointOpts,'Point3D')
            obj.pointD=pointORpointOpts;
        else
            pointOpts=pointORpointOpts;
            obj.gen_pointD(pointOpts);
        end

        % point W
        pointOpts=struct();
        pointOpts.posXYZm=obj.pointD.posXYZm;
        pointOpts.posXYZm(3)=0;
        pointOpts.IppZm=-obj.pointD.posXYZm(3);

        obj.gen_pointW(pointOpts);

        % point S
        pointOpts=struct();
        pointOpts.posXYZm=obj.pointD.posXYZm;
        pointOpts.posXYZm(3)=obj.pointD.posXYZm(3) + obj.VDisp.Zm;
        pointOpts.IppZm=obj.VDisp.Zm;

        obj.gen_pointS(pointOpts);

    end
%% GEN
    function obj=gen_pointW(obj,pointOpts)
        winZO=obj.win.posXYZm(3);
        CppZm=ret(obj.VDisp.Zm)-winZO;
        winZ=0;

        LExyz=obj.VDisp.SubjInfo.LExyz;
        RExyz=obj.VDisp.SubjInfo.RExyz;
        LExyz(3)=LExyz(3)-winZO;
        RExyz(3)=RExyz(3)-winZO;
        pointOpts.LExyz=LExyz;
        pointOpts.RExyz=RExyz;
        pointOpts.IppZm=CppZm;

        obj.pointW=Point3D(obj.VDisp, pointOpts);
    end
    function obj=gen_pointD(obj,pointOpts)
        cppZmO=obj.VDisp.Zm;
        winZ=obj.win.posXYZm(3)-cppZmO;
        CppZm=0;

        LExyz=obj.VDisp.SubjInfo.LExyz;
        RExyz=obj.VDisp.SubjInfo.RExyz;
        LExyz(3)=LExyz(3)-cppZmO;
        RExyz(3)=RExyz(3)-cppZmO;
        pointOpts.LExyz=LExyz;
        pointOpts.RExyz=RExyz;
        pointOpts.IppZm=CppZm;

        obj.pointD=Point3D(obj.VDisp, pointOpts);
    end
    function obj=gen_pointS(obj,pointOpts)
        % SUBJECT / OBJSERVER
        pointOpts.IppZm=obj.VDisp.Zm;
        pointOpts.LExyz=obj.win.LExyz;
        pointOpts.RExyz=obj.win.RExyz;
        pointOpts.IppZm=obj.VDisp.Zm;

        obj.pointS=Point3D(obj.VDisp, pointOpts);
    end
%% WIN to DSP
    function obj=update_win(obj);
        obj.win_to_disp;
        obj.disp_to_subj();
    end
    function obj=win_to_disp(obj)
        winZO=obj.win.posXYZm(3);
        CppZm=ret(obj.VDisp.Zm)-winZO;

        posXYZm=obj.pointW.posXYZm;
        posXYZm(3)=obj.pointW.posXYZm(3) + obj.win.posXYZm(3) - CppZm;
        obj.pointD.set_posXYZm(posXYZm);
    end
    %%
    function set_win_vrsXY(obj,val)
        obj.pointW.set_vrsXY(val);
        obj.update_win();
    end
    function set_win_vrgXY(obj,val)
        obj.pointW.set_vrgXY(val);
        obj.update_win();
    end
    function set_win_posXYZm(obj,val)
        obj.pointW.set_posXYZm(val);
        obj.update_win();
    end
    function set_win_posXYpixRaw(obj,val)
        obj.pointW.set_posXYpixRaw(val);
        obj.update_win();
    end
    function set_win_posXYpix(obj,val,val2)
        obj.pointW.set_posXYpix(val,val2);
        obj.update_win();
    end
%% DISP to WIN
    function obj=update_disp(obj);
        obj.disp_to_win;
        obj.disp_to_subj();
    end
    function obj=disp_to_win(obj)
        CppZm=ret(obj.VDisp.Zm);

        IppZmOld=obj.pointW.IppZm;
        obj.pointW.IppZm=-obj.pointD.posXYZm(3);

        LZdiff=obj.pointW.LExyz(3)-IppZmOld;
        RZdiff=obj.pointW.RExyz(3)-IppZmOld;
        obj.pointW.LExyz(3)=LZdiff+obj.pointW.IppZm;
        obj.pointW.RExyz(3)=RZdiff+obj.pointW.IppZm;
        obj.pointW.set_posXYZm(obj.pointW.posXYZm);
    end
    %%
    function set_disp_vrsXY(obj,val)
        obj.pointD.set_vrsXY(val);
        obj.update_disp();
    end
    function set_disp_vrgXY(obj,val)
        obj.pointD.set_vrgXY(val);
        obj.update_disp();
    end
    function set_disp_posXYZm(obj,val)
        obj.pointD.set_posXYZm(val);
        obj.update_disp();
    end
    function set_disp_posXYpixRaw(obj,val)
        obj.pointD.set_posXYpixRaw(val);
        obj.update_disp();
    end
    function set_disp_posXYpix(obj,val1,val2)
        obj.pointD.set_posXYpix(val1,val2);
        obj.update_disp();
    end
%% DISP to Subj
    function obj=update_subj(obj);
        obj.subj_to_disp;
        obj.disp_to_win();
    end
    function obj=subj_to_disp(obj)
        CppZm=ret(obj.VDisp.Zm);

        posXYZm=obj.pointS.posXYZm;
        posXYZm(3)=obj.pointS.posXYZm(3) - CppZm;
        obj.pointD.set_posXYZm(posXYZm);

    end
    function obj=disp_to_subj(obj)
        CppZm=ret(obj.VDisp.Zm);

        posXYZm=obj.pointD.posXYZm;
        posXYZm(3)=obj.pointD.posXYZm(3) + CppZm;
        obj.pointS.set_posXYZm(posXYZm);
    end
    function set_subj_posXYpix(obj,val1,val2)
        obj.pointS.set_posXYpix(val1,val2);
        obj.update_subj();
    end
end
end
