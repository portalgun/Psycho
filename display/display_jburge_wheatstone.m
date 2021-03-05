classdef display_jburge_wheatstone < handle & DISPLAY
properties
    scrnZmm    = 1000;         % VIEWING DISTANCE
    scrnZm     = 1;
    scrnXYmm   = [522 291]; % DISPLAY SIZE IN MM
    gamFncExponent = 2.2;
    comp       = 'MACI64';
    wdwXYpix   = [0 0 1920 1080];
    hostname   = 'jburge-wheatstone';
    scrnXYpix  = [1920 1080];
    scrnHz      = 120;
    displaySize = [518 291]

    bDataPixx         = 1;
    defaultStereoMode = 6;
    bPreScript        = 0

    gammaCorrectionType='LookupTable';
    calName = 'VIEWPixx3D_Calib'
    X
    Y
    
    bSkipSyncTest=1;
    
end
end
