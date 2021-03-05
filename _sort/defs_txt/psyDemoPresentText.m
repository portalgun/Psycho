function [D] = psyDemoPresentText(n,N,D,C,P)

Screen('TextSize', D.wdwPtr, D.txtSize);
Screen('TextFont', D.wdwPtr, D.txtFont);

[T,fg,bg]    = psyDemoText(n,N,D,C,P);
[X,Y,XY]        = psyDemoPositions(D,T);

cLeft=5;
cRight=cLeft*-1;

for b = 0:D.bStereo
    if     b==0 && D.bStereo==1
        cDisp=cLeft;
    elseif b==1 && D.bStereo==1
        cDisp=cRight;
    else
        cDisp=0;
    end
    %Draw Left & Right
    Screen('SelectStereoDrawBuffer', D.wdwPtr, b);


    if D.bLeftHide==0
        %DRAW TEXT BACKGROUNDS
        Screen('FillRect',D.wdwPtr,fg,[XY.rectLeft(1)-1+cDisp XY.rectLeft(2)-1 XY.rectLeft(3)+1+cDisp XY.rectLeft(4)+1]);
        Screen('FillRect',D.wdwPtr,bg,[XY.rectLeft(1)-0+cDisp XY.rectLeft(2)-0 XY.rectLeft(3)+0+cDisp XY.rectLeft(4)+0]);

        for j =1:length(T.params)
            Screen('DrawText',D.wdwPtr,T.params{j},X.params+cDisp,Y.params+D.lineMult*(j-1),fg,bg);
        end
        for j =1:length(T.select)
            Screen('DrawText',D.wdwPtr,T.select{j},X.select+cDisp,Y.params+D.lineMult*(j-1),fg,bg);
        end
        for j =1:length(T.vals)
            Screen('DrawText',D.wdwPtr,T.vals{j},X.vals+cDisp,Y.params+D.lineMult*(j-1),fg,bg);
        end
    end

    %Draw Right
    if D.bRightHide==0
        %DRAW TEXT BACKGROUNDS
        Screen('FillRect',D.wdwPtr,fg,[XY.rectRight(1)-1+cDisp XY.rectRight(2)-1 XY.rectRight(3)+1+cDisp XY.rectRight(4)+1]);
        Screen('FillRect',D.wdwPtr,bg,[XY.rectRight(1)-0+cDisp XY.rectRight(2)-0 XY.rectRight(3)+0+cDisp XY.rectRight(4)+0])

        for j =1:length(T.stimProp)
            Screen('DrawText',D.wdwPtr,T.stimProp{j},X.stimProp+cDisp,Y.stimProp+D.lineMult*(j-1),fg,bg);
        end
        for j =1:length(T.stimPropVals)
            Screen('DrawText',D.wdwPtr,T.stimPropVals{j},X.stimPropVals+cDisp,Y.stimProp+D.lineMult*(j-1),fg,bg);
        end
    end

    %Draw Bottom
    if D.bBottomHide==0
        %DRAW TEXT BACKGROUNDS
        Screen('FillRect',D.wdwPtr,D.blk,XY.rectBottom);

        for j =1:length(T.helpKey)
            Screen('DrawText',D.wdwPtr,T.helpKey{j},X.command,Y.command+D.lineMult*(j-1),fg,D.blk);
        end
    end
    Screen('DrawText',D.wdwPtr,D.str,X.commandText,Y.command,fg,D.blk);


    %Draw Help
    if D.Help ~= 0
        %DRAW TEXT BACKGROUNDS
        Screen('FillRect',D.wdwPtr,fg,[XY.Help(1)-1+cDisp*2 XY.Help(2)-1 XY.Help(3)+1+cDisp*2 XY.Help(4)+1]);
        Screen('FillRect',D.wdwPtr,bg,[XY.Help(1)-0+cDisp*2 XY.Help(2)-0 XY.Help(3)+0+cDisp*2 XY.Help(4)+0]);
    end
    if D.Help == 1
        for j =1:length(T.help)
            Screen('DrawText',D.wdwPtr,T.help{j},X.help+cDisp*2, Y.help+D.lineMult*(j-1),fg,D.blk);
        end
    elseif D.Help == 2
        for j =1:length(T.commands)
            Screen('DrawText',D.wdwPtr,T.commands{j},X.help+cDisp*2, Y.help+D.lineMult*(j-1),fg,D.blk);
        end
    elseif D.Help == 3
        for j =1:length(T.numMenu)
            Screen('DrawText',D.wdwPtr,T.numMenu{j},X.help+cDisp*2,Y.help+D.lineMult*(j-1),fg,D.blk);
        end
    %DRAW SECONDARY
    elseif D.bSecondarySelect==1
        %DRAW TEXT BACKGROUNDS
        Screen('FillRect',D.wdwPtr,fg,[XY.secondary(1)-1+cDisp XY.secondary(2)-1 XY.secondary(3)+1+cDisp XY.secondary(4)+1]);
        Screen('FillRect',D.wdwPtr,bg,[XY.secondary(1)-0+cDisp XY.secondary(2)-0 XY.secondary(3)+0+cDisp XY.secondary(4)+0]);
        for j=1:length(T.secondary)
            Screen('DrawText',D.wdwPtr,T.secondary{j},X.secondary+cDisp,Y.secondary+D.lineMult*(j-1),fg,D.blk);
        end
    elseif D.bExpPrompt==1
        Screen('FillRect',D.wdwPtr,D.blk,XY.Help);
        length(T.expVals)
        length(T.exp2)
        for j=1:length(T.expVals)
            if     D.nIntrvl>2
                Screen('DrawText',D.wdwPtr,T.exp3{j},X.exp,Y.exp+D.lineMult*(j-1),fg,D.blk);
            elseif D.nIntrvl==2
                Screen('DrawText',D.wdwPtr,T.exp2{j},X.exp,Y.exp+D.lineMult*(j-1),fg,D.blk);
            elseif D.nIntrvl==1
                Screen('DrawText',D.wdwPtr,T.exp1{j},X.exp,Y.exp+D.lineMult*(j-1),fg,D.blk);
            end
            Screen('DrawText',D.wdwPtr,T.expSelect{j},X.expSelect,Y.exp+D.lineMult*(j-1),fg,D.blk);
            Screen('DrawText',D.wdwPtr,T.expVals{j},X.expVals,Y.exp+D.lineMult*(j-1),fg,D.blk);
        end
    end
end
