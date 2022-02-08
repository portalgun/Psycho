
    function obj=get_ims(obj,t,int)
        obj.get_stm_params(t,int);
        obj.get_stm_im(t,int);
        if obj.D.bSBS
            obj.get_sbs();
        end
        if obj.D.bXYZ
            obj.get_xyz();
        end
        if obj.D.bPht
            obj.get_pht();
        end
    end
    function obj=get_stm_im(obj,tt,int)
        if obj.bViewer
            obj.im.stm=obj.VIEWER.F.ptchs.ptch.im.img;
        elseif obj.bPtchs & obj.D.bXYZ
            [obj.im.stm, obj.im.xyz]=obj.S.get_interval_im(tt,int);
        elseif obj.bPtchs
            [obj.im.stm]=obj.S.get_interval_im(tt,int);
        else
            if obj.S.stdIntrvl(tt)==int-1
                fld='std';
            else
                fld='cmp';
            end
            obj.im.stm{1}=obj.S.([ fld 'IphtL'])(:,:,tt);
            obj.im.stm{2}=obj.S.([ fld 'IphtR'])(:,:,tt);
            if obj.D.bXYZ
                % TODO
            end
        end
    end
    function obj=get_xyz(obj)
        obj.get_map('xyz',-1);
    end
    function obj=get_pht(obj)
        obj.get_map('pht',obj.D.bSBS+1);
    end
    function obj=get_map(obj,name,num,p)
        obj.add_fld(name);
        obj.rect.(name)=obj.rect_to_sbs('stm',num);

        if obj.S.ptch.bDSP
            fld='maps';
        else
            fld='mapsBuff';
        end

        map=obj.VIEWER.F.ptchs.ptch.(fld).(name);
        %assignin('base','p',obj.VIEWER.F.ptchs.ptch)

        if size(map{1},3) > 1
            map{1}=map{1}(:,:,3);
        end
        if size(map{2},3) > 1
            map{2}=map{2}(:,:,3);
        end

        obj.im.(name)=map;
        obj.im.(name)=obj.im_to_sbs(name);
        for i = 1:2
            obj.im.(name){i}=obj.im.(name){i}-min(obj.im.(name){i},[],'all');
            obj.im.(name){i}=obj.im.(name){i}/max(obj.im.(name){i},[],'all');
        end
    end
