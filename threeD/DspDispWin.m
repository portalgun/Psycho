classdef DspDispWin < handle
properties
    trgtDSP
    obsDSP
    diffDSP
    offsetDSP=0

    win
    foc %pointDispWin
    trgt %pointDispWin

    VDisp

    F % gridded interpolant
end
properties(Hidden)
    PszRC
    WH
end
methods
    function obj=DspDispWin(VDisp,winOpts,trgtOpts,focOpts)
        obj.VDisp=VDisp;

        obj.parse_win(winOpts);                % 55%
        trgtDsp=obj.parse_target(trgtOpts);    % 21%
        obj.parse_foc(focOpts);

        obj.set_trgtDSP(trgtDsp);

    end
    function parse_win(obj,winOpts)
        if isa(winOpts,'Win3D')
            obj.win=winOpts;
        else
            obj.win=Win3D(obj.VDisp,winOpts); % BOTTLNECK 1
        end
    end
    function trgtDSP=parse_target(obj,trgtOpts)
        if isa(trgtOpts,'PointDispWin3D')
            obj.trgt=trgtOpts;
        else
            trgtDispORwin=trgtOpts.dispORwin;
            trgtOpts=rmfield(trgtOpts,'dispORwin');

            trgtDSP=trgtOpts.trgtDsp; %/60; % NOTE WHERE WAS DOING TEMP FIX
            trgtOpts=rmfield(trgtOpts,'trgtDsp');

            obj.trgt=PointDispWin3D(obj.VDisp,obj.win,trgtOpts,trgtDispORwin); %BOTTLENECK 2
        end
    end
    function parse_foc(obj,focOpts)
        if isa(focOpts,'PointDispWin3D')
            obj.foc=focOpts;
        else
            focDispORwin=focOpts.dispORwin;
            focOpts=rmfield(focOpts,'dispORwin');
            obj.foc =PointDispWin3D(obj.VDisp,obj.win,focOpts,  focDispORwin); % BOTTLENECK 2
        end
    end
    function get_gridded_interpolant(obj,PszRC)
        if isequal(obj.PszRC,PszRC) && isequal(obj.WH,obj.winWHpix)
            return
        end
        obj.WH=obj.win.WHpix;
        obj.PszRC=PszRC;
        obj.F=Win3D.getWin2PtchInterp(obj.WH,obj.PszRC,1000);
    end
%% UTIL
    function [IppXm,IppYm,IppZm,IppXdeg,IppYdeg]=getWinPP(obj,LorRorC,multFactor,dnk)
        if ~exist('LorRorC','var') || isempty(LorRorC)
            LorRorC='C';
        end
        if ~exist('dnK','var') || isempty(dnK)
            dnK=1;
        end
        if ~exist('multFactor','var') || isempty(multFactor)
            multFactor=1;
        end
        [IppXm,IppYm,IppZm,IppXdeg,IppYdeg]=...
        VDisp.proj_plane(obj.VDisp.SubjInfo.LExyz,...
                         obj.VDisp.SubjInfo.RExyz,...
                         obj.win.WHpix,...
                         obj.win.WHm*1000,...
                         obj.win.IppZm,...
                         LorRorC);
    end
    function dsp=xyzToDsp(obj,xyz)
        dsp=XYZ.xyz_to_vrg('C',obj.VDisp.SubjInfo.IPDm,xyz)-obj.foc.pointS.vrgXY;
    end
    function dsp=xyzToDspArcmin(obj,xyz)
        dsp=60*obj.xyzToDsp(xyz);
    end
%% UPDATE
    function obj=set_offsetDSP(obj,offsetDSP)
        obj.offsetDSP=offsetDSP;
        obj.update;
    end
    function obj=update(obj)
        obj.get_obsDSP();
        obj.get_diffDSP();
        if abs(obj.diffDSP) > 1e-4
            obj.correct_disparity();
        end
    end
    function obj=get_obsDSP(obj)
        obj.obsDSP=obj.trgt.pointS.vrgXY(1) - obj.foc.pointS.vrgXY(1) - obj.offsetDSP(1);
    end
    function obj=get_diffDSP(obj)
        %obj.diffDSP=obj.obsDSP-obj.trgtDSP;
        obj.diffDSP=obj.trgtDSP-obj.obsDSP;
        %should be zero when sampling at centered CPs
    end
    function correct_disparity(obj)
        % TRGT INFO
        % NOTE: pointW not pointD ->
        %    we want to know how much to shift the patch
        %dsp=obj.win.diffDSP; % everything is in
        cps=cellfun(@(x) fliplr(x), obj.trgt.pointS.posXYpix, 'UniformOutput',false);
        % IN CORNER COORDINATES (RIGHT?)

        %dsp=dsp/60; %into degrees

        CPsNew=cell(1,2);
        %[CPsNew{1}, CPsNew{2}]= ...
        %    CPs.add_dsp(cps{1}, ...
        %            cps{2}, ...
        %            obj.diffDSP,...
        %            'C',...
        %            obj.VDisp.PP.C.Xm, ... % center is zero
        %            obj.VDisp.PP.C.Ym,...
        %            obj.VDisp.Zm,...
        %            obj.VDisp.SubjInfo.IPDm  ...
        %);
        [CPsNew{1}, CPsNew{2}]= ...
         CPs.addDsp(...
                    cps{1}, ...
                    cps{2}, ...
                    obj.diffDSP,...
                    obj.VDisp...
        );
        obj.set_trgt_subj_posXYpix(fliplr(CPsNew{1}),fliplr(CPsNew{2}));

    end
%% SET
    function obj=set_trgtDSP(obj,trgtDSP)
        obj.trgtDSP=trgtDSP;
        obj.update();
    end
    function obj=set_trgt_disp_posXYpix(obj,val1,val2)
        obj.trgt.set_disp_posXYpix(val1,val2);
        obj.update();
    end
    function obj=set_trgt_subj_posXYpix(obj,val1,val2)
        obj.trgt.set_subj_posXYpix(val1,val2);
        obj.update();
    end
    function PctrCPs=get_patch_CPs(obj,PszRC,PszRCbuff)
        % convert from win to patch or patchbuff coordinates
        % PszRC & PszRCbuff required for patchbuff
        bBuff= exist('PszRCbuff','var') && ~isempty(PszRCbuff);

        CPsNew=cellfun(@(x) fliplr(x), obj.trgt.pointS.posXYpix, 'UniformOutput',false);
        scrnCtr=fliplr(obj.VDisp.WHpix./2);
        winCtr=fliplr(obj.win.WHpix./2);
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
    end
end
methods(Static)
end
end
