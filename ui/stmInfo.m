classdef  stmInfo < handle & pStr & Cursor
properties
    type
    INFO
end
methods
    function obj=stmInfo(S,expType,ptb,Opts)
        if ~exist('Opts','var')
            Opts=struct();
        end
        obj@pStr(Opts,ptb);
        obj.INFO=struct();
        switch expType
            case '2IFC'
                obj.parse_stm_2IFC(S);
        end
    end
    function obj=parse_stm_2IFC(obj,S)
        if isstruct(S)
            obj.parse_struct(S);
        elseif isa(S,'ptchs')
            obj.parse_ptchs(S);
        end

    end
    function obj=parse_struct(obj,S)
        obj.INFO.cmpIntrvl=S.cmpIntrvl+1;
        obj.INFO.stdX=S.stdX;
        obj.INFO.cmpX=S.cmpX;
        if abs(S.cmpX) - abs(S.stdX) < 0.0001
            answ=-1;
        else
            answ=double(abs(S.cmpX) > abs(S.stdX))+1;
        end
        obj.INFO.correct=answ;
    end
    function obj=parse_ptchs(obj,P)
        obj.INFO.cmpIntrvl=P.Blk.blk('intrvl').ret();
        obj.INFO.stdX=P.Blk.get_stdX();
        obj.INFO.cmpX=P.Blk.get_cmpX();
        obj.INFO.correct=P.Blk.get_correct();
    end

    function obj=draw(obj,trial)
        obj.get_text(trial);
        draw@pStr(obj);
    end
    function obj=get_text(obj,trial)
        flds=fieldnames(obj.INFO);
        A=cell(numel(flds),2);
        for i = 1:length(flds)
            fld=flds{i};
            A{i,1}=fld;
            A{i,2}=obj.INFO.(fld)(trial);
        end
        obj.text=printCellList(A,'left','   ');
    end
end
methods(Static=true)
    function obj=test(S)
        expType='2IFC';
        Opts=struct();
        Opts.relRec=[441 312 839 712];
        Opts.relPosPRC='OBM'; %Y - TR TL BL BR
        Opts.bgColor=.5;
        Opts.lineSpacing=5;
        Opts.borderWidth=2;
        Opts.borderColor=1;
        Opts.borderFill=0;
        ptb=ptb_session;
        try
            obj=stmInfo(S,expType,ptb,Opts);
            for i = 1:4:100
                obj.draw(i);
                Screen('FrameRect', obj.wdwPtr, obj.borderColor, obj.relRec, obj.borderWidth);
                ptb.flip;
                pause(.1);
            end
            sca;
            ListenChar(0);
        catch ME
            sca;
            ListenChar(0);
            rethrow(ME);
        end

    end
end
end
