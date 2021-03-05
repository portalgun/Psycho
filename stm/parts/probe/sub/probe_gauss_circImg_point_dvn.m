classdef probe_gauss_circImg_point_dvn < point_dvn
properties

    bContrast
    %generated
    Li
    Ri
    Lg
    Rg

    crpLoc
    secondary % XXX
    partialOcclude=0;
    rmpSz=6;
    %rmpSz=.0001
    bBinoImg
    XYdeg
    XYpix
    prbFace

    Lp
    Rp
    LpRaw
    RpRaw
    Lprb
    Rprb

    Limg
    Rimg
    LimgRaw
    RimgRaw
    interp='bilinear'
end
methods
    function obj = probe_gauss_circImg_point_dvn(ptb,p,gry,Opts)
        % XXX
        if ~exist('gry','var')
            try
                gry=ptb.gry;
            catch
                gry=.5;
            end
        end

        if ~exist('Opts','var')
            Opts=struct;
        end
        if isfield(Opts,'secondary')
            obj.secondary=Opts.secondary;
        else
            obj.secondary=1;
        end
        if isfield(Opts,'bBinoImg')
            obj.bBinoImg=Opts.bBinoImg;
        else
            obj.bBinoImg=0;
        end
        if isfield(Opts,'locType')
            obj.locType=Opts.locType;
        else
            obj.locType='m3';
        end
        if isfield(Opts,'XYoffsetPixInit')
            obj.XYoffsetPixInit=Opts.XYoffsetPixInit;
        else
            obj.XYoffsetPixInit=[0 0];
        end
        if isfield(Opts,'LOS')
            obj.LOS=Opts.LOS;
        else
            obj.LOS='ambig';
        end
        if isfield(Opts,'XYdeg')
            obj.XYdeg=Opts.XYdeg;
        else
            obj.XYdeg=[.18 .18];
        end
        if isfield(Opts,'prbFace')
            obj.prbFace=Opts.prbFace;
        else
            obj.prbFace=1;
        end

        obj=obj.update(ptb,p,gry);
    end

    function obj = update(obj,ptb,p,gry)
        %Update Params
        obj.XYpix=obj.XYdeg.*ptb.display.pixPerDegXY;
        obj.LorR=p.LorR;

        %Location
        p=p.get_depth_map(ptb.display);
        obj=obj.get_crop_loc(ptb.display,p);

        %Probes
        obj=obj.get_circImg(ptb,p,gry);
        obj=obj.get_gaussRing(ptb,p);

        %Combine
        obj=obj.get_mask(p);
        obj=obj.get_prb;

        %Tex
        if ~isempty(ptb.wdwPtr)
            obj=obj.make_tex(ptb);
        end
    end
    function obj = get_crop_loc(obj,display,p)
        obj=obj.get_all_pos(p,display); %point
        if p.LorR=='L'
            obj.crpLoc=fliplr(obj.LitpXY-display.scrnCtr+p.PszXY/2);
        elseif p.LorR=='R'
            obj.crpLoc=fliplr(obj.RitpXY-display.scrnCtr+p.PszXY/2);
        end
    end
    function obj = get_circImg(obj,ptb,p,gry)
        if p.LorR=='L'
            Aimg=p.Limg;
            Bimg=p.Rimg;
        elseif p.LorR=='R'
            Aimg=p.Limg;
            Bimg=p.Rimg;
        end
        Ai=probe_circImg(ptb,p,Aimg,obj.crpLoc,obj.XYdeg,gry,obj.rmpSz);
        if obj.bBinoImg==1
            Bi=probe_circImg(ptb,p,Bimg,obj.crpLoc,obj.XYdeg,gry,obj.rmpSz);
        else
            Bi=Ai;
        end
        if p.LorR=='L'
            obj.Li=Ai;
            obj.Ri=Bi;
        elseif p.LorR=='R'
            obj.Li=Bi;
            obj.Ri=Ai;
        end
    end
    function obj = get_gaussRing(obj,ptb,p)
        obj.Lg=probe_gaussRing(ptb,obj.XYdeg,p.PszXY,obj.prbFace);
        obj.Rg=probe_gaussRing(ptb,obj.XYdeg,p.PszXY,obj.prbFace);
    end
    function obj = get_mask(obj,p)
        if ~obj.partialOcclude
            return
        end
        if obj.LorR=='L'
            bFG  = (obj.crpLoc(2) > p.AitpRCfgnd+obj.prbRadius(1));
            BG=p.BLs | p.FL;
            obj.L.mask=crop_mask(bFG,BG);
            obj.R.mask=obj.zer;
        elseif obj.LorR=='R'
            bFG  = (obj.crpLoc(2) < p.AitpRCfgnd+obj.prbRadius(1));
            BG=p.BRs | p.FR;
            obj.R.mask=crop_mask(bFG,BG);
            obj.L.mask=obj.zer;
        end
    end
    function mask = crop_mask(obj,bFG,BG)
        if ~bFG
            try
                mask=cropImageCtrInterp(double(BG), obj.crpLoc,obj.sz,obj.interp,0);
            end
        end
        if ~isvar('bgn')
            mask=obj.zer;
        end
    end
    function obj = get_prb(obj)
        s=size(obj.Li.Alpha);
        obj.Lprb=imresize(obj.Lg.Alpha,s,'method',obj.interp);
        obj.Rprb=imresize(obj.Rg.Alpha,s,'method',obj.interp);
        obj.Lprb=obj.Lprb./maxall(obj.Lprb);
        obj.Rprb=obj.Rprb./maxall(obj.Rprb);


        obj.Li.Alpha=obj.Li.Alpha./maxall(obj.Li.Alpha);
        obj.Ri.Alpha=obj.Ri.Alpha./maxall(obj.Ri.Alpha);

        obj.LpRaw=obj.Li.face.*obj.Li.Alpha;
        obj.RpRaw=obj.Ri.face.*obj.Ri.Alpha;
        %obj.LpRaw(obj.LpRaw<.05)=0;
        %obj.RpRaw(obj.RpRaw<.05)=0;

        obj.Lp=obj.LpRaw.*(1-obj.Lprb)+obj.Lprb;
        obj.Rp=obj.RpRaw.*(1-obj.Rprb)+obj.Rprb;
    end
    function [maskBG,new] = get_prb_mask(obj,Limg,Rimg,prbORimgORb,bTest)
        % HERE XXX %
        if ~isvar('bTest')
            bTest=0;
        end
        if obj.LorR=='L'
            map=Limg;
        elseif obj.LorR=='R'
            map=Rimg;
        end

        if obj.LorR=='L' && (strcmp(prbORimgORb,'b') || strcmp(prbORimgORb,'p'))
            mask=obj.Lg.Alpha;
            insert=obj.Lg.face;
        elseif obj.LorR=='R'&& (strcmp(prbORimgORb,'b') || strcmp(prbORimgORb,'p'))
            mask=obj.Rg.Alpha;
            insert=obj.Rg.face;
        elseif obj.LorR=='L' && strcmp(prbORimgORb,'i')
            mask=obj.Rg.Alpha/2;
            insert=obj.Li.face;
        elseif obj.LorR=='R' && strcmp(prbORimgORb,'i')
            mask=obj.Rg.Alpha/2;
            insert=obj.Ri.face;
        elseif obj.LorR=='L' &&  strcmp(prbORimgORb,'si')
            mask=ones(size(obj.Rg.Alpha))/10;
            insert=obj.Li.face;
        elseif obj.LorR=='R' &&  strcmp(prbORimgORb,'si')
            mask=ones(size(obj.Rg.Alpha))/10;
            insert=obj.Ri.face;
        end

        mask  =imresize(mask,  obj.XYpix,'method',obj.interp);
        insert=imresize(insert,obj.XYpix,'method',obj.interp);

        [new,maskBG]=cutAndFillHole(map,obj.crpLoc,mask,insert,0,bTest);
        if ~strcmp(prbORimgORb,'p')
            k=logical(maskBG>.05);
            maskBG=(cumsum(k) & cumsum(k,'reverse')).*new;
            maskBG=logical(maskBG);
        else
            maskBG=logical(maskBG>.05);
        end
        % NOTE
        %obj.plot
    end
    function [mask,insert]=face_fun(obj,gAlpha,gFace,iAlpha,iFace)
        bTest=0;
        insert=zeros(size(gFace));
        mask=iAlpha;

        %iAlpha=ones(size(iAlpha)):
        ind1=logical(iAlpha & ~gAlpha);
        insert(ind1)=iFace(ind1);

        ind=~(ind1 | logical(~iAlpha & ~gAlpha));

        gA=gAlpha(ind);
        gN=(1-gAlpha(ind));
        gF=gFace(ind);
        iF=iFace(ind);

        insert(ind)=gA.*gF+iF.*gN;

        if bTest==1
            obj.face_fun_plot(insert,mask);
        end
    end
    function []=face_fun_plot(obj,insert,mask)
        figure(22)
        imagesc(insert)
        formatImage;
        title('Insert')
        colorbar

        figure (667)
        imagesc(mask)
        formatImage
        title('mask')
        colorbar
    end
    function [] = plot_prb(obj)
        cx=[0 1];

        subplot(3,1,1);
        imagesc(obj.LpRaw)
        formatImage;
        caxis(cx);
        colorbar

        subplot(3,1,2);
        imagesc(obj.Lprb)
        formatImage;
        caxis(cx);
        colorbar

        subplot(3,1,3)
        imagesc(obj.Lp)
        formatImage;
        caxis(cx);
        colorbar
    end
    function [] = plot(obj)
        imagesc([obj.Limg obj.Rimg].^.4)
        formatImage;
        colorbar
        hold on
        %if obj.LorR=='L'
        %    plot(obj.crpLoc(2),obj.crpLoc(1),'.r')
        %    %plot(obj.crpLoc(2)-.5,obj.crpLoc(1)+.5,'.r')
        %elseif obj.LorR=='R'
        %    plot(obj.crpLoc(2),obj.crpLoc(1)+PszXY(1),'.r')
        %end
        hold off
    end
end
end
