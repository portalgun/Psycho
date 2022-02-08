classdef Psycho_hooks < handle
methods
    function present_keystart(obj)
        obj.draw_bg();
        obj.draw_keystart();
        obj.draw_complete();
        bTimeout=obj.Viewer.wait(te);
        if bTimeout
            error('timeout');
        end
    end
    function present_countdown(obj)
        for c = obj.D.nCountDown:-1:1
            obj.draw_aux();
            obj.draw_count(c);
            obj.draw_complete();
            obj.Viewer.wait(obj.D.countDownTime);
        end
        obj.draw_aux();
        obj.draw_complete();
    end
    function present_loading(obj)
        str='Loading...';
        obj.draw_bg();
        for s=obj.buffs
            sz=obj.PTB.display.scrnXYpix;
            Screen('SelectStereoDrawBuffer', obj.PTB.wdwPtr, s);
            Screen('DrawText',obj.PTB.wdwPtr, str, sz(1)/2-165, sz(2)/2-5, [obj.PTB.wht],[obj.PTB.gry obj.PTB.gry obj.PTB.gry]);
        end
        obj.draw_complete();
    end
    function present_quit_prompt(obj)
        Opts=struct();
        Opts.relPosPRC='IMM';
        text='Really quit? (y,n)';
        out=pStr(Opts,obj.PTB,text);
        out.draw();
    end
%% HELPERS
    function obj=draw_keystart(obj)
        sz=obj.PTB.display.scrnXYpix;
        str='Press Up To start';
        for s=obj.buffs
            Screen('SelectStereoDrawBuffer', obj.PTB.wdwPtr, s);
            Screen('DrawText',obj.PTB.wdwPtr, str, sz(1)/2-165, sz(2)/2-5, [obj.PTB.wht],[obj.PTB.gry obj.PTB.gry obj.PTB.gry]);
        end
    end
    function obj=draw_count(obj,c)
        sz=obj.PTB.display.scrnXYpix;
        str=num2str(c);
        for s=obj.buffs
            Screen('SelectStereoDrawBuffer', obj.PTB.wdwPtr, s);
            Screen('DrawText',obj.PTB.wdwPtr, str, ...
                sz(1)/2-10, sz(2)/2-8, ...
                [obj.PTB.wht], ...
                [obj.PTB.gry obj.PTB.gry obj.PTB.gry]);
        end
    end
end
end

