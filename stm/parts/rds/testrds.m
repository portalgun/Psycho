if ~isvar('D')
    loadD
end
if ~isvar('P')
    loadP
end

n=length(P.LorRall);
R=rns;
R=R.one_over(n,P.PszXY,-1);
stmXYdeg=D.stmXYdeg;
depthMaps=P.depthImgDisp;
LmonoBG=P.LmonoBGmain;
RmonoBG=P.RmonoBGmain;
LbinoFG=P.LbinoFGmain;
RbinoFG=P.RbinoFGmain;
width=P.width;
LorR=P.LorRall;
R=R.add_depth(depthMaps,stmXYdeg,'jburge-wheatstone',LmonoBG,RmonoBG,LbinoFG,RbinoFG,width,LorR)
