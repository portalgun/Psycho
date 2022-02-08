classdef Probe < ptch
methods
    function obj=Probe(PszRC,shape,subjInfo,trgtInfo,winInfo)
        obj@ptch(PszRC,PszRC,srcInfo,bStereo,mapNames,mskNames,texNames,wdwInfo,src)
        obj.update_dsp()
    end
    function obj=update_dsp(obj)
        obj.get_win()
    end
end
end
