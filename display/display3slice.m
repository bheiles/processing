function display3slice()
%% This function will display 3 slices on the same figure
% Created by Baptiste Heiles on 01/04/2022
% display3slice displays the middle of the volume in a subplot or at 
% coordinates iz, ix, iy present in the base workspace

%% Get additional arguments or calculate the coordinates
BFConfig=evalin('base','BFConfig');
Img=evalin('base','IQ_DAS');
if evalin('base','exist(''iz'')')
    iz=evalin('base','iz');
    ix=evalin('base','ix');
    iy=evalin('base','iy');
else
    iz=ceil(size(Img,1)/2);
    ix=ceil(size(Img,2)/2);
    iy=ceil(size(Img,3)/2);
    if ix==1 || iy==1
        ix=1;iy=1;BypassSingleX=[1:128];
        BypassSingleY=[128:255];
    else
        BypassSingleX=1:(size(Img,2));
        BypassSingleY=0;
    end
end


%% Compression and normalizing
ImgLogCmp = logCmp(Img(1:end,:,:));
% switch size(ImgLogCmp,2)
%     case 128
%         t{1}=ImgLogCmp(:,1:32,33:96);
%         t{2}=permute(ImgLogCmp(:,33:96,1:32),[1,3,2]);
%         t{3}=ImgLogCmp(:,97:128,33:96);
%         t{4}=permute(ImgLogCmp(:,33:96,97:128),[1,3,2]);
%         t=cell2mat(t');ImgLogCmp(:,1:32,33:96)=ImgLogCmp(:,1:32,33:96)-max(t(:));
%         ImgLogCmp(:,33:96,1:32)=ImgLogCmp(:,33:96,1:32)-max(t(:));
%         ImgLogCmp(:,97:128,33:96)=ImgLogCmp(:,97:128,33:96)-max(t(:));
%         ImgLogCmp(:,33:96,97:128)=ImgLogCmp(:,33:96,97:128)-max(t(:));
%         t=ImgLogCmp(:,33:96,33:96);ImgLogCmp(:,33:96,33:96)=ImgLogCmp(:,33:96,33:96)-max(t(:));
%     case 256
%         t{1}=ImgLogCmp(:,1:26,27:231);
%         t{2}=permute(ImgLogCmp(:,27:231,1:26),[1,3,2]);
%         t{3}=ImgLogCmp(:,232:256,27:231);
%         t{4}=permute(ImgLogCmp(:,27:231,232:256),[1,3,2]);
%         tt=ImgLogCmp(:,1:26,27:231);
%         ImgLogCmp(:,1:26,27:231)=ImgLogCmp(:,1:26,27:231)-max(tt(:));
%         ImgLogCmp(:,27:231,1:26)=ImgLogCmp(:,27:231,1:26)-max(tt(:));
%         ImgLogCmp(:,232:256,27:231)=ImgLogCmp(:,232:256,27:231)-max(tt(:));
%         ImgLogCmp(:,27:231,232:256)=ImgLogCmp(:,27:231,232:256)-max(tt(:));
% end


%% Display or update display
if ~ishandle(12345)
    % Create figure and axes
    f=figure(12345);
    set(f,'Position',[10 500 1000 300])
    zAx=[1:size(Img,1)].*BFConfig.ScaleZ.*1e3;
    xAx=[1:size(Img,2)].*BFConfig.ScaleX.*1e3;
%    yAx=[1:size(Img,3)].*BFConfig.ScaleY.*1e3;% commented this because it
%    was causing problems with the single sound sheet mode so we'll assume
%    it's always the same as x
    
    % Clean figure
    f.Color='w';
    f.InvertHardcopy='off';
    
    % Display
    tiledlayout(1,3,'TileSpacing','tight');
    nexttile;imagesc(xAx,xAx,squeeze(ImgLogCmp(iz,:,:)));ax1=gca;
    axis image;colormap gray;xlabel('C-scan (XY)');
    nexttile;imagesc(zAx,xAx,squeeze(ImgLogCmp(:,BypassSingleX,iy)));ax2=gca;
    axis image;colormap gray;xlabel('ZX-scan');
    nexttile;imagesc(zAx,xAx,squeeze(ImgLogCmp(:,ix+BypassSingleY,:)));ax3=gca;
    axis image;colormap gray;xlabel('ZY-scan');
    drawnow
else
    % Display
    f=figure(12345);
    f.Children.Children(3).Children.CData=squeeze(ImgLogCmp(iz,:,:));
    f.Children.Children(2).Children.CData=squeeze(ImgLogCmp(:,BypassSingleX,iy));
    f.Children.Children(1).Children.CData=squeeze(ImgLogCmp(:,ix+BypassSingleY,:));
    drawnow;
end






end
