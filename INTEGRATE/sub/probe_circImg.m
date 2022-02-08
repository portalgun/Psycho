classdef probe_circImg < probe
properties
    zer
    rmpSz
    crpLoc
    sz
    mask
    gry
    img
end
methods
    %% RESPONSE PROBE
    function obj=probe_circImg(ptb,p,img,crpLoc,stmXYdeg,gry,rmpSz)
        obj@probe(ptb,p.stmXYdeg,p.PszXY);
        obj.crpLoc=crpLoc;
        obj.stmXYdeg=stmXYdeg;
        obj.gry=gry;
        obj.rmpSz=rmpSz;
        obj.img=img;
        obj.pixPerDegXY=ptb.display.pixPerDegXY;
        obj=obj.face_gen_probe_circImg;
        obj=obj.alpha_gen_probe_circImg;
        obj=obj.gry_gen;
    end
    function obj=face_gen_probe_circImg(obj)
        try
            obj.face=cropImageCtrInterp(obj.img,obj.crpLoc(1,:),obj.pixPerDegXY.*obj.stmXYdeg+obj.rmpSz,'linear',0);
        catch
            obj.face=ones(round(fliplr(obj.pixPerDegXY.*obj.stmXYdeg+obj.rmpSz))).*obj.gry;
        end
        obj.sz=[size(obj.face,2) size(obj.face,1)];
        obj.zer=zeros(round(fliplr(size(obj.face))));
    end

    function obj= alpha_gen_probe_circImg(obj)

        %CIRCULAR WINDOW -> ALPHA C
        sz=max(size(obj.face))-obj.rmpSz;
        szs=[size(obj.face,1) size(obj.face,2)];
        obj.Alpha=cosWindowFlattop(szs,sz-5,obj.rmpSz+5,1);
        obj.Alpha(logical(ceil(obj.mask)))=0; %Alpha
        obj.Alpha=double(logical(obj.Alpha));

        % XXX
        %obj.Alpha=ones(size(obj))

    end
end
end
