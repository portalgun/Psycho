classdef display_BONICH < handle & DISPLAY
properties
    scrnZmm    = 1000;         % VIEWING DISTANCE
    scrnZm     = 1;
    scrnXYmm   = [505 316]; % DISPLAY SIZE IN MM
    comp       = 'Linux';
    wdwXYpix   = [0 0 1920 1200];
    hostname   = 'BONICE';
    scrnXYpix  = [1920 1200];
    scrnHz      = 60;
    displaySize = [505 316];

    bDataPixx         = 0;
    defaultStereoMode = 6;
    bPreScript        = 0;

    gamFncExponent = 2.2;
    gammaCorrectionType='None';
    calName='';
    X
    Y
end
end
