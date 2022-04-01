function [CNR,well_signal,artifact_signal] = measureWells(Img,varargin)
    
    % Load varargin
    switch nargin
        case 3
            r=varargin{1};
            thickness=varargin{2};% assuming it's always 3rd dimension
        case 2
            r=varargin{1};
            thickness=1;
        case 1
            r=20;% Fix radius at 20 pixels=10mm
            thickness=1;
    end
    
    % Create log compression of the image/volume
    ImgLog=logCmp(Img(:,:,round(end/2)));
    
    % Display image and select
    f=figure;imagesc(ImgLog);colormap gray;drawnow;
    [xs,ys]=getpts;% Select two centers for the filled well first and then the empty well
    
    
    % Calculate CNR
    CNR=[];
    for i_slice=1:thickness
        tt=abs(Img(:,:,i_slice));
        well_signal = tt(createMask(images.roi.Circle(gca,'Center',[xs(1) ys(1)],'Radius',r)));   % signal inside well
        artifact_signal = tt(createMask(images.roi.Circle(gca,'Center',[xs(2) ys(2)],'Radius',r)));   % signal inside well
        CNR(i_slice)=20*log(mean(well_signal)/mean(artifact_signal));
    end
    pause(1);close(f);
end

