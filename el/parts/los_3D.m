classdef los_3D < handle
%A point in 3D space given a display
properties
    LorR
    LOS

    %Coordinates
    XYZm %relative to display
    PPTxyzM %relative to observer

    %CPs
    LitpXY
    RitpXY

    depth
    depthC

    dspArcMin
    vrgArcMin
    vrsArcMin
    vrsArcMinL
    vrsArcMinR
    elvArcMin

    bBino
end
methods
    % obj.PPTxyzM=[0 0 0]
    % obj.get_xyz_ambig(display)
    function obj=get_CPs(obj,display,guide)
        switch obj.LOS
        case 'naive'
            obj=obj.get_xyz_naive;
        case 'ambig'
            obj=obj.get_xyz_ambig(display);
        case 'C'
            obj=obj.get_xyz_C(guide);
        case 'cartesian'
            obj=obj.get_xyz_cartesian(guide);
        case 'anchor'
            obj=obj.get_xyz_anchor(guide,display);
        end
        obj=obj.get_CPs_only(display);
        %obj=obj.get_eye_versions(display)
    end
    function obj=get_xyz_naive(obj)
        obj.XYZm = [      0, 0, obj.depthC];
        obj.vrsArcMin=0;
    end
    function obj=get_xyz_ambig(obj,display)
        if obj.LorR=='L'
            obj.XYZm=intersectLinesFromPoints(display.LExyz,obj.PPTxyzM,[-2 0 obj.depth],[2 0 obj.depth]);
        elseif obj.LorR=='R'
            obj.XYZm=intersectLinesFromPoints(display.RExyz,obj.PPTxyzM,[-2 0 obj.depth],[2 0 obj.depth]);
        end
        obj.vrsArcMin=60*atand(obj.PPTxyzM(1)/obj.depth);
    end
    function obj=get_xyz_C(obj,guide)
        %XYZ COORDINATES OF RESPONSE PROBE - FROM SIMLAR TRIANGLES
        obj.XYZm(1)=obj.depthC*guide.PPTxyzM(1)/guide.depthC;
        obj.XYZm(2)=obj.PPTxyzM(2);
        obj.XYZm(3)=obj.depthC*guide.depth/guide.depthC; %XYZm = depth
    end
    function obj=get_xyz_cartesian(obj,guide)
        obj.depth=obj.depthC*guide.depth/guide.depthC;
        obj.XYZm=[guide.XYZm(1) guide.XYZm(2) obj.depth];
        obj.vrsArcMin=0;
    end
    function obj=get_xzy_anchor(obj,guide,display)
        %ASSIGN ANCHOR EYE COORDINATES

        if strcmp(obj.LorR,'L')
            Axyz=display.LExyz;
        elseif strcmp(obj.LorR,'R')
            Axyz=display.RExyz;
        end

        %GET ANCHOR EYE VERSION
        prbCurXYpixA=abs(Axyz(1)-obj.PPTxyzM(1));
        obj.vrsArcMin=60*atand(prbCurXYpixA/guide.depth);

        %XYZ COORDINATES OF RESPONSE PROBE
        theta=90-obj.vrsArcMin/60;
        obj.XYZm=[sind(theta*obj.depthC), guide.XYZm(2), guide.XYZm(3)*obj.depthC/guide.depthC];
        if strcmp(obj.LorR,'L')
            Xi=guide.XYZm(1)+display.IPDm/2;
            obj.XYZm(1)=obj.depthC*Xi/guide.depthC-display.IPDm/2;
        elseif strcmp(obj.LorR,'R')
            Xi=guide.XYZm(1)-display.IPDm/2;
            obj.XYZm(1)=obj.depthC*Xi/guide.depthC+display.IPDm/2;
        end
        obj.XYZm(2)=guide.XYZm(2);
        obj.XYZm(3)=obj.depthC*guide.XYZm(3)/guide.depthC;
    end
    function obj=get_eye_versions(obj,display)
        straightL=[display.Lxyz(1) display.Lxyz(2) obj.XYZm(3)]
        straightR=[display.Rxyz(1) display.Rxyz(2) obj.XYZm(3)]
        L=xyz2triangleAngles(display.Lxyz,straightL,obj.XYZm);
        R=xyz2triangleAngles(display.Rxyz,straightR,obj.XYZm);
        obj.vrsArcMinL=rad2deg(L)*60;
        obj.vrsArcMinR=rad2deg(R)*60;
    end
    function obj=get_CPs_only(obj,display)
        LitpXYZ=intersectLinesFromPoints(display.LExyz,obj.XYZm,display.PPxyz(1,:),display.PPxyz(2,:));
        RitpXYZ=intersectLinesFromPoints(display.RExyz,obj.XYZm,display.PPxyz(1,:),display.PPxyz(2,:));
        obj.LitpXY=LitpXYZ(1:2).*display.pixPerMxy+display.scrnCtr;;
        obj.RitpXY=RitpXYZ(1:2).*display.pixPerMxy+display.scrnCtr;;

       LS=xyz2dist(display.LExyz,obj.XYZm);
       RS=xyz2dist(display.RExyz,obj.XYZm);

       obj.vrgArcMin=60*acosd((LS^2+RS^2-(display.IPDm)^2)/(2*LS*RS)); %LAW OF COSINES -> VERGENCE
       obj.dspArcMin=obj.vrgArcMin-display.vrgArcMinF;
       obj.elvArcMin=60*atand(obj.PPTxyzM(2)/obj.depth);      %ELEVATION ...
    end
end
end

