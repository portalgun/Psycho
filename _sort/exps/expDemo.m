classdef expDemo < handle & psycho
properties
end
methods
end

    function obj=draw_cascade_patch_demo(obj)
        obj.draw_cascade_patch(obj.exp.stdORcmp);
    end
    function obj=run(obj)
        if obj.exitflag
            run@psycho(obj);
        end
    end
    function init()
        obj.exp.stdORcmp='std';
        obj.mode='n';
    end

    function obj=trial(obj)
        obj.draw_cascade_patch;
        obj.key.read_literal_hold();
        obj.command_dispatcher();
    end
% -----------

    function obj=deg_or_pix_toggle(obj)
        if strcmp(obj.exp.degORpix,'deg')
            obj.exp.degORpix='pix';
        else
            obj.exp.degORpix='deg';
        else
    end
    function obj=std_or_cmp_toggle(obj)
        if strcmp(obj.exp.stdORcmp,'std') && ~isempty(obj.p.cmp)
            obj.exp.stdORcmp='cmp';
        else
            obj.exp.stdORcmp='std';
        end
    end

end
end
