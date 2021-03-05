classdef probe < handle & stim
properties
    %bino stim is a struct of 2 probe
    bBino
    prbFace
    prbBack
    alphaScale %prbAlpha

    faceRaw
    face
    Alpha
    rgba
    tex

    Lratio
end
methods
    function obj = probe(ptb,stmXYdeg,PszXY)
        obj.get_psy(ptb,stmXYdeg,PszXY);
    end
    function obj=alpha_gen_0(obj)
        obj.Alpha=obj.face*255;
    end
    function obj=alpha_gen_1(obj)
        obj.Alpha=prb;
        obj.Alpha(faceRaw == 0)=0;
        obj.Alpha(faceRaw ~= 0)=obj.alphaScale*255;
    end
    function obj=alpha_gen_2(obj)
        obj.Alpha=prb;
        obj.Alpha(obj.faceRaw == 0)=0;
        obj.Alpha(obj.faceRaw ~= 0)=1;
        obj.Alpha=obj.Alpha*obj.alphaScale; %.8
    end

    function obj=gry_gen(obj)
        obj.rgba=repmat(obj.face,1,1,4);
        obj.rgba(:,:,4)=obj.Alpha;
    end

    function obj=l_ratio_gen(obj)
        obj.Lratio=size(Prb,1)/size(Prb,2);
    end
    function obj= make_tex(obj,ptb)
        if obj.bBino
            obj.tex{1} = Screen('MakeTexture', ptb.wdwPtr, obj.rgba{1},[],[],2);
            obj.tex{2} = Screen('MakeTexture', ptb.wdwPtr, obj.rgba{2},[],[],2);
        else
            obj.tex = Screen('MakeTexture', prb.wdwPtr, obj.rgba,[],[],2);
        end
    end
end
end
