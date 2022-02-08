
D.prbXYdeg=D.prbXYdegG;

G.szPix            = 128;
G.frqCpd
[x, y]= meshgrid(Wave.smpPos(G.szPix,G.szPix));
Prb = gabor2D(x,y,0,0,G.frqCpd,G.thetaDeg,G.phaseDeg,G.sigmaXdeg,G.sigmaYdeg,1,0);
G.DC=.1;
G.RMS=.1;
PRB = (Prb+min(min(Prb))*2)/2;

prb=zeros(size(Prb,1),size(Prb,2),4);
prb(:,:,1)=PRB;
prb(:,:,2)=PRB;
prb(:,:,3)=PRB;
prb(:,:,4)=Prb*255;
