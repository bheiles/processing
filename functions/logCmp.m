function ImgLogCmp = logCmp(Img)
    %% Log compresses an image/volume
    ImgLog=20*log(abs(Img));
    MaxImg=max(ImgLog(:));
    ImgLogCmp=ImgLog-MaxImg;
end

