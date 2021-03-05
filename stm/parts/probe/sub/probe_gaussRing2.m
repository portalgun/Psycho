classdef probe_gaussRing2 < probe
properties
end
methods
    function obj=gauss_ring2()
        obj.face_gen
        obj.gry_gen
        obj.alpha_gen_1
    end
    function obj=face_gen
        N = 21;
        Ra = floor(sqrt(N.^2/pi/2));
        ii = abs(floor((1:N) - N/2));
        obj.faceRaw = double(hypot(ii',ii) <= Ra);
        obj.face=obj.faceRaw;
        obj.face(obj.faceRaw == 1)=D.prbFace*255;
        obj.face(obj.faceRaw == 0)=D.prbBack*255;
    end
end
