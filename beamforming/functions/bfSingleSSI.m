function [IQOut,BFConfig] = bfSingleSSI(RcvData,varargin)
%% This function is a lazy function to beamform on sound-sheet SSI/NSSI data
% Created by Baptiste Heiles on 07/03/2022
% IQOut=bfSingleSSI(RcvData,fNumber); beamforms the RcvData with an OPW
% kernel and a custom fNumber
% IQOut=bfSingleSSI(RcvData,fNumber,kernel_name); beamforms the RcvData
% with a custom fNumber and kernel

tic;
%% Create BFConfig structure with the Verasonics mode
BFConfig=makeBFConfig('SingleNSSI');

%% Convert RcvData from cell to array
if iscell(RcvData)
    RcvData=RcvData{1};
end

%% Overwrite values if fNumber and kernel_name are specified
switch nargin
    case 2
        BFConfig.fNumber=varargin{1};
    case 3
        BFConfig.fNumber=varargin{1};
        BFConfig.kernel_name=varargin{2};
end

%% Compile beamformer and load kernel
BFConfig.isCompile=0;
k=PTXCreate(BFConfig.isCompile,BFConfig.kernel_name,[BFConfig.Nz,BFConfig.Nx,BFConfig.Ny],128,16*128);

%% Demodulate
% Try to see if you're trying to overwrite the mode
try
    modeSSI=evalin('base','UserParam.mode');
    RF=arrangeRF2SSI(RcvData(:,:,1),BFConfig.Nz_RF,BFConfig.NAnglesPerBis*BFConfig.NBisectorsTot/2,modeSSI);
catch
    disp('RF to NSSI');
    RF=arrangeRF2SSI(RcvData(:,:,1),BFConfig.Nz_RF,BFConfig.NAnglesPerBis*BFConfig.NBisectorsTot/2,'NSSI');
end
IQ=RF2IQ(RF,BFConfig.decimSampleRate,BFConfig.demodFrequency);

%% Beamform
IQOut = zeros(BFConfig.Nz, BFConfig.Nx, BFConfig.Ny);
IQOut = feval(k, IQOut, IQ,BFConfig.ScaleZ, BFConfig.ScaleX, BFConfig.ScaleY, BFConfig.Nz, BFConfig.Nx, BFConfig.Ny, BFConfig.Nz_RF, BFConfig.fNumber, BFConfig.ZPiezo, BFConfig.XPiezo, BFConfig.YPiezo, BFConfig.Origin, BFConfig.Angles, BFConfig.NAnglesPerBis,BFConfig.BisectorIdx,BFConfig.NBisectorsTot,BFConfig.BisectorAp, BFConfig.samplesPerWave, BFConfig.decimSampleRate, BFConfig.demodFrequency, BFConfig.speedOfSound, BFConfig.CorrectionForTW, BFConfig.CorrectionForLens, BFConfig.CorrectionForRcvData,BFConfig.isDemod);
IQOut=gather(IQOut);

%% If there is a value IQ_DAS in the base workspace, consider you're in a 
% VSX sequence and assign the IQOut to IQ_DAS
try 
    evalin('base','exist(''IQ_DAS'');');
    assignin('base','IQ_DAS',IQOut);
    assignin('base','BFConfig',BFConfig);
    display3slice;
end
toc
end
