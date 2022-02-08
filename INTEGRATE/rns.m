classdef rns
    properties
        type
        PszXY
        images
        imagesB
        rndSds
        rndSdsB
        Rimages
        Limages
    end
    methods
        function obj=rns(images)
            if ~exist('images','var') || isempty(images)
                return
            end
            obj.images=images;
            obj.type='custom';
        end
        function obj=rngSd(obj,n)
            rng('shuffle')
            obj.rndSds=randi(2^32 - 1,n,1);
            rng('shuffle')
            obj.rndSdsB=randi(2^32 - 1,n,1);
        end
        function obj=one_over(obj,n,PszXY,exponent)
            obj.PszXY=PszXY;
            obj.type=['1 over f^' num2str(exponent)];
            obj=obj.rngSd(n);

            PszXY=[ceil(PszXY(1).*2) ceil(PszXY(2).*1.1)];
            if mod(PszXY(1),2)~=0
                PszXY(1)=PszXY(1)+1;
            end
            if mod(PszXY(2),2)~=0
                PszXY(2)=PszXY(2)+1;
            end

            %obj.images=zeros([fliplr(PszXY) n]);
            obj.images=zeros([fliplr(PszXY)-1 n]);
            obj.imagesB=zeros([fliplr(PszXY)-1 n]);
            for i = 1:n
                tmp=Noise.img(PszXY,exponent,0,obj.rndSds(i));
                obj.images(:,:,i)=tmp(1:end-1,1:end-1);
                tmp=Noise.img(PszXY,exponent,0,obj.rndSdsB(i));
                obj.imagesB(:,:,i)=tmp(1:end-1,1:end-1);
                progressreport(i,10,n);
            end

        end
        function []=plot_images(obj)
            for i = 1:size(obj.images,3)
                imagesc(obj.images(:,:,i))
                Fig.formatIm;
                drawnow
                waitforbuttonpress
            end
        end

        function []=plot_LR(obj)
            for i = 1:size(obj.Limages,3)
                imagesc([obj.Limages(:,:,i) obj.Rimages(:,:,i)])
                Fig.formatIm;
                drawnow
                waitforbuttonpress
            end
        end

        function obj=add_depth(obj,depthMaps,stmXYdeg,hostname,LmonoBG,RmonoBG,LbinoFG,RbinoFG,width,LorR)
            bTest=1;
            PszXYL=fliplr(size(obj.images(:,:,1)));
            D=psyPTBdisplayParameters([],hostname);
            pixPerDeg=D.pixPerDegXY;
            scrnXYpix=D.scrnXYpix;
            scrnXYmm=D.scrnXYmm;

            IPDm=LRSIcameraIPD;
            LExyzM  =[-IPDm/2, 0, 0];
            %CExyzM  =[        0, 0, 0];
            RExyzM  =[ IPDm/2, 0, 0];

            pixPerMxy=scrnXYpix./scrnXYmm*1000;
            stmXYm=stmXYdeg.*pixPerDeg./pixPerMxy;

            %PIXEL COORDINATES
            %[X,Y]=meshgrid(1:PszXY(1),1:PszXY(2));

            %XY COORDINATES FOR EACH SURFACE POINT
            x=linspace(-stmXYm(1)/2,stmXYm(1)/2,obj.PszXY(1));
            y=linspace(-stmXYm(1)/2,stmXYm(2)/2,obj.PszXY(2));

            dif=mean(diff(x));
            nDiff=(PszXYL(1)-obj.PszXY(1));
            aE=max(x)+dif:dif:(max(x)+dif*nDiff);
            aB=min(x)-dif:-dif:(max(x)-dif*nDiff);
            xE=[aB x aE];

            dif=mean(diff(y));
            nDiff=(PszXYL(2)-obj.PszXY(2));
            aE=max(y)+dif: dif:(max(y)+dif*nDiff);
            aB=min(y)-dif:-dif:(max(y)-dif*nDiff);
            yE=[aB y aE];

            Zm=obj.PszXY;
            LRpad=(PszXYL(1)-Zm(1))/2;
            TBpad=(PszXYL(2)-Zm(2))/2;
            xa=ones(Zm(2),LRpad);
            ya=ones(TBpad,PszXYL(1));

            [Xm,Ym]=meshgrid(xE,yE);
            zer=zeros(numel(Xm),1);
            locXYmX=[Xm(:) zer];
            locXYmY=[zer, Ym(:)];

            %COORDINATES FOR PROJECTION PLANE
            PPxyzMX=[1,y(1),1];
            PPxyzMX(2,:)=[-1,y(1),1];
            PPxyzMY=[x(1),-1,1];
            PPxyzMY(2,:)=[x(1),1,1];

            %Z COORDINATES FOR EACH SURFACE POINT
            obj.Limages=zeros(size(depthMaps));
            obj.Rimages=zeros(size(depthMaps));
            for i = 1:size(depthMaps,3)

                %GET LUMINANCE VALUES
                if size(obj.images,3)==1 && i==1
                    image=obj.images;
                    imageB=obj.imagesB;
                elseif size(obj.images,3)>1
                    image=obj.images(:,:,i);
                    imageB=obj.imagesB(:,:,i);
                end
                vals=image(:);
                valsB=imageB(:);

                %FULL COORDINATES FOR EACH SURFACE POINT
                Zm=depthMaps(:,:,i);
                Zm=fillmissing(Zm,'nearest');
                [Zm]=fixExtremeValues(Zm);

                if bTest
                    ZmO=Zm;
                end
                Zm=[xa.*Zm(:,1), Zm, xa.*Zm(:,end)];
                Zm=[ya.*Zm(1,:); Zm; ya.*Zm(end,:)];
                locXYZmX=[locXYmX,Zm(:)];
                locXYZmY=[locXYmY,Zm(:)];

                %GET INTERSECTIONS IN THE PROJECTION PLANE AT EACH DIMENSION AND IN EACH EYE
                LX=intersectLinesFromPoints(PPxyzMX(1,:),PPxyzMX(2,:),LExyzM,locXYZmX);
                LY=intersectLinesFromPoints(PPxyzMY(1,:),PPxyzMY(2,:),LExyzM,locXYZmY);
                LX=LX(:,1);
                LY=LY(:,2);
                LX=interp_fun(LX);
                LnewLocXY=[LX, LY];

                RX=intersectLinesFromPoints(PPxyzMX(1,:),PPxyzMX(2,:),RExyzM,locXYZmX);
                RY=intersectLinesFromPoints(PPxyzMY(1,:),PPxyzMY(2,:),RExyzM,locXYZmY);
                RX=RX(:,1);
                RY=RY(:,2);
                RX=interp_fun(RX);
                RnewLocXY=[RX RY];

                %GET UNIQUE ARRAY, IF DUPLICATE VALUES, AVERAGE
                [~,valsLB]=uniqu_fun(LnewLocXY,valsB);
                [~,valsRB]=uniqu_fun(RnewLocXY,valsB);
                [LnewLocXY,valsL]=uniqu_fun(LnewLocXY,vals);
                [RnewLocXY,valsR]=uniqu_fun(RnewLocXY,vals);

                %Remove NANS IF THEY EXIST
                bindL=any(isnan(LnewLocXY) |  isnan(valsL),2);
                bindR=any(isnan(RnewLocXY) |  isnan(valsR),2);
                LnewLocXY(bindL,:)=[];
                valsL(bindL,:)=[];
                valsLB(bindL,:)=[];
                RnewLocXY(bindR,:)=[];
                valsR(bindR,:)=[];
                valsRB(bindR,:)=[];

                %GET VALUES AT FULL PIXELS FOR FOREGROUND
                FL=scatteredInterpolant(LnewLocXY(:,1),LnewLocXY(:,2),valsL,'natural');
                FR=scatteredInterpolant(RnewLocXY(:,1),RnewLocXY(:,2),valsR,'natural');
                tmp=FL(Xm,Ym);
                FGL=tmp(TBpad+1:end-TBpad,LRpad+1:end-LRpad);
                tmp=FR(Xm,Ym);
                FGR=tmp(TBpad+1:end-TBpad,LRpad+1:end-LRpad);
                FGL=LbinoFG(:,:,i).*FGL;
                FGR=RbinoFG(:,:,i).*FGR;


                %GET VALUES AT FULL PIXELS FOR BACKGOUND
                FL=scatteredInterpolant(LnewLocXY(:,1),LnewLocXY(:,2),valsLB,'natural');
                FR=scatteredInterpolant(RnewLocXY(:,1),RnewLocXY(:,2),valsRB,'natural');
                tmp=FL(Xm,Ym);
                BL=tmp(TBpad+1:end-TBpad,LRpad+1:end-LRpad);
                tmp=FR(Xm,Ym);
                BR=tmp(TBpad+1:end-TBpad,LRpad+1:end-LRpad);
                BGL=(~LbinoFG(:,:,i) & ~LmonoBG(:,:,i)).*BL;
                BGR=(~RbinoFG(:,:,i) & ~RmonoBG(:,:,i)).*BR;

                %FL=scatteredInterpolant(Xm(:),Ym(:),valsLB,'natural');
                %FR=scatteredInterpolant(Xm(:),Ym(:),valsRB,'natural');
                %tmp=FL(Xm,Ym);
                %ML=tmp(TBpad+1:end-TBpad,LRpad+1:end-LRpad);
                %tmp=FR(Xm,Ym);
                %MR=tmp(TBpad+1:end-TBpad,LRpad+1:end-LRpad);
                if LorR(i)=='L'
                    tmp=[BL(:,width(i)+1:end) BL(:,1:width(i))];
                    ML=LmonoBG(:,:,i).*tmp;
                    MR=0;
                elseif LorR(i)=='L'
                    tmp=[BL(:,end-width(i)+1:end) BL(:,1:end-width(i))];
                    MR=RmonoBG(:,:,i).*tmp;
                    ML=0;
                end

                obj.Limages(:,:,i)=FGL + BGL + ML;
                obj.Rimages(:,:,i)=FGR + BGR + MR;
                if bTest
                    imagesc([obj.Limages(:,:,i) obj.Rimages(:,:,i)])
                    title(LorR(i));
                    Fig.formatIm;
                    drawnow
                    waitforbuttonpress
                end

                progressreport(i,50,size(depthMaps,3));
            end

        end
    end
end

% -----------------------------------------------------------------------
function X=interp_fun(X)
    bind=~isnan(X);
    x=find(bind);
    xq=find(~bind);
    v=X(bind);
    vals=interp1(x,v,xq);
    X(~bind)=vals;
end

function [X,vals]=uniqu_fun(X,vals)
    [u,~,i]=unique(X,'rows');
    out=[u(:,:),accumarray(i,vals,[],@mean)];
    X=out(:,1:2);
    vals=out(:,3);
end

function [M]=fixExtremeValues(M)
    [Lvals]=extremeValuesLeft(M);
    [Rvals]=extremeValuesLeft(fliplr(M));
    Lind=extremeNansLeft(M);
    Rind=extremeNansLeft(fliplr(M));
    n=max(sum(Lind,2));
    Lvals=repmat(Lvals,1,n);
    if ~isempty(Lvals)
        M(Lind)=Lvals(Lind(:,1:n));
    end
    if ~isempty(Rvals)
        M(Rind)=Rvals(Rind(:,end-n:end));
    end
end

function[vals,ind]=extremeValuesLeft(M)
    val=~isnan(M);
    ind=diff(cumprod(~val | [zeros(size(val,1),1) diff(val,[],2)==1],2),[],2)==-1;
    vals=M(ind);
end

function[ind]=extremeNansLeft(M)
    ind=logical(cumprod(isnan(M),2));
end
