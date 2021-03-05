classdef s_quit_prompt < handle & prompt
methods
    function obj=s_quit_prompt(ptb)
        % Key
        K=struct;
        K.KeyDefName='key_def_quit_prompt';
        K.initialMode='i';
        %K.bUseCaps
        %K.pauseLength

        %Text box
        tb=struct();
        tb.posXYctr=ptb.display.scrnXYpix/2;
        tb.HW=[400 400];
        tb.fillColor=ptb.blk;
        tb.borderColor=ptb.wht;
        tb.borderWidth=2;

        % pstr
        p=cell(3,1);
        p{1}=struct;
        % text
        p{1}.text=['Are you sure you want to quit?' newline '(Yes/N)'];
        p{1}.relPosHW=tb.HW;
        %p{2}.bHidden=1;
        p{1}.relXYctr=tb.posXYctr;
        %p{1}.relRec
        p{1}.relPosPRC='OMM';
        %p{1}.fgColor=ptb.wht;
        %p{1}.bgColor=ptb.blk;
        %p{1}.font=
        %p{1}.fontSize
        %p{1}.padXY=[10 10]
        %p{1}.lineSpacing
        %p{1}.borderColor
        %p{1}.borderWidth
        %p{1}.borderPad
        %p{1}.borderFill
        p{1}.bActive=0;
        p{1}.bActivateable=0;


        p{2}=struct();
        %p{2}.bHidden=1;
        p{2}.relPosHW=tb.HW;
        p{2}.relXYctr=tb.posXYctr;
        %p{1}.relRec
        p{2}.relPosPRC='OMM';
        p{2}.fgColor=ptb.wht;
        %p{2}.bgColor
        %p{2}.font
        %p{2}.fontSize
        %p{2}.padXY
        %p{2}.lineSpacing
        %p{2}.borderColor
        %p{2}.borderWidth
        %p{2}.borderPad
        %p{2}.borderFill
        p{2}.bActive=1;
        p{2}.bActivateable=0;
        %p{2}.cursorFrameColor
        %p{2}.cursorFrameWidth
        %p{2}.cursorFillColor
        p{2}.cursorStyle='underline'
        p{2}.cusorLineWidth=3;


        p{3}=struct();
        p{3}.text=['Invalid Response'];
        p{3}.relPosHW=tb.HW;
        p{3}.bHidden=1;
        p{3}.relXYctr=tb.posXYctr;
        %p{1}.relRec
        p{3}.relPosPRC='OBM';
        %p{2}.fgColor
        %p{2}.bgColor
        %p{2}.font
        %p{2}.fontSize
        %p{2}.padXY
        %p{2}.lineSpacing
        %p{2}.borderColor
        %p{2}.borderWidth
        %p{2}.borderPad
        %p{2}.borderFill
        p{3}.bActive=0;
        p{3}.bActivateable=0;
        %p{2}.cursorFrameColor
        %p{2}.cursorFrameWidth
        %p{2}.cursorFillColor
        %p{2}.cursorStyle
        %p{2}.cusorLineWidth


        allOpts=struct();
        allOpts.keyOpts=K;
        allOpts.textBoxOpts=tb;
        allOpts.textBoxOpts.pStrOpts=p;

        obj@prompt(allOpts,ptb);
    end
    function obj=handle_return(obj)
        s=obj.KEY.OUT{3};
        if strcmp(s,'Y')
            obj.exitflag=1;
        elseif strcmp(s,'n')
            obj.exitflag=-1;
        else
            obj.PSTRS{2}.clear_text;
            obj.PSTRS{2}.bHidden=0;
        end
    end

end
methods(Static=true)
    function obj=test()
        ptb=ptb_session;
        try
            obj=s_quit_prompt(ptb);
            while true
                obj.read();
                ptb.flip();
                if abs(obj.exitflag)==1
                    break
                end
            end
        catch ME
            ptb.sca;
            rethrow(ME);
        end
        ptb.sca;

    end
end
end
