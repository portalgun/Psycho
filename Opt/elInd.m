classdef elInd < handle & psyInd
%  XXX initialize UnqInds
properties
    %trlInds < psyInd
    %   interval index
    %   [nTrl x 1 + nIntrvl + 1]
    %     init
    %     close
    %        shape
    %        img
    %        tex
    %        point
    %        text

    % [nti x 1]
    sUnqInds
    tUnqInds
    iUnqInds

    % STATUS
    %[ nti x 1]
    % -1 0 1 2 3
    % -2 needs get
    % -1 closed
    % 0 uninitialized
    % 1 init
    % 2 drawn
    iStatus
    % -2 -1 0 1
    pStatus
    % -2 -1 0 1
    xStatus % text
    % -2 -1 0 1x 2
    sStatus
    % -2 -1 0 1x 2
    tStatus
    % -2 -1 0 1x 2

    InitText  % Txt
    InitPoint % point3D
    InitShape % shape3D
    InitImg   % Ptch
    InitTex   % Img

    bDrawText  % Txt
    bDrawShape % shape3D
    bDrawTex   % Img

    bCloseText  % Txt
    bClosePoint % point3D
    bCloseShape % shape3D
    bCloseTex   % Img

end
properties(Hidden=true)

    tUnqInd
    sUnqInd
    iUnqInd
    ipInd

end
methods
    function obj=elInd(psyEl,Opts)
        obj@psyInd(psyEl,Opts);
    end
    function obj=init_unqInds(obj);
        % XXX
    end
%% INIT HELPERS
    function obj=init_trlInds(obj,iORc)
        obj.init_trlInds('init','shape');
        obj.init_trlInds('init','img');
        obj.init_trlInds('init','tex');
        obj.init_trlInds('init','point');
        obj.init_trlInds('init','text');

        obj.init_trlInds('close','shape');
        obj.init_trlInds('close','img');
        obj.init_trlInds('close','tex');
        obj.init_trlInds('close','point')
        obj.init_trlInds('close','text')

    end
%% CHECK
    function obj=check_init(obj,t,i)
        obj.update_ti(t,i);
        obj.InitShape=obj.trlInds.init.shape{obj.ti_p};
        obj.InitImg=obj.trlInds.init.img{obj.ti_p};
        obj.InitTex=obj.trlInds.init.tex{obj.ti_p}:
        obj.InitTex=obj.trlInds.init.text{obj.ti_p}:
        obj.InitPoint=obj.trlInds.init.point{obj.ti_p}:
    end
    function obj=check_draw(obj,t,i)
        obj.update_ti(t,i);
        obj.check_draw_shape();
        obj.check_draw_tex();
        obj.check_draw_text();
    end
    function obj=check_close(obj,t,i)
        obj.update_ti(t,i);
        obj.check_close_tex();
        obj.check_close_shape();
        obj.check_close_point();
        obj.check_close_text();
    end

%% CHECK DRAW
    function obj=check_draw_shape(obj)
        obj.bDrawShape=~isempty(obj.sUnqInd)
        if obj.bDrawShape && obj.sStatus(ob.ti)<1
            error('Trying to draw shape, but not initialized.')
        end
    end
    function obj=check_draw_tex(obj);
        obj.bDrawTex=~isempty(obj.tUnqInd)
        if obj.bDrawTex && obj.tStatus(obj.ti)<1
            error('Trying to draw shape, but not initialized.')
        end
    end
    function obj=check_draw_text(obj)
        obj.bDrawText=~isempty(obj.xUnqInd)
        if obj.bDrawText && obj.xStatus(obj.ti)<1
            error('Trying to draw text, but not initialized.')
        end
    end
%% CHECK CLOSE
    function obj=check_close_tex(obj);
        obj.bCloseTex=obj.trlInds.close.tex(obj.ti_p);
        if obj.bCloseTex && obj.tStatus(obj.ti)<2
            error('Trying to close tex, but not drawn.')
        end
    end
    function obj=check_close_shape(obj);
        obj.bCloseShape=obj.trlInds.close.shape(obj.ti_p);
        if obj.bCloseShape && obj.sStatus(obj.ti)<1
            error('Trying to close shape, but not initialized.')
        end
    end
    function obj=check_close_point(obj);
        obj.bClosePoint=obj.trlInds.close.point(obj.ti_p);
        if obj.bClosePoint && obj.pStatus(obj.ti)<1
            error('Trying to close point, but not initialized.')
        end
    end
    function obj=check_close_image(obj)
        obj.bCloseImage=obj.trlInds.close.Image(obj.ti_p);
        if obj.bCloseImage && obj.tStatus(obj.ti)<1
            error('Trying to close image, but not initialzied.')
        end
    end
    function obj=check_close_text(obj)
        obj.bCloseText=obj.trlInds.close.text(obj.ti_p);
        if obj.bCloseText && obj.xStatus(obj.ti)<1
            error('Trying to close tex, but not initialized.')
        end
    end
%% INDECES

    function obj=get_unqInd(obj)
        obj.sUnqInd=obj.sUnqInds(obj.ti)
        obj.iUnqInd=obj.iUnqInds(obj.ti)
        obj.tUnqInd=obj.tUnqInds(obj.ti)
        obj.xUnqInd=obj.xUnqInds(obj.ti)
    end
%% STATUS
    function out=update_img_status(t,i,code)
        obj.update_ti(t,i);
        obj.iStatus(obj.ti)=code;
    end
    function out=update_tex_status(t,i,code)
        obj.update_ti(t,i);
        obj.tStatus(obj.ti)=code;
    end
    function out=update_shape_status(t,i,code)
        obj.update_ti(t,i);
        obj.sStatus(obj.ti)=code;
    end
    function out=update_text_status(t,i,code)
        obj.update_ti(t,i);
        obj.xStatus(obj.ti)=code;
    end
    function out=update_point_status(t,i,code)
        obj.update_ti(t,i);
        obj.pStatus(obj.ti)=code;
    end
end
