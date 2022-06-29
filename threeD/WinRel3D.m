classdef WinRel3D < handle & PointRel3D
properties(Dependent)
    WHm
    WHpix
    WHdeg
    WHAM
    WHdegRaw
    WHAMRaw
end
properties(Hidden)
    bCacheArgs=true
end
methods
    function obj=WinRel3D(varargin)
        if nargin < 1
            return
        end
        %p={'VDisp','winOpts','varargin'};
        p={'VDisp','winOpts','varargin'};
        opts=Args.group(p,varargin);

        obj.bInit=true;
        if obj.bCacheArgs
            global WINREL3D_ARGS;
            if isempty(WINREL3D_ARGS);
                [opts,~,~,WINREL3D_ARGS]=Args.parse(struct(),obj.getP,opts);
            else
                opts=WINREL3D_ARGS.parse(struct(),opts);
            end

        else
            opts=Args.parse([],obj.getP,opts);
        end
        obj.bInit=false;
        opts.dispORwin='subj';

        obj.Toggler.Parent=obj;

        [~,opts]=Args.applyIf(obj,opts);

        if isfield(opts,'win3D')
            obj.win3D=opts.win3D;
        elseif isfield(opts,'winOpts') && numel(fieldnames(opts.winOpts)) > 0
            if isa(opts.winOpts,'Win3D')
                obj.win3D=opts.winOpts;
            else
                obj.win3D=Win3D(obj.VDisp,opts.winOpts);
            end
        end
        obj.parse_pointS(obj.win3D);
    end
%% UPDATE
    function updateWin_subj(obj)
        obj.winS2W();
        obj.winS2D();
    end
    function updateWin_win(obj)
        obj.winW2S();
        obj.winS2D();
    end
    function updateWin_disp(obj)
        obj.winD2S();
        obj.winS2W();
    end
%%
    function winS2W(obj)
        obj.pointW.WHm=obj.pointS.WHm;
    end
    function winS2D(obj)
        obj.pointD.WHm=obj.pointS.WHm;
    end
    function winW2S(obj)
        obj.pointS.WHm=obj.pointW.WHm;
    end
    function winD2S(obj)
        obj.pointS.WHm=obj.pointD.WHm;
    end

%% SET
    %%
    function set.WHm(obj,val)
        obj.win3D.WHm=val;
        obj.udpateWin_subj();
    end
    function set.WHpix(obj,val)
        obj.win3D.WHpix=val;
        obj.updateWin_subj();
    end
    %%
    function out=get.WHm(obj)
        out=obj.win3D.WHm;
    end
    function out=get.WHpix(obj)
        out=obj.win3D.WHpix;
    end
    %%
    function update(obj)
        switch obj.dispORwin
            case 'subj'
                obj.updateWin_subj;
            case 'win'
                obj.updateWin_win;
            case 'disp'
                obj.updateWin_disp;
        end
    end
    function set.WHdeg(obj,val)
        switch obj.dispORwin
            case 'subj'
                obj.win3D.WHdeg=val;
                if obj.bInit; return; end
                obj.updateWin_subj;
            case 'win'
                obj.pointW.WHdeg=val;
                if obj.bInit; return; end
                obj.updateWin_win;
            case 'disp'
                obj.pointD.WHdeg=val;
                if obj.bInit; return; end
                obj.updateWin_disp;
        end
    end
    function set.WHAM(obj,val)
        switch obj.dispORwin
            case 'subj'
                obj.win3D.WHAM=val;
                if obj.bInit; return; end
                obj.updateWin_subj;
            case 'win'
                obj.pointW.WHAM=val;
                if obj.bInit; return; end
                obj.updateWin_win;
            case 'disp'
                obj.pointD.WHAM=val;
                if obj.bInit; return; end
                obj.updateWin_disp;
        end
    end
    function set.WHdegRaw(obj,val)
        switch obj.dispORwin
            case 'subj'
                obj.win3D.WHdegRaw=val;
                if obj.bInit; return; end
                obj.updateWin_subj;
            case 'win'
                obj.pointW.WHdegRaw=val;
                if obj.bInit; return; end
                obj.updateWin_win;
            case 'disp'
                obj.pointD.WHdegRaw=val;
                if obj.bInit; return; end
                obj.updateWin_disp;
        end
    end
    function set.WHAMRaw(obj,val)
        switch obj.dispORwin
            case 'subj'
                obj.win3D.WHAMRaw=val;
                if obj.bInit; return; end
                obj.updateWin_subj;
            case 'win'
                obj.pointW.WHAMRaw=val;
                if obj.bInit; return; end
                obj.updateWin_win;
            case 'disp'
                obj.pointD.WHAMRaw=val;
                if obj.bInit; return; end
                obj.updateWin_disp;
        end
    end
%% GET

    function out=get.WHdeg(obj)
        switch obj.dispORwin
            case 'subj'
                out=obj.win3D.WHdeg;
            case 'win'
                out=obj.pointW.WHdeg;
            case 'disp'
                out=obj.pointD.WHdeg;
        end
    end
    function out=get.WHAM(obj)
        switch obj.dispORwin
            case 'subj'
                out=obj.win3D.WHAM;
            case 'win'
                out=obj.pointW.WHAM;
            case 'disp'
                out=obj.pointD.WHAM;
        end
    end
    function out=get.WHdegRaw(obj)
        switch obj.dispORwin
            case 'subj'
                out=obj.win3D.WHdegRaw;
            case 'win'
                out=obj.pointW.WHdegRaw;
            case 'disp'
                out=obj.pointD.WHdegRaw;
        end
    end
    function out=get.WHAMRaw(obj)
        switch obj.dispORwin
            case 'subj'
                out=obj.win3D.WHAMRaw;
            case 'win'
                out=obj.pointW.WHAMRaw;
            case 'disp'
                out=obj.pointD.WHAMRaw;
        end
    end
end
end
