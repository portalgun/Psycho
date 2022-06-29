classdef Win3D_set < handle
methods
% GET
    function out=get.WHpix(obj)
        out=obj.WHpixDep;
    end
    %function out=get.Wpix(obj)
    %    out=obj.WHpixDep(1);
    %end
    %function out=get.Hpix(obj)
    %    out=obj.WHpixDep(2);
    %end
    %%
    function out=get.WHdeg(obj)
        out=obj.WHdegDep;
    end
    function out=get.WHAM(obj)
        out=obj.WHdegDep*60;
    end
    %function out=get.Wdeg(obj)
    %    out=obj.WHdegDep(1);
    %end
    %function out=get.Hdeg(obj)
    %    out=obj.WHdegDep(2);
    %end
    %%
    function out=get.WHm(obj)
        out=obj.WHmDep;
    end
    %function out=get.Wm(obj)
    %    out=obj.WHmDep(1);
    %end
    %function out=get.Hm(obj)
    %    out=obj.WHmDep(2);
    %end
    %%
    function out=get.WHdegRaw(obj)
        out=obj.WHdegRawDep;
    end
    function out=get.WHAMRaw(obj)
        out=obj.WHdegRaw*60;
    end
    %function out=get.WdegRaw(obj)
    %    out=obj.WHdegRawDep(1);
    %end
    %function out=get.HdegRaw(obj)
    %    out=obj.WHdegRawDep(2);
    %end

%SET
    %%
    function set.WHpix(obj,val)
        if isempty(WHpix); return; end
        if ischar(val) && strcmp('@VDisp')
            val=obj.VDisp.WHpix;
        end
        obj.WHpixDep=val;
    end
    %function set.Wpix(obj,Wpix);
    %    if isempty(Wpix); return; end
    %    obj.WHpixDep(1)=Wpix;
    %end
    %function set.Hpix(obj,Hpix);
    %    if isempty(Hpix); return; end
    %    obj.WHpixDep(2)=Hpix;
    %end

    function set.WHdeg(obj,WHdeg)
        if isempty(WHdeg); return; end
        if ischar(val) && strcmp('@VDisp')
            val=obj.VDisp.WHpix./VDidsp.pixPerDegXY;
        end
        obj.WHdegDep=WHdeg;
    end
    function set.WHAM(obj,val)
        if isempty(WHdeg); return; end
        if ischar(val) && strcmp('@VDisp')
            val=obj.VDisp.WHpix./VDidsp.pixPerDegXY;
        end
        obj.WHdegDep=val./60;
    end
    %function set.Wdeg(obj,Wdeg);
    %    if isempty(Wdeg); return; end
    %    obj.WHdegDep(1)=Wdeg;
    %end
    %function set.Hdeg(obj,Hdeg);
    %    if isempty(Hdeg); return; end
    %    obj.WHdegDep(2)=Hdeg;
    %end
    %%
    function set.WHm(obj,val)
        if isempty(WHm); return; end
        if ischar(val) && strcmp('@VDisp')
            val=obj.VDisp.WHpix./obj.VDisp.pixPerMxy;
        end
        obj.WHmDep=val;
    end
    %function set.Wm(obj,Wm);
    %    if isempty(Wm); return; end
    %    obj.WHmDep(1)=Wm;
    %end
    %function set.Hm(obj,Hm);
    %    if isempty(Hm); return; end
    %    obj.WHmDep(2)=Wm;
    %end
    %%
    function set.WHdegRaw(obj,WHdegRaw)
        if isempty(WHdegRaw); return; end
        if ischar(val) && strcmp('@VDisp')
            val=obj.VDisp.WHpix./obj.VDisp.pixPerDeg;
        end
        obj.WHdegRawDep=WHdegRaw;
    end
    function set.WHAMRaw(obj,val)
        if isempty(WHdegRaw); return; end
        if ischar(val) && strcmp('@VDisp')
            val=obj.VDisp.WHpix./obj.VDisp.pixPerDeg;
        end
        obj.WHdegRawDep=val./60;
    end
    %function set.WdegRaw(obj,HdegRaw);
    %    if isempty(HdegRaw); return; end
    %    obj.WHdegRawDep(1)=WdegRaw;
    %end
    %function set.HdegRaw(obj,HdegRaw);
    %    if isempty(HdegRaw); return; end
    %    obj.WHdegRawDep(2)=HdegRaw;
    %end
end
end
