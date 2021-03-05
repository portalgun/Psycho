function obj = psyDemoInput(obj)
    if obj.Help == 1
        obj.key_help();
    elseif obj.Help == 2 || D.Help == 3
        obj.key_help2 %SUB-HELP MENU
    elseif obj.bDeleteMode == 1
        obj.key_delete():
    elseif obj.bSecondarySelect==1
        obj.key_secondary();
    elseif obj.bNumMode==1
        obj.key.read_numeric();
    elseif obj.bInputCapture==1
        obk.key_insert();
    elseif  obj.bExpPrompt==1
        obj.key_cmd();
    elseif obj.bExpPrompt==0
        obj.key_main();
    end
%KEYS THAT CAN BE DISABLED
    if D.bLeftHide == 0
        obj.key_disabled();
    end

%PARSE SOME FLAGS
    if obj.exitflag==1 || obj.saveflag==1; return;end
    if obj.n~=obj.nlast;    obj.bUpdate=1;            end
end
end

function obj=key_help(obj)
    switch obj.keycode
        case {K.escape,K.q}
            obj.Help = 0;
        case K.c
            obj.Help = 2;
        case K.n
            obj.Help = 3;
    end
end

function obj=key_help2(obj)
    switch obj.keycode
        case {K.escape,K.q}
            obj.Help = 1;
    end
end

function obj=key_delete(obj)
    switch obj.keycode
        case K.escape
            obj.bDeleteMode = 1;
        case K.d
            obj.markedStimulus = obj.n;
            obj.mark='d';
        case K.x
            obj.markedStimulus = obj.n;
            obj.mark='x';
    end
end

function key_cmd
    rete=1;
    switch keycode
        case K.escape
            obj.bExpPrompt=0;
            obj.cRepeat=1;
        case K.enter
            obj.bExpPrompt=0;
            obj.bDemo=0;
            obj.exitflag=1;
        case K.b
            P.expSelected=3;
        %case K.t
        %  P.expSelected=4;
        case K.s
            P.expSelected=5;
        case K.n
            P.expSelected=7;
        case K.i
            P.expSelected=8;
        case K.e
            P.expSelected=9;
        case K.h
            P.expSelected=10;
        case K.u
            if D.nIntrvl <= 2
                P.expSelected=12;
            else
                ret=0;
            end
        case K.r
            P.expSelected=13;
        case K.p
            P.expSelected=14;
        case K.f
            P.expSelected=15;
        case K.l
            P.expSelected=16;

        case K.d
            P.expSelected=18;
        case K.c
        if D.prevKey==K.c
            D.cRepeat=D.cRepeat+1;
        end
        if D.cRepeat>length(D.cmp); D.cRepeat=1; end
            P.expSelected=18+D.cRepeat;
        case {K.k,K.Uarrow}
            [D,C,P]=psyExpAdjStim(D,C,P, 1,'r');
            bUpdate=1;
        case {K.j,K.Darrow}
            [D,C,P]=psyExpAdjStim(D,C,P,-1,'r');
            bUpdate=1;
        otherwise
            ret=0;
            rete=0;
    end
    if obj.ret=1
        D.prevKey=keycode;
    end
end

function obj=key_main(obj)
    switch obj.keycode
    case {K.k,K.Uarrow}
        [D,C,P]=psyDemoAdjStim(D,C,P, 1,'r');
        bUpdate=1;
    case {K.j,K.Darrow}
        [D,C,P]=psyDemoAdjStim(D,C,P,-1,'r');
        bUpdate=1;
    %Numbers
    case K.y
        obj.markedStimulus=n;
        obj.mark='y';
    case K.t
        obj.selected='sizeMult';
    case K.tab
        obj.bUseMask=obj.toggle(obj.bUseMask);
    case K.comma
        obj.bLeftHide=obj.toggle(obj.bLeftHide);
    case K.period
        obj.bRightHide=obj.toggle(obj.bRightHide);
    case K.z
        Ch.shape=obj.rotate(Ch.shape,obj.shapes);
    case K.x
        obj.Ch.bDichoptic=obj.toggle(obj.Ch.bDichoptic)
        obj.bCHupdate=1;
    case K.space
        obj.Ch.bCH=toggle(obj.Ch.bCH)
    case K.a
        obj.selected='X';
    case K.s
        if ~strcmp(obj.secondary,'')
            obj.selected='X2';
        end
    case K.q
        obj.selected='X2Menu';
        obj.bSecondarySelect=1;
    %HELP
    case K.backslash
        obj.Help=1;
    end

end
function obj=key_secondary(obj)
    sLast=P.secondary;
    switch keycode
        case K.one
            P.secondary=D.secondaries{1};
            D.bSecondarySelect=0;
        case K.two
            P.secondary=D.secondaries{2};
            D.bSecondarySelect=0;
        case K.three
            P.secondary=D.secondaries{3};
            D.bSecondarySelect=0;
        case K.four
            P.secondary=D.secondaries{4};
            D.bSecondarySelect=0;
        case K.five
            P.secondary=D.secondaries{5};
            D.bSecondarySelect=0;
        case K.six
            P.secondary=D.secondaries{6};
            D.bSecondarySelect=0;
        case K.seven
            P.secondary=D.secondaries{7};
            D.bSecondarySelect=0;
        case K.eight
            P.secondary=D.secondaries{8};
            D.bSecondarySelect=0;
        case K.nine
            P.secondary=D.secondaries{9};
            D.bSecondarySelect=0;
        case K.zero
            P.secondary='';
            D.bSecondarySelect=0;
        case K.escape
            D.bSecondarySelect=0;
    end
    if ~strcmp(sLast,P.secondary)
        P.bUpdateIdx2=1;
    end
end

%DIRECTIONS case K.escape P.selected='null'; case K.enter D.bForceUpdate=1; %P.bUpdateIdx=0; %P.bUpdateIdx2=0; case K.h n=n-1; if n < 1; n=1; end case K.l n=n+1;
