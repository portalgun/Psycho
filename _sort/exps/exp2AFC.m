classdef exp2AFC < handle & psycho
properties
    expType='2AFC';
end
methods
    function obj=exp2AFC(patchesExp,Opts,bTest)
        obj@psycho(patchesExp,Opts,bTest);
    end
    function obj=init(obj)
        obj.OUT=struct();
        obj.OUT.R=nan(size(obj.indTrl));
        obj.OUT.bCorrect=nan(size(obj.indTrl));
        obj.OUT.bCmpChosen=nan(size(obj.indTrl));

        if obj.exp.xORz=='x'
            set_key_defs(obj,'x');
        elseif obj.exp.xORz=='z'
            set_key_defs(obj,'z');
        end

    end
    function P=parse_defs_exp(obj)
        P={ ...
                'xORz'         ,'x'   ,@(x) isequal(x,'x') || isequal(x ,'z') ...
                ;'magORval'     ,'val' ,@(x) isequal(x,'mag') | isequal(x,'val') ...
                ;'iii'          ,.1    ,@isnumeric ...
                ;'iti'          ,.1    ,@isnumeric ...
                ;'duration'     ,.5    ,@isnumeric ...
                ;'bSoundCorrect',1     ,@isbinary ...
                ;'RMSmonoORbino','bino',@ischar ...
        };
    end
    function obj=trial(obj)
        % INTERVAL 1
        %obj.get_patch_stim(obj.patches.stdX,p,[],'1','tex',1);
        %obj.draw_cascade_basic();
        obj.draw_cascade_patch_intrvl(1);
        obj.pause_stim();

        % BETWEEN INTERVAL
        obj.draw_cascade_blank();
        obj.pause_iii();

        %INTERVAL 2
        %obj.get_patch_stim(obj.patches.cmpX,p,[],'2','tex',2);
        %obj.draw_cascade_basic();
        obj.draw_cascade_patch_intrvl(2);
        obj.pause_stim();

        % POST INTERVAL
        obj.draw_cascade_blank();
        obj.pause_iii();

        % GET RESPONSE

        obj.key.read_literal_hold();
        obj.command_dispatcher();

        %obj.get_key();
        %obj.parse_key_2AFC();
        %obj.sound_correct();


    end
    function obj=rest(obj)
        obj.pause_iti();
    end

    function obj=exp_menu(obj);
        iii         %1x1 or nx1 inter-interval-interval
    end

    function obj=gen_test_data(obj)
        n=10;
        indTrl=1:n;
        std=zeros(10,10,n);
        std=patches(std,std);
        cmp=ones(10,10,n);
        cmp=patches(cmp,cmp);
        bRandomize=1;
        seed=[];

        % XXX
        obj.p=patches_exp(indTrl,std,cmp,bRandomize,seed);
    end
    function obj=plot_fun(obj)
    end
end
end
