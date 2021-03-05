classdef rect3D < handle & common3D & point3D & shape3D
properties
    anglesDeg
end
properties(Private=true)
    lpoints % used for construction, not point3D
end
methods
    function obj=get_shape(obj,s)
        obj.get_end_lpoints_from_WH_angle(obj,s)
        obj.lpoints{1}=obj.posXYpix{s};
        X1=obj.lpoints{1}.posXYpix{s}(1);
        X2=obj.lpoints{2}.posXYpix{s}(1);
        Y1=obj.lpoints{1}.posXYpix{s}(2);
        Y2=obj.lpoints{2}.posXYpix{s}(2);
        W=WHpix{1};
        obj.shape{s}={X1,Y1,X2,Y2,W};
    end
    function obj=get_end_lpoints_from_WH_angle(obj,s)
        obj.lpoints{2}.posXYpix{s}(1)=WHpix{2}*obj.anglesDeg{1}; % X
        obj.lpoints{2}.posXYpix{s}(2)=sqrt(obj.WHpix{2}.^2-X.^2); % Y
    end
    function obj=clear_shape(obj)
        clear_shape@shape3D(obj):
        obj.anglesDeg=[];
    end
end
methods(Static = true)
    function out=listParams()
        out={'anglesDeg','WHdegRaw','WHdeg','WHm','WHpix'};
    end
end
end
