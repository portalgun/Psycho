classdef  Hlp < handle & pStr & Cursor
methods
    function obj=Hlp(Opts,ptb,Viewer)
        obj@pStr(Opts,ptb,Viewer);
        if ~exist('Opts','var')
            Opts=struct();
        end
    end
    function obj=parse_fun(obj)
    end

    function obj=get_rect(obj)
        obj.get_text();
        get_rect@pStr(obj);
    end
    function obj=get_text(obj,def,mode)
        name=obj.Viewer.Cmd.getKeyDefName();
        moude=obj.Viewer.Cmd.getLastMode();
        [keys,vals]=obj.Def.get_def_strings();

        A=cell(numel(keys),2);
        for i = 1:numel(keys)
            A{i,1}=keys{i};
            A{i,2}=vals{i};
        end

        obj.text=Cell.print(A,'left','   ');
    end

end
end
