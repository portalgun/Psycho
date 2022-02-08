classdef PsyElObj < handle
methods(Abstract)
    get_tex(obj,f)
    get_rect(obj)
    draw(obj,f)
    close(obj)
end
end
