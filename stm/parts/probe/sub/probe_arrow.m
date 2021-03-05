classdef probe_arrow < probe
properties
end
methods
    function obj=probe_arrow()
        obj
        obj.alpha_gen_2
        obj.l_ratio_gen;
    end
    function obj=face_gen_probe_arrow(obj)
        W=10;
        H=W*2;
        prb=zeros(round(H/3),W);
        prb2=zeros(1,W);
        prb3=zeros(round(H/2.5),W);
        if mod(W,2)==0
            prb(:,W/2:W/2+1)=1;
        else
            prb(:,floor(W/2):ceil(W/2))=1;
            prb2(:,floor(W/2):ceil(W/2))=1;
        end
        obj.face=[prb;prb2;prb3;prb2;prb];
        obj.faceRaw=obj.face;
    end
    function obj=make_tex_probe_arrow(obj,ptb)
        obj.prbRingTex{1} = Screen('MakeTexture', ptb.wdwPtr, obj.face,[],[],2);
        obj.prbRingTex{2} = Screen('MakeTexture', ptb.wdwPtr, obj.face,[],[],2);
    end
end
end
