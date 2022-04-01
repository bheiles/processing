function  ImgAx=imRCA( Img, disprange ,varargin)
%IMSHOW3DFULL displays 3D grayscale or RGB images from three perpendicular
%views (i.e. axial, sagittal, and coronal) in slice by slice fashion with
%mouse based slice browsing and window and level adjustment control.
%
% Usage:
% imRCA ( Image )
% imRCA ( Image , [] )
% imRCA ( Image , [LOW HIGH] )
% imRCA ( Image , [LOW HIGH] , scales)
%    Image:      3D image MxNxKxC (K slices of MxN images) C is either 1
%                (for grayscale images) or 3 (for RGB images)
%    [LOW HIGH]: display range that controls the display intensity range of
%                a grayscale image (default: the widest available range)
%
% Use the scroll bar or mouse scroll wheel to switch between slices. To
% adjust window and level values keep the mouse right button pressed and
% drag the mouse up and down (for level adjustment) or right and left (for
% window adjustment). Window and level adjustment control works only for
% grayscale images.
%
% Use 'A', 'S', and 'C' buttons to switch between axial, sagittal and
% coronal views, respectivelly.
% 
% "Auto W/L" button adjust the window and level automatically 
%
% While "Fine Tune" check box is checked the window/level adjustment gets
% 16 times less sensitive to mouse movement, to make it easier to control
% display intensity rang.
%
% Note: The sensitivity of mouse based window and level adjustment is set
% based on the user defined display intensity range; the wider the range
% the more sensitivity to mouse drag.
% 
% 
%   Example
%   --------
%       % Display an image (MRI example)
%       load mri 
%       Image = squeeze(D); 
%       figure, 
%       imshow3Dfull(Image) 
%
%       % Display the image, adjust the display range
%       figure,
%       imshow3Dfull(Image,[20 100]);
%
%   See also IMSHOW.

%
% - Maysam Shahedi (mshahedi@gmail.com)
% - Released: 1.0.0   Date: 2013/04/15
% - Revision: 1.1.0   Date: 2013/04/19
% - Revision: 2.0.0   Date: 2014/08/05
% - Revision: 2.5.0   Date: 2016/09/22
% - Revision: 2.5.1   Date: 2018/10/29
% 
if nargin>2
    scales=varargin{1};
else
    scales=[1 1 1];
end
ScalesView=scales([1,2]);

sno = size(Img);  % image size
sno_a = sno(3);  % number of axial slices
S_a = round(sno_a/2);
sno_s = sno(2);  % number of sagittal slices
S_s = round(sno_s/2);
sno_c = sno(1);  % number of coronal slices
S_c = round(sno_c/2);
S = S_a;
sno = sno_a;

global InitialCoord;

MinV = -1E-6;
MaxV = max(Img(:));
Rmax = (double( MaxV) + double(MinV)) / 2;
Rmin = double(MaxV) - double(MinV);
WLAdjCoe = (Rmin + 1)/1024;
FineTuneC = [1 1/16];    % Regular/Fine-tune mode coefficients

if isa(Img,'uint8')
    MaxV = uint8(Inf);
    MinV = uint8(-Inf);
    Rmax = (double( MaxV) + double(MinV)) / 2;
    Rmin = double(MaxV) - double(MinV);
    WLAdjCoe = (Rmin + 1)/1024;
elseif isa(Img,'uint16')
    MaxV = uint16(Inf);
    MinV = uint16(-Inf);
    Rmax = (double( MaxV) + double(MinV)) / 2;
    Rmin = double(MaxV) - double(MinV);
    WLAdjCoe = (Rmin + 1)/1024;
elseif isa(Img,'uint32')
    MaxV = uint32(Inf);
    MinV = uint32(-Inf);
    Rmax = (double( MaxV) + double(MinV)) / 2;
    Rmin = double(MaxV) - double(MinV);
    WLAdjCoe = (Rmin + 1)/1024;
elseif isa(Img,'uint64')
    MaxV = uint64(Inf);
    MinV = uint64(-Inf);
    Rmax = (double( MaxV) + double(MinV)) / 2;
    Rmin = double(MaxV) - double(MinV);
    WLAdjCoe = (Rmin + 1)/1024;
elseif isa(Img,'int8')
    MaxV = int8(Inf);
    MinV = int8(-Inf);
    Rmax = (double( MaxV) + double(MinV)) / 2;
    Rmin = double(MaxV) - double(MinV);
    WLAdjCoe = (Rmin + 1)/1024;
elseif isa(Img,'int16')
    MaxV = int16(Inf);
    MinV = int16(-Inf);
    Rmax = (double( MaxV) + double(MinV)) / 2;
    Rmin = double(MaxV) - double(MinV);
    WLAdjCoe = (Rmin + 1)/1024;
elseif isa(Img,'int32')
    MaxV = int32(Inf);
    MinV = int32(-Inf);
    Rmax = (double( MaxV) + double(MinV)) / 2;
    Rmin = double(MaxV) - double(MinV);
    WLAdjCoe = (Rmin + 1)/1024;
elseif isa(Img,'int64')
    MaxV = int64(Inf);
    MinV = int64(-Inf);
    Rmax = (double( MaxV) + double(MinV)) / 2;
    Rmin = double(MaxV) - double(MinV);
    WLAdjCoe = (Rmin + 1)/1024;
elseif isa(Img,'logical')
    MaxV = 0;
    MinV = 1;
    Rmax =0.5;
    Rmin = 1;
    WLAdjCoe = 0.1;
elseif isa(Img,'double') && isreal(Img)
    Img=20*log10(Img);
    Img=Img-max(Img(:));
    MaxV=max(Img(:));
    MinV=min(Img(:));
    Rmax = MaxV;
    Rmin = MinV;
    WLAdjCoe = (Rmin + 1)/1024;
elseif isa(Img,'double') && ~isreal(Img)
    Img=20*log(abs(Img));
        Img=Img-max(Img(:));% do this if you want to normalize by all the volume
       switch size(Img,2)
           case 128
            disp('Normalizing with Wide parameters');
            t{1}=Img(:,1:32,33:96);
            t{2}=permute(Img(:,33:96,1:32),[1,3,2]);
            t{3}=Img(:,97:128,33:96);
            t{4}=permute(Img(:,33:96,97:128),[1,3,2]);
            t=cell2mat(t');Img(:,1:32,33:96)=Img(:,1:32,33:96)-max(t(:));
            %t=Img(:,33:96,1:32);
            Img(:,33:96,1:32)=Img(:,33:96,1:32)-max(t(:));
            %t=Img(:,97:128,33:96);
            Img(:,97:128,33:96)=Img(:,97:128,33:96)-max(t(:));
            %t=Img(:,33:96,97:128);
            Img(:,33:96,97:128)=Img(:,33:96,97:128)-max(t(:));
            t=Img(:,33:96,33:96);Img(:,33:96,33:96)=Img(:,33:96,33:96)-max(t(:));
           case 256
            disp('Normalizing with SuperWide parameters');
            t{1}=Img(:,1:26,27:233);
            t{2}=permute(Img(:,27:233,1:26),[1,3,2]);
            t{3}=Img(:,231:256,27:233);
            t{4}=permute(Img(:,27:233,231:256),[1,3,2]);
            t=cell2mat(t');Img(:,1:26,27:233)=Img(:,1:26,27:233)-max(t(:));
            %t=Img(:,33:96,1:32);
            Img(:,27:233,1:26)=Img(:,27:233,1:26)-max(t(:));
            %t=Img(:,97:128,33:96);
            Img(:,233:256,27:233)=Img(:,233:256,27:233)-max(t(:));
            %t=Img(:,33:96,97:128);
            Img(:,27:233,233:256)=Img(:,27:233,233:256)-max(t(:));
            t=Img(:,27:233,27:233);Img(:,27:233,27:233)=Img(:,27:233,27:233)-max(t(:));
       end
        MaxV=max(Img(:));
%         Img(1:40,:,:)=Img(1:40,:,:).*1.15;%for linear
        %Img(1:16,:,:)=Img(1:16,:,:).*2.8;%for non linear
        %Img(1:16,:,:)=Img(1:16,:,:).*1.5;
        %Img(:,1:25,:)=Img(:,1:25,:).*0.9;
        %Img(:,234:256,:)=Img(:,234:256,:).*2.8;
    MinV=min(Img(:));
    Rmax = MaxV;
    Rmin = MinV;
    WLAdjCoe = (Rmin + 1)/1024;
end 

ImgAx = Img;
if verLessThan('matlab', '8')
    ImgSg = flipdim(permute(Img, [3 1 2 4]),1);   % Sagittal view image
    ImgCr = flipdim(permute(Img, [3 2 1 4]),1);   % Coronal view image
else
    ImgSg = permute(Img, [1 3 2 4]);   % Sagittal view image
    ImgCr = flip(permute(Img, [3 2 1 4]),1);   % Coronal view image
end

View = 'A';

SFntSz = 9;
LFntSz = 10;
WFntSz = 10;
VwFntSz = 10;
LVFntSz = 9;
WVFntSz = 9;
BtnSz = 10;
ChBxSz = 10;

if (nargin < 2)
    [Rmin Rmax] = WL2R(Rmin, Rmax);
elseif numel(disprange) == 0
    [Rmin Rmax] = WL2R(Rmin, Rmax);
else
    Rmax = (double(disprange(2)) + double(disprange(1))) / 2;
    Rmin = double(disprange(2)) - double(disprange(1));
    WLAdjCoe = (Rmin + 1)/1024;
    [Rmin Rmax] = WL2R(Rmin, Rmax);
end

clf
hdl_im = axes('position',[0,0.2,1,0.8]);
imshow(squeeze(Img(:,:,S,:)), [Rmin Rmax]);axis image;

FigPos = get(gcf,'Position');
S_Pos = [50 50 uint16(FigPos(3)-100)+1 20];
Stxt_Pos = [50 70 uint16(FigPos(3)-100)+1 15];
Wtxt_Pos = [20 20 60 20];
Wval_Pos = [75 20 60 20];
Ltxt_Pos = [140 20 45 20];
Lval_Pos = [180 20 60 20];
BtnStPnt = uint16(FigPos(3)-210)+1;
if BtnStPnt < 360
    BtnStPnt = 360;
end
Btn_Pos = [BtnStPnt 20 80 20];
ChBx_Pos = [BtnStPnt+90 20 100 20];
Vwtxt_Pos = [255 20 35 20];
VAxBtn_Pos = [290 20 15 20];
VSgBtn_Pos = [310 20 15 20];
VCrBtn_Pos = [330 20 15 20];

if sno > 1
    shand = uicontrol('Style', 'slider','Min',1,'Max',sno,'Value',S,'SliderStep',[1/(sno-1) 10/(sno-1)],'Position', S_Pos,'Callback', {@SliceSlider, Img});
    stxthand = uicontrol('Style', 'text','Position', Stxt_Pos,'String',sprintf('Slice# %d / %d',S, sno), 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', SFntSz);
else
    stxthand = uicontrol('Style', 'text','Position', Stxt_Pos,'String','2D image', 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', SFntSz);
end    
ltxthand = uicontrol('Style', 'text','Position', Ltxt_Pos,'String','Max: ', 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', LFntSz);
wtxthand = uicontrol('Style', 'text','Position', Wtxt_Pos,'String','Min:: ', 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', WFntSz);
lvalhand = uicontrol('Style', 'edit','Position', Lval_Pos,'String',sprintf('%6.0f',Rmax), 'BackgroundColor', [1 1 1], 'FontSize', LVFntSz,'Callback', @WinLevChanged);
wvalhand = uicontrol('Style', 'edit','Position', Wval_Pos,'String',sprintf('%6.0f',Rmin), 'BackgroundColor', [1 1 1], 'FontSize', WVFntSz,'Callback', @WinLevChanged);
Btnhand = uicontrol('Style', 'pushbutton','Position', Btn_Pos,'String','Save', 'FontSize', BtnSz, 'Callback' , @Save);
ChBxhand = uicontrol('Style', 'checkbox','Position', ChBx_Pos,'String','Fine Tune', 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', ChBxSz);
Vwtxthand = uicontrol('Style', 'text','Position', Vwtxt_Pos,'String','View: ', 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', LFntSz);
VAxBtnhand = uicontrol('Style', 'pushbutton','Position', VAxBtn_Pos,'String','A', 'FontSize', BtnSz, 'Callback' , @AxialView);
VSgBtnhand = uicontrol('Style', 'pushbutton','Position', VSgBtn_Pos,'String','S', 'FontSize', BtnSz, 'Callback' , @SagittalView);
VCrBtnhand = uicontrol('Style', 'pushbutton','Position', VCrBtn_Pos,'String','C', 'FontSize', BtnSz, 'Callback' , @CoronalView);

set (gcf, 'WindowScrollWheelFcn', @mouseScroll);
set (gcf, 'ButtonDownFcn', @mouseClick);
set(get(gca,'Children'),'ButtonDownFcn', @mouseClick);
set(gcf,'WindowButtonUpFcn', @mouseRelease)
set(gcf,'ResizeFcn', @figureResized)


% -=< Figure resize callback function >=-
    function figureResized(object, eventdata)
        FigPos = get(gcf,'Position');
        S_Pos = [50 45 uint16(FigPos(3)-100)+1 20];
        Stxt_Pos = [50 65 uint16(FigPos(3)-100)+1 15];
        BtnStPnt = uint16(FigPos(3)-210)+1;
        if BtnStPnt < 360
            BtnStPnt = 360;
        end
        Btn_Pos = [BtnStPnt 20 80 20];
        ChBx_Pos = [BtnStPnt+90 20 100 20];
        if sno > 1
            set(shand,'Position', S_Pos);
        end
        set(stxthand,'Position', Stxt_Pos);
        set(ltxthand,'Position', Ltxt_Pos);
        set(wtxthand,'Position', Wtxt_Pos);
        set(lvalhand,'Position', Lval_Pos);
        set(wvalhand,'Position', Wval_Pos);
        set(Btnhand,'Position', Btn_Pos);
        set(ChBxhand,'Position', ChBx_Pos);
        set(Vwtxthand,'Position', Vwtxt_Pos);
        set(VAxBtnhand,'Position', VAxBtn_Pos);
        set(VSgBtnhand,'Position', VSgBtn_Pos);
        set(VCrBtnhand,'Position', VCrBtn_Pos);
        daspect(scales);
    end

% -=< Slice slider callback function >=-
    function SliceSlider (hObj,event, Img)
        S = round(get(hObj,'Value'));
        set(get(gca,'children'),'cdata',squeeze(Img(:,:,S,:)))
        caxis([Rmin Rmax])
        if sno > 1
            set(stxthand, 'String', sprintf('Slice# %d / %d',S, sno));
        else
            set(stxthand, 'String', '2D image');
        end
    end

% -=< Mouse scroll wheel callback function >=-
    function mouseScroll (object, eventdata)
        UPDN = eventdata.VerticalScrollCount;
        S = S - UPDN;
        if (S < 1)
            S = 1;
        elseif (S > sno)
            S = sno;
        end
        if sno > 1
            set(shand,'Value',S);
            set(stxthand, 'String', sprintf('Slice# %d / %d',S, sno));
        else
            set(stxthand, 'String', '2D image');
        end
        set(get(gca,'children'),'cdata',squeeze(Img(:,:,S,:)))
    end

% -=< Mouse button released callback function >=-
    function mouseRelease (object,eventdata)
        set(gcf, 'WindowButtonMotionFcn', '')
    end

% -=< Mouse click callback function >=-
    function mouseClick (object, eventdata)
        MouseStat = get(gcbf, 'SelectionType');
        if (MouseStat(1) == 'a')        %   RIGHT CLICK
            InitialCoord = get(0,'PointerLocation');
            set(gcf, 'WindowButtonMotionFcn', @WinLevAdj);
        end
    end

% -=< Window and level mouse adjustment >=-
    function WinLevAdj(varargin)
        PosDiff = get(0,'PointerLocation') - InitialCoord;

        Rmin = Rmin + PosDiff(1) * WLAdjCoe * FineTuneC(get(ChBxhand,'Value')+1);
        Rmax = Rmax - PosDiff(2) * WLAdjCoe * FineTuneC(get(ChBxhand,'Value')+1);
        if (Rmin < 1)
            Rmin = 1;
        end

        [Rmin, Rmax] = WL2R(Rmin,Rmax);
        caxis([Rmin, Rmax])
        set(lvalhand, 'String', sprintf('%6.0f',Rmax));
        set(wvalhand, 'String', sprintf('%6.0f',Rmin));
        InitialCoord = get(0,'PointerLocation');
    end

% -=< Window and level text adjustment >=-
    function WinLevChanged(varargin)

        Rmax = str2double(get(lvalhand, 'string'));
        Rmin = str2double(get(wvalhand, 'string'));

        [Rmin, Rmax] = WL2R(Rmin,Rmax);
        caxis([Rmin, Rmax])
    end

% -=< Window and level to range conversion >=-
    function [Rmn Rmx] = WL2R(W,L)
        Rmn = W;
        Rmx =L;
    end

% -=< Window and level auto adjustment callback function >=-
    function Save(object,eventdata)
        ImCdata=get(gca,'children');
        CMap=get(gcf,'Colormap');
        DaspectRatio=get(gca,'DataAspectRatio');
        f=figure(1952);
        f.InvertHardcopy='off';
        f.Color=[1,1,1];
        imagesc(ImCdata.CData);caxis([Rmin,Rmax]);colormap gray
        colorbar;title(['Section number ',num2str(S)]);
        set(gca,'DataAspectRatio',DaspectRatio);
        xt=arrayfun(@num2str,get(gca,'xtick')*ScalesView(2),'un',0);
        yt=arrayfun(@num2str,get(gca,'ytick')*ScalesView(1),'un',0);
        set(gca,'xticklabel',xt,'yticklabel',yt);
        [filename,pathfile]=uiputfile('.fig');
        [~,fname,~]=fileparts(filename);
        savefig(f,[pathfile,fname,'.fig']);
        print(f, '-dtiff', [pathfile,fname,'.tiff']);
        close(f)
    end

% -=< Axial view callback function >=-
    function AxialView(object,eventdata)
        if View == 'S'
            S_s = S;
            ScalesView=scales([1,3]);
        elseif View == 'C'
            S_c = S;
            ScalesView=scales([2,3]);
        end            
        View = 'A';
        ScalesView=scales([1,2]);
        
        Img = ImgAx;
        S = S_a;
        sno = sno_a;
        cla(hdl_im);
        hdl_im = axes('position',[0,0.2,1,0.8]);
        imshow(squeeze(Img(:,:,S,:)), [Rmin Rmax])

        if sno > 1
            shand = uicontrol('Style', 'slider','Min',1,'Max',sno,'Value',S,'SliderStep',[1/(sno-1) 10/(sno-1)],'Position', S_Pos,'Callback', {@SliceSlider, Img});
            stxthand = uicontrol('Style', 'text','Position', Stxt_Pos,'String',sprintf('Slice# %d / %d',S, sno), 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', SFntSz);
        else
            stxthand = uicontrol('Style', 'text','Position', Stxt_Pos,'String','2D image', 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', SFntSz);
        end
        
        caxis([Rmin Rmax])
        if sno > 1
            set(stxthand, 'String', sprintf('Slice# %d / %d',S, sno));
        else
            set(stxthand, 'String', '2D image');
        end
        
        set(get(gca,'children'),'cdata',squeeze(Img(:,:,S,:)))
        set (gcf, 'ButtonDownFcn', @mouseClick);
        set(get(gca,'Children'),'ButtonDownFcn', @mouseClick);
    end

% -=< Sagittal view callback function >=-
    function SagittalView(object,eventdata)
        if View == 'A'
            S_a = S;
            ScalesView=scales([1,2]);
        elseif View == 'C'
            S_c = S;
            ScalesView=scales([1,3]);
        end            
        View = 'S';
        ScalesView=scales([1,3]);
        
        Img = ImgSg;
        S = S_s;
        sno = sno_s;
        cla(hdl_im);
        hdl_im = axes('position',[0,0.2,1,0.8]);
        imshow(squeeze(Img(:,:,S,:)), [Rmin Rmax])

        if sno > 1
            shand = uicontrol('Style', 'slider','Min',1,'Max',sno,'Value',S,'SliderStep',[1/(sno-1) 10/(sno-1)],'Position', S_Pos,'Callback', {@SliceSlider, Img});
            stxthand = uicontrol('Style', 'text','Position', Stxt_Pos,'String',sprintf('Slice# %d / %d',S, sno), 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', SFntSz);
        else
            stxthand = uicontrol('Style', 'text','Position', Stxt_Pos,'String','2D image', 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', SFntSz);
        end
        
        caxis([Rmin Rmax])
        if sno > 1
            set(stxthand, 'String', sprintf('Slice# %d / %d',S, sno));
        else
            set(stxthand, 'String', '2D image');
        end

        set(get(gca,'children'),'cdata',squeeze(Img(:,:,S,:)))
        set (gcf, 'ButtonDownFcn', @mouseClick);
        set(get(gca,'Children'),'ButtonDownFcn', @mouseClick);

    end

% -=< Coronal view callback function >=-
    function CoronalView(object,eventdata)
        if View == 'A'
            S_a = S;
            ScalesView=scales([1,2]);
        elseif View == 'S'
            S_s = S;
            ScalesView=scales([1,3]);
        end            
        View = 'C';
        ScalesView=scales([2,3]);
        
        Img = ImgCr;
        S = S_c;
        sno = sno_c;
        cla(hdl_im);
        hdl_im = axes('position',[0,0.2,1,0.8]);
        imshow(squeeze(Img(:,:,S,:)), [Rmin Rmax])

        if sno > 1
            shand = uicontrol('Style', 'slider','Min',1,'Max',sno,'Value',S,'SliderStep',[1/(sno-1) 10/(sno-1)],'Position', S_Pos,'Callback', {@SliceSlider, Img});
            stxthand = uicontrol('Style', 'text','Position', Stxt_Pos,'String',sprintf('Slice# %d / %d',S, sno), 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', SFntSz);
        else
            stxthand = uicontrol('Style', 'text','Position', Stxt_Pos,'String','2D image', 'BackgroundColor', [0.8 0.8 0.8], 'FontSize', SFntSz);
        end
        
        caxis([Rmin Rmax])
        if sno > 1
            set(stxthand, 'String', sprintf('Slice# %d / %d',S, sno));
        else
            set(stxthand, 'String', '2D image');
        end

        set(get(gca,'children'),'cdata',squeeze(Img(:,:,S,:)))
        set (gcf, 'ButtonDownFcn', @mouseClick);
        set(get(gca,'Children'),'ButtonDownFcn', @mouseClick);
    end

end
% -=< Maysam Shahedi (mshahedi@gmail.com), September 22, 2016>=-