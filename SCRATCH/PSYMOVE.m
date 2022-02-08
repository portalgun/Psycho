    function obj=wait_for_press(obj)
        tt=GetSecs;
        while true
            obj.KEY.read();
            if ~isempty(obj.KEY.capture.OUT)
                break
            end
            elap=GetSecs-tt;
            if obj.Test & elap > 15
                error('timeout');
            end
        end
    end

    function obj=get_response_and_wait(obj,tt)
        obj.KEY.OUT=[];
        while true
            obj.KEY.read();
            if isempty(obj.KEY.key)
                continue
            end
            if obj.promptflag && any(obj.KEY.key=='y')
                obj.promptflag=0;
                obj.exitflag=1;
                break
            elseif obj.promptflag && any(obj.KEY.key=='n')
                obj.promptflag=0;
                obj.exitflag=0;
                obj.repeatflag=1;
                break
            elseif obj.promptflag || isempty(obj.KEY.OUT)
                continue
            end

            %obj.KEY.OUT
            if strcmp(obj.KEY.OUT{2},'exp') && strcmp(obj.KEY.OUT{3},'exit')
                obj.KEY.OUT=[];
                obj.promptflag=1;
                break
            elseif obj.bTest && strcmp(obj.KEY.OUT{2},'exp') && strcmp(obj.KEY.OUT{3},'next') && obj.t+1 <= obj.D.nTrial
                obj.goto=obj.t+1;
                break
            elseif obj.bTest && strcmp(obj.KEY.OUT{2},'exp') && strcmp(obj.KEY.OUT{3},'previous') && obj.t-1 > 0
                obj.KEY.OUT=[];
                obj.goto=obj.t-1;
                obj.load_check('prev',obj.t);
                break
            elseif obj.bTest && strcmp(obj.KEY.OUT{2},'exp') && strcmp(obj.KEY.OUT{3},'repeat')
                obj.KEY.OUT=[];
                obj.repeatflag=1;
                break
            elseif strcmp(obj.KEY.OUT{2},'rsp')
                R=obj.KEY.OUT{3};
                obj.KEY.OUT=[];
                obj.RSP.record(tt,1,R);
                break
            else
               % obj.KEY.OUT
            end
        end
    end
