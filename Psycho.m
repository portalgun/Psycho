classdef Psycho < handle & Psycho_hooks
properties
    D
    initflag=-1 % -1 not yet, 0 initializing, 1 initialized

end
properties(Hidden=true)
    ptch
    bInc
end
%properties(Access=?PtchsViewer)
properties
    A % NAME, NUM,

    ptbOpts
    PTB
    bPTB=0
    nBuff
    buffs % zero-indexing

    names
    nums
    priority
    bUpdatePriority=true

    stmList
    utilList
    promptList
    auxList

    selected
end
properties(Access=private)
    PsyInt
    Viewer
end
methods(Static)
    function alias=getAlias()
        alias=getenv('PSY_ALIAS');
    end
    function Opts=readConfig(alias)
        if nargin < 1
            alias=Psycho.getAlias();
        end
        Opts=Cfg.read(['D_viewer_' alias '.cfg']);
        %Opts=Cfg.read(['D_' alias '.cfg']);
    end
end
methods
    function obj = Psycho(viewer,allOpts);
        if nargin >= 1 && ~isempty(viewer)
            obj.Viewer=viewer;
            S=obj.Viewer.Ptchs;
        else
            viewer=[];
            S=struct();
        end
        if nargin < 2 || isempty(allOpts);
            allOpts=dict();
        end
        obj.parse(allOpts);
    end
    function obj=set.PTB(obj,PTB)
        obj.dispSep('PTB');
        obj.PTB=PTB;
        obj.nBuff=double(obj.PTB.bStereo>0)+1;
        obj.buffs=0:obj.nBuff-1;
    end
%% INIT
    function obj=parse(obj,allOpts)
        flds=fieldnames(allOpts);
        opts=struct;
        for i = 1:length(flds)
            fld=flds{i};
            if strcmp(fld,'ptb')
                obj.ptbOpts=allOpts{'ptb'};
                continue
            end

            % GET NAME AND NUM
            mtch=regexp(fld,'(^[a-zA-Z0-9_]+)\.([0-9])$','tokens','once');

            if ~isempty(mtch)
                name=mtch{1};
                num=str2double(mtch{2});
                if ~isfield(bA,(name))
                    bA.(name)=true;
                end
            else
                name=fld;
                bA.(name)=true;
                num=1;
            end

            % INTI PSYEL
            if ~isfield(obj.A,name)
                obj.A.(name)=cell(0,1);
            end
            obj.A.(name){num,1}=PsyEl(obj.Viewer,allOpts{fld},name,num);

        end

        sOpts=struct('class','SelBox','priority',0,'bHidden',true);
        obj.A.SelBox{1}=PsyEl(obj.Viewer,sOpts,'SelBox',1);

        obj.names=[fieldnames(bA); 'SelBox'];
        obj.nums=[structfun(@numel,obj.A); 1];
        obj.get_utilList();

    end
%% INIT
    function init_aux(obj)
        obj.dispSep('AUX');
        T={};
        for i = 1:length(obj.names)
            name=obj.names{i};
            n=obj.nums(ismember_cell(obj.names,name));
            for iA = 1:n
                obj.A.(name){iA}.init();
                list=obj.A.(name){iA,1}.list;
                t=[repmat({name iA},length(list),1) list];
                T=[T;t];
            end
        end
        obj.dispSep('AUX_END');
    end
    function val=get_rect(obj,name,num)
        if ~ismember_cell(name,fieldnames(obj.Viewer.Psy.A))
            error([ 'PsyEl ' name ' not yet initialized']);
        end
        if isempty(num)
            num=1;
        end
        O=obj.A.(name){num}.Obj;
        if ~isempty(O)
            if isprop(O,'prect')
                val=obj.A.(name){num}.Obj.prect;
            elseif isprop(O,'rect')
                val=obj.A.(name){num}.Obj.rect;
            end
        else
            val=obj.A.(name){num}.rect;
        end
    end
    function update_im(obj,name,num,im)
        if isempty(num)
            num=1;
        end
        obj.A.(name){num}.im=im;
    end
    function update_geom(obj,name,num,XYpix,WHpix)
        if isempty(num)
            num=1;
        end
        if ~iscell(XYpix) && numel(XYpix)==2
            XYpix={XYpix XYpix};
        end
        obj.A.(name){num}.XYpix=XYpix;
        obj.A.(name){num}.WHpix=WHpix;
    end
    function update_duration(obj,name,num,duration)
        if isempty(num)
            num=1;
        end
        obj.A.(name){num}.duration=duration;
    end
    function update_priority(obj,name,num,priority)
        if isempty(num)
            num=1;
        end
        if ~isequal(obj.A.(name){num}.priority,priority)
            obj.A.(name){num}.priority=priority;
            obj.bUpdatePriority=true;
        end
    end
    function get_utilList(obj)
        names=obj.names;
        obj.stmList=cell(0,2);
        obj.utilList=cell(0,2);
        obj.promptList=cell(0,2);
        obj.auxList=cell(0,2);
        for i = 1:length(names)
            name=names{i};
            n=obj.nums(ismember_cell(obj.names,name));
            for iA = 1:n
                switch obj.A.(name){iA}.type
                case {0,'stm'}
                    obj.stmList{end+1,1}=name;
                    obj.stmList{end  ,2}=iA;
                case {1,'util'}
                    obj.utilList{end+1,1}=name;
                    obj.utilList{end  ,2}=iA;
                case {2,'prompt'}
                    obj.promptList{end+1,1}=name;
                    obj.promptList{end  ,2}=iA;
                case {3,'aux'}
                    obj.auxList{end+1,1}=name;
                    obj.auxList{end  ,2}=iA;
                end
            end
        end
    end
    function list=show_util(obj)
        list={};
        for i = 1:size(list,1)
            name=obj.utilList{i,1};
            iA=obj.utilList{i,2};
            if obj.A.(name){iA}.bHidden
                obj.A.(name){iA}.bHidden=false;
                list{end+1,1}=name;
            end
        end
    end
    function list=hide_util(obj)
        list={};
        for i = 1:size(list,1)
            name=obj.utilList{i,1};
            iA=obj.utilList{i,2};
            if ~obj.A.(name){iA}.bHidden
                obj.A.(name){iA}.bHidden=true;
                list{end+1,1}=name;
            end
        end
    end
    function toggle_hidden(obj,name,num)
        val=obj.A.(name){num}.bHidden;
        if val
            obj.A.(name){num}.bHidden=false;
        else
            obj.A.(name){num}.bHidden=true;
        end
    end
    function show(obj, name, num)
        obj.A.(name){num}.bHidden=false;
    end
    function hide(obj, name, num)
        obj.A.(name){num}.bHidden=true;
    end
    function norect(obj,name,num)
        obj.A.(name){num}.bRectUpdate=false;
    end
    function notex(obj,name,num)
        obj.A.(name){num}.bTexUpdate=false;
    end
%% SELECT
    function select_init(obj)
        if isempty(obj.selected)
            obj.select_nearest();
        else
            obj.A.SelBox{1}.Obj.bActive=false;   % BOX COLOR
        end
    end
    function select_nearest(obj,direct)
        if nargin < 2 || isempty(direct)
            direct='*';
        end
        [name,num]=obj.get_nearest(direct);
        if ~isempty(name)
            obj.select(name,num);
        end
    end
    function select_nearest_interior(obj,direct)
        direct=['i' direct];
        [name,num]=obj.get_nearest(direct);
        if ~isempty(name)
            obj.select(name,num);
        end
    end
    function h=return_selected_params(obj)
        h=obj.A.SelBox{1}.Obj.Sel;
    end
    function select(obj,name,num)
        if nargin < 3 || num
            num=1;
        end
        obj.selected={name,num};
        obj.A.SelBox{1}.Obj.Sel=obj.A.(name){num};
        obj.A.SelBox{1}.bRectUpdate=true;
        %obj.A.SelBox{1}.bTexUpdate=true;
        obj.A.SelBox{1}.bHidden=false;
    end
    function reselect(obj)
        if ~isempty(obj.selected)
            obj.select(obj.selected{1},obj.selected{2});
        end
    end
    function unselect(obj)
        obj.A.SelBox{1}.bHidden=true;
    end
    function inc_selected_line(obj)
        obj.A.params{1}.Obj.inc_line();
    end
    function dec_selected_line(obj)
        obj.A.params{1}.Obj.dec_line();
    end
    function inc_selected_opt(obj,n)
        [exitflag,msg]=obj.Viewer.Im.inc_selected_opt(n);
        if ~exitflag
            obj.Viewer.append_bUp('Im');
            obj.activate_selected;
            obj.Viewer.redraw();
        end
    end
    function [name,num,flds,val]=get_selected(obj)
        flds={};
        val=[];
        name='';
        num=[];
        if isempty(obj.selected)
            return
        end
        [name,num]=obj.selected{:};

        str=obj.A.params{1}.Obj.KeyStr.get_str();

        [flds,val,exitflag,msg]=Cfg.parseStr(str,': *');
    end
    function [bestName,bestNum]=get_nearest(obj,direct)
        bestName='';
        bestNum='';
        bestD=inf;
        names=[obj.stmList; obj.auxList];
        %names(ismember(names,{'SelBox'}))=[];
        if isempty(obj.A.SelBox{1}.Obj.Sel)
            XYpix=obj.Viewer.PTB.VDisp.ctrXYpix;
            Rect=obj.Viewer.PTB.VDisp.ctrXYpix;
            Rect=[Rect Rect];
            direct='*';
            oldName='';
            oldNum=0;
        else
            XYpix=obj.A.SelBox{1}.Obj.Sel.XYpix;
            Rect=obj.A.SelBox{1}.Obj.Sel.rect;
            Rect=mean([Rect{1}{1}; Rect{2}{1}],1);
            oldName=obj.A.SelBox{1}.Obj.Sel.name;
            oldNum=obj.A.SelBox{1}.Obj.Sel.num;
        end
        Rect4=obj.psyRect2Rect(Rect);
        if iscell(XYpix)
            XYpix=mean([XYpix{1}; XYpix{2}],1);
        end
        for i = 1:length(names)
            name=names{i,1};
            iA=names{i,2};
            if strcmp(name,oldName) && oldNum==iA
                continue
            end
            rect=obj.A.(name){iA}.rect;
            if isempty(rect) || isempty(rect{1}{1})
                continue
            end
            xypix=obj.A.(name){iA}.XYpix;
            if isempty(xypix)
                continue
            elseif iscell(xypix)
                xypix=mean([xypix{1}; xypix{2}],1);
            end
            rect=mean([rect{1}{1}; rect{2}{1}],1);
            rect4=obj.psyRect2Rect(rect);

            dfp=XYpix-xypix;
            %df=Rect(1:2)-rect(1:2);
            df=Rect4-rect4;
            d=norm(df);
            dp=norm(dfp);
            tol=0;
            tol=0.5;
            bHalf=false;

            bNot=false;
            bIn=false;
            bSkip=false;
            switch direct
                case 'iu'
                    %% up with down inds
                    ind=[3:4];
                    D=2;
                    iq='gt';

                    bIn=true;
                case 'id'
                    %% down with up inds
                    ind=[1:2];
                    D=2;
                    iq='lt';
                    bIn=true;
                case 'il'
                    %% left with right inds
                    ind=[1 4];
                    D=1;
                    iq='gt';
                    bIn=true;
                case 'ir'
                    %% right with left inds
                    ind=[2:3];
                    D=1;
                    iq='lt';
                    bIn=true;

                case 'u'
                    ind=[1:2];
                    D=2;
                    iq='gt';
                case 'd'
                    ind=[3:4];
                    D=2;
                    iq='lt';
                case 'l'
                    ind=[2:3];
                    D=1;
                    iq='gt';
                    dd=df(ind,:);
                case 'r'
                    ind=[1 4];
                    D=1;
                    iq='lt';
                case 's'
                    iq='lg';
                    bSkip=true;
                otherwise
                    D=2;
                    bNot=true;
                    iq='';
            end

            if bSkip
                ;
            elseif bNot
                dd=10;
                ddp=dfp(D);
            else
                dd=df(ind,D);
                ddp=dfp(D);
            end

            if strcmp(iq,'lt')
                bGd=all(dd<0);
                %bGd   =all(dd < 0 & ddp < 0);
                bHlfGd=all(dd < 0 | ddp < 0);
            elseif strcmp(iq,'gt')
                bGd=all(dd>0);
                %bGd=   all(dd > 0 & ddp > 0);
                bHlfGd=all(dd > 0 | ddp > 0);
            elseif strcmp(iq,'lg')
                bGd=all(df < tol | df > 0);
                bHlfGd=false;
            else
                bGd=true;
                bHlfGd=true;
            end
            if bIn
                ddu=df(4,2) > 0; % up
                ddd=df(2,2) < 0; % down

                ddl=df(4,1) > 0; % left
                ddr=df(2,1) < 0; % right


                bGd=bGd && ddu && ddl && ddd && ddr;
                bHlfGd=false;
            end

            if bGd && (bIn || (abs(ddp) > tol && (bHalf || d < bestD)))
                bHalf=false;
                bestD=d;
                bestName=name;
                bestNum=iA;
            elseif isempty(bestName) && bHlfGd && abs(ddp) > tol
                bHalf=true;
                bestD=d;
                bestName=name;
                bestNum=iA;
            end
        end
    end
    function RECT=psyRect2Rect(obj,rect)
        RECT=[rect([3,2]); rect(1:2); rect([1,4]); rect(3:4)];
    end
    function deactivate_selected(obj)
        obj.A.SelBox{1}.Obj.bActive=false;   % BOX COLOR
        obj.A.params{1}.Obj.deactivate();
    end
    function activate_selected(obj)
        % move to by-line

        obj.A.SelBox{1}.Obj.bActive=true;   % BOX COLOR

        obj.A.params{1}.bRectUpdate=true;

        pstr=obj.A.params{1}.Obj;
        pstr.Cursor.style='box';
        pstr.sep=1;
        pstr.bRect=false;
        pstr.bInit=true;
        pstr.activate();
        pstr.get_rect;
    end
%% EDIT
    function enter_edit(obj)
        obj.A.params{1}.bRectUpdate=true;

        pstr=obj.A.params{1}.Obj;
        pstr.sep=2;
        pstr.Cursor.style='bar';
        pstr.bRect=true;
        pstr.bInit=true;
        pstr.activate();

        pstr.get_rect;
        KS=pstr.KeyStr;

        O=obj.A.SelBox{1}.Obj.Sel;
        switch O.type
            case 0
                typ='stm';
            case 1
                typ='util';
            case 2
                typ='prompt';
            case 3
                typ='aux';
        end
        dests={{typ O.name}};
        obj.Viewer.Cmd.appendKeyStr('sel',KS,true,dests);
    end
    function edit_left(obj)
        obj.A.params{1}.Obj.dec_char();
    end
    function edit_right(obj)
        obj.A.params{1}.Obj.inc_char();
    end
%% APPLY
    function [bSuccess,name]=apply_text(obj,name,num,txt,textOpts)
        % INTOPTS

        if ~isempty(textOpts) && isstruct(textOpts)
            apply_opts(name,num,textOpts);
        end
        obj.A.(name){num}.Obj.text=txt;
        obj.A.(name){num}.bHidden=isempty(txt);
        %obj.A.(name){num}.bHidden=false;
        obj.A.(name){num}.bRectUpdate=true;

        function apply_opts(name,num,textOpts)
            flds=fieldnames(textOpts);
            for i = 1:length(flds)
                if isprop(obj.A.(name){num}.Obj,flds{i})
                    obj.A.(name){1}.Obj.(flds{i})=textOpts.(flds{i});
                elseif     isprop(obj.A.(name){num},    flds{i})
                    obj.A.(name){1}.(flds{i})=textOpts.(flds{i});
                end
            end
        end
    end
    function lists=apply_infos(obj,nms)
        if nargin < 2
            nms={};
        elseif ~iscell(nms)
            nms={nms};
        end
        bNm=ismember_cell(obj.names,nms);
        % INFO
        for i = 1:length(obj.names)
            name=obj.names{i};
            n=obj.nums(i);
            for iA = 1:n
                opts=obj.A.(name){iA}.stringOpts;
                if ~isempty(opts.list)
                    txt=obj.Viewer.Info.format(opts.list, opts);
                    if ~strcmp(obj.A.(name){iA}.Obj.text, txt{1}) || bNm(i);
                        out=obj.Viewer.append_update(name);
                        obj.A.(name){iA}.Obj.text=txt{1};
                        obj.A.(name){iA}.bRectUpdate=true;
                        %%if out
                        %    obj.A.(name){iA}.bRectUpdate=true;
                        %else
                        %    obj.A.(name){iA}.bRectUpdate=false;
                        %end
                    end
                end
            end
        end
    end
%% DRAW
    function inc_selected(obj,inc)
        [name,num]=obj.Parent.Psy.get_selected();
    end
    function draw(obj,opts)
        if obj.bUpdatePriority
            obj.get_priorities();
            obj.bUpdatePriority=false;
        end

        opts.reset{end+1}='SelBox';
        opts.draw{end+1}='SelBox';

        obj.subInt_fun(opts,'reset');
        obj.subInt_fun(opts,'draw');
        obj.PTB.flip();
        obj.subInt_fun(opts,'close');
    end
    function P=get_priorities(obj)
        P=cell(sum(obj.nums),3);
        c=0;
        for i = 1:length(obj.names)
            name=obj.names{i};
            n=obj.nums(ismember_cell(obj.names,name));
            for iA = 1:n
                c=c+1;
                P(c,:)={obj.A.(name){iA}.priority, name, iA};
            end
        end
        zind=vertcat(P{:,1})==0;
        lind=vertcat(P{:,1}) < 0;
        P0=P(zind,:);
        Pl=P(lind,:);
        P=P(~zind & ~lind,:);
        [~,ind] =sort(vertcat( P{:,1}));
        [~,lind] =sort(vertcat( Pl{:,1}));
        P=[P(ind,:); P0; Pl(lind,:)];
        obj.priority=P(:,2:end);
    end
    function subInt_fun(obj,opts,prp)
        bAll=ismember_cell('all',opts.(prp)); %% Slowish
        inds=ismember_cell(obj.priority(:,1),opts.(prp));
        for i = 1:size(obj.priority,1)
            name=obj.priority{i,1};
            num= obj.priority{i,2};
            if bAll || inds(i)
                obj.A.(name){num}.(prp)();
            end
        end
    end
end
methods(Static)
    function dispSep(name)
        l=76-length(name);
        txt=[name repmat('-',1,l)];
        disp(txt);
    end
end
end

