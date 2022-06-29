classdef Win3D < handle & Rect3D
properties
%% SHAPE3D
    %shape

    %WHm
    %WHpix
    %WHdeg
    %WHdegRaw % assuming cnetered

    %% T for set time in shape4D

    %rect
    %relRec
    %relPosPRC


%% POINT3D
    %posXYZm
    %posXYpix %CPs
    %posXYpixRaw % if point had no depth

    %vrgXY
    %vrsXY
    %

end
methods(Static)
    function P=getP()
        P=Shape3D.getP();
    end
end
methods
    function obj=Win3D(varargin)
        %p={'VDisp','varargin'};
        p={'VDisp','varargin'};
        opts=Args.group(p,varargin);

        obj.input_parser_Shape3D(opts);
        obj.init_point();
        obj.init_shape();
    end
end
methods(Static=true)
    function F=getPtch2WinInterp(winWHPix,PszRC,res)
    % ptch pix to win pix
        X=linspace(0,PszRC(2),res);
        Y=linspace(0,PszRC(1),res);
        Vx=linspace(0,winWHpix(1),res);
        Vy=linspace(0,winWHpix(2),res);
        F{1}=griddedInterpolant(X,Vx,'linear');
        F{2}=griddedInterpolant(Y,VY,'linear');
    end
    function F=getWin2PtchInterp(winWHPix,PszRC,res)
    % Win pix to patch pix
        X=linspace(0,winWHPix(1),res);
        Y=linspace(0,winWHPix(2),res);
        Vx=linspace(0,PszRC(2),res);
        Vy=linspace(0,PszRC(1),res);
        F{1}=griddedInterpolant(X,Vx,'linear');
        F{2}=griddedInterpolant(Y,Vy,'linear');
    end
end
end
