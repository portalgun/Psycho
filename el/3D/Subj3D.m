classdef Subj3D < handle
methods(Static=true)
    function out=input_parser(Opts)

        p=Subj3D.opts();
        out=parse([],Opts,p);
        if isempty(out.subjInfo)
            out.subjInfo=struct();
            out.subjInfo.LExyz=out.LExyz;
            out.subjInfo.LExyz=out.RExyz;
            out.subjInfo.IPDm=out.IPDm;
        end
        % TODO limit
    end
    function out=opts()
        out={'subjInfo',[],...
             'IPDm,',.065,...
             'LExyz,',[],...
             'RExyz,',[],...
          };
    end
end
end
