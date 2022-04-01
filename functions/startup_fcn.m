function startup_fcn(path_to_User,mode)
%% Function to add different paths to work for Baptiste Heiles
% Created by Baptiste Heiles on 01/04/2022

switch mode
    case '3DVSX'
        path_to_Github=[path_to_User,'\MarescaLGithub'];
        addpath([path_to_Github, '\ImagingSequences\plane_wave_imaging\3D\external_functions\']);
        addpath([path_to_Github, '\ImagingSequences\probe_library\']);
        addpath([path_to_Github, '\ImagingSequences\plane_wave_imaging\3D\private_functions\']);
        addpath([path_to_Github, '\Beamformers\preprocessing\']);
        addpath([path_to_Github, '\Beamformers\CUDA\3D\RCA\NSSI\']);
        addpath([path_to_Github, '\Beamformers\CUDA\external\']);
        addpath([path_to_Github, '\processing\beamforming\functions\']);
        addpath([path_to_Github, '\processing\display\']);
    case '3DPP'
end