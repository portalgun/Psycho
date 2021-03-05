classdef counter < handle & pStr
properties
end
properties(Hidden=true)
    maxChar
    nTrial

    %offrect
    %height
    %advance

end
methods

    function obj=counter(nTrial,ptb,Opts)
        if ~exist('Opts','var')
            Opts=struct();
        end
        obj@pStr(Opts,ptb);
        obj.nTrial=nTrial;
        obj.init();
    end
    function obj=get_rect(obj)
    % OVERRIDE
        n=ceil(log10(obj.nTrial));
        trial=10^n*8;
        obj.maxChar=n+1;
        obj.get_text(trial);

        get_rect@pStr(obj);
    end
    function obj=draw(obj,trial)
    % OVERRIDE
        if ~exist('trial','var') && ~isempty(trial)
            trial=0;
        end
        obj.get_text(trial);
        draw@pStr(obj);
    end
    function obj=get_text(obj,trial)
        f=['% ' num2str(obj.maxChar) 'i'];
        str=num2str(trial,f);
        obj.text=['Trial ' num2str(str) '/' num2str( obj.nTrial ) ];
    end
end
methods(Static=true)
    function obj=test()
        Opts=struct();
        Opts.relPosPRC='IBM';
        Opts.borderColor=1;
        ptb=ptb_session;
        try
            obj=counter(100,ptb,Opts);
            for i = 1:5:100
                obj.draw(i);
                ptb.flip;
                pause(.1)
            end
            sca
            ListenChar(0);
        catch ME
            sca
            ListenChar(0);
            rethrow(ME);
        end

    end
end
end


