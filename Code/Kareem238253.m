clc; clear; close all;

% ================================================
%        Digital Communications (1) Project
%    Adaptive PCM Audio Transmission System
% ================================================

disp('   Digital Communications (1) Project');
disp('              Supervised By:');
disp('        Dr. Mohammad Abdellatif');
disp('          TA: Mohamed Tameem');
disp('              Prepared By:');
disp('          Kareem Mohammed 238253');
disp('================================================');
disp('   Adaptive PCM Audio Transmission System        ');
disp('================================================');

%% 1. System Inputs
default_file = 'recording.wav'; 
audio_filename = input(['Enter Audio file name (Default: ' default_file '): '], 's');
if isempty(audio_filename)
    audio_filename = default_file;
end

% Input Parameters
BW_kHz = input('Enter Available Transmission BW (in kHz) [Ex: 100]: ');
SNR_dB = input('Enter Channel SNR (in dB) [Ex: 20]: ');
A_val  = input('Enter A-law Parameter A [Standard is 87.6]: ');

% Defaults if user presses Enter
if isempty(BW_kHz), BW_kHz = 100; end
if isempty(SNR_dB), SNR_dB = 20; end
if isempty(A_val), A_val = 87.6; end

% Read Audio File
try
    [x, fs] = audioread(audio_filename);
catch
    error('File not found! Make sure the .wav file is in the same folder.');
end
x = x(:); 

% Convert Stereo to Mono
if size(x, 2) > 1
    x = mean(x, 2);
    disp('-> Converted Stereo audio to Mono.');
end

% Normalize Signal (Critical for correct A-law operation)
x = x / max(abs(x));

%% 2. Adaptation Logic (Smart Block)
BW_Hz = BW_kHz * 1000;

% Calculate Max Bit Depth (l) to fit in Bandwidth
% Rb <= 2*BW  --> l*fs <= 2*BW --> l <= 2*BW/fs
l = floor((2 * BW_Hz) / fs); 

if l < 1
    error('Bandwidth is too low for this sampling rate!');
end

Rb = l * fs;      % Transmission Rate
L = 2^l;          % Number of Quantization Levels

fprintf('\n--- System Adaptation Parameters ---\n');
fprintf('Sampling Freq (fs) : %d Hz\n', fs);
fprintf('Available BW       : %d Hz\n', BW_Hz);
fprintf('Adaptive Bits (l)  : %d bits/sample\n', l);
fprintf('Transmission Rate  : %d bps\n', Rb);
fprintf('------------------------------------\n');

%% 3. Transmitter (Tx)
disp('-> Processing Transmitter...');

% A-law Compressor
K = 1 + log(A_val);
x_comp = sign(x) .* log(1 + A_val * abs(x)) / K;

% Uniform Quantizer
partition = linspace(-1, 1, L+1); 
codebook = linspace(-1, 1, L); 
partition = partition(2:end-1); 
[index, x_quant] = quantiz(x_comp, partition, codebook);

% Force column vectors
x_comp = x_comp(:);
x_quant = x_quant(:);

% Binary Encoder (Decimal to Binary)
bits_matrix = dec2bin(index, l);
tx_bits = reshape(bits_matrix', [], 1) - '0';

% Pulse Modulation (Polar NRZ: 0->-1V, 1->+1V)
signal_tx = 2 * tx_bits - 1;

%% 4. AWGN Channel
disp('-> Transmitting over AWGN Channel...');
rx_signal_noisy = awgn(signal_tx, SNR_dB, 'measured');

%% 5. Receiver (Rx)
disp('-> Processing Receiver...');

% Pulse Detection with Adaptive Threshold
adaptive_threshold = mean(rx_signal_noisy); % Adapts to DC offset
rx_bits_detected = rx_signal_noisy > adaptive_threshold; 

% Binary Decoder (Binary to Decimal)
rx_bits_matrix = reshape(rx_bits_detected, l, [])';
weights = 2.^(l-1:-1:0);
rx_indices = rx_bits_matrix * weights';
rx_indices = rx_indices + 1; % Adjust 0-based to 1-based index
rx_indices = max(1, min(L, rx_indices)); % Safety clipping

% Map back to quantized voltage levels
x_quant_rx = codebook(rx_indices);
x_quant_rx = x_quant_rx(:); 

% A-law Expander (Inverse Operation)
abs_val = (exp(abs(x_quant_rx) * K) - 1) / A_val;
x_out = sign(x_quant_rx) .* abs_val;
x_out = x_out(:); 

%% 6. Metrics Calculation
disp('-> Calculating Metrics...');

% A. Bandwidth Efficiency
BW_Efficiency = Rb / BW_Hz;

% B. Bandwidth Utilization % (Efficiency relative to Nyquist Limit)
% Max theoretical efficiency is 2 bps/Hz (Nyquist)
BW_Utilization_Percent = (BW_Efficiency / 2) * 100;

% C. SQNR
q_noise = x_comp - x_quant; 
SQNR_val = mean(x_comp.^2) / mean(q_noise.^2);
SQNR_dB_val = 10 * log10(SQNR_val);

% D. NMSE (Normalized Mean Squared Error)
len = min(length(x), length(x_out));
x_ref = x(1:len);
x_rec = x_out(1:len);

numerator = sum((x_ref - x_rec).^2);
denominator = sum(x_ref.^2);
NMSE = numerator / denominator;

% E. Audio Quality Score (Based on SQNR)
Target_SQNR = 50; 
Audio_Quality_Percent = (SQNR_dB_val / Target_SQNR) * 100;
Audio_Quality_Percent = max(0, min(100, Audio_Quality_Percent));

%% 7. Final Results Display
fprintf('\n========================================\n');
fprintf('       >_< FINAL RESULTS REPORT >_<       \n');
fprintf('========================================\n');
fprintf('1. Bit Resolution (l)   : %d bits\n', l);
fprintf('2. Transmission Rate    : %.2f kbps\n', Rb/1000);
fprintf('3. BW Efficiency        : %.2f bps/Hz\n', BW_Efficiency);
fprintf('   > BW Utilization     : %.2f %%\n', BW_Utilization_Percent);
fprintf('4. SQNR                 : %.2f dB\n', SQNR_dB_val);
fprintf('5. NMSE                 : %.6f\n', NMSE);
fprintf('6. Audio Quality        : %.2f %% (Based on SQNR)\n', Audio_Quality_Percent);
fprintf('========================================\n');

%% 8. Visualization (Plots)
t = (0:len-1)/fs;

figure('Name', 'Adaptive PCM Project Results', 'Color', 'w');

% Subplot 1: Audio Signals Comparison
subplot(3,1,1);
plot(t, x_ref, 'b', 'LineWidth', 1); hold on;
plot(t, x_rec, 'r--', 'LineWidth', 1); 
legend('Original Transmitted', 'Received Reconstructed');
title(['Audio Signal Comparison (SNR=' num2str(SNR_dB) 'dB, l=' num2str(l) ' bits)']);
xlabel('Time (s)'); ylabel('Amplitude'); grid on;

% Subplot 2: Digital Pulses
subplot(3,1,2);
num_bits_show = min(100, length(signal_tx));
stairs(signal_tx(1:num_bits_show), 'LineWidth', 1.5);
title('Transmitted Digital Pulses (First 100 bits)');
xlabel('Bit Index'); ylabel('Voltage (V)'); grid on;
ylim([-1.5 1.5]);

% Subplot 3: Error Signal
subplot(3,1,3);
plot(t, x_ref - x_rec, 'k');
title('Error Signal (Difference)');
xlabel('Time (s)'); ylabel('Error Amplitude'); grid on;

% Play Audio
disp('Playing Received Audio...');
sound(x_out, fs);
disp('Done.');

output_filename = sprintf('Received_Audio_%dbits_SNR%d.wav', l, SNR_dB);
x_to_save = x_out / max(abs(x_out)); 
audiowrite(output_filename, x_to_save, fs);
fprintf('\n-> Success! Received audio saved as: %s\n', output_filename);