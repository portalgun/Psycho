classdef  Stm < handle & Parent & psyEl & common3D & shape3D & point3D
% XXX t and i
% TODO add gabor and rds
properties
    callOrder %whether constructors get called & order populates children
    STMOPTS
    STMIND % XXX

    OptsInit

    Plate
    Ch
    Ptch
    %Win
    %mask
end
properties(Hidden=true)
    flds={'ch','plate','mask','win','patch'};
end
events
    % select_child
    % select_grandcild
end
methods
    function obj=Stm(ptb,Opts,Parent,index)
        if ~exist('Parent','var')
            Parent=[];
        end
        OPTS=PAR.OPTS.Stm;
        callOrder=Opts.callOrder;
        ptb=PAR.PTB;

        obj@Parent(ptb,Opts,Parent,index);

    end
    function obj=update_patch(obj,Ptch)
        obj.patch=Ptch;
        obj.STMIND.update_ptch_status(t,i,-2);
    end
    function obj=update_Opts(obj,Opts)
        obj.STMOPTS.update(Opts);
        if obj.STMOPTS.bPlate
            obj.Plate.update_Opts(obj.STMOPTS.Plate);
            obj.STMIND.update_plate_status(t,i,-2);
        end
        if obj.STMOPTS.bCh
            obj.Ch.update_Opts(obj.STMOPTS.Ch);
            obj.STMIND.update_ch_status(t,i,-2);
        end
        if obj.STMOPTS.bWin
            obj.Ptch.update_winOpts(obj.STMOPTS.Win);
            obj.STMIND.update_win_status(t,i,-2);
        end
        if obj.STMOPTS.bMask
            obj.Ptch.update_maskOpts(obj.STMOPTS.Mask);
            obj.STMIND.update_mask_status(t,i,-2);
        end
        if obj.STMOPTS.bPtch
            obj.Ptch.update_Opts(obj.STMOPTS.Ptch);
            obj.STMIND.update_ptch_status(t,i,-2);
        end
    end
    function obj=check(obj)
        for i = 1:length(obj.callOrder)
            child=obj.callOrder{i};
            switch child
                case 'Ch'
                    if obj.STMIND.cStatus==-2
                        obj.Ch.check(); % XXX ?
                        obj.Ch.update();
                        obj.STMIND.update_ch_status(t,i,1);
                    end
                case 'Plate'
                    if obj.STMIND.plateStatus==-2
                        obj.Plate.check(); % XXX ?
                        obj.Plate.update();
                        obj.STMIND.update_plate_status(t,i,1);
                    end
                case 'Ptch'
                    if obj.STMIND.ptchStatus==-2
                        obj.Ptch.check(); % XXX ?
                        obj.Ptch.update();
                        obj.STMIND.update_ptch_status(t,i,1);
                    end
                otherwise
                    error(['unhandled child ' child ' for Stm'])
            end
        end
    end
    function obj=draw(obj)
        for i = 1:length(obj.callOrder)
            child=obj.callOrder{i};
            switch child
                case 'Ch'
                    if obj.STMIND.cStatus==1
                        obj.Ch.draw();
                        obj.STMIND.update_ch_status(t,i,2);
                    end
                case 'Plate'
                    if obj.STMIND.plStatus==1
                        obj.Plate.draw();
                        obj.STMIND.update_plate_status(t,i,2);
                    end
                case 'Ptch'
                    if obj.STMIND.pStatus==1
                        obj.Ptch.draw();
                        obj.STMIND.update_ptch_status(t,i,2);
                    end
                otherwise
                    error(['unhandled child ' child ' for Stm'])
            end
        end
    end
    function obj=close(obj)
        for i = 1:length(obj.callOrder)
            child=obj.callOrder{i};
            switch child
                case 'Ch'
                    obj.Ch.close();
                     obj.STMIND.update_ch_status(t,i,-1);
                case 'Plate'
                    obj.Plate.close();
                     obj.STMIND.update_plate_status(t,i,-1);
                case 'Ptch'
                    obj.Ptch.close();
                     obj.STMIND.update_ptch_status(t,i,-1);
                otherwise
                    error(['unhandled child ' child ' for Stm'])
            end
        end
    end
end
end
