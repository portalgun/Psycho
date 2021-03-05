classdef psycho_simple < handle
%
%   example call: % GENERATE STIMULUS STRUCT
%                   Screen('Preference', 'SkipSyncTests', 1);
%                   S = psyDSPstimStructTEMPLATE(6,0);
%                   ExpDSPestimationTEMPLATE(S,'JNK',1:6,1,0,1);
%
% run 2AFC experiment on speed discrimination w. natural stims
%
% Sexp:          stimulus structure containing all stimuli to be used
%                in the entire experiment
%                'JNK', 'JDB', etc
% bUseFeedback:  boolean indicating whether to use feedback or not
% bSKIPSYNCTEST: flag for skipping the psychtoolbox synctests
%                NOTE! experimental data should be gathered only when = 0
%                1 -> skip PTB sync tests
%                0 -> skip PTB sync tests
% bDEBUG:        flag for debugging
%                1 -> DEBUGGIN!
%                0 -> run for serious
% %%%%%%%%%%%%%%%%%%%%%%
% S:             stimulus parameters and subject responses
% D:             display  parameters
% ==============================================================================
properties
    COUNTER
    STMINFO
    CH
    RSP
    KEY
    PTB
    D
    S
    expType
    Opts
end
properties(Hidden=true)
    stm
    stmTex
    t=0
    exitflag=0;  % 1 = deliberate quit
    returncode=0 % 1  complete  0  run  -1 error  -2 exited
    bRunner=0;
    ME
    
end
methods
    function obj = psycho_simple(S,allOpts,bRunner,bTest);
        if exist('bRunner','var') && ~isempty(bRunner)
            obj.bRunner=bRunner; 
        end
        if ~exist('bTest','var') || isempty(bTest)
            bTest=0;
        end
        if exist('allOpts','var') && ~isempty(allOpts) && isstruct(allOpts)
            unpackOpts(allOpts);
        end
        if ~exist('expType','var')
            expType=struct();
        end
        if ~exist('ptbOpts','var')
            ptbOpts=struct();
        end
        if ~exist('keyOpts','var')
            keyOpts=struct();
        end
        if ~exist('rspOpts','var')
            rspOpts=struct();
        end
        if ~exist('chOpts','var')
            chOpts=struct();
        end
        if ~exist('dOpts','var')
            dOpts=struct();
        end
        if ~exist('counterOpts','var')
            counterOpts=struct();
        end
        if ~exist('stmInfoOpts','var')
            stmInfoOpts=struct();
        end

        obj.parse_expType(expType);
        disp('D------------------------------------------------------------------')
        obj.parse_dOpts(dOpts,bTest);
        disp('S------------------------------------------------------------------')
        obj.parse_S(S);
        disp('KEY----------------------------------------------------------------')
        obj.KEY=Key(keyOpts);
        disp('RSP----------------------------------------------------------------')
        obj.RSP=Rsp(rspOpts,obj.D.nTrial,1);
        disp('PTB----------------------------------------------------------------')
        obj.PTB=ptb_session([],ptbOpts,0); % 10 ptb

        try
        disp('CH----------------------------------------------------------------')
            obj.CH=Ch(chOpts,obj.PTB);

            if obj.D.bTest
                disp('STM_INFO----------------------------------------------------------')
                stmInfoOpts.relRec=obj.CH.prect;
                obj.STMINFO=stmInfo(S,obj.expType,obj.PTB,stmInfoOpts);
            end
            disp('COUNTER-----------------------------------------------------------')
            obj.COUNTER=counter(obj.D.nTrial,obj.PTB,counterOpts);

            obj.get_ply();

            if obj.D.bMotion
                obj.D.numFrm = round((obj.S.durationMs./1000)./obj.PTB.ifi);
            end
            disp('PTB---------------------------------------------------------------')
        catch ME
            obj.ME=ME;
            obj.exit();
        end
        if ~bRunner
            obj.run();
        end
    end
    function obj=parse_expType(obj,expType)
        switch expType
            case {'2IFC','2AFC'}
                obj.expType='2IFC';
        end
    end
    function obj=parse_S(obj,S)
        obj.S=S;
        flds=fieldnames(S);

        trls=flds(ismember(flds,{'nTrls','nTrl','nTrial','nTrials','trlPerRun'}));
        if ~isempty(flds)
            obj.D.nTrial=S.(trls{1});
        end

        stm=flds(ismember(flds,{'cmpIphtXY','cmpIpht'}));
        if ~isempty(flds) && numel(size(S.(stm{1}))) > 3
            obj.D.bMotion=1;
        else
            obj.D.bMotion=0;
        end
    end
    function obj=parse_dOpts(obj,dOpts,bTest)
        if contains(obj.expType,'IFC')
            bHide=1;
        else
            bHide=0;
        end
        names={...
                  'bTest',0         ,'isbinary';...
                  'nInterval' ,1    ,'isint';...
                  'bUseBg'  ,1    ,'isbinary';...
                  'isi'       ,0.250,'isnumeric';...
                  'iti'       ,0.250,'isnumeric';...
                  'breakTime' ,1    ,'isnumeric';...
                  'nCountDown',3    ,'isint';...
                  'countDownTime', 1,'isnumeric';...
                  'nReset',10   ,'isint';...
                  'bHideLastInterval', bHide ,'isint'
              };
        obj.D=parse(obj.D,dOpts,names);
        if obj.D.bTest || bTest
            obj.D.bTest=bTest;
        end
            
    end
    function obj=get_ply(obj)
        % SET STIMULUS PARAMETERS %
        obj.D.plyXYpix = bsxfun(@times,obj.S.stmXYdeg,obj.PTB.display.pixPerDegXY);

        % BUILD DESTINATION RECTANGLE IN MIDDLE OF DISPLAY
        obj.D.plySqrPix    = CenterRect([0 0 obj.D.plyXYpix(1) obj.D.plyXYpix(2)], obj.PTB.display.wdwXYpix);
        plySqrPixCrdXY = obj.D.plySqrPix(1:2);
        plySqrPixSizXY = obj.D.plySqrPix(3:4)-obj.D.plySqrPix(1:2);

        %[fPosX,fPosY] = RectCenter(obj.D.wdwXYpix);
        %obj.D.fixStm = [fPosX-1,fPosY+plySqrPixSizXY(2),fPosX+1,fPosY+plySqrPixSizXY(2)+25; ...
        %            fPosX-1,fPosY-plySqrPixSizXY(2),fPosX+1,fPosY-plySqrPixSizXY(2)-25; ...
        %            fPosX+plySqrPixSizXY(1),fPosY+1,fPosX+plySqrPixSizXY(1)+25,fPosY-1; ...
        %            fPosX-plySqrPixSizXY(1),fPosY+1,fPosX-plySqrPixSizXY(1)-25,fPosY-1]';
    end
    function obj=reset_bg(obj)
        obj.make_bg();
        obj.present_break();
        obj.present_countdown();
    end
    function obj= make_bg(obj)
        if isfield(obj.D,'tex1oF') && ~isempty(obj.D.tex1oF)
            Screen('Close', obj.D.tex1oF);
            obj.D.tex1oF=[];
        end
        if   obj.D.bUseBg
            msk1oF=obj.make_noise();
            obj.D.tex1oF = Screen('MakeTexture', obj.PTB.wdwPtr, msk1oF,[],[],2);
        end
    end
    function obj= draw_bg(obj)
        for s = 0:obj.sStereo
            Screen('SelectStereoDrawBuffer', obj.PTB.wdwPtr, s);
            Screen('DrawTexture', obj.PTB.wdwPtr, obj.D.tex1oF, [],obj.PTB.display.wdwXYpix);
        end
    end
    function obj=draw_cross(obj)
        obj.CH.draw();
    end
    % CREATE & DISPLAY STIMULI
    function obj=draw_aux(obj,bCross)
        %Screen('BlendFunction', obj.D.wdwPtr, 'GL_ONE', 'GL_ONE');
        if ~exist('bCross','var') || isempty(bCross)
            bCross=1;
        end
        if obj.D.bUseBg
            obj.draw_bg;
        end
        if bCross
            obj.draw_cross();
        end
        obj.COUNTER.draw(obj.t);

        if obj.D.bTest & obj.t > 0
            obj.STMINFO.draw(obj.t);
        end

    end
    function obj=draw_complete(obj)
        Screen('DrawingFinished', obj.PTB.wdwPtr);
        if obj.t > 0
            obj.D.flipTime(obj.t)=Screen('Flip', obj.PTB.wdwPtr);
        else
            Screen('Flip', obj.PTB.wdwPtr);
        end
    end
%% MAIN
    function obj=run(obj)
        try
            obj.run_helper();
        catch ME
            obj.ME=ME;
            obj.exit(); 
        end 
        obj.exit();
    end

    function obj=run_helper(obj)
        disp('RUN---------------------------------------------------------------')
        Screen('Flip', obj.PTB.wdwPtr);
        obj.make_bg();
        obj.present_keystart;
        obj.present_countdown();
        for tt = 1:obj.D.nTrial
            if tt~=1 &&  mod(tt-1,obj.D.nReset)==0
                obj.reset_bg();
            end
            obj.draw_aux();
            WaitSecs(obj.D.iti);
            obj.present_trial(tt);
            obj.get_response(tt);
            if obj.exitflag
                break
            end
        end
    end
    function obj=present_break(obj)
        obj.draw_aux(0);
        obj.draw_complete();
        WaitSecs(obj.D.breakTime);
    end
    function obj=present_countdown(obj)
        for c = obj.D.nCountDown:-1:1
            obj.draw_aux();

            for s=0:obj.sStereo
                sz=obj.PTB.display.scrnXYpix;
                str=num2str(c);
                Screen('SelectStereoDrawBuffer', obj.PTB.wdwPtr, s);
                Screen('DrawText',obj.PTB.wdwPtr, str, sz(1)/2-10, sz(2)/2-8, [obj.PTB.wht],[obj.PTB.gry obj.PTB.gry obj.PTB.gry]);
            end

            obj.draw_complete();
            WaitSecs(obj.D.countDownTime);
        end
    end
    function obj=present_keystart(obj)
        obj.draw_bg();
        for s=0:obj.sStereo
            sz=obj.PTB.display.scrnXYpix;
            str='Press Up To start';
            Screen('SelectStereoDrawBuffer', obj.PTB.wdwPtr, s);
            Screen('DrawText',obj.PTB.wdwPtr, str, sz(1)/2-165, sz(2)/2-5, [obj.PTB.wht],[obj.PTB.gry obj.PTB.gry obj.PTB.gry]);
        end
        obj.draw_complete();
        tt=tic;
        while true
            obj.KEY.read();
            if isempty(obj.KEY.OUT)
                continue
            end
            break
            elap=toc(tt);
            if obj.D.bTest & elap > 15
                error('timeout')
            end
        end
    end
    function  obj=present_trial(obj,tt)
        obj.t=tt;
        for int=1:obj.D.nInterval
            obj.present_isi();
            obj.present_interval(tt,int);
        end
        if obj.D.bHideLastInterval
            obj.present_isi();
        end
    end
    function obj=present_isi(obj)
        obj.draw_aux();
        obj.draw_complete();
        WaitSecs(obj.D.isi);
    end
    function obj=present_interval(obj,tt,i)
        if endsWith(obj.expType,'IFC')
            obj.present_interval_IFC(tt,i);
        end
    end
    function obj=get_stm(obj,tt,int)
        if ~obj.D.bMotion
            obj.get_stm_static(tt,int);
        end
    end
    function obj=get_stm_static(obj,tt,int)
        if obj.S.stdIntrvl(tt)==int-1
            obj.stm{1}=obj.S.stdIphtL(:,:,tt);
            obj.stm{2}=obj.S.stdIphtR(:,:,tt);
        else
            obj.stm{1}=obj.S.cmpIphtL(:,:,tt);
            obj.stm{2}=obj.S.cmpIphtR(:,:,tt);
        end
        for s = 0:obj.sStereo
            Screen('SelectStereoDrawBuffer', obj.PTB.wdwPtr, s);
            obj.stmTex{s+1}  = Screen('MakeTexture', obj.PTB.wdwPtr, obj.stm{s+1},[],[],2);
        end
    end
    function obj=close_stm(obj)
        if isempty(obj.stmTex)
            return
        end
        for s = 1:obj.PTB.bStereo+1
            if ~isempty(obj.stmTex{s})
                Screen('Close', obj.stmTex{s});
            end
        end
        obj.stmTex=[];
    end
    function obj=draw_stm(obj)
        for s = 0:obj.sStereo
            Screen('SelectStereoDrawBuffer', obj.PTB.wdwPtr, s);
            Screen('DrawTexture', obj.PTB.wdwPtr, obj.stmTex{s+1}, [],obj.D.plySqrPix);
        end
    end
    function obj=present_interval_IFC(obj,tt,int)
        obj.get_stm(tt,int);

        obj.draw_aux();
        obj.draw_stm();
        obj.draw_complete();
        WaitSecs(obj.S.durationMs./1000);
        obj.close_stm();

    end
    function obj=wait_for_press(obj)
        tic=tt;
        while true
            obj.KEY.read();
            if ~isempty(obj.KEY.capture.OUT)
                break
            end
            elap=toc(tt);
            if obj.D.bTest & elap > 15
                error('timeout')
            end
        end
    end


    function obj=get_response(obj,tt)
        obj.KEY.OUT=[];
        while true
            obj.KEY.read();
            if isempty(obj.KEY.OUT)
                continue
            elseif strcmp(obj.KEY.OUT{2},'exp') && strcmp(obj.KEY.OUT{3},'exit')
                obj.exitflag=1;
                break
            elseif strcmp(obj.KEY.OUT{2},'rsp')
                R=obj.KEY.OUT{3};
                std=obj.S.stdX(obj.t);
                cmp=obj.S.cmpX(obj.t);
                int=obj.S.cmpIntrvl(obj.t);
                [~,answer]=obj.RSP.get_correct_2IFC(R,std,cmp,int);
                obj.RSP.record(tt,1,R,answer);
                break
            end
        end
    end
%% EXIT
    function obj=exit(obj)
        %returncode % 1 complete, -1 error -2 exited
        tic
            obj.PTB.sca;
        toc
        obj.get_return_code();
        if ~isempty(obj.ME) && ~obj.bRunner
            rethrow(obj.ME); 
        end
        return
    end
    function obj=get_return_code(obj)
    % consistent with runner
    % 1  complete  0  run  -1 error  -2 exited
        if ~isempty(obj.ME)
            obj.returncode=-1;   
        elseif obj.exitflag==1
            obj.returncode=-2;
        elseif obj.exitflag==0;
            % TODO also check completion
            obj.returncode=1;
        end
    end
    function out=sStereo(obj)
        out=double(obj.PTB.bStereo);
    end
    function mskNoise=make_noise(obj)
        PszXY=obj.PTB.display.scrnXYpix;
        mskNoise = coloredNoise(PszXY,-1);
        CIsz = 99.9./100;
        [Qlohi]=quantile(mskNoise(:),[(1 - CIsz)./2  1-(1 - CIsz)./2]);

        mskNoise = (mskNoise - Qlohi(1))./(Qlohi(2) - Qlohi(1));
        bIndLo = mskNoise<0;
        bIndHi = mskNoise>1;
        mskNoise(bIndLo) = 0;
        mskNoise(bIndHi) = 1;
    end
end
end

