classdef Common3D < handle
% init &  planes
% no ptb stuff
properties
    VDisp
end

methods
    function obj=update_display(obj,ptbORd)
        obj.get_vDisp(ptbORd);
    end
    function get_vDisp(obj,ptbORd)
        if isa(ptbORd,'Ptb')
            obj.bStereo=ptbORd.bStereo;
            obj.VDisp=ptbORd.vDisp;
        elseif isa(ptbORd,'VDisp')
            obj.VDisp=ptbORd;
        elseif isa(ptbORd,'Win3D')
            obj.VDisp=DISPALY.win2disp();
        elseif ischar(ptbORd)
            obj.VDisp=VDisp();
        end
    end
%% UPDATE
    function m=pix2m(obj,val)
        m=val./obj.VDisp.pixPerMXY;
    end
    function pix=m2pix(obj,val)
        pix=val.*obj.VDisp.pixPerMxy;
    end
    function m=deg2m(obj,val)
        m=val./obj.VDisp.degPerMxy;
    end
    function deg=m2deg(obj,val)
        deg=val.*obj.VDisp.degPerMxy;
    end

end
end
