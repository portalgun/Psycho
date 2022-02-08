classdef Counter < handle & pStr
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

    function obj=Counter(Opts,ptb,Viewer)
        if nargin < 1 || isempty(Opts)
            Opts=struct();
        end
        obj@pStr(Opts,ptb,Viewer);
        obj.nTrial=obj.Viewer.Info.nTrial;
        obj.get_text(0);
        %onarignbj.init();
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
        obj.nTrial=obj.Viewer.Info.nTrial;
        obj.get_text(obj.Viewer.trl);
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
        ptb=Ptb;
        try
            obj=Counter(100,ptb,Opts);
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


