classdef trlInt < handle
properties
    Opts
    OptsTable
end
methods
    function obj=trlint_init(PAR)
        % XXX
    end
    function obj=update(t,i)
        opts=obj.get_opts(t,i);
        flds=fieldnames(opts)
        for i = 1:length(flds)
            fld=flds{i};
            obj.(fld)=opts.(fld);
        end
    end
    function opts=get_opts(t,i)
        ind=OptsTable(t,i);
        opts=obj.Opts{ind};
    end
end
end
