classdef snd
properties
    device
    pahandle
end
methods
    function obj=get_device(deviceType,deviceIndex)
        if ~exist('deviceType','var') || isempty(deviceType)
            deviceType=[];
        end
        if ~exist('deviceIndex','var') || isempty(deviceIndex)
            deviceIndex=[];
        end
        %devicetype by priority
        %13 windows wasapi
        %11 windows wdmks
        %1  windows direct sound
        %2  windows mme
        %8  linux   alsa
        %12 linux   jack
        %7  linux   oss
        %5  mac     coreaudio
        devices=PsychPortAudio('GetDevices' ,deviceType, deviceIndex);
        PsychPortAudio('Close');
        [out,ind]=Input.select({devices.DeviceName});
        deviceIndex=ind-1;
        obj.device=PsychPortAudio('GetDevices',[],deviceIndex)
        PsychPortAudio('Close');
    end
    function
        #Volume
        PsychPortAudio('Volume', pahandle [, masterVolume][, channelVolumes]);

        #Buffer
        [underflow, nextSampleStartIndex, nextSampleETASecs] = PsychPortAudio('FillBuffer', pahandle, bufferdata [, streamingrefill=0][, startIndex=Append]);
        bufferhandle = PsychPortAudio('CreateBuffer' [, pahandle], bufferdata);
        PsychPortAudio('DeleteBuffer'[, bufferhandle] [, waitmode]);

        #Audio data
        [audiodata absrecposition overflow cstarttime] = PsychPortAudio(‘GetAudioData’, pahandle [, amountToAllocateSecs][, minimumAmountToReturnSecs][, maximumAmountToReturnSecs][, singleType=0]);


        #Start stop
        startTime = PsychPortAudio(‘Start’, pahandle [, repetitions=1] [, when=0] [, waitForStart=0] [, stopTime=inf] [, resume=0]);
        [startTime endPositionSecs xruns estStopTime] = PsychPortAudio(‘Stop’, pahandle [,waitForEndOfPlayback=0] [, blockUntilStopped=1] [, repetitions] [, stopTime]);

        status = PsychPortAudio(‘GetStatus’ pahandle);
    end
    function test
        load handel.mat
        Fs
        y
    end
    function help
        InitializePsychSound
    end
    function open(mode)
        mode=1 %1 playbay, 2 capture, both
        OpenSlave
        reqlatencyclass=0 %0 don't care, 1 balance 2 full control, 3 super agressive
        freq %sampling rate
        obj.pahandle=psychPortAudio('Open',obj.deviceid,mode,reqlatencyclass,freq,channels,bufferSize,suggestedLatency,selectchannels,specialFlags)
        InitializePsychSound(bReallyLow)
    end
    function close
        psychPortAudio('Close')
    end
end
end
