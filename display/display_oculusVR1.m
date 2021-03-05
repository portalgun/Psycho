classdef display_oculusVR1 < handle & DISPLAY
properties
    scrnZmm    = 1000;         % VIEWING DISTANCE % XXX
    scrnZm     = 1;
    scrnXYmm   = [710 400]; % DISPLAY SIZE IN MM % XXX
    comp       = 'Win64';
    wdwXYpix   = [0 0 1200 1080];
    hostname   = 'BONICE';
    scrnXYpix  = [1200 1080]; % or 1200 2160
    scrnHz      = 90;
    displaySize = [505 316]; % XXX

    bDataPixx         = 0;
    defaultStereoMode = 4; % 
    bPreScript        = 0;

    gamFncExponent = 2.2;
    gammaCorrectionType='None';
    calName = 'VIEWPixx3D_Calib'; % XXX
    X
    Y
    % ~90 horizontal ~89 vertical 110 diagonal
    % Native Color Space: Between Adobe RGB and DCI-P3 gamut, 2.2 gamma, D75 white point
    % CIE 1931 xy color-primary values:
    % Red : (0.666, 0.334)
    % Green: (0.238, 0.714)
    % Blue : (0.139, 0.053)
    % White: (0.298, 0.318)
    % Default SDK Color Space: Same as native color space, linear gamma (or native sRGB)

    % rbwidth % XXX virtual render buffer, size of virtual framebuffer
    % rbheight % XXX
    % fovL % left right up down deg
    % fovR % left right up down deg
    %
    % aspect ratio per eye 8:9
    % PPD 9.6 % pixel per degree
    % PPI 450
    % PPD = 2 * d * r tan(.5deg) # r = resolution, d distance
    % dp = sqrt(w^2+h_p^2) # dp diagonal in pxiesl:
    % PPI = dp/di # di diagonal in inches
    % IPD 58-72
end
