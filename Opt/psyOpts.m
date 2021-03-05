classdef psyOpt
properties
end
methods

    function obj=select_Opt_all(obj,ti)
        for i = 1:length(obj.flds)
            fld=obj.flds{i};
            obj.select_opt(obj,fld,ti)
        end
    end
    function obj=select_Opt(obj,fld,ti)
        obj.Opt.(fld)=obj.Opts.(fld){ti};
    end
    function obj=send_Opt_all(obj)
        for i = 1:length(obj.flds)
            fld=obj.flds{i};
            if ~isempty(obj.Opt)
                obj.send_Opt(fld)
            end
        end
    end
    function obj=send_Opt()
        % NOTE abstract
    end
    function obj=parse_OPTS(obj,OPT)
        % XXX get options that remain constant
    end

    function obj=send_Opt(obj,fld)
        obj.STM.update_Opts(obj.Opt.(fld));
    end
end
end
