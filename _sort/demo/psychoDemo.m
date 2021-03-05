Opts=struct;
Opts.expType           = '2AFC';
%Opts.magORval          =
%
%Opts.bRandomize        =
%Opts.seed              =
%Opts.secondaries       =
%
%Opts.bTrialCounter     =
%Opts.bInstructions     =
%Opts.bIntro            =
%Opts.nReset            =
%Opts.bCountdownOnReset =
%
%Opts.pointORloc        =
%Opts.stmXYdeg          =
%Opts.stmLOS            = % XXX
%Opts.bRMSfix           =
%Opts.RMSfix            =
%Opts.RMSdc             =
%Opts.RMSmonoORbino     =
%Opts.bCheckRMS         =
%Opts.bWindow           =
%Opts.windowType        =
%Opts.WszRCT            =
%Opts.Wk                =
%
%Opts.iii               =
%Opts.iti               =
%Opts.duration          =
%
%Opts.DC                =
%Opts.gry               =
%Opts.bSkipSyncTest     =
%Opts.bDebug            =
%Opts.textSize          =
%Opts.textFont          =
%Opts.streomode         =
%Opts.bDummy            =
%
%
%Opts.bUseCaps          =
%Opts.pauseLength       =
%
Opts.bUseCH            = 1;
%Opts.CHtype            = {'x'};
%Opts.CHcolor           = [1 1 1];
%Opts.CHhairWHdeg       =
%Opts.CHradiuswhdeg     =
%Opts.CHshape           =
%Opts.CHbDichoptic      =
%
Opts.bUseBg            = 1;
%Opts.BGType            =
Opts.BGbPlate          = 1;
%Opts.BGplateRadiusXYdeg=
%Opts.BGplateShape      =
%Opts.BGplateColor      = [0 0 0];

n=10;
indTrl=1:n;

std=ones(10,10,n);
std=patches(std,std);
std.X=zeros(10,1);

cmp=ones(10,10,n)*.0;
cmp=patches(cmp,cmp);
cmp.X=ones(10,1);

bRandomize=1;
seed=[];
p=patches_exp(indTrl,std,cmp,bRandomize,seed);

P=psycho(p,Opts);
