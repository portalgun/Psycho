classdef  plate < handle & common3D & shape3D & psyEl
% function obj=plate(ptb,plateType,Opts)
% plate types:
%   'rect'
%   'oval'
% most useful Opts:
%   WHpix or WHdeg
%   color1
%   alpha1
methods
    function obj=plate(ptb,Opts,type)
        if isfield(Opts,'type') && (~exist('type') || ~isempty(type))
            type=Opts.type)
        end

        flds=fieldnames(Opts)
        if ~any(ismember(flds,plate.reqShapeParams))
            Opts.WHpix=ptb.display.wdwXYpix*.8;
        end
        if ~any(ismember(flds,plate.reqPointParams))
            Opts.posXYpix=ptb.display.scrnCtr;
        end

        obj@psyEl(Opts,ptb,Opts);
        obj.type=type;

        obj.update();
    end
end
end
