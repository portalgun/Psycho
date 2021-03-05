classdef Rsp < handle & trlInt
properties
    flags % XXX
    FlagNames % XXX


    % OUT
    responses
    bCorrect

%listening
end
properties(Hidden=true)
    % PARAMS
    answer % trlint
    bCheckCorrect % trlint
    bSoundCorrect % trlint
    bRecordAnswer
    bRecordResponse

    bPsycho=0;
end
events
end
methods
    function obj=Rsp(PARorOpts,nTrial,nInterval2Rsp,answers);
        if isa(PARorOpts,'psycho')
            PAR=PARorOpts;
            obj.bPsycho=1;
            I=PAR.EXP.nInterval
            % XXX opts ?
        else
            Opts=PARorOpts;
            obj=obj.parse_Opts(Opts);
        end
        if obj.bPsycho && ~exist('nTrial','var') || isempty(nTrial)
            nTrial=PAR.EXP.nTrial;
        end
        if obj.bPsycho && (~exist('nInterval','var') || isempty(nInterval))
            nInterval=PAR.EXP.nInterval;
        elseif ~exist('nInterval','var') || isempty(nInterval)
            nInterval=1;
        end

        obj.responses=zeros(nTrial,nInterval2Rsp);
        obj.answer=zeros(nTrial,nInterval2Rsp);
        obj.bCorrect=zeros(nTrial,nInterval2Rsp);
        if obj.bPsycho
            obj.trlint_init(PAR); %handles update and all that
        end
    end
    function obj=parse_Opts(obj,Opts)
        names={...
                  'bCheckCorrect', 1, 'isbinary';...
                  'bSoundCorrect', 1, 'isbinary';...
                  'bRecordResponse', 1, 'isbinary';...
                  'bRecordAnswer', 1, 'isbinary'...
        };
        obj=parse(obj,Opts,names);
    end

    function obj=record(obj,t,int,keyValue, answer)
        if ~exist('int') || isempty(int)
            int=1;
        end

        obj.record_answer(answer,t,int);
        obj.record_response(keyValue,t,int);
        obj.get_correct(answer,t,int);
        if obj.bSoundCorrect
            obj.sound(t,int);
        end
    end
    function obj=record_answer(obj,answer,t,i)
        obj.answer(t,i)=answer;
    end
    function obj=record_response(obj,keyValue,t,i)
        obj.responses(t,i)=keyValue;
    end
    function obj=get_correct(obj,answer,t,i)
        obj.bCorrect(t,i)=obj.responses(t,i)==answer;
    end
    function obj=sound(obj,t,i)
        if obj.bSoundCorrect & obj.bCorrect(t,i)
            obj.sound_incorrect();
        elseif obj.bSoundCorrect & ~obj.bCorrect(t,i)
            obj.sound_correct();
        end
    end
    function obj = sound_correct(obj)
        freq = 0.73; 
        sound(sin(freq.*[0:1439]).*cosWindowFlattop([1 1440],720,720,0));
    end
    function obj = sound_incorrect(obj)
        freq = 0.73/2; 
        sound(sin(freq.*[0:1439]).*cosWindowFlattop([1 1440],720,720,0));
    end
    function OUT=return_OUT(obj)
        OUT=struct();
        OUT.responses=obj.responses;
        OUT.answer=obj.answer;
    end
end
methods(Static=true)
    function RcmpChs=get_RcmpChs(R,cmpIntrvl,bFlip)
        if ~exist('bFlip','var')
            bFlip=0;
        end
        if bFlip
            RcmpChs=R~=cmpIntrvl;
        else
            RcmpChs=R==cmpIntrvl;
        end
    end
    function [correct,answer] = get_correct_2IFC(R,stdX,cmpX,cmpIntrval)
        %function [correct,answer] = get_correct_2IFC(R,stdX,cmpX,cmpIntrvl)
        % cmpIntrvl is binary
        if cmpX > stdX
            answer=cmpIntrval;
        elseif cmpX < stdX
            answer=~cmpIntrval;
        else
            answer = rand>0.5;
        end
        correct=R==answer;
    end
end
end
