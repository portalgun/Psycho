classdef Ptch < handle & psyEl & common3D & shape3D & point3D
    % XXX when to fetch Ptch
end
properties
    PATCHES
    rule % how patches should be initialized etc.

    updateInd

    shape='rect'

    index % conversion from t i to patches index LOADED XXX?
    patch % current
end
methods
    function Ptch(ptb,patchesOpts)
        obj.PATCHES=ptchs.load(patchesOpts.imgDatabase,patchesOpts.name);
        obj@psyEl(ptb,patchesOpts,Parent,index)
        obj.PATCHES.adopt_win_opts(patchesOpts.win);
        obj.PATCHES.adopt_img_opts(patchesOpts.img);
        obj.PATCHES.adopt_mask_opts(patchesOpts.mask);
    end
    function call_interval(obj,i)
        % XXX obj.t already set?
        obj.get_ptch()
        call_interval@psyEl(obj.i);
    end
    function obj=get_ptch(t,i)
        % XXX updating
        obj.get_patch_index(t,i)

        obj.patch=obj.PATCHES.get_patch(obj.index);
        obj.patch_to_Ptch()
    end
    function ind=get_patch_index(t,i)
        % XXX
    end
    function obj=patch_to_img()
        % XXX
        obj.img
    end
%%
    function obj=get_winOpt(obj,t,i)
    end
    function obj=get_maskOpt(obj,t,i)
    end
end
end
