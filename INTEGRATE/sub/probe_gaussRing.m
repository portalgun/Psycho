classdef probe_gaussRing < probe
properties
    prbRingTex
    thresh=.98;
    expo=100;
    %expo=1000;
    diameter=21;
end
methods
    function obj=probe_gaussRing(ptb,stmXYdeg,PszXY,prbFace)
        obj@probe(ptb,stmXYdeg,PszXY);
        obj.prbFace=prbFace;
        obj=obj.update(ptb,obj.stmXYdeg);
    end
    function obj=update(obj,ptb,stmXYdeg,PszXY,prbFace)
        if exist('PszXY','var')
            obj.PszXY=PszXY;
        end
        if exist('stmXYdeg','var')
            obj.stmXYdeg=stmXYdeg;
        end
        if exist('prbFace','var')
            obj.prbFace=prbFace;
        end
        obj=obj.alpha_gen_probe_gaussRing; % unique here
        obj=obj.face_gen_probe_gaussRing;
        obj=obj.gry_gen;
        if ~isempty(ptb.wdwPtr)
            obj=obj.make_tex(ptb);
        end
    end
    function obj=alpha_gen_probe_gaussRing(obj)
        x=linspace(-10,10,obj.diameter);
        [x,y]=meshgrid(x);
        z = sin(sqrt(.03*x.^2 + .03*y.^2))/3;
        mult=1/max(max(z));

        z=z*mult;
        z(z<obj.thresh)=0;
        obj.Alpha=z.^obj.expo;
    end
    function obj=face_gen_probe_gaussRing(obj)
        obj.face=obj.prbFace*ones(size(obj.Alpha));
    end
end
end
