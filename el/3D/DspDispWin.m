classdef DspDispWin < handle
properties
    trgtDSP
    obsDSP
    diffDSP

    win
    foc %pointDispWin
    trgt %pointDispWin

end
methods
    function obj=DspDispWin(trgtDSP,display,winOpts,trgtDispORwin,trgtOpts,focDispORwin,focOpts)
        obj.win=Win3D(display,winOpts);
        obj.trgt=PointDispWin3D(display,obj.win,trgtOpts,trgtDispORwin);
        obj.win=obj.trgt.win;
        obj.foc =PointDispWin3D(display,obj.win,focOpts,  focDispORwin);

        obj.set_DSP(trgtDSP);

    end
    function obj=set_DSP(obj,trgtDSP)
        obj.trgtDSP=trgtDSP;
        obj.get_obsDSP();
        obj.get_diffDSP();
    end
    function obj=get_obsDSP(obj)
        obj.obsDSP=obj.trgt.pointD.vrgXY - obj.foc.pointD.vrgXY;
    end
    function obj=get_diffDSP(obj)
        obj.diffDSP=obj.trgtDSP-obj.obsDSP;
    end
%%
end
end
