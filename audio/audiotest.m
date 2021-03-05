%ASIO
type=8;
freq=44100;
%freq=10000;
%mode=5
channels=2;
mvol=100;
chvol=[100 100];

PsychPortAudio('Close');
% select device
if ~isvar('deviceIndex')
    devices=PsychPortAudio('GetDevices' ,type);
    [out,ind]=basicSelect({devices.DeviceName});
    deviceIndex=ind-1
    PsychPortAudio('Close');
end

%Open
InitializePsychSound(1);
pahandle=PsychPortAudio('Open',deviceIndex,[],4,freq,channels,[])
%Vol
PsychPortAudio('Volume', pahandle, 1);

%Create buffer
load handel.mat
Y=repmat(y,1,2)';

fname='/home/dambam/Code/mat/projects/_davePsychTools/psychtoolbox/audio/piano2.wav';
[y, Fs] = audioread(fname);
Y=y';
[underflow, nextSampleStartIndex, nextSampleETASecs] = PsychPortAudio('FillBuffer', pahandle, Y);
startTime = PsychPortAudio('Start', pahandle);


%startTime = PsychPortAudio(‘Start’, pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);

%play

%Fs
%y


%InitializePsychSound(1)
%drivers
%    asioforall
%        portaudio_x86.dll
%    libportaudio
%latency too low
%open latency class (2-3)
%device & type (13 for win, 5 for mac)
%buffers still open
%open
%    increase latency
%    suggestedlatency=.015
%
%t1=GetSecs
%t2=GetSecs
%latency=t2-t1;
%PsychPortAudo('EngineTunables')
