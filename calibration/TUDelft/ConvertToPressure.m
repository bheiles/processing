function data=ConvertToPressure( waveform , waveform_label , preamble , enabled_rows , enabled_cols, hydrophone ,amplifier , path_to_calibration)
%% This function will convert the output of the hydrophone of the calibration bench in kPa
% at ImPhys, TU Delft into pressure
% Function written by Baptiste heiles on 2021/06/04
% Adapted from Djalma's script
% waveform : waveform cell from the calibration
% waveform_label : cell with the label of the waveforms
% preamble : struct containing useful info from the oscilloscope
% enabled_rows : enabled rows in the probe (remnant from the PUMA code)
% enabled_cols : enabled columns in the probe (remnant from the PUMA code)
% hydrophone : string, hydrophone type  '1mm', '2385' or '1688';
% amplifier : double, amplifier model 60
% path_to_calibration :  string, path to the file CalibrationData holding
% the hydrophone characteristics

% Create time vectors
t_start = preamble.x_origin;
t_step = preamble.x_increment;
t_stop = t_start + (length(waveform{1, 1}) - 1)*t_step;
t = t_start:t_step:t_stop;

% Scale amplitude
waveform_volt{length(waveform),1} = [];
for n = 1:1:length(waveform)
    waveform_volt{n ,1} = (waveform{n, 1} - preamble.y_reference) .* preamble.y_increment + preamble.y_origin;
end

% Saves waveform and label in one variable
for n = 1:1:min(length(waveform),max(enabled_rows))
    data.label{n, 1} =  waveform_label{n, 1};
    data.waveform{n, 1} =  waveform_volt{n, 1};
end
data.time = t';
data.preamble = preamble;

% Convert Volts to pressure
for i = 1:length(data.waveform)
        data.waveform{i} = data.waveform{i} / db2mag(amplifier);    % Subtract amplifier gain
        
        data.waveform{i} = VtoPa(data.time, data.waveform{i}, hydrophone,path_to_calibration);
        data.waveform{i} = data.waveform{i} * 1e-3; % Convert to kPa
end
end
%% Include function to convert Volts to Pascals
function output = VtoPa(time, input, hydrophone,path_to_calibration)
    %% Prepare data
    dFreq=(1/diff(time(1:2))/ length(time)) * ifftshift( -floor( length(time)/2) : ceil( length(time)/2)-1 )*1E-6;
    data = fft(input);

    %% Load and prepare calibration data
    % It's too much too assume the frequency spectrum stays constant
    persistent cData freq usedH
    if(isempty(cData) || ~strcmpi(usedH, hydrophone))
        load(path_to_calibration,'CalibrationData')
        freq = cell2mat(table2cell(CalibrationData(:,1)));
        if(strcmpi(hydrophone, '1mm'))
            cData = cell2mat(table2cell(CalibrationData(:,2)));
        elseif(strcmpi(hydrophone, '2385'))
            cData = cell2mat(table2cell(CalibrationData(:,3)));
        elseif(strcmpi(hydrophone, '1688'))
            cData = cell2mat(table2cell(CalibrationData(:,4)));
        else
            error('Hydrophone not known')
        end
        usedH = hydrophone;

        % Add negative frequencies
        freq = [-flip(freq(2:end)); freq];
        cData = [ flip(cData(2:end)); cData];
    end
    
    % Interpolate calibration data
    cFac = interp1(freq, cData, dFreq, 'linear').' * (1e-3/1e6); % Also convert from mV/MPa to V/Pa
    
    %% Convert to Pascals
    data = data ./ cFac;
    data(isnan(data) | isinf(data)) = 0;
    output = real(ifft(data));
    output(isnan(output) | isinf(output)) = 0;
end
