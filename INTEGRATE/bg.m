classdef  bg < handle & common3D & shape3D & psyEl
% function obj=bg(ptb,type)
% bg types:
%   'oval'
% most useful Opts:
%   WHpix or WHdeg
%   color1
%   alpha1
methods
    function obj=bg(ptb,type)
        obj.type='rect';
        Opts=struct();
        img=[];

        if ismember(type,{'gry','wht','blk'})
            Opts.color1=type;
        elseif ismember(type,'pnkNs','whtNs','brnNs')
            img=noiseBackgroundImg(type,ptb.display.wndwXYpix)
        elseif isa(type,'img')
            img=type;
        end
        Opts.posXYpix=ptb.display.scrnCtr;

        obj@psyEl(Opts,ptb,img);
        obj.update();
    end
end
end
