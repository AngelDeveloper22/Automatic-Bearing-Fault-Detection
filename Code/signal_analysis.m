%Project for diagnostics and testing
%This code is to analyze raw data from signals

%% Baseline data
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

%%  Analysis for inner fault

%Supressing Offset and normalizing signal
BPFI = 118; %Inner fault frequency
signal = inner_1.bearing.gs;
fs = inner_1.bearing.sr;
signal = (signal - mean(signal))/std(signal);
signal = signal(1*(0.5*fs):2*(0.5*fs));

%using a high pass filter to get rid off the operating frequency in case
%it has too high amplitude
fc = 40;
hpFilter = designfilt('highpassiir', 'FilterOrder', 8, ...
                      'HalfPowerFrequency', fc, ...
                      'SampleRate', fs);
filtered_signal = filtfilt(hpFilter, signal);
signal = filtered_signal;
%
%preparing signal for time domain plot
xInner = signal;
fsInner = inner_1.bearing.sr;
tInner = (0:length(xInner)-1)/fsInner;
figure
plot(tInner, xInner)
xlabel('Time, (s)')
ylabel('Acceleration (g)')
title('Raw Signal: Inner Race Fault')
xlim([0 1])
grid on;

%Visualizing data in frequency domain
figure
[pInner, fpInner] = pspectrum(xInner, fsInner);
pInner = 10*log10(pInner);
plot(fpInner, pInner)
xlabel('Frequency (Hz)')
ylabel('Power Spectrum (dB)')
title('Raw Signal: Inner Race Fault')
legend('Power Spectrum')
grid on

%zooming to check the frequency BPFI
n_harmonics = 10;
harmonics = (1:n_harmonics) * BPFI; %harmonics for plot
figure
plot(fpInner, pInner)
ncomb = 10;
%helperPlotCombs(ncomb, BPFI)
xlabel('Frequency (Hz)')
ylabel('Power Spectrum (dB)')
title('Raw Signal: Inner Race Fault')
legend('Power Spectrum', 'BPFI Harmonics')
xlim([0 1000])
grid on;
hold on;
% Add dashed lines for the harmonics
for i = 1:length(harmonics)
    xline(harmonics(i), '--r', 'LineWidth', 1); % Dashed red line
end
hold off;

%Envelope of the signal
[pEnvInner, fEnvInner, xEnvInner, tEnvInner] = envspectrum(xInner, fsInner);
%plotting the envelope signal with harmonics
figure
plot(fEnvInner, pEnvInner)
xlim([0 1000])
xlabel('Frequency (Hz)')
ylabel('Peak Amplitude')
title('Envelope Spectrum: Inner Race Fault')
%legend('Envelope Spectrum', 'BPFI Harmonics')
grid on;
hold on;
% Add dashed lines for the harmonics
for i = 1:length(harmonics)
    xline(harmonics(i), '--r', 'LineWidth', 1); % Dashed red line
end
hold off;
%}

%
%% Analysis for outer fault
BPFO = 81.12; %outer fault frequency
xOuter = outer_1.bearing.gs;
fsOuter = outer_1.bearing.sr;
tOuter = (0:length(xOuter)-1)/fsOuter;

%outer race envelope spectrum
[pEnvOuter, fEnvOuter, xEnvOuter, tEnvOuter] = envspectrum(xOuter, fsOuter);

%Kurtogram and spectral kurtosis & bandpass filter
level = 9;
[~, ~, ~, fc, ~, BW] = kurtogram(xOuter, fsOuter, level)
kurtogram(xOuter, fsOuter, level)

if ((fc-BW/2)>0)
    disp('band Pass filter')
    bpf = designfilt('bandpassfir', 'FilterOrder', 200, 'CutoffFrequency1', fc-BW/2, ...
        'CutoffFrequency2', fc+BW/2, 'SampleRate', fsOuter);
else
    disp('High Pass filter')
    bpf = designfilt('highpassiir', 'FilterOrder', 200, ...
                      'HalfPowerFrequency', fc+BW/2, ...
                      'SampleRate', fsOuter);
end
xOuterBpf = filter(bpf, xOuter);
[pEnvOuterBpf, fEnvOuterBpf, xEnvOuterBpf, tEnvBpfOuter] = envspectrum(xOuter, fsOuter, ...
    'FilterOrder', 200, 'Band', [fc-BW/2 fc+BW/2]);


figure
subplot(2, 1, 1)
kurtOuter = kurtosis(xOuter);
plot(tOuter, xOuter, tEnvOuter, xEnvOuter)
ylabel('Amplitude')
title(['Raw Signal: Outer Race Fault, kurtosis = ', num2str(kurtOuter)])
xlim([0 0.1])
legend('Signal', 'Envelope')

subplot(2, 1, 2)
kurtOuterBpf = kurtosis(xOuterBpf);
plot(tOuter, xOuterBpf, tEnvBpfOuter, xEnvOuterBpf)
ylabel('Amplitude')
xlim([0 0.1])
xlabel('Time (s)')
title(['Bandpass Filtered Signal: Outer Race Fault, kurtosis = ', num2str(kurtOuterBpf)])
legend('Signal', 'Envelope')

%Seeing the envelope spectrum after kurtosis bandpass filter applied
harmonics_o = (1:n_harmonics) * BPFO;
figure
plot(fEnvOuterBpf, pEnvOuterBpf);
xlim([0 1000])
xlabel('Frequency (Hz)')
ylabel('Peak Amplitude')
title('Envelope Spectrum of Bandpass Filtered Signal: Outer Race Fault ')
%legend('Envelope Spectrum', 'BPFO Harmonics')
grid on;
hold on;
% Add dashed lines for the harmonics
for i = 1:length(harmonics_o)
    xline(harmonics_o(i), '--r', 'LineWidth', 1); % Dashed red line
end
hold off;
%}
