function [T,fg,bg]=psyDemoText(n,N,D,C,P)
fg=[D.wht D.wht D.wht];
bg=[D.blk D.blk D.blk];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%HELP MENU

%HELP SUB-MENU
T.commands={ ...
    'Enter command followed or {shortcut string} followed by hitting return';...
    '    save  {w}      Save';...
    '    quit  {q}      Quit';...
    '    reload{r}      Reload';...
    '    exp            Enter experiment mode';...
    '    !!!            ???';
};

%HELP SUB-MENU
T.numMenu={ ...
    'Enter string of numbers [num] followed by a letter key:';...
    '    [num]g   Go to stimulus [num]';...
    '    [num]h   Go left [num] stimuli';...
    '    [num]l   Go right [num] stimuli';...
    '    [num]k   Increment parameter by [num]';...
    '    [num]j   Decrement parameter by [num]';...
};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Secondary Menu
T.secondary=cell(length(D.secondaries));
if ~isempty(D.secondaries)
  for i = 1:length(D.secondaries)
      T.secondary{i}=[num2str(i) '  ' D.secondaries{i}];
  end
  T.secondary{i+1}='0  None';
else
    T.secondary{1}='';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Experiment Menu

%VALS
if D.nIntrvl > 2
    bRevKeysStr='';
else
    bRevKeysStr=num2str(D.bRevKeys);
end

T.expVals={ ...
    ' ';...
    '';...
    num2str(D.nBlks);...
    num2str(D.trlPerBlk);...
    D.subjName;...
    '';...
    num2str(D.nIntrvl);...
    num2str(D.itiSec);...
    num2str(D.isiSec);...
    num2str(D.durationMs);...
    '';...
    bRevKeysStr;...
    num2str(D.mskReset);...
    num2str(D.bPsyIntro);...
    num2str(D.bUsefeedback);...
    num2str(D.bPlot);...
    '';...
    num2str(D.std);
};

for i = 1:length(D.cmp)
    T.expVals{end+1,1}=num2str(D.cmp(i));
end
for i = 1:(10-length(D.cmp)+2)
    T.expVals{end+1,1}='';
end

%3+ INTERVAL OPTIONS
T.exp3={ ...
    'Parameters to simulate experiment';... %1
    '';... %2
    ' b   Number of blocks (only 1 will be presented)';... %3
    '     Trials per block';... %4
    ' s   Subject Name';... %5
    '';... %6
    ' n   Number of Intervals';... %7
    ' i   Between interval pause (seconds)' ;... %8
    ' e   Between trial pause (seconds)';... %9
    ' h   Interval presentation time (seconds)';... %10
    '';... %11
    '';... %12
    ' r   Reset mask after how many runs (0 = off)';... %13
    ' p   Include intro';... %14
    ' f   Use feedback';... %15
    ' l   Plot psychometric curve after run';... %16
    '';... %17
    ' d   standard';...
    ' c   comparison(s) (repeat c to cycle through)';...
};

for i = 1:9
    T.exp3{end+1}='';
end
T.exp3{end+1,1}='All other parameters will be transfered from this demo.';  %18
T.exp3{end+1,1}='Press Return to simulate experiment, Esc to return to demo'; %19

%SINGLE INTERVAL OPTIONS
T.exp1=T.exp3;
T.exp1{12}=' u   Press ''Up'' (1) or ''Down'' (0) for no';
%TWO INTERVAL OPTIONS
T.exp2=T.exp3;
T.exp2{12}=' u   Press ''Up'' (1) or ''Down'' (0) to choose 2nd intervl';

%SELECT
T.expSelect=cell(length(T.exp3),1);
for i = 1:length(T.exp3)
    T.expSelect{i}=' ';
end

if P.expSelected~=0
    T.expSelect{P.expSelected}='>>';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%LEFT

T.select=cell(11,1);
for i = 1:11
    T.select{i}=' ';
end

if D.bLeftHide == 1
    T.params='';
else
    T.params={ ...
        '   primary parameter';...
        'a  primary value';...
        'q  secondary parameter';...
        's  secondary bin';...
        'b  black level';...
        'w  white level';...
        'g  grey  level';...
        'i  crosshair length';...
        'o  crosshair thickness';...
        'p  crosshair radius';...
        't  stimulus size';...
        ',  hide and disable this menu';...
    };
    if isempty(P.secondary)
        secOnOff='OFF';
    else
        secOnOff='ON';
    end
    T.vals={ ...
        D.prjCode; ...
        num2str(P.XselectedVal); ...
        secOnOff; ...
        num2str(D.X2(P.secondaryInd));...
        num2str(D.blk); ...
        num2str(D.wht); ...
        num2str(D.gry); ...
        num2str(C.hairLength);
        num2str(C.hairThick);
        num2str(C.radius);
        num2str(D.sizeMult); ...
        '';...
    };


    if D.bExpPrompt==0
    switch P.selected
        %line 1 does not change
        %
        case 'X'
            T.select{2}='>>';
        case 'X2Menu'
            T.select{3}='>>';
        case 'X2'
            T.select{4}='>>';
        case 'blk'
            T.select{5}='>>';
        case 'wht'
            T.select{6}='>>';
        case 'gry'
            T.select{7}='>>';

        case 'hairLength'
            T.select{8}='>>';
        case 'hairThick'
            T.select{9}='>>';
        case 'radius'
            T.select{10}='>>';
        case 'sizeMult'
            T.select{11}='>>';
        case 'null'
            for i = 1:11
                T.select{i}=' ';
            end
     end
     end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%RIGHT

if isempty(P.secondary)
    secondary='Secondary';
else
    secondary=P.secondary;
end

T.stimProp={ ...
    'Selected Stimulus'
    '  Stim #';...
    ['  '  D.prjCode ' value'];...
    ['  '  secondary ' bin'];...
    ['            value'];...
    '  bin range';...
    'Press . to hide this menu';...
};

if any(isnan(D.secondaryBinRangeVals(n,:)))
    binvals='NaN';
else
    binvals=[num2str(D.secondaryBinRangeVals(n,1)) '-' num2str(D.secondaryBinRangeVals(n,2))];
end


T.stimPropVals={ ...
    '';...
    [num2str(n) '/' num2str(N)];...
    [num2str(D.Xvals(n))];...
    [num2str(D.secondaryVals(n))];...
    [num2str(P.secondaryActual(n))];...
    binvals;...
    '';...
};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%BOTTOM
T.helpKey={ ...
    '>';...
    '    Press ''/'' for help';...
};
