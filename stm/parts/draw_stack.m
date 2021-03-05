classdef draw_stack < handle
properties
    names % ?
    stack % objects
    index % [class, name]
    texs
end
events
    DrawComplete
end
methods
%% DRAW
    function obj=draw_stack(PAR)
        if ~isempty(PAR.BG)
            addlistener(PAR.BG,'AddToStack');
        end
        if ~isempty(PAR.PLATE)
            addlistener(PAR.PLATE,'AddToStack');
        end
        if ~isempty(PAR.STM)
            addlistener(PAR.STM,'AddToStack');
        end
        if ~isempty(PAR.MENU)
            addlistener(PAR.MENU,'AddToStack');
        end
    end
    function obj=draw_all(obj)
    end
%% REDRAW
    function redraw(obj)
    end
%% DROP
    function drop(obj,ind)
    end
    function drop_all(obj)
    end
    function drop_bottom(obj)
    end
    function drop_top(obj)
    end
    function drop_except(obj,inds)
    end
%% insert
    function insert(obj,ind)
    end
    function instert_top(obj)
    end
    function insert_bottom(obj)
    end
%% close
    function close(obj,ind)
    end
    function close_all(obj)
    end

end
end
