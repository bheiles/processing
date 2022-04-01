function [IQOut,BFConfig] = bfVerasonics(RcvData,varargin)
%% This function is a lazy function to beamform Verasonics data
% Created by Baptiste Heiles on 07/03/2022
% IQOut=bfVerasonics(RcvData) beamforms the RcvData with an OPW kernel and
% a fNumber=1
% IQOut=bfVerasonics(RcvData,fNumber); beamforms the RcvData with an OPW
% kernel and a custom fNumber
% IQOut=bfVerasonics(RcvData,fNumber,kernel_name); beamforms the RcvData
% with a custom fNumber and kernel


%% Create BFConfig structure with the Verasonics mode
BFConfig=makeBFConfig('Verasonics');

%% Overwrite values if fNumber and kernel_name are specified
switch nargin
    case 2
        BFConfig.fNumber=varargin{1};
    case 3
        BFConfig.fNumber=varargin{1};
        BFConfig.kernel_name=varargin{2};
end

%% Compile beamformer and load kernel
k=PTXCreate(1,BFConfig.kernel_name,[BFConfig.Nz,BFConfig.Nx,BFConfig.Ny],128,16*128);
%% Demodulate
RF=RcvData{1,1}(1:BFConfig.NAngles.*2.*BFConfig.Nz_RF,:,1);
RF=[RF(end/2+[1:end/2],:,:);RF(1:end/2,:,:)];% First TX is on 1:128 and we beamform with the first TX on 129:256
IQ=RF2IQ(RF,BFConfig.decimSampleRate,BFConfig.demodFrequency);
%% Beamform
IQOut = zeros(BFConfig.Nz, BFConfig.Nx, BFConfig.Ny);
IQOut = feval(k, IQOut, IQ, BFConfig.ScaleZ, BFConfig.ScaleX, BFConfig.ScaleY, BFConfig.Nz, BFConfig.Nx, BFConfig.Ny, BFConfig.Nz_RF, BFConfig.fNumber, BFConfig.ZPiezo, BFConfig.XPiezo, BFConfig.YPiezo, BFConfig.Origin, BFConfig.Angles, BFConfig.NAngles,  BFConfig.samplesPerWave, BFConfig.decimSampleRate, BFConfig.demodFrequency, BFConfig.speedOfSound, BFConfig.CorrectionForTW, BFConfig.CorrectionForLens, BFConfig.CorrectionForRcvData,BFConfig.isDemod);
IQOut=gather(IQOut);
end

