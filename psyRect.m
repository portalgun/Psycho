function []=psyRect(ImCtrRC,h,w)
    t=ImCtrRC(:,1)-h/2;
    b=ImCtrRC(:,1)+h/2;
    r=ImCtrRC(:,2)+w/2;
    l=ImCtrRC(:,2)-w/2;
    rect=[l,t,r,b]
