%gaussian
classdef probe_gauss < probe
properties
end
methods
    function obj=probe_gauss()
        face_gen;
        alpha_gen_1;
    end
    function obb=face_gen()
        prbInt=1;
        Prb=gaussKernel2D([],20,0);
        Prb=Prb/max(max(Prb));
        obj.face=Prb/(1-D.gry)+D.gry;
        obj.faceRaw=Prb;
    end
end
