classdef prompt < handle & text_box
properties
    bActive
    KEY

    OUT
    exitflag=0;
end
properties(Hidden=true)
end
methods
    function obj=prompt(allOpts,ptb)
        if exist('allOpts','var') && ~isempty(allOpts) && isstruct(allOpts)
            unpackOpts(allOpts);
        end
        if ~exist('keyOpts','var')
            keyOpts=struct();
        end
        if ~exist('textBoxOpts','var')
            textBoxOpts=struct();
        end
        obj@text_box(textBoxOpts,ptb);
        obj.KEY=Key(keyOpts);
    end
    % obj.OUT={'set','str',obj.STR.str,obj.STR.pos,obj.str.flag};
    function obj=read(obj)
        obj.draw();
        obj.KEY.read();
        if isempty(obj.KEY.OUT)
            return
        end
        text=obj.KEY.OUT{3};
        pos=obj.KEY.OUT{4};
        obj.PSTRS{2}.update_str(text,pos);

        %obj.PSTRS{2}.change_cursor_charNo(obj.KEY.OUT{4});
        %obj.PSTRS{2}.text=obj.KEY.OUT{3};
        if strcmp(obj.KEY.OUT{2},'str') && obj.KEY.OUT{5}==1
            obj.handle_return();
            obj.OUT=obj.KEY.OUT{3};
            obj.exitflag=1;
        elseif strcmp(obj.KEY.OUT{2},'str') && obj.KEY.OUT{5}==-1
            obj.exitflag=-1;
        end

    end

end
end
