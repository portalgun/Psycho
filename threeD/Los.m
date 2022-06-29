classdef Los < handle
%A point in 3D space given a display
% trgtXYZ PPTxyzM
properties
    posXYZm
    vrs

    los
    dist

    trgtXYZ
    guide
    LorR
    VDisp
end
methods
    function out=copy(obj)
        out=Los(obj.VDisp);
        flds={'posXYZm','vrs','los','dist','trgtXYZ','guide','LorR'};
        for i = 1:length(flds)
            out.(flds{i})=obj.(flds{i});
        end
    end
    function obj=Los(vDisp)
        if nargin > 0
            obj.VDisp=vDisp;
        end
    end
    function getXYZ(obj,los,dist, trgtXYZ,guideLOS,LorR)
        % naive:  [0 0 dist]
        % ambig:  follow LorR, between subj and trgt
        % trans:  XXX
        % C:      XXX
        % anchor: XXX
        if nargin < 3
            trgtXYZ=[];
        end
        if nargin < 4
            guideLos=[];
        end
        if nargin < 5
            LorR=[];
        end
        switch los
        case 'naive'
            obj.get_xyz_naive(dist);               % no x or y
        case 'ambig'
            obj.get_xyz_ambig(dist,trgtXYZ,LorR);  %
        case {'cartesian','trans'}
            obj.get_xyz_trans(dist,guideLOS);
        case 'C'
            obj.get_xyz_C(dist,trgtXYZ,guideLOS);
        case 'anchor'
            obj.get_xyz_anchor(dist,trgtXYZ,guideLOS,LorR);
        end
        obj.los=los;
        obj.dist=dist;
        obj.trgtXYZ=trgtXYZ;
        obj.guide=guideLos;
        obj.LorR=LorR;
    end
%% XYZ
    function get_xyz_naive(obj,dist)
        obj.posXYZm = [      0, 0, dist];
        obj.vrs=0;
    end
    function get_xyz_trans(obj,dist,guide)
        depth=dist*guide.obj.posXYZm(3)/guide.dist;
        obj.posXYZm=[guide.obj.posXYZm(1) guide.obj.posXYZm(2) depth];
        obj.vrs=0;
    end
    function get_xyz_ambig(obj,dist,trgtXYZ,LorR)
        if LorR=='L'
            obj.posXYZm=intersectLinesFromPoints(obj.VDisp.SubjInfo.LExyz,trgtXYZ,[-2 0 dist],[2 0 dist]);
        elseif LorR=='R'
            obj.posXYZm=intersectLinesFromPoints(obj.VDisp.SubjInfo.RExyz,trgtXYZ,[-2 0 dist],[2 0 dist]);
        end
        obj.vrs=atand(trgtXYZ(1)/dist);
    end
    function get_xyz_C(obj,dist,trgtXYZ,guide)
        %XYZ COORDINATES OF RESPONSE PROBE - FROM SIMLAR TRIANGLES
        % XXX guide.trgtXYZ
        obj.posXYZm(1)=dist*guide.trgtXYZ(1)/guide.dist;
        obj.posXYZm(2)=trgtXYZ(2);
        obj.posXYZm(3)=dist*guide.obj.posXYZm(3)/guide.dist;

        % XXX
        % vrs
    end
    function get_xyz_anchor(obj,dist,trgtXYZ,guide,LorR)
        %ASSIGN ANCHOR EYE COORDINATES
        if strcmp(LorR,'L')
            Axyz=obj.VDisp.SubjInfo.LExyz;
        elseif strcmp(LorR,'R')
            Axyz=obj.VDisp.SubjInfo.RExyz;
        end

        %GET ANCHOR EYE VERSION
        prbCurXYpixA=abs(Axyz(1)-trgtXYZ(1));
        obj.vrs=atand(prbCurXYpixA/guide.obj.posXYZm(3));

        %XYZ COORDINATES OF RESPONSE PROBE
        theta=90-vrs;
        obj.posXYZm=[sind(theta*dist), guide.obj.posXYZm(2), guide.obj.posXYZm(3)*dist/guide.dist];
        if strcmp(LorR,'L')
            Xi=guide.obj.posXYZm(1)+obj.VDisp.PP.Dm/2;
            obj.posXYZm(1)=dist*Xi/guide.dist-obj.VDisp.PP.Dm/2;
        elseif strcmp(LorR,'R')
            Xi=guide.obj.posXYZm(1)-obj.VDisp.PP.Dm/2;
            obj.posXYZm(1)=dist*Xi/guide.dist+obj.VDisp.PP.Dm/2;
        end
        obj.posXYZm(2)=guide.obj.posXYZm(2);
        obj.posXYZm(3)=dist*guide.obj.posXYZm(3)/guide.dist;
    end
%% UTIL
end
end

