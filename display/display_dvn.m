function
end
function [D,prb]=get_probe_details(D,P,G)
    rmpSz=6;

    prb=depthProbeGen(D,G);
    D.pixPerMxy=D.scrnXYpix./D.scrnXYmm*1000;
    D.multFactorXY = D.stmXYdeg.*D.pixPerDegXY./P.PszXY;
    sz=[size(prb,2) size(prb,1)];

    D.plyXYpix          = bsxfun(@times,D.stmXYdeg,D.pixPerDegXY(1,:));
    D.plySqrPix         = CenterRect([0 0 D.plyXYpix(1) D.plyXYpix(2)], D.wdwXYpix);
    D.plySqrSizXYpix    = D.plySqrPix(3:4)-D.plySqrPix(1:2);   %Square in display

    if ~isfield(D,'prbXYdeg')
        D.prbPlyXYpix=D.plyXYpix;
        D.prbPlySqrpix=D.plySqrPix;

        D.prbPlySqrSizXYpix=D.plySqrSizXYpix;
    else
        D.prbPlyXYpix=bsxfun(@times,D.prbXYdeg,D.pixPerDegXY);
        D.prbPlySqrPix= [0 0 D.prbPlyXYpix(1) D.prbPlyXYpix(2)];

        D.prbPlySqrSizXYpix=D.prbPlySqrPix(3:4)-D.prbPlySqrPix(1:2);
    end
    D.prbRadius         = abs(D.prbPlySqrPix(3) - D.prbPlySqrPix(1))/2;
end
DPA_getDepth(s,P,D,X,Y,prbCurXYpix,bSkipMap,bForce)
