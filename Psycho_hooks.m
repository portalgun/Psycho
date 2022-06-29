classdef Psycho_hooks < handle
methods
    function present_keystart(obj)
        text='Press key to start.';
    end
    function present_countdown(obj,count,num)
        text=num2str(num);
    end
    function present_loading(obj)
        text='Loading...';
    end
    function present_quit_prompt(obj)
        text='Really quit? (y,n)';
    end
    function present_continue_prompt(obj)
        text='Continue to next block? (y,n)';
    end
end
end

