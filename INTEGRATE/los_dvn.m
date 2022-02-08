classdef point_dvn < point_3D
properties
    type
    locType
    locDsp
    XYoffsetPix
    XYoffsetPixInit
    curXYpix
    multFactorXY

    %PPTxyzM %probe as it appears in the display
end
methods
    function obj=get_all_pos(obj,p,display)
        obj.multFactorXY   = p.stmXYdeg.*display.pixPerDegXY./p.PszXY;
        obj=obj.get_loc_width(p);
        obj=obj.get_offset_image(p);
        obj=obj.get_cur_pix(p);
        obj=obj.get_cur_pix_display(p,display);
        obj=obj.get_depth_at_loc(p);
        obj=obj.get_CPs(display); %
    end
    function obj=get_loc_width(obj,p)
        switch obj.locType
            case 'm1'
                obj.locDsp=0;
            case 'm2'
                obj.locDsp=p.width/4;
            case 'm3'
                obj.locDsp=p.width/2;
            case 'm4'
                obj.locDsp=p.width/4*3;
            case 'm5'
                obj.locDsp=p.width;
            case 'be'
                obj.locDsp         = -1*obj.XYpix(1);
            case 'fe'
                obj.locDsp         = p.width+obj.XYpix(1);
            case 'bc'
                if strcmp(p.LorR,'L')
                    obj.locDsp       = -1*(p.beginWidth/2);
                elseif strcmp(p.LorR,'R')
                    obj.locDsp       = -1*(p.endWidth/2);
                end
        end
    end
    function obj=get_loc_link(obj,p)
        obj.locDsp=p.width-obj.locDsp;
        obj=obj.get_loc;
    end
    function obj=get_loc_border(obj,p)
        obj.locDsp=p.width;
        obj=obj.get_loc;
    end
    function obj=get_offset_image(obj,p)
        obj.XYoffsetPixInit=[p.PszXY(1)/2-p.CPs.AitpRCbgnd(2) 0];
        obj.XYoffsetPix=obj.XYoffsetPixInit;
    end
    function obj=get_cur_pix(obj,p)
    %AitpRCbgnd - anchor ctrORedg
    %OFFSET FROM CENTER
        if strcmp(p.LorR,'L')
            obj.XYoffsetPix(1)=obj.XYoffsetPixInit(1)-obj.locDsp+1;
        elseif strcmp(p.LorR,'R')
            obj.XYoffsetPix(1)=obj.XYoffsetPixInit(1)+obj.locDsp-1;
        end
        obj.curXYpix = p.PszXY./2-obj.XYoffsetPix;
    end
    function obj =get_cur_pix_display(obj,p,display)
        if isempty(p.multFactorXY)
            mF=obj.multFactorXY;
        else
            mF=p.multFactorXY;
        end
        curXYscrnM=(obj.curXYpix-p.PszXY/2).*mF./display.pixPerMxy;
        obj.PPTxyzM=[curXYscrnM display.PPxyz(2,3)];
    end
    function obj = get_depth_at_loc(obj,p)
        if strcmp(obj.LorR,'L')
            obj.depth= interp2(p.X,p.Y,p.z,obj.curXYpix(1),obj.curXYpix(2));
        elseif strcmp(obj.LorR,'R')
            obj.depth= interp2(p.X,p.Y,p.z,obj.curXYpix(1)-3-p.width,obj.curXYpix(2));
        end
    end
end
end
