classdef stmInd < handle & psyInd
%  XXX initialize UnqInds
properties
    %trlInds < psyInd
    %   interval index
    %   [nTrl x 1 + nIntrvl + 1]
    %     init
    %     close
    %        plate
    %        ch
    %        patch
    %        win
    %        mask


    % [nti x 1]
    plUnqInds
    cUnqInds
    pUnqInds
    wUnqInds
    mUnqInds

    % STATUS
    %[ nti x 1]
    % -1 0 1 2 3
    % -2 needs initialized
    % -1 closed
    % 0 uninitialized
    % 1 init
    % 2 drawn
    plStatus
    % -2 -1 0 1
    cStatus
    % -2 -1 0 1
    pStatus % text
    % -2 -1 0 1x 2
    wStatus
    % -2 -1 0 1x 2
    mStatus
    % -2 -1 0 1x 2

    InitPlate
    initCh
    InitPatch
    InitWin
    InitMask

    bDrawPlate
    bDrawPatch
    bDrawCh

    bClosePlate
    bCloseCh
    bCloseWin
    bCloseMask
    bClosePatch

end
properties(Hidden=true)

    plUnqInd
    cUnqInd
    pUnqInd
    wUnqInd
    mUnqInd

end
methods
    function obj=stmInd(Stm,Opts)
        obj@psyInd(psyEl,Opts);
    end
    function obj=init_unqInds(obj);
        % XXX
    end
%% INIT HELPERS
    function obj=init_trlInds(obj,iORc)
        obj.init_trlInds('init','plate');
        obj.init_trlInds('init','ch');
        obj.init_trlInds('init','win');
        obj.init_trlInds('init','mask');
        obj.init_trlInds('init','patch');

        obj.init_trlInds('close','plate');
        obj.init_trlInds('close','ch');
        obj.init_trlInds('close','win');
        obj.init_trlInds('close','mask')
        obj.init_trlInds('close','patch')

    end
%% CHECK
    function obj=check_init(obj,t,i)
        obj.update_ti(t,i);
        obj.InitPlate=obj.trlInds.init.plate{obj.ti_p}:
        obj.initCh=obj.trlInds.init.ch{obj.ti_p};
        obj.InitWin=obj.trlInds.init.win{obj.ti_p};
        obj.InitMask=obj.trlInds.init.mask{obj.ti_p}:
        obj.InitPatch=obj.trlInds.init.patch{obj.ti_p}:
    end

    function obj=check_draw(obj,t,i)
        obj.update_ti(t,i);
        obj.check_draw_plate();
        obj.check_draw_ch();
        obj.check_draw_patch();
    end
    function obj=check_close(obj,t,i)
        obj.update_ti(t,i);
        obj.check_close_plate();
        obj.check_close_ch();
        obj.check_close_win();
        obj.check_close_mask();
        obj.check_close_patch();
    end
    function obj=check_draw_plate(obj);
        obj.bDrawPlate=~isempty(obj.plUnqInd)
        if obj.bDrawPlate && obj.plStatus(ob.ti)<1
            error('Trying to draw plate, but not initialized.')
        end
    end
    function obj=check_draw_ch(obj);
        obj.bDrawCh=~isempty(obj.cUnqInd)
        if obj.bDrawCh && obj.cStatus(ob.ti)<1
            error('Trying to draw Ch, but not initialized.')
        end
    end
    function obj=check_draw_patch(obj);
        obj.bDrawPatch=~isempty(obj.pUnqInd)
        if obj.bDrawPatch && obj.pStatus(obj.ti)<1
            error('Trying to draw patch, but not initialized.')
        end
    end
%% CHECK CLOSE
    function obj=check_close_plate(obj);
        obj.bClosePlate=obj.trlInds.close.plate(obj.ti_p);
        if obj.bClosePlate && obj.plStatus(obj.ti)<1
            error('Trying to close tex, but not initialized.')
        end
    end
    function obj=check_close_ch(obj);
        obj.bCloseCh=obj.trlInds.close.ch(obj.ti_p);
        if obj.bCloseCh && obj.cStatus(obj.ti)<1
            error('Trying to close Ch, but not initialized.')
        end
    end
    function obj=check_close_win(obj);
        obj.bCloseCh=obj.trlInds.close.ch(obj.ti_p);
        if obj.bCloseCh && obj.cStatus(obj.ti)<1
            error('Trying to close Ch, but not initialized.')
        end
    end
    function obj=check_close_mask(obj);
        obj.bCloseMask=obj.trlInds.close.mask(obj.ti_p);
        if obj.bCloseMask && obj.mStatus(obj.ti)<1
            error('Trying to close mask, but not initialized.')
        end
    end
    function obj=check_close_patch(obj);
        obj.bClosePatch=obj.trlInds.close.patch(obj.ti_p);
        if obj.bClosePatch && obj.pStatus(obj.ti)<2
            error('Trying to close Patch, but not drawn.')
        end
    end
%% INDECES

    function obj=get_unqInd(obj)
        obj.plUnqInd=obj.plUnqInds(obj.ti)
        obj.cUnqInd=obj.cUnqInds(obj.ti)
        obj.pUnqInd=obj.pUnqInds(obj.ti)
        obj.wUnqInd=obj.wUnqInds(obj.ti)
        obj.mUnqInd=obj.mUnqInds(obj.ti)
    end
%% STATUS
    function out=update_plate_status(t,i,code)
        obj.update_ti(t,i);
        obj.plStatus(obj.ti)=code;
    end
    function out=update_ch_status(t,i,code)
        obj.update_ti(t,i);
        obj.chStatus(obj.ti)=code;
    end
    function out=update_win_status(t,i,code)
        obj.update_ti(t,i);
        obj.wStatus(obj.ti)=code;
    end
    function out=update_mask_status(t,i,code)
        obj.update_ti(t,i);
        obj.mStatus(obj.ti)=code;
    end
    function out=update_patch_status(t,i,code)
        obj.update_ti(t,i);
        obj.pStatus(obj.ti)=code;
    end
end
