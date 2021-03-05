classdef Img < handle
% HANDLES FRAMES
%function obj=img(img,shape,win,mask)
%%
 %Screen(‘DrawTexture’, windowPointer, texturePointer [,sourceRect] [,destinationRect] [,rotationAngle] [, filterMode] [, globalAlpha] [, modulateColor] [, textureShader] [, specialFlags] [, auxParameters]);
properties
    self % cell of pointers
    win % cell of pointers
    mask % cell of ponters

    tex
    rect

    imgSize
    winSize
    maskSize

    bMovie;
    bImgMovie=0;
    bWinMovie=0;
    bMaskMovie=0;

    bDynamic;
    nFrames=1;
    bDrawn=[0 0];
end
properties(Hidden=true)
    wdwPtr
    bStereo
end

methods
    function obj=Img(img,shape,win,mask)
        if exist('win','var')
            win=[];
        end
        if ~exist('mask','var')
            mask=[];
        end
        obj.bStereo=shape.bStereo;

        obj.construct_img(img);
        obj.construct_win(win);
        obj.construct_mask(mask);

        obj.check_sizes();
        bMovie=obj.bImgMovie | obj.bWinMovie | obj.bMaskMovie;
        if bMovie
            obj.Drawn=zeros(obj.nFrames,obj.bStereo+1);
        end

        obj.get_tex();
        obj.get_rect(shape)
    end
    function obj=parse_ptch(obj)
        % TODO
    end
    function obj=parse_struct(obj)
        % TODO
    end
%% IMG
    function obj=construct_img(obj,img)
        obj.self=cell();
        if isa(img,'ptch')
            obj.parse_ptch(img);
        elseif isnumeric(img)
            obj.parse_numeric(img);
        elseif iscell(img)
            obj.parse_cell(img);
        elseif isstruct(img)
            obj.parse_struct(img)
        else
            error('invalid img type')
        end
    end
    function obj=parse_cell(obj,img)
        if numel(img)==2
            obj.parse_numeric(img{1},1);
            obj.parse_numeric(img{2},2);
        elseif numel(img)==1
            obj.parse_numeric(img{1},1);
        elseif numel(cell) > 2
            error('cell image size')
        end
    end
    function obj=parse_numeric(obj,in,num)
        if ndims(in)==3 size(in,3)==2
            obj.parse_numeric(in(:,:,1),1);
            obj.parse_numeric(in(:,:,2),2);
        elseif nDims(in) > 3
            obj.bImgMovie=1;
        end
        obj.imgSize{num}=size(in);
        obj.self{num}=pointer(in);
    end
%% WIN
    function obj=construct_win(obj,win);
        if isempty(win)
            obj.win{1}=ones(imgSize(1:2));
            obj.win{2}=pointer(obj.win{1});
            return
        elseif iscell(win)
            obj.parse_win_cell();
        elseif isnumeric(win)
            obj.parse_win_numeric(win);
        end
        if obj.bStereo && isempty(obj.win{2})
            obj.win{2}=obj.win{1};
        end
    end
    function obj=parse_win_cell(obj,win,num)
        if numel(win)==2
            obj.parse_win_numeric(win{1},1);
            obj.parse_win_numeric(win{2},2);
        elseif numel(in)==1
            obj.parse_numeric(in{1},1);
        elseif numel(cell) > 2
            error('cell image size')
        end
    end
    function obj=parse_win_numeric(obj,in,num)
        if ndims(in)==3 size(in,3)==2
            obj.parse_win_numeric(in(:,:,1),1);
            obj.parse_win_numeric(in(:,:,2),2);
        elseif nDims(in) > 3
            obj.bWinMovie=1;
        end
        obj.winSize{num}=size(in);
        obj.win{num}=pointer(in);
    end
%% MASK
    function obj=construct_mask(obj,mask)
        if isempty(mask)
            obj.mask{1}=ones(imgSize(1:2));
            obj.mask{2}=ones(imgSize(1:2));
            return
        elseif iscell(mask)
            obj.parse_mask_cell();
        elseif isnumeric(mask)
            obj.parse_mask_numeric(mask);
        end
        if obj.bStereo && isempty(obj.mask{2})
            obj.mask{2}=obj.mask{1};
        end
        if obj.bStereo && isempty(obj.mask{2})
            obj.mask{2}=obj.mask{1};
        end
    end
    function obj=parse_mask_cell(obj,mask,num)
        if numel(mask)==2
            obj.parse_mask_numeric(mask{1},1);
            obj.parse_mask_numeric(mask{2},2);
        elseif numel(in)==1
            obj.parse_numeric(in{1},1);
        elseif numel(cell) > 2
            error('cell mask size')
        end
        if any(in) > 1
            in=in/256;
        end
    end
    function obj=parse_mask_numeric(obj,in,num)
        if ndims(in)==3 size(in,3)==2
            obj.parse_mask_numeric(in(:,:,1),1);
            obj.parse_mask_numeric(in(:,:,2),2);
        elseif nDims(in) > 3
            obj.bMaskMovie=1;
        end
        if any(in) > 1
            in=in/256;
        end
        obj.maskSize{num}=size(in);
        obj.mask{num}=pointer(in);
    end
%% apply
    %function obj=gen_mask(obj)
    %end
    %function obj=obj_apply_win(obj)
    %end
    %function obj=obj_apply_mask(obj)
    %    if obj.bMaskMovie && obj.bImgMovie
    %        end
    %    end
    %end
    %function obj=apply(fld)
    %    bMovieFld=['b' makeUpperCase(fld(1)) fld(2:end) 'Movie'];
    %    for s=1:obj.bStereo+1
    %        thing=ret(obj.(fld));
    %        self=ret(obj.self{s});
    %        win=ret(obj.win{s}
    %        if obj.(bMovieFld) && obj.bImgMovie
    %            thing=repmat(thing,1,1,size(self,3));
    %        end
    %        self=thing.*self;
    %    end
    %end
    function obj=check_sizes(obj)
        for s = 1:obj.bStereo+1
            m=isequal(obj.imgSize{s}(1:2),obj.maskSize{s}(1:2));
            w=isequal(obj.imgSize{s}(1:2),obj.winSize{s}(1:2));
            if  w & m
                error('Mask and Win sizes do not match')
            elseif w
                error('Win sizes do not match')
            elseif m
                error('Mask sizes do not match')
            end
            frames=[];
            if bImageMovie
                frames=[frames obj.imgSize{s}(3)]
            end
            if bWinMovie
                frames=[frames obj.winSize{s}(3)]
            end
            if bMaskMovie
                frames=[frames obj.maskSize{s}(3)]
            end
            if obj.bMovie && ~isuniform(frames)
                error('Motion dimensions are off')
            elseif obj.bMovie
                obj.nFrames{s}=frames(1)
            end
        end
    end
%% tex
    function obj=get_tex(obj)
        if obj.bMovie
            obj.get_movie_tex(obj)
        else
            obj.get_static_tex(obj)
        end
    end
    function obj=get_static_tex(obj)
        for s = 1:obj.bStereo+1
            self=ret(obj.self{s});
            if ndims(self)==2
                self=repmat(self,1,1,3);
            end
            self(:,:,4)=combineAlpha(ret(obj.win{s}),mask=ret(obj.mask{s}));

            obj.tex{s} = Screen('MakeTexture', obj.wdwPtr, self,[],[],2);
        end
    end
    function obj=get_movie_tex(obj)
        for s = 1:obj.bStereo+1
            if obj.bImgMovie
                SELF=ret(obj.self{s}):
            elseif nDims(self)==2
                self=repmat(obj.self{s},1,1,3);
            else
                self=ret(obj.self{s});
            end

            if obj.bWinMovie
                WIN=ret(obj.win{s}):
            else
                win=ret(obj.win{s});
            end

            if obj.bMaskMovie
                MASK=ret(obj.mask{s});
            else
                mask=ret(obj.mask{s});
            end

            for k = 1:obj.nFrames
                if obj.bImgMovie
                    self=repmat(SELF(:,:,k),1,1,3):
                end
                if obj.bWinMovie
                    win=WIN(:,:,1);
                end
                if obj.bMaskMovie
                    mask=MASK(:,:,1);
                end
                self(:,:,4)=combineAlpha(mask,win);
                obj.tex{s}{f} = Screen('MakeTexture', obj.wdwPtr, self,[],[],2);
            end
        end
    end

%% rect
    function obj=get_rect(obj,shape)
        if  strcmp(shape.primitive,'parent')
            error('parent shape cannot hold tex');
        elseif strcmp(shape.primitive,'line')
            error('line shape cannot hold text');
        elseif strcmp(shape.primitive,'poly')
            error('WRITE CODE TO INSCRIBE RECTANGLE IN POLY THAT MAXIMIZES AREA');
        elseif isa(shape,'shape4D') && strcmp(shape.primitive,'rect')
            obj.rect=shape;
            obj.bDynamic=1;
            nFrames=shape.T;
        elseif strcmp(shape.primitive,'rect')
            obj.rect=obj.shape.shape;
        end
    end
%% DRAW
    function obj=draw(obj,wdwPtr,f,s)
        obj.wdwPtr=wdwPtr;
        if ~exist('var','s')
            s=[];
        end
        if exist('f','var') && ~isempty(f)
            obj.draw_frame(f,s);
        elseif obj.bMovie && obj.bDynamic
            obj.draw_dynamic_movie(s):
        elseif obj.bMovie
            obj.draw_static_movie(s);
        elseif obj.bDynamic
            obj.draw_dynamic(s);
        else
            obj.draw_static_frame(s);
        end
    end
    function obj=draw_frame(obj.f,s)
        if obj.bMovie && obj.bDynamic
            obj.draw_dynamic_movie_frame(f,s):
        elseif obj.bMovie
            obj.draw_static_movie_frame(f,s);
        elseif obj.bDynamic
            obj.draw_dynamic_frame(f,s);
        else
            obj.draw_static_frame(s);
        end
    end
%%
    function obj=draw_movie_dynamic(obj,s)
        for f = 1:obj.nFrames
            obj.draw_movie_dynamic_frame(obj,f,s);
        end
    end
    function obj=draw_movie_static(obj,S)
        for f = 1:obj.nFrames
            obj.draw_movie_static_frame(obj,f);
        end
    end
    function obj=draw_dyanamic(obj,s)
        for f = 1:obj.nFreames
            obj.draw_dynamic_frame(obj.f);
        end
    end
    function obj=draw_static(obj,s)
        obj.draw_static_frame(s);
    end
%%
    function obj=draw_movie_dynamic_frame(obj,s)
        if isempty(s)
            s=0:obj.bStereo;
        end
        for ss=s
            Screen('DrawTexture',obj.wdwPtr,obj.tex{ss}{f},[],obj.rect{ss}.shape_at_time(f));
            obj.bDrawn(f,ss)=1;
        end
    end
    function obj=draw_movie_static_frame(obj,f,s)
        if isempty(s)
            s=0:obj.bStereo;
        end
        for ss=s
            Screen('DrawTexture',obj.wdwPtr,obj.tex{ss}{f},[],obj.rect{ss});
            obj.bDrawn(f,ss)=1;
        end
    end
    function obj=draw_dynamic_frame(obj,f,s)
        if isempty(s)
            s=0:obj.bStereo;
        end
        for ss=s
            Screen('DrawTexture',obj.wdwPtr,obj.tex{ss},[],obj.rect{ss}.shape_at_time(f));
            obj.bDrawn(ss)=1;
        end
    end
    function obj=draw_static_frame(obj,s)
        if isempty(s)
            s=0:obj.bStereo;
        end
        for ss=s
            Screen('DrawTexture',obj.wdwPtr,obj.tex{ss},[],obj.rect{ss});
            obj.bDrawn(ss)=1;
        end
    end
%% CLOSE
    function obj=close(obj)
        if obj.bMovie
            obj.close_movie();
        else
            obj.close_static();
        end
    end
    function obj=close_movie();
        for f=1:obj.nFrames
            obj.close_frame(f);
        end
    end
    function obj=close_frame(obj,f);
        for s=1:2
            if obj.bDrawn(f,s)
                Screen('SelectStereoDrawBuffer', obj.wdwPtr, s);
                Screen('Close',obj.wdwPtr,obj.tex{s}{f});
                obj.bDrawn(f,s)=0;
            end
        end
    end
    function obj=close_static();
        for s=1:2
            if obj.bDrawn(s)
                Screen('SelectStereoDrawBuffer', obj.wdwPtr, s);
                Screen('Close',obj.wdwPtr,obj.tex{s});
                obj.bDrawn(s)=0;
            end
        end
    end
end
end
