classdef probe_circle < probe
properties
end
methods
    function obj=probe_circle()
        obj.gry_gen
        obj.alpha_gen_1
    end
    function obj=face_gen(obj)
    %circle to fill half the area of the matrix
        N = 101;
        Ra = floor(sqrt(N.^2/pi/2));
        ii = abs(floor((1:N) - N/2));
        faceRaw = double(hypot(ii',ii) <= Ra);
        face=faceRaw;

        face(faceRaw == 1)=D.prbFace*255;
        face(faceRaw == 0)=D.prbBack*255;
    end
end

%CREATE LOGICAL CIRCLE IN MATR.X

%GET ALPHA CHANNEL
Alpha=prb;
Alpha(prb ~= 0)=D.prbAlpha*255;
Alpha(prb == 0)=0;

% MAKE RGB IMAGE
obj=prb.gry_gen
prb(:,:,4)=Alpha;
