classdef Common3D < handle
% init &  planes
% no ptb stuff
properties
    LExyz=[-0.065/2 0 0]
    RExyz=[0.065/2 0 0]
    IPDm=0.065
    IppXm
    IppYm
    IppZm
    IppXpix
    IppYpix

    wdwXYpix
    scrnCtr
    bStereo

    pixPerDeg
    pixPerM
    MperDeg
end
methods
    function obj=update_display(obj,ptbORd)
        display=obj.get_display(ptbORd);
        obj.update_pp(display);
        obj.update_pp_pix(display);
        obj.update_units(display);
    end
    function display=get_display(obj,ptbORd)
        if isa(ptbORd,'ptb_session')
            obj.bStereo=ptbORd.bStereo;
            display=ptbORd.display;
        elseif isa(ptbORd,'DISPLAY')
            display=ptbORd;
        elseif isa(ptboRd,'Win3D')
            display=DISPALY.win2disp();
        elseif ischar(ptbORd)
            display=DISPLAY.get_display_from_hostname();
        end
    end
%% UPDATE
    function obj=update_pp(obj,ptbORd)
        display=obj.get_display(ptbORd);
        obj.IppXm=pointer(display.CppXm);
        obj.IppYm=pointer(display.CppYm);
        obj.IppZm=pointer(display.CppZm);
    end
    function obj=update_pp_pix(obj,ptbORd)
        display=obj.get_display(ptbORd);
        obj.IppXpix=pointer(display.CppXpix);
        obj.IppYpix=pointer(display.CppYpix);
    end
    function obj=update_units(obj,ptbORd)
        display=obj.get_display(ptbORd);
        obj.pixPerDeg=display.pixPerDegXY;
        obj.pixPerM=display.pixPerMxy;
        obj.MperDeg=1./display.degPerMxy;
    end
    function obj=update_wdwXYpix(obj,ptbORd)
        display=obj.get_display(ptbORd);
        obj.wdwXYpix=display.wdwXYpix;
        obj.scrnCtr=display.scrnCtr;
    end


    function [IppXm,IppYm,IppZm]=get_pp(obj)
        IppXm=ret(obj.IppXm);
        IppYm=ret(obj.IppYm);
        IppZm=ret(obj.IppZm);
    end
    function [IppXpix,IppYpix]=get_pp_pix(obj)
        IppXpix=ret(obj.IppXpix);
        IppYpix=ret(obj.IppYpix);
    end
%%  CONVERSIONS

    function m=pix2m(obj,val)
        m=val./obj.pixPerM;
    end
    function pix=m2pix(obj,val)
        pix=val.*obj.pixPerM;
    end
    function m=deg2m(obj,val)
        m=val.*MperDeg;
    end
    function deg=m2deg(obj,val)
        deg=val./MperDeg;
    end

end
methods(Static)
    function p=get_parseOpts()
        p={ ...
            'LExyz', [-0.065/2 0 0], ...
           ;'RExyz', [0.065/2 0 0], ...
           ;'IPDm',  0.065, ...
           ;'IppXm', [], ...
           ;'IppYm', [], ...
           ;'IppZm', [], ...
           ;'IppXpix',[], ...
           ;'IppYpix',[], ...
           ;'wdwXYpix',[], ...
           ;'scrnCtr',[], ...
           ;'bStereo',[], ...
           ;'pixPerDeg',[], ...
           ;'pixPerM',[], ...
           ;'MperDeg',[], ...
        };
    end

end
end
