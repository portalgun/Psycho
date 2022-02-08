classdef Rect3D < handle & Common3D & Point3D & Shape3D
methods
    function obj=Rect3D(ptbORdisp,Opts)
        if ~exist('ptbORdisp','var') && ~exist('Opts','var')
            return
        end
        if ~exist('Opts','var') || isempty(Opts)
            Opts=struct();
        end

        obj=obj.input_parser_shape3D(Opts);
        obj.update_display(ptbORdisp);
        obj.init_point();
        obj.init_shape();

    end
    function obj=get_shape(obj,s)
        ctrRC=flipLR(obj.posXYpix{s});
        h=obj.WHpix{s}(2);
        w=obj.WHpix{s}(1);
        obj.shape{s}=Rec.rect(ctrRC,h,w);
    end
end
end
