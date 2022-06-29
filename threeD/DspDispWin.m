classdef DspDispWin < handle
properties(Dependent)
    Dsp
    Vrg
    DspAM
    VrgAM

    Zm
    Dist

    Depth

    foc  %pointDispWin
    trgt %pointDispWin - observed target point
    win
end
properties
    obsDsp
    diffDsp
    uMoude
end
properties(Dependent)
    offsetDsp
    offsetVrg
    offsetZm
    offsetDist
end
properties(Hidden)
    win3D

    trgtDispOrWin
    focDispOrWin

    DepthDep
    DistDep
        offsetDistDep
    ZmDep
        offsetZmDep
    DspDep
        offsetDspDep
    VrgDep
        offsetVrgDep

    focDep  %pointDispWin
    trgtDep %pointDispWin - observed target point
    winDep  %pointDispWin - observed target point


    PszRC
    WH

    VDisp
    toggler


    F % gridded interpolant
    bInit=true
    lastWin3D
    bCacheArgs=true
end
methods(Static)
    function S=getInfo(obj)
        flds={'DspAM','Vrg','Dsp','Zm','Dist','offsetZm'};
        for i = 1:length(flds)
            S.(flds{i})=obj.(flds{i});
        end
    end
    function P=getP()
        V={'!VDisp' [], '!VDisp', 1, ''};
        P=[...
           V;
           DspDispWin.getP_win ;
           DspDispWin.getP_foc ;
           DspDispWin.getP_trgt;
           DspDispWin.getP_desTrgt;
           ];

           %trgt=struct();
           %flds={'Vrg','trgtZ','trgtDis','Dsp','offsetDsp'};
           %for i = 1:length(flds)
           %    if isfield(trgtOpts,flds{i})
           %        trgt.(flds{i})=trgtOpts.(flds{i}); %/60; % NOTE WHERE WAS DOING TEMP FIX
           %        trgtOpts=rmfield(trgtOpts,flds{i});
           %    end
           %end
           %focDispORwin=focOpts.dispORwin;
           %focOpts=rmfield(focOpts,'dispORwin');
    end

    function P=getP_win()
        P={ ...
            {'!win3D','winOpts'},               [], '!Win3D',              11, '!';
          };
    end
    function P=getP_foc()
        P={ ...
            {'!foc','focOpts'},                    [], '!PointRel3D',      1, '!';
            {'focOpts.dispORwin','focDispORwin'},  [],{'subj,''disp','win'},          1, '';
        };
    end
    function P=getP_trgt()
        P={...
            {'!trgt','trgtOpts'},                  [], '!PointRel3D',      1, '!';
            {'trgtOpts.dispORwin','trgtDispOrWin'},[],{'subj','disp','win'},          1, '';
        };

    end
    function P=getP_desTrgt()
        P={ ...
            {'Vrg','trgt.Vrg'},                               [], '',            43, '';
            {'Zm','trgt.Zm'},                                 [], '',            44, '';
            {'Dist','trgt.Dist'},                             [], '',            45, '';
            {'Dsp','trgtDsp','trgtDSP','trgtOpts.trgtDsp','trgtOpts.Dsp'},                 [], '',            42, '';
            ...
            {'offsetDsp','offsetDsp'},                                0,  '',           -42, '';
            'offsetVrg',                                              0,  '',           -43, '';
            'offsetZm',                                               0,  '',           -44, '';
            'offsetDist',                                             0,  '',           -45, '';
        };
    end
end
methods
    function set(obj,fldname,val,bUpdate);
        if nargin < 4
            bUpdate=true;
        end
        obj.toggler.set(fldname,val);
        %if iscell(fldname)
        %    setfield(obj,fldname{:},val);
        %else
        %    obj.(fldname)=val;
        %end
        if bUpdate
            obj.update();
        end
    end
    function obj=DspDispWin(varargin)
        %p={'VDisp','winOpts','trgtOpts','focOpts');
        if nargin < 1
            return
        end
        p={'VDisp','winOpts','trgtOpts','focOpts'};
        opts=Args.group(p,varargin);

        %opts.trgtOpts
        %[opts,~]=Args.parse([],obj.getP,opts);

        if obj.bCacheArgs
            global DSPDISPWIN_ARGS;
            if isempty(DSPDISPWIN_ARGS)
                [opts,~,~,DSPDISPWIN_ARGS]=Args.parse(struct(),obj.getP,opts);
            else
                opts=DSPDISPWIN_ARGS.parse(struct(),opts);
            end

        else
            opts=Args.parse([],obj.getP,opts);
        end

        %obj.toggler.Parent=obj;
        %opts.winOpts
        %'t'
        %opts.trgtOpts
        %'f'
        %opts.focOpts
        %opts
        %dk


        obj.bInit=true;
        [~,opts]=Args.applyIf(obj,opts);

        if isfield(opts,'winOpts')
            obj.parse_win3D(opts.winOpts);
        end
        obj.parse_win();
        if isfield(opts,'trgtOpts')
            obj.parse_target(opts.trgtOpts);    % 21%
        end
        if isfield(opts,'focOpts')
            obj.parse_foc(opts.focOpts);
        end
        obj.bInit=false;

        obj.update();
    end
    function update_win(obj,bForce)
        if nargin < 2
            bForce=false;
        end
        bUpdate=false;
        dif=obj.win3D.posXYZm-obj.lastWin3D.posXYZm;
        if any(abs(dif) > 10^-7)
            bUpdate=true;
            obj.trgtDep.posXYZm=obj.trgtDep.posXYZm+dif;
            obj.focDep.posXYZm=obj.focDep.posXYZm+dif;
        end
        % TODO UPDATE WHPIX

        if ~obj.bInit && (bUpdate || bForce)
            obj.update('dsp');
        end
    end
    function resetDsp(obj)
        obj.bInit=true;
        obj.Dsp=0;
        obj.Dist=0;
        obj.Depth=0;
        obj.obsDsp=0;
        obj.diffDsp=0;
        obj.bInit=false;
    end
    function parse_win3D(obj,winOpts)
        obj.win3D=Win3D(obj.VDisp, winOpts); % BOTTLNECK 1
        obj.lastWin3D=obj.win3D.copy;
    end

    function parse_win(obj)
        winOpts=struct();
        winOpts.posXYZm=obj.win3D.posXYZm;
        obj.winDep=WinRel3D(obj.VDisp,obj.win3D,winOpts);
    end
    function parse_target(obj,trgtOpts)
        if isfield(trgtOpts,'Dsp')
            obj.Dsp=trgtOpts.Dsp;
            trgtOpts=rmfield(trgtOpts,'Dsp');
        end
        trgtOpts.VDisp=obj.VDisp;
        trgtOpts.win3D=obj.win3D;
        obj.trgtDep=PointRel3D(trgtOpts);
    end
    function parse_foc(obj,focOpts)
        focOpts.VDisp=obj.VDisp;
        focOpts.win3D=obj.win3D;
        obj.focDep=PointRel3D(focOpts); % BOTTLENECK 2
    end
%%
    function get_gridded_interpolant(obj,PszRC)
        if isequal(obj.PszRC,PszRC) && isequal(obj.WH,obj.win3D.WHpix)
            return
        end
        obj.WH=obj.win3D.WHpix;
        obj.PszRC=PszRC;
        obj.F=Win3D.getWin2PtchInterp(obj.WH,obj.PszRC,1000);
    end
%% UTIL
    function [IppXm,IppYm,IppZm,IppXdeg,IppYdeg]=getWinPP(obj,LorRorC,multFactor,dnk)
        if nargin < 2 || isempty(LorRorC)
            LorRorC='C';
        end
        % XXX NOT USED
        if nargin < 3 || isempty(dnK)
            dnK=1;
        end
        % XXX NOT USED
        if nargin < 4 || isempty(multFactor)
            multFactor=1;
        end
        [IppXm,IppYm,IppZm,IppXdeg,IppYdeg]=...
        VDisp.proj_plane(obj.VDisp.SubjInfo.LExyz,...
                         obj.VDisp.SubjInfo.RExyz,...
                         obj.win3D.WHpix,...
                         obj.win3D.WHm*1000,...
                         obj.win.IppZm,...
                         LorRorC);
    end
    function dsp=xyzToDsp(obj,xyz)
        dsp=XYZ.xyz_to_vrg('C',obj.VDisp.SubjInfo.IPDm,xyz)-obj.focDep.pointS.vrgXY;
    end
    function dsp=xyzToDspArcmin(obj,xyz)
        dsp=60*obj.xyzToDsp(xyz);
    end
    function PctrCPs=get_patch_CPs(obj,PszRC,PszRCbuff)
        % convert from win to patch or patchbuff coordinates
        % PszRC & PszRCbuff required for patchbuff
        bBuff= exist('PszRCbuff','var') && ~isempty(PszRCbuff);

        CPsNew=cellfun(@(x) flip(x,2), obj.trgtDep.pointS.posXYpix, 'UniformOutput',false);

        %scrnCtr=fliplr(obj.VDisp.WHpix./2); % XXX
        scrnCtr=flip(obj.win3D.posXYpixRaw,2); % NEW

        winCtr=flip(obj.win3D.WHpix./2,2);
        patchCtr=PszRC./2;
        if bBuff
            buffCtr=PszRCbuff./2;
        end

        obj.get_gridded_interpolant(PszRC);

        PctrCPs=cell(2,1);
        for i = 1:2

            % from screen coordinates to central  to win corner coordinates
            WctrCPs=CPsNew{i}-scrnCtr+winCtr;

            % win to patch
            PctrCPs{i}(1)=obj.F{1}(WctrCPs(1));
            PctrCPs{i}(2)=obj.F{2}(WctrCPs(2));


            % patch to buffCtr
            if bBuff
                PctrCPs{i}=PctrCPs{i}-patchCtr+buffCtr;
            end

        end
        PctrCPs=flip(PctrCPs,1); % WHY? XXX
    end
    function out=copy(obj)
        out=DspDispWin;
        out.VDisp=obj.VDisp;
        out.win3D=obj.winDep.win3D.copy();
        out.lastWin3D=obj.lastWin3D.copy();

        out.focDep=obj.focDep.copy(1);
        out.focDep.win3D=out.win3D;

        out.winDep=obj.winDep.copy(1);
        out.winDep.win3D=out.win3D;

        out.trgtDep=obj.trgtDep.copy(1);
        out.trgtDep.win3D=out.win3D;

        flds={'DepthDep','DistDep','ZmDep','DspDep','VrgDep',...
              'offsetDistDep','offsetZmDep','offsetDspDep','offsetVrgDep',...
              'diffDsp','uMoude',...
              'F','WH','PszRC',...
              %'trgtDispOrWin,','focDispOrWin',...
        };
        for i = 1:length(flds)
            out.(flds{i})=obj.(flds{i});
        end

    end
%% UPDATE
    function obj=update(obj,moude)

        if nargin < 2  || isempty(moude)
            if ~isempty(obj.Dsp)
                moude='dsp';
            elseif ~isempty(obj.Vrg)
                moude='vrg';
            elseif ~isempty(obj.Zm)
                moude='z';
            elseif ~isempty(obj.Dist)
                moude='dist';
            end
        end

        switch moude
        case 'dsp'
            obj.obsDsp=obj.trgtDep.pointS.vrgXY(1) - obj.focDep.pointS.vrgXY(1) - obj.offsetDsp(1);
            obj.diffDsp=obj.DspDep-obj.obsDsp;

            obj.correct_disparity();
            % TODO GET vrg, z, dist
        case 'vrg'
            obsVrg=obj.trgtDep.pointS.vrgXY(1);
            obj.diffDsp=obj.VrgDep-obsVrg;

            obj.correct_disparity();
            % TODO GET z, dist
        case 'z'
            LExyz=obj.VDisp.SubjInfo.LExyz;
            RExyz=obj.VDisp.SubjInfo.RExyz;
            xyz=[obj.trgtDep.pointS.posXYZm(1:2) obj.ZmDep];
            obj.Vrg=XYZ.toVrgAngle(xyz,LExyz,RExyz);

            obsVrg=obj.trgtDep.pointS.vrgXY;
            obj.diffDsp=obj.Vrg-obsVrg;

            obj.correct_disparity();
            % TODO GET vrg, dist
        case 'dist'
            obj.Vrg=XYZ.vrsAndDistToVrg(obj.trgtDep.pointS.vrsXY(1),obj.DistDep);

            obsVrg=obj.trgtDep.pointS.vrgXY;
            obj.diffDsp=obj.VrgDep-obsVrg;

            obj.correct_disparity();
            % TODO GET vrg, z
        otherwise
            error(TODO);
        end
    end
    function correct_disparity(obj)
        if abs(obj.diffDsp) <= 1e-6;
            return
        end
        % TRGT INFO
        % NOTE: pointW not pointD ->
        %    we want to know how much to shift the patch
        %dsp=obj.win.diffDsp; % everything is in

        % IN CORNER COORDINATES (RIGHT?)
        cps=cellfun(@(x) flip(x,2), obj.trgtDep.pointS.posXYpix, 'UniformOutput',false);
        %dsp=dsp/60; %into degrees

        CPsNew=cell(1,2);
        [CPsNew{1}, CPsNew{2}]=CPs.addDsp(cps{1}, cps{2}, obj.diffDsp, obj.VDisp);
        obj.set_trgt_subj_posXYpix(flip(CPsNew{1},2),flip(CPsNew{2},2));

        obj.DistDep=norm(obj.trgtDep.posXYZm-obj.focDep.posXYZm);
        obj.DepthDep=norm(obj.trgtDep.posXYZm(3)-obj.focDep.posXYZm(3));
    end
    function obj=set_trgt_disp_posXYpix(obj,val1,val2)
        obj.trgtDep.set_disp_posXYpix(val1,val2);
        obj.update();
    end
    function obj=set_trgt_subj_posXYpix(obj,val1,val2)
        obj.trgtDep.set_subj_posXYpix(val1,val2);
        obj.update();
    end
%% SET
    function obj=set.foc(obj,args)
        if isa(args,'point3D')
            obj.focDep=args;
        elseif isstruct(args)
            s=args;
            flds=Struct.getFields(args);
            for i = 1:length(flds)
                val=getfield(s,flds{i}{:});
                obj.focDep=setfield(obj.SDep,flds{i}{:},val);
            end
        else
            error('somthing went wrong')
        end
        if ~obj.bInit
            obj.update();
        end
    end
    function obj=set.trgt(obj,args)
        if isa(args,'point3D')
            obj.trgtDep=args;
        elseif isstruct(args)
            s=args;
            flds=Struct.getFields(args);
            for i = 1:length(flds)
                val=getfield(s,flds{i}{:});
                obj.trgtDep=setfield(obj.SDep,flds{i}{:},val);
            end
        else
            error('somthing went wrong')
        end
        if ~obj.bInit
            obj.update();
        end
    end
    function obj=set.win(obj,args)
        if isa(args,'win3D')
            obj.win3D=args;
        elseif isstruct(args)
            s=args;
            flds=Struct.getFields(args);
            for i = 1:length(flds)
                val=getfield(s,flds{i}{:});
                obj.win3D=setfield(obj.SDep,flds{i}{:},val);
            end
        else
            error('somthing went wrong')
        end
        if ~obj.bInit
            obj.update();
        end
    end
%%
    function set.Zm(obj,val)
        obj.ZmDep=val;
        if obj.bInit; return; end
        obj.update('z');
    end
    function set.Dist(obj,val)
        obj.DistDep=val;
        if obj.bInit; return; end
        obj.update('dist');
    end
    function set.Depth(obj,val)
        obj.DistDep=val;
        if obj.bInit; return; end
        obj.update('depth');
    end
    function set.Dsp(obj,val)
        obj.DspDep=val;
        if obj.bInit; return; end
        obj.update('dsp');
    end
    function set.DspAM(obj,val)
        obj.DspDep=val/60;
        if obj.bInit; return; end
        obj.update('dsp');
    end
    function set.Vrg(obj,val)
        obj.VrgDep=val;
        if obj.bInit; return; end
        obj.update('vrg');
    end
    function set.VrgAM(obj,val)
        obj.VrgDep=val/60;
        if obj.bInit; return; end
        obj.update('vrg');
    end
%%
    function set.offsetDsp(obj,val)
        obj.offsetDspDep=val;
        if obj.bInit; return; end
        obj.update('dsp');
    end
    function set.offsetVrg(obj,val)
        obj.offsetVrgDep=val;
        if obj.bInit; return; end
        obj.update('vrg');
    end
    function set.offsetZm(obj,val)
        obj.offsetZmDep=val;
        if obj.bInit; return; end
        obj.update('z');
    end
    function set.offsetDist(obj,val)
        obj.offsetDistDep=val;
        if obj.bInit; return; end
        obj.update('dist');
    end
% GET
    function out=get.win3D(obj)
        out=obj.win3D;
    end
    function out=get.win(obj)
        out=obj.winDep;
    end
    function out=get.foc(obj)
        out=obj.focDep;
    end
    function out=get.trgt(obj)
        out=obj.trgtDep;
    end
%%
    function out=get.Zm(obj)
        out=obj.ZmDep;
    end
    function out=get.Depth(obj)
        out=obj.DepthDep;
    end
    function out=get.Dist(obj)
        out=obj.DistDep;
    end
    function out=get.DspAM(obj)
        out=obj.DspDep*60;
    end
    function out=get.Dsp(obj)
        out=obj.DspDep;
    end
    function out=get.Vrg(obj)
        out=obj.VrgDep;
    end
    function out=get.VrgAM(obj)
        out=obj.VrgDep*60;
    end
%%
    function out=get.offsetDsp(obj)
        out=obj.offsetDspDep;
    end
    function out=get.offsetVrg(obj)
        out=obj.offsetVrgDep;
    end
    function out=get.offsetZm(obj)
        out=obj.offsetZmDep;
    end
    function out=get.offsetDist(obj)
        out=obj.offsetDistDep;
    end
% POINT T
end
methods(Static)
    function trgtOpts=getDefaultTargetOpts()
        trgtOpts.dispORwin='disp';
        trgtOpts.posXYZm=[0 0 0];
        trgtOpts.Dsp=0;
    end
    function focOpts=getDefaultFocOpts()
        focOpts.dispORwin='disp';
        focOpts.posXYZm=[0 0 0];
    end
end
end
