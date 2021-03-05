classdef text_box < handle
properties
    posXYctr
    HW

    PSTRS
    TEXT
    pStrOpts

    fillColor
    borderColor
    borderWidth
    rect
end
properties(Hidden=true)
    scrnXYpix
    wdwPtr
    sStereo
end
methods
    function obj=text_box(Opts,ptb)
        if ~exist('Opts','var') || isempty(Opts)
            Opts=struct();
        end
        obj=obj.parser(Opts,ptb);

        obj.update_ptb(ptb);
        obj.init(ptb);
    end
    function obj=parser(obj,Opts,ptb)
        s={struct()};
        w=ptb.wht;
        b=ptb.blk;
        g=ptb.gry;
        names={...
                'pStrOpts',s,[]; ...
                'HW',[30 30], 'isnumeric';...
                'fillColor',b,'isnumeric';...
                'borderColor',w,'isnumeric';...
                'borderWidth',2,'isnumeric';
                'posXYctr',ptb.display.scrnXYpix/2,'isnumeric';
              };
        obj=parse(obj,Opts,names);
        if numel(obj.fillColor) == 1
            obj.fillColor=repmat(obj.fillColor,1,3);
        end
        if numel(obj.borderColor) == 1
            obj.borderColor=repmat(obj.borderColor,1,3);
        end
        n=numel(obj.pStrOpts);
        obj.TEXT=cell(n,1);
        for i = 1:n
            if isfield(obj.pStrOpts{i},'text') && ~isempty(obj.pStrOpts{i}.text)
                obj.TEXT{i}=obj.pStrOpts{i}.text;
                obj.pStrOpts{i}=rmfield(obj.pStrOpts{i},'text');
            else
                obj.TEXT{i}='';
            end
        end
    end
    function obj=update_ptb(obj,ptb)
        obj.scrnXYpix=ptb.display.scrnXYpix;
        obj.wdwPtr=ptb.wdwPtr;
        obj.sStereo=double(ptb.bStereo);
    end
    function obj=init(obj,ptb)
        obj.get_rect();
        n=numel(obj.pStrOpts);
        obj.PSTRS=cell(n,1);
        for i = 1:n
            if isempty(obj.TEXT{i})
                text='';
            else
                text=obj.TEXT{i};
            end
            obj.PSTRS{i}=pStr(obj.pStrOpts{i},ptb,text);
        end
    end
    function obj=get_rect(obj)
        obj.rect=shape3D.ctr2rect(obj.posXYctr,obj.HW(2),obj.HW(1));
    end
    function obj=draw(obj)
        for s = 0:obj.sStereo
            Screen('SelectStereoDrawBuffer', obj.wdwPtr, s);
            Screen('FillRect', obj.wdwPtr, obj.fillColor, obj.rect);
            Screen('FrameRect', obj.wdwPtr, obj.borderColor, obj.rect, obj.borderWidth);
        end
        for i = 1:length(obj.PSTRS)
            obj.PSTRS{i}.draw();
        end
    end
end
end
