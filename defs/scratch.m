
    function P=parse_defs_bg(obj)
        P={ ...
                 'bUse'            ,1          ,@isbinary...
                ;'Type'            , '1/f'     ,@ischar ...
                ;'bPlate'          ,1          ,@isbinary ...
                ;'plateRadiusXYdeg',20         ,@(x) isnumeric(x) & numel(x)==2 ...
                ;'plateShape'      ,'circle'   ,@ischar ...
                ;'plateColor'      ,[]         ,@isnumeric ...
        };
    end
    function P=parse_defs_ch(obj)
        P={ ...
                 'bUse',1,@isnumeric ...
                ;'type',{'+','x','O','o'},@(x) ischar(x) | iscell(x); ...
                ;'color',[1 1 1; 1 1 1; 1 1 1; .5 .5 .5],@isnumeric; ...
                ;'innerBorder',[1 1],@isnumeric); ...
                ;'hairWHdeg',[.25,4],@(x) isnumeric(x) & numel(x)==2 ...
                ;'radiusWHdeg',[2.5,3],@(x) isnumeric(x) & numel(x)==2 ...
                ;'shape','o',@ischar ...
                ;'bDichoptic',0,@isbinary ...
        };
    end
    function P= parse_defs_keys(obj)
        P={...
                 'bUseCaps'   ,1 ,@isbinary ...
                ;'pauseLength',.2,@isnumeric...
        };
    end
    function P = parse_defs_prb(obj)
        % XXX
    end
    function P=parse_defs_ptb(obj)
        P={...
               'gry'           ,.5 ,@isnumeric ...
              ;'wht'           ,1  ,@isnumeric ...
              ;'blk'           ,0  ,@isnumeric ...
              ;'bSkipSyncTest' ,[] ,@isnumeric ...
              ;'bDebug'        ,0  ,@isnumeric ...
              ;'textSize'      ,20 ,@isnumeric ...
              ;'display'       ,[] ,@isnumeric ...
              ;'bDummy'        ,[] ,@isnumeric ...
              ;'textFont'      ,[] ,@isnumeric ...
              ;'stereoMode'    ,[] ,@isnumeric ...
              ;'DC'            ,[] ,@isnumeric ...
              ;'bSkipSyncTest' ,0  ,@isbinary ...
              ;'bDebug'        ,0  ,@isbinary ...
        };
    end
    function P=parse_defs_stm(obj)
        P={...
             'pointORloc',[]        ,@isnumeric ...
            ;'stmXYdeg'  ,[1        ,1],@(x) isnumeric(x) & numel(x)==2) ...
            ;'bCheckRMS' ,0         ,@isbinar ...
            ;'RMSfix'    ,.14       ,@isnumeric ...
            ;'bRMSfix'   ,[]        ,@isbinary ...
            ;'RMSdc'     ,obj.ptb.DC,@isnumeric ...
            ;'stmType'   ,[]        ,@ischar ...
            ;'timeMult'  ,1         ,@isnumeric ...
            ;'sizeMult'  ,1         ,@isnumeric
        };
    end
    function P=parse_defs_win(obj)
        P={...
            ;'bUse'   ,1         ,@isbinary ...
            ;'type','cos'        ,@ischar ...
            ;'bSymInd'    ,[]        ,@isnumeric ...
            ;'dskDmRCT'  ,[]        ,@isnumeric ...
            ;'rmpDmRCT'  ,[]        ,@isnumeric ...
        };
    end
    function P=parse_defs_ui(obj)
        P={...
             'bUseTrialCounter' ,1 ,@isbinary ...
            ;'bInstructions'    ,0 ,@isbinary ...

            ;'bCountdownOnReset',0 ,@isnumeric ...
            ;'bIntro'           ,1 ,@isnumeric ...
            ;'nReset'           ,10,@isnumeric ...


            ;'textSize'         ,20,@isnumeric ...
            ;'textVal'         ,1.8,@isnumeric ...

            ;'zoomInc',        ,.1,@isnumeric ...
            ;'maxSizeXYdeg',[10 10],   @isnumeric...
            ;'minSizeXYdeg',[.01 .01], @isnumeric ...

            ;'bShowInfo', [], @isnumeric ...
        };
    end
    function P=parse_defs_exp(obj)
    end
    function p=def_params()
    p={...
        % name               , value                         , bShow         , where  , min  ,max,vals,bActive
        'pointORloc'         , num2str(obj.stm.pointORloc    ) ,0              ,'panel' ,[] ,[] ,1,0... % XXX pointORlocVal
        ; 'RMSmonoORbino'    ,         obj.stm.RMSmonoORbino   ,1              ,'panel' ,[] ,[] ,1,0...
        ; 'stmXYdeg'         , num2str(obj.stm.stmXYdeg      ) ,0              ,'panel' ,0  ,1  ,1,0...
        ; 'bCheckRMS'        , num2str(obj.stm.bCheckRMS     ) ,1              ,'panel' ,0  ,1  ,1,0...
        ; 'bRMSfix'          , num2str(obj.stm.bRMSfix       ) ,1              ,'panel' ,0  ,1  ,1,0...
        ; 'RMSfix'           , num2str(obj.stm.RMSfix        ) ,obj.stm.bRMSfix,'panel' ,0  ,1  ,1,0...
        ; 'RMSdc'            , num2str(obj.stm.RMSdc         ) ,obj.stm.bRMSfix,'panel' ,0  ,1  ,1,0...
        ; 'stmType'          ,         obj.stm.stmType         ,1              ,'panel' ,0  ,1  ,1,0...
        ; 'timeMult'         , num2str(obj.stm.timeMult      ) ,0              ,'panel' ,0  ,1  ,1,0...
        ; 'sizeMult'         , num2str(obj.stm.sizeMult      ) ,0              ,'panel' ,0  ,1  ,1,0...

        ; 'bWindow'          , num2str(obj.stm.bWindow       ) ,0              ,'window',0  ,1  ,1,0...
        ; 'windowType'       ,         obj.stm.windowType      ,0              ,'window',0  ,1  ,1,0...
        ; 'wszRCT'           , num2str(obj.stm.wszRCT        ) ,0              ,'window',0  ,1  ,1,0...
        ; 'Wk'               , num2str(obj.stm.Wk            ) ,0              ,'window',0  ,1  ,1,0...
        ; 'dskDmRCT'         , num2str(obj.stm.dsmDmRCT      ) ,0              ,'window',0  ,1  ,1,0...
        ; 'rmpDMRCT'         , num2str(obj.stm.rmpDMRCT      ) ,0              ,'window',0  ,1  ,1,0...

        ; 'bUseTrialCounter' , num2str(obj.bUseTrialCounter  ) ,0              ,'exp'   ,0  ,1  ,1,0...
        ; 'bInstructions'    , num2str(obj.bInstructions     ) ,0              ,'exp'   ,0  ,1  ,1,0...
        ; 'bIntro'           , num2str(obj.bIntro            ) ,0              ,'exp'   ,0  ,1  ,1,0...
        ; 'iii'              , num2str(obj.iii               ) ,0              ,'exp'   ,0  ,1  ,1,0...
        ; 'nReset'           , num2str(obj.bCountDownOnReset ) ,0              ,'exp'   ,0  ,1  ,1,0...

        ; 'bUse'             ,num2str(obj.Ch.bUse            ) ,0              ,'exp'   ,0  ,1  ,1,0...
        ; 'crossType'        ,        obj.Ch.crossType         ,0              ,'exp'   ,0  ,1  ,1,0...
        ; 'color'            ,num2str(obj.Ch.color           ) ,0              ,'exp'   ,0  ,1  ,1,0...
        ; 'innerBorder'      ,num2str(obj.Ch.innerBorder     ) ,0              ,'exp'   ,0  ,1  ,1,0...
        ; 'hairWHdeg'        ,num2str(obj.Ch.hairWHdeg       ) ,0              ,'exp'   ,0  ,1  ,1,0...
        ; 'radiusWHdeg'      ,num2str(obj.Ch.radiusWHdeg     ) ,0              ,'exp'   ,0  ,1  ,1,0...
        ; 'shape'            ,num2str(obj.Ch.shape           ) ,0              ,'exp'   ,0  ,1  ,1,0...
        ; 'bDichoptic'       ,num2str(obj.Ch.bDichoptic      ) ,0              ,'exp'   ,0  ,1  ,1,0...


        ;'bUse'              ,num2str(obj.Bg.bUse            ) ,0              ,'exp'   ,0  ,1  ,1,0...
        ;'type'              ,        obj.Bg.type              ,0              ,'exp'   ,0  ,1  ,1,0...
        ;'bPlate'            ,num2str(obj.Bg.bPlate          ) ,0              ,'exp'   ,0  ,1  ,1,0...
        ;'plateRadiusXYdeg'  ,num2str(obj.Bg.plateRadiusXYdeg) ,0              ,'exp'   ,0  ,1  ,1,0...
        ;'plateShape'        ,        obj.Bg.plateShape        ,0              ,'exp'   ,0  ,1  ,1,0...
        ;'plateColor'        ,num2str(obj.Bg.plateColor      ) ,0              ,'exp'   ,0  ,1  ,1,0...
        ;'bUpdate'           ,num2str(obj.Bg.bUpdate         ) ,0              ,'exp'   ,0  ,1  ,1,0...
      };

%; 'expType'          ,         obj.expTypeSaved        ,0              ,'exp'   ,0  ,1  ,1,0...
%; 'xORz'             ,         obj.xORz                ,0              ,'exp'   ,0  ,1  ,1,0...
%; 'magORval'         ,         obj.magORval            ,0              ,'exp'   ,0  ,1  ,1,0...
   end
