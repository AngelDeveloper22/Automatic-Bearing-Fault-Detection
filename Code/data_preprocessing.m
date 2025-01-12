%% Creating datasets for bearing data

%Downloading data
baseline_1 = load('C:\Users\hurta\OneDrive\Documents\College\Masters\diagnostics & testing\project\bearing_data 1\baseline_1.mat');
baseline_2 = load('C:\Users\hurta\OneDrive\Documents\College\Masters\diagnostics & testing\project\bearing_data 1\baseline_2.mat');
baseline_3 = load('C:\Users\hurta\OneDrive\Documents\College\Masters\diagnostics & testing\project\bearing_data 1\baseline_3.mat');
inner_1 = load('C:\Users\hurta\OneDrive\Documents\College\Masters\diagnostics & testing\project\bearing_data 1\InnerRaceFault_1.mat');
inner_2 = load('C:\Users\hurta\OneDrive\Documents\College\Masters\diagnostics & testing\project\bearing_data 1\InnerRaceFault_2.mat');
inner_3 = load('C:\Users\hurta\OneDrive\Documents\College\Masters\diagnostics & testing\project\bearing_data 1\InnerRaceFault_3.mat');
outer_1 = load('C:\Users\hurta\OneDrive\Documents\College\Masters\diagnostics & testing\project\bearing_data 1\OuterRaceFault_1.mat');
outer_2 = load('C:\Users\hurta\OneDrive\Documents\College\Masters\diagnostics & testing\project\bearing_data 1\OuterRaceFault_2.mat');
outer_3 = load('C:\Users\hurta\OneDrive\Documents\College\Masters\diagnostics & testing\project\bearing_data 1\OuterRaceFault_3.mat');
outer_4 = load('C:\Users\hurta\OneDrive\Documents\College\Masters\diagnostics & testing\project\bearing_data 1\OuterRaceFault_4.mat');
outer_5 = load('C:\Users\hurta\OneDrive\Documents\College\Masters\diagnostics & testing\project\bearing_data 1\OuterRaceFault_5.mat');

%Preparing data for preprocessing
signals = {baseline_1.bearing, baseline_2.bearing, baseline_3.bearing, inner_1.bearing, inner_2.bearing, inner_3.bearing, outer_1.bearing, outer_2.bearing, outer_3.bearing, outer_4.bearing, outer_5.bearing};
labels = [0, 0, 0, 1, 1, 1, 2, 2, 2, 2, 2];

all_windows = {};
all_labels = [];

%checking for sampling rate and resampling
target_fs = 97656;

%iterating over signals for resampling if necessary
for i = 1:length(signals)
    %accessing current signal structure
    signal_struct = signals{i};
    signal_data = signal_struct.gs;
    original_fs = signal_struct.sr;

    %checking
    if original_fs ~= target_fs
        resampled_signal = resample(signal_data, target_fs, original_fs);
        signals{i}.gs = resampled_signal;
        signals{i}.sr = target_fs;
    end
end

%% Sliding windows technique - Data Augmentation
for i = 1:length(signals)
    % Extract signal and sampling rate
    signal_struct = signals{i};
    signal_data = signal_struct.gs;
    fs = signal_struct.sr;
    label = labels(i);

    % Sliding window parameters
    window_length = 0.5 * fs; % 5 seconds
    step_size = 1000; % Step size
    num_samples = length(signal_data);
    num_windows = floor((num_samples - window_length) / step_size) + 1;

    % Generate sliding windows
    for j = 1:num_windows
        start_idx = (j-1) * step_size + 1;
        sliding_window = signal_data(start_idx:start_idx + window_length - 1);

        % Append the sliding window and label to storage
        all_windows{end+1, 1} = sliding_window; % Add the window as a new cell
        all_labels(end+1, 1) = label;           % Add the label as a new entry
    end
end

% Create a table with the signals and labels
dataset_table = table(all_windows, all_labels, ...
                      'VariableNames', {'Signal', 'Label'});
%important data for training
dataset_table.kurtosis = zeros(height(dataset_table),1);
dataset_table.domfreq = zeros(height(dataset_table),1);
disp('borre las tablas')
%

%% trying with a second table
% This was for testing after using a general preprocessing technique
dataset_table_2 = dataset_table;

%% Preprocessing for filling the table

%Kurtogram filter, Envelope Analsysis and feature extraction
for i= 1:2349%height(dataset_table)
    signal = dataset_table_2.Signal{i};
    label = dataset_table_2.Label(i);

    if label == 2 
        xInner = signal;
        fsInner = 97656;
        tInner = (0:length(xInner)-1)/fsInner;
        [pEnvInner, fEnvInner, xEnvInner, tEnvInner] = envspectrum(xInner, fsInner);
        domf = fEnvInner(pEnvInner == max(pEnvInner));
        dataset_table_2.domfreq(i) = domf;
        dataset_table_2.kurtosis(i) = kurtosis(xInner);
    elseif label == 1 | label == 0
        xOuter = signal;
        fsOuter = 97656;
        tOuter = (0:length(xOuter)-1)/fsOuter;
        level = 9;
        [~, ~, ~, fc, ~, BW] = kurtogram(xOuter, fsOuter, level);
        
        % Calculate cutoff frequencies
        cutoff1 = max(fc - BW/2, 0); % Ensure lower cutoff is non-negative
        cutoff2 = min(fc + BW/2, (fsOuter / 2)); % Ensure upper cutoff does not exceed Nyquist frequency
        if (cutoff2<fsOuter/2)
            if ((cutoff1)>0)
            disp('bandpass')
            bpf = designfilt('bandpassfir', 'FilterOrder', 200, 'CutoffFrequency1', fc-BW/2, ...
                'CutoffFrequency2', fc+BW/2, 'SampleRate', fsOuter);
            elseif ((cutoff1)<=0)
            disp('highpass')
            bpf = designfilt('highpassiir', 'FilterOrder', 200, ...
                              'HalfPowerFrequency', fc+BW/2, ...
                              'SampleRate', fsOuter);
            end
            xOuterBpf = filter(bpf, xOuter);
            [pEnvOuterBpf, fEnvOuterBpf, xEnvOuterBpf, tEnvBpfOuter] = envspectrum(xOuter, fsOuter, ...
            'FilterOrder', 200, 'Band', [cutoff1 cutoff2]);
        else
            [pEnvOuterBpf, fEnvOuterBpf, xEnvOuterBpf, tEnvBpfOuter] = envspectrum(xOuter, fsOuter, ...
            'FilterOrder', 200);
        end
        domf =  fEnvOuterBpf(pEnvOuterBpf == max(pEnvOuterBpf));
        dataset_table_2.domfreq(i) = domf;
        dataset_table_2.kurtosis(i) = kurtosis(xOuterBpf);
    end
    disp(i)
end

%
%% Randomize the row order of the table for better distribution for training
num_rows = height(dataset_table_2); % Get the number of rows
random_indices = randperm(num_rows); % Generate random row indices
shuffled_table = dataset_table_2(random_indices, :); % Reorder the rows

%% Additional features for signals

dataset_table_3 = dataset_table_2;

for i=1:height(dataset_table_3)
    testSignal = dataset_table_3.Signal{i};

    % Crest Factor
    rms_value = rms(testSignal);
    peak_value = max(abs(testSignal));
    crest_factor = peak_value/rms_value;
    dataset_table_3.crest(i) = crest_factor;
end

%% Randomize the row order of the table for better distribution for training 3
%this was with a table adding crest factor to see if improved
%classification was achieved
num_rows = height(dataset_table_3); % Get the number of rows
random_indices = randperm(num_rows); % Generate random row indices
shuffled_table_2 = dataset_table_3(random_indices, :); % Reorder the rows