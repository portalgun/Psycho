classdef threeD < handle
properties
    %DspDispWin
    dsp
    dspAM
    vrg
    vrgAM
    distZm
    depthZm

    offsetDsp
    offsetVrg
    offsetDist

    %Win3D
    shape
    rect
    relRec
    relPosPRC

    WHm
    WHpix
    WHdeg
    WHdegRaw


properties(Access=protected)
    DspDispWin
end
end
function get.dsp()
end
function get.dspAM()
end
function get.vrg()
end
function get.vrgAM()
end
function get.depthZm()
end
function get.offsetDsp()
end
function get.offsetVrg()
end
function get.offsetDist()
end
