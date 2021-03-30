classdef ptb_session < handle
% help OculusVR
% developer.oculus.com/download
% PsychVRHMD

properties
    display
    bSkipSyncTest=0
    bVR=0
    bDebug=0
    bDummy=0
    opacityAlpha
    cal
    stereoMode
    bStereo
    gry=0.5
    blk=0.0
    wht=1.0

    wdwPtr
    wdwXYpix

    refreshRate
    bitsOut
    bAlphaBlendingOn=0
    bDataPixxOn=0
    textSize=30
    textFont
    ifi
    fps
    DC

    HMD

end
methods
    function obj=ptb_session(display,Opts,bDummy)
        if ~exist('Opts','var')
            Opts=struct();
        end
        obj.parse_opts(Opts);
        if exist('bDummy','var') && isempty(bDummy)
            obj.bDummy=bDummy;
        end

        % DISPLAY
        if (~exist('display','var') || isempty(display)) && isfield(Opts,'display')
            display=Opts.display;
            Opts=rmfield(Opts,'display');
        elseif (~exist('display','var') || isempty(display))
            obj.display=DISPLAY.get_display_from_hostname(obj.bVR);
        elseif isa(display,'DISPLAY')
            obj.display=display;
        elseif ischar(display)
            obj.display=DISPLAY.get_display_from_string(display,obj.bVR);
        end

        if isprop(obj.display,'bSkipSyncTest') && ~isempty(obj.display.bSkipSyncTest)
            obj.bSkipSyncTest=obj.display.bSkipSyncTest;
        end


        if ~exist('stereomode','var')
            obj.stereoMode=obj.display.defaultStereoMode;
        end
        obj.bStereo=obj.stereoMode > 0;

        if obj.bDummy
            return
        end

        try
            sca;
        end
        obj.ptb_session_main;

    end
    function obj=parse_opts(obj,Opts)
        % INPUT PARSER
        flds=fieldnames(Opts);
        for i = 1:length(flds)
            fld=flds{i};
            obj.(fld)=Opts.(fld);
        end
        if isempty(obj.textFont) && ismac
            obj.textFont = 'Andale Mono';
        elseif isempty(obj.textFont) && islinux
            textFont             = '-misc-dejavu sans mono-bold-o-normal--0-0-0-0-m-0-ascii-0';
        end

        if obj.bDebug
            obj.opacityAlpha = 0.5;
        else
            obj.opacityAlpha = 1.0;
        end
    end
    function obj=ptb_session_main(obj)
        disp('---SETUP_START-----------------------------------------------------')
        try
            if obj.display.bPreScript
                obj.display.prescript();
            end
            disp('---DISPLAY---------------------------------------------------------')
            obj.display=obj.display.init(obj);
            disp('---SETUP-----------------------------------------------------------')
            obj.setup();
            disp('---GAMMA-----------------------------------------------------------')
            obj.gamma_setup();

            obj.DP_open();
            disp('---OPEN------------------------------------------------------------')
            obj.open(); %wdwPtr
            if obj.bVR

                disp('---VR------------------------------------------------------------')
                obj.VR_setup();
            end
            disp('---IFI------------------------------------------------------------')
            obj.get_ifi();
            disp('---TEXT-----------------------------------------------------------')
            obj.set_text;
            disp('---ALPHA----------------------------------------------------------')
            obj.alpha_blend_on;
            disp('---GAMMA_APPLY----------------------------------------------------')
            obj.gamma_correct();
            disp('---FLIP-----------------------------------------------------------')
            Screen('Flip', obj.wdwPtr,[],0);
            obj.refresh;
            ListenChar(-1);
            disp('---SETUP_END------------------------------------------------------')
        catch ME
            try
                obj.sca;
            end
            rethrow(ME);
        end
    end
    function obj = get_ifi(obj)
        obj.ifi     = Screen('GetFlipInterval', obj.wdwPtr);
        obj.fps     = 1/obj.ifi;
    end

    function obj=setup(obj)
        AssertOpenGL;

        % PREPARE PSYCHIMAGING
        PsychImaging('PrepareConfiguration');
        % FLOATING POINT NUMBERS
        PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
        % USE NORMALIZED [0 1] RANGE FOR COLOR AND LUMINANCE LEVELS
        PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange');
        % SKIP SYNCTESTS OR NOT
        Screen('Preference', 'SkipSyncTests', double(obj.bSkipSyncTest));
        if obj.bVR
            obj.setup_VR();
        end

        PsychDebugWindowConfiguration([],obj.opacityAlpha); % NOTE! must call before opening ptb window
    end
    function obj=VR_setup(obj)
        if obj.bStereo
            str='Stereoscopic';
        elseif ~obj.bStereo
            str='Monoscopic';
        end
        obj.HMD = PsychVRHMD('AutoSetupHMD', str);

        [projL,projR]=psychVRHMD('GetStaticREnderParameters',hmd);
        needPanelFitter = psychVRHMD('GetPanelFitterParameters',hmd);
        [bufferSize, imagingFlags, stereoMode]=PsychVRHMD('GetClientRenderingParameters',hmd);
        PsychVRHMD('SetBasicQuality', hmd, basicQuality);
        PsychVRHMD('SetupRenderingParameters', hmd, basicTask,basicRequirements,basicQuality,fov,pixelsPerDisplay)
        %pixelsPerDisplay - ratio of number of render target pixels to display pixels at center of distortion (def 1.0)
        %fov [leftdeg rightdeg updeg downdeg]
        info = PsychVRHMD('GetInfo',hmd);
        PsychVRHMD('Close',hmd);
        hmnd;

    end

    function obj=DP_open(obj)
        dhn=strrep(obj.display.hostname,'-','_');

        if obj.display.bDataPixx && isequal(hostname,dhn)
            disp('---DATAPIXX------------------------------------------------------')
            % SET BOOLEAN INDICATING THAT DATAPIXX IS BEING USED

            % TURN DATAPIXX ON
            Datapixx('Open');
            Datapixx('SelectDevice',2,'LEFT');      % SELECT LEFT  VIEWPIXX MONITOR
            Datapixx('SetVideoGreyscaleMode',1);    % TURN ON CUSTOM GRAYSCALE MODE: RED CHANNEL==LEFT
            Datapixx('SelectDevice',2,'RIGHT');     % SELECT RIGHT VIEWPIXX MONITOR
            Datapixx('SetVideoGreyscaleMode',2);    % TURN ON CUSTOM GRAYSCALE MODE: GREEN==RIGHT CHANNEL
            Datapixx('SelectDevice',-1);            % NORMAL OPERATION
            Datapixx('RegWr');                      % WRITE
            obj.bDataPixxOn = 1;
        else
            obj.bDataPixxOn = 0;
            %disp(['psyDatapixxInit: WARNING! unrecognized localHostName: ' hostname() '. Write code?']);
        end
    end
    function obj=DP_close(obj)
        %% TURN DATAPIXX OFF
        if obj.bDataPixxOn==0
            return
        end
        Datapixx('Open');
        Datapixx('SelectDevice',2,'LEFT');      % SELECT LEFT  VIEWPIXX MONITOR
        Datapixx('SetVideoGreyscaleMode',0);    % TURN OFF CUSTOM GRAYSCALE MODE
        Datapixx('SelectDevice',2,'RIGHT');     % SELECT RIGHT VIEWPIXX MONITOR
        Datapixx('SetVideoGreyscaleMode',0);    % TURN OFF CUSTOM GRAYSCALE MODE
        Datapixx('SelectDevice',-1);            % NORMAL OPERATION
        Datapixx('RegWr');                      % WRITE
        Datapixx('Close');
        obj.bDataPixxOn = 0;
    end

    function obj=alpha_blend_on(obj)
% MOST COMMON ALPHA-BLENDING FACTORS
        Screen('BlendFunction', obj.wdwPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        obj.bAlphaBlendingOn=1;
    end

    function obj=alpha_blend_off(obj,wdwPtr)
        Screen('BlendFunction', wdwPtr, GL_ONE, GL_ZERO);
        obj.bAlphaBlendingOn=0;
    end

    function obj=open(obj)
        [obj.wdwPtr, obj.wdwXYpix]  = PsychImaging('OpenWindow', obj.display.sid, obj.gry, [],[], [], obj.stereoMode);
    end

    function []=set_text(obj)
        Screen('TextFont', obj.wdwPtr, obj.textFont);
        Screen('TextSize',obj.wdwPtr,obj.textSize);
    end

    function []=flip(obj,when)
        if ~exist('when','var')
            when=0;
        end
        Screen('DrawingFinished',obj.wdwPtr);
        Screen('Flip',obj.wdwPtr,when,0,0,1);
    end
    function []=flip_hold(obj,when)
        if ~exist('when','var')
            when=0;
        end
        Screen('DrawingFinished',obj.wdwPtr);
        Screen('Flip',obj.wdwPtr,when,1,0,1);
    end

    function obj=refresh(obj)
        obj.refreshRate=Screen('GetFlipInterval',obj.wdwPtr);
    end

    function []= gamma_correct(obj)
        switch obj.display.gammaCorrectionType
        case 'LookupTable'
            PsychColorCorrection('SetLookupTable', obj.wdwPtr, obj.display.gamInv);
            disp(['psyPTBgammaCorrect: Using ' obj.display.gammaCorrectionType ' to correct gamma']);
        case 'SimpleGamma'
% SIMPLE GAMMA
            PsychColorCorrection('SetEncodingGamma', obj.wdwPtr, 1./obj.display.gamFncExponent);
            disp('PsychColorCorrection: WARNING! correcting gamma via SimpleGamma. This is not advised!');
        case 'None'
            %
        otherwise
            error(['psyPTBgammaCorrect: WARNING! unhandled D.gammaCorrectionType: ' obj.display.gammaCorrectionType ]);
        end
    end

    function obj=close(obj)
        obj.sca();
    end
    function obj= sca(obj)
        disp('---CLOSE----------------------------------------------------------')

        try
            obj.DP_close;
        end
        sca;
        if obj.display.bPreScript
            try
                rd();
            end
        end
        ListenChar(1);
        disp('---END------------------------------------------------------------')
    end

    function []=gamma_setup(obj)
        obj.display.load_cal;
        dhn=strrep(obj.display.hostname,'-','_');
        if ~isequal(hostname,dhn)
            return
        end
        switch obj.display.gammaCorrectionType
        case 'LookupTable'
            PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'LookupTable');
        case 'Standard'
            error(['psyPTBgammaCorrectSetup: WARNING! gammaCorrectType = ' num2str(obj.gammaCorrectionType) ' not working and not tested']);
        case 'SimpleGamma'
            PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'SimpleGamma');
        otherwise
            error(['psyPTBsetup: WARNING! unhandled gammaCorrectionType. gamCrctType=' obj.display.gammaCorrectionType]);
        end
    end
end
end
