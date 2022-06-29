classdef PointRel3D < handle
%
properties
    dispORwin
end
properties(Dependent)

    posXYZm
    posXYpix
    posXYpixRaw
    vrgXY
    vrsXY
    los
    dist
end
properties(Dependent, Hidden)
    point
end
properties(Hidden)
    win3D
    PointSet
    pointD % point3D relative to display
    pointW % point3D relative to window
    pointS % point3D relative to subject/observer



      % winORwinOpts and pointORpointOpts are independent objects
      % winORwinOpts has its own point
    VDisp
    Toggler
    bCacheArgsL=true
    bInit
end
methods(Static)
    function P=getP()
        P={...
            {'!win3D','winOpts'},                     [],'!Win3D',        1;
            '!VDisp',                               [],'!VDisp',        0;
            ...
            {'!PointSet','pointOpts'}                 [],'!Point3D',     1;
            {'pointOpts.posXYZm','posXYZm'}         [],''              2;
            {'pointOpts.posXYpix','posXYpix'}       [],''              3;
            {'pointOpts.posXYpixRaw','posXYpixRaw'} [],''              4;
            {'pointOpts.vrgXY','vrgXY'} [],''                          5;
            {'pointOpts.vrsXY','vrsXY'} [],''                          5;
            {'pointOpts.dist','dist'} [],''                            6;
            {'pointOpts.los','los'} [],''                              0;
            ...
            {'dispORwin','pointOpts.dispORwin'},     [],{'disp','win','subj'}, 1;
        };
    end
end
methods
    function out=copy(obj,bParent)
        if nargin < 2
            bParent=false;
        end
        bWin=isa(obj,'WinRel3D');
        if bWin
            out=WinRel3D();
        else
            out=PointRel3D();
        end
        out.dispORwin=obj.dispORwin;
        out.pointS=obj.pointS.copy();
        out.pointW=obj.pointW.copy();
        out.pointD=obj.pointD.copy();
        out.VDisp=obj.VDisp;
        if ~bParent
            out.win3D=obj.win3D;
        end
        % XXX win3D
    end
    function set(obj,fld,name)
   % function set(obj,dspORwinORsubj,fld,name)
        %switch dspORwinORsubj
        %    case {'d','dsp','disp','display'}
        %        typ=1;
        %        str=['pointD.' fld];
        %    case {'w','win','window'};
        %        typ=2;
        %        str=['pointW.' fld];
        %    case {'s','subj','subject'};
        %        typ=3;
        %        str=['pointD.' fld];
        %    otherwise
        %        error('invalid') %TODO
        %end
        if ischar(fld)
            strsplit(fld,'.');
        end
        switch fld{1}
        case 'PointSet'
            switch obj.dispORwin
            case 'disp'
                typ=1;
            case 'win'
                typ=2;
            case 'subj'
                typ=3;
            end
        case 'pointD'
            typ=1;
            obj.set_dispORwin('disp');
        case 'pointW'
            typ=2;
            obj.set_dispORwin('win');
        case 'pointS'
            typ=3;
            obj.set_dispORwin('subj');
        end
        obj.Toggler.set(fld,name);
        if typ==1
            obj.update_disp;
        elseif typ==2
            obj.update_win;
        elseif typ==3
            obj.update_subj;
        end
    end
    function obj=PointRel3D(varargin)
        %PointDIspWin3D(1 VDisp, 2 win OR winOpts, 3 point OR pointOpts, 4 dispORwin};
        if nargin < 1
            return
        end
        p={'VDisp','winOpts','pointOpts','dispORwin'};
        opts=Args.group(p,varargin);

        %[opts,~,obj.Toggler]=Args.parse([],obj.getP,opts);

        obj.bInit=true;
        if obj.bCacheArgsL
            global POINTREL3D_ARGS;
            if isempty(POINTREL3D_ARGS);
                [opts,~,~,POINTREL3D_ARGS]=Args.parse(struct(),obj.getP,opts);
            else
                opts=POINTREL3D_ARGS.parse(struct(),opts);
            end

        else
            opts=Args.parse([],obj.getP,opts);
        end
        %[opts,~]=Args.parse([],obj.getP,opts);
        %obj.Toggler.Parent=obj;
        [~,opts]=Args.applyIf(obj,opts);


        if isfield(opts,'winOpts')
            obj.win3D=Win3D(obj.VDisp,winOpts);
        end

        if isfield(opts,'pointOpts')
            switch obj.dispORwin
                case 'disp'
                    obj.parse_pointD(opts.pointOpts);
                case 'win'
                    obj.parse_pointW(opts.pointOpts);
                case 'subj'
                    obj.parse_pointS(opts.pointOpts);
            end
        end
        obj.bInit=false;

    end
    function re_init(obj)
        obj.parse_pointS(obj.pointS);
    end
    function update(obj)
        switch obj.dispORwin
            case 'dsp'
                obj.update_disp();
            case 'win'
                obj.update_win();
            case 'subj'
                obj.update_subj();
        end
    end
%% PARSE
    function obj=parse_pointW(obj,pointORpointOpts)
        if isa(pointORpointOpts,'Point3D')
            obj.pointW=pointORpointOpts;
        else
            pointOpts=pointORpointOpts;
            obj.gen_pointW(pointOpts);
        end
        if nargin < 3; bPointSet=false; end

        % point D
        % CHECKED
        pointOpts=struct();
        pointOpts.posXYZm=obj.pointW.posXYZm;
        pointOpts.posXYZm(3)=obj.pointW.posXYZm(3) + obj.win3D.posXYZm(3) - obj.VDisp.Zm;
        pointOpts.IppZm=0;
        obj.gen_pointD(pointOpts);

        % point S
        % CHECKED
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

        % point S
        % CHECKED
        pointOpts=struct();
        pointOpts.posXYZm=obj.pointD.posXYZm;
        pointOpts.posXYZm(3)=obj.pointD.posXYZm(3) + obj.VDisp.Zm;
        pointOpts.IppZm=obj.VDisp.Zm;
        obj.gen_pointS(pointOpts);

        % point W
        % CHECKED
        pointOpts=struct();
        pointOpts.posXYZm=obj.pointD.posXYZm;

        pointOpts.posXYZm(3)=0; % XXX
        pointOpts.IppZm=-obj.pointD.posXYZm(3); % XXX
        %pointOpts.posXYZm(3)=obj.pointS.posXYZm(3)-obj.win3D.posXYZm(3);

        pointOpts.IppZm=obj.pointS.IppZm-obj.win3D.posXYZm;


        obj.gen_pointW(pointOpts);
    end
    function obj=parse_pointS(obj,pointORpointOpts)
        if isa(pointORpointOpts,'Point3D')
            obj.pointS=pointORpointOpts;
        else
            pointOpts=pointORpointOpts;
            obj.gen_pointS(pointOpts);
        end

        % point W
        % CHECKED
        pointOpts=struct();
        pointOpts.posXYZm=obj.pointS.posXYZm;
        pointOpts.posXYZm(3)=obj.pointS.posXYZm(3) - obj.win3D.posXYZm(3);
        pointOpts.IppZm=obj.pointS.IppZm-obj.win3D.posXYZm(3);

        obj.gen_pointW(pointOpts);

        % point D
        % CHECKED
        pointOpts=struct();
        pointOpts.posXYZm=obj.pointW.posXYZm;
        pointOpts.posXYZm(3)=obj.pointW.posXYZm(3) + obj.win3D.posXYZm(3) - obj.VDisp.Zm;
        pointOpts.IppZm=0;
        obj.gen_pointD(pointOpts);

    end
%% GEN
    function obj=gen_pointW(obj,pointOpts)
        winZO=obj.win3D.posXYZm(3);
        CppZm=ret(obj.VDisp.Zm)-winZO;
        %winZ=0;

        LExyz=obj.VDisp.SubjInfo.LExyz;
        RExyz=obj.VDisp.SubjInfo.RExyz;
        LExyz(3)=LExyz(3)-winZO;
        RExyz(3)=RExyz(3)-winZO;
        pointOpts.LExyz=LExyz;
        pointOpts.RExyz=RExyz;
        pointOpts.IppZm=CppZm;

        if isa(obj,'WinRel3D')
            pointOpts.WHm=obj.pointS.WHm;
            obj.pointW=Win3D(obj.VDisp, pointOpts);
        else
            obj.pointW=Point3D(obj.VDisp, pointOpts);
        end
    end
    function obj=gen_pointD(obj,pointOpts)
        cppZmO=obj.VDisp.Zm;
        %winZ=obj.win.posXYZm(3)-cppZmO;
        CppZm=0;

        LExyz=obj.VDisp.SubjInfo.LExyz;
        RExyz=obj.VDisp.SubjInfo.RExyz;
        LExyz(3)=LExyz(3)-cppZmO;
        RExyz(3)=RExyz(3)-cppZmO;
        pointOpts.LExyz=LExyz;
        pointOpts.RExyz=RExyz;
        pointOpts.IppZm=CppZm;

        if isa(obj,'WinRel3D')
            pointOpts.WHm=obj.pointS.WHm;
            obj.pointD=Win3D(obj.VDisp, pointOpts);
        else
            obj.pointD=Point3D(obj.VDisp, pointOpts);
        end
    end
    function obj=gen_pointS(obj,pointOpts)
        % SUBJECT / OBJSERVER
        pointOpts.IppZm=obj.VDisp.Zm;
        pointOpts.LExyz=obj.VDisp.SubjInfo.LExyz;
        pointOpts.RExyz=obj.VDisp.SubjInfo.RExyz;

        if isa(obj,'WinRel3D')
            error('This should not happen');
        end
        obj.pointS=Point3D(obj.VDisp, pointOpts);
    end

    function obj=win_to_disp(obj)
        % HERE
        winZO=obj.win3D.posXYZm(3);
        CppZm=ret(obj.VDisp.Zm)-winZO;

        posXYZm=obj.pointW.posXYZm;
        posXYZm(3)=obj.pointW.posXYZm(3) + obj.win3D.posXYZm(3) - CppZm;
        obj.pointD.set_posXYZm(posXYZm);
    end
    function obj=disp_to_win(obj)
        %CppZm=ret(obj.VDisp.Zm);
        % HERE

        IppZmOld=obj.pointW.IppZm;
        obj.pointW.IppZm=-obj.pointD.posXYZm(3);

        LZdiff=obj.pointW.LExyz(3)-IppZmOld;
        RZdiff=obj.pointW.RExyz(3)-IppZmOld;
        obj.pointW.LExyz(3)=LZdiff+obj.pointW.IppZm;
        obj.pointW.RExyz(3)=RZdiff+obj.pointW.IppZm;
        obj.pointW.posXYZm=obj.pointW.posXYZm;
    end
    function obj=subj_to_disp(obj)
        % HERE
        CppZm=ret(obj.VDisp.Zm);

        posXYZm=obj.pointS.posXYZm;
        posXYZm(3)=obj.pointS.posXYZm(3) - CppZm;
        obj.pointD.posXYZm=posXYZm;

    end
    function obj=disp_to_subj(obj)
        % HERE
        CppZm=ret(obj.VDisp.Zm);

        posXYZm=obj.pointD.posXYZm;
        posXYZm(3)=obj.pointD.posXYZm(3) + CppZm;
        obj.pointS.posXYZm=posXYZm;
    end
%% WIN to DSP
    function obj=update_win(obj)
        obj.win_to_disp;
        if obj.bInit; return; end
        obj.disp_to_subj();
    end
    %%
    function set_win_vrsXY(obj,val)
        obj.pointW.vrsXY=val;
        if obj.bInit; return; end
        obj.update_win();
    end
    function set_win_vrgXY(obj,val)
        obj.pointW.vrgXY=val;
        if obj.bInit; return; end
        obj.update_win();
    end
    function set_win_posXYZm(obj,val)
        obj.pointW.posXYZm=val;
        if obj.bInit; return; end
        obj.update_win();
    end
    function set_win_posXYpixRaw(obj,val)
        obj.pointW.posXYpixRaw=val;
        if obj.bInit; return; end
        obj.update_win();
    end
    function set_win_posXYpix(obj,val,val2)
        obj.pointW.posXYpix={val,val2};
        if obj.bInit; return; end
        obj.update_win();
    end
%% DISP to WIN
    function obj=update_disp(obj)
        obj.disp_to_win;
        if obj.bInit; return; end
        obj.disp_to_subj();
    end
    %%
    function set_disp_vrsXY(obj,val)
        obj.pointD.set_vrsXY(val);
        if obj.bInit; return; end
        obj.update_disp();
    end
    function set_disp_vrgXY(obj,val)
        obj.pointD.set_vrgXY(val);
        if obj.bInit; return; end
        obj.update_disp();
    end
    function set_disp_posXYZm(obj,val)
        obj.pointD.set_posXYZm(val);
        if obj.bInit; return; end
        obj.update_disp();
    end
    function set_disp_posXYpixRaw(obj,val)
        obj.pointD.set_posXYpixRaw(val);
        if obj.bInit; return; end
        obj.update_disp();
    end
    function set_disp_posXYpix(obj,val1,val2)
        obj.pointD.set_posXYpix(val1,val2);
        if obj.bInit; return; end
        obj.update_disp();
    end
%% DISP to Subj
    function update_subj(obj)
        obj.subj_to_disp;
        if obj.bInit; return; end
        obj.disp_to_win();
    end
    function set_subj_posXYpix(obj,val1,val2)
        obj.pointS.posXYpix={val1,val2};
        if obj.bInit; return; end
        obj.update_subj();
    end
%% POINT
    function out=get.point(obj)
        switch obj.dispORwin
        case 'disp'
            out=obj.pointD;
        case 'win'
            out=obj.pointW;
        case 'subj'
            out=obj.pointS;
        end
    end
    %%
    function out=get.posXYZm(obj)
        out=obj.point.posXYZm;
    end
    function out=get.posXYpix(obj)
        out=obj.point.posXYpix;
    end
    function out=get.posXYpixRaw(obj)
        out=obj.point.posXYpixRaw;
    end
    function out=get.vrgXY(obj)
        out=obj.point.vrgXY;
    end
    function out=get.vrsXY(obj)
        out=obj.point.vrsXY;
    end
    function out=get.los(obj)
        out=obj.point.los;
    end
    function out=get.dist(obj)
        out=obj.point.dist;
    end
%% SET
    function set.posXYZm(obj,val)
        obj.point.posXYZm=val;
        if obj.bInit; return; end
        obj.update();
    end
    function set.posXYpix(obj,val)
        obj.point.posXYpix=val;
        if obj.bInit; return; end
        obj.update();
    end
    function set.posXYpixRaw(obj,val)
        obj.point.posXYpixRaw=val;
        if obj.bInit; return; end
        obj.update();
    end
    function set.vrgXY(obj,val)
        obj.point.vrgXY=val;
        if obj.bInit; return; end
        obj.update();
    end
    function set.vrsXY(obj,val)
        obj.point.vrsXY=val;
        if obj.bInit; return; end
        obj.update();
    end
    function set.los(obj,val)
        obj.point.los=val;
        if obj.bInit; return; end
        obj.update();
    end
    function set.dist(obj,val)
        obj.point.dist=val;
        if obj.bInit; return; end
        obj.update();
    end
    %function set.win3D(obj,val)
    %    obj.win3D=val;
    %end
end
end
