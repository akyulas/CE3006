%Define carrier frequency in Hz
Fc = 10000; 
%Given 16 times over-sampled Fs = Fc * 16
Fs = Fc * 16;
%Data rate 1kpbs
dataRate = 1000;
%Signal length
numOfBits = 1024;

%Define amp
amplitude = 1;

%low pass butter filter, 6th order with cut of freq of 0.2
[b, a] = butter(6, 0.2);

%sampling time
time = 1/(2 * Fs): 1/Fs: numOfBits/dataRate;

%carrier
carrier = cos(2 * pi * Fc * time);

%input
input = randi([0, 1], [1, 1024]);

%sampling rate is larger than data rate
%need to extend 1s and 0s by the ratio of the sampling rate and the data
%rate
extension_vector = ones(1, Fs/dataRate);
sampled_input = kron(input, extension_vector);

sampled_ook = sampled_input .* carrier;

SNR = 5;

noise_variance = 1 / 10^(SNR/10);
noise_std = sqrt(noise_variance);
noise = noise_std .* randn(1, 1024 * Fs/dataRate);
received_signal = sampled_ook + noise;
demodulated_signal = received_signal .* (2 * carrier);
filtered_signal = filtfilt(b, a, demodulated_signal);
decoded_signal = zeros(1,1024);
for i = 1:1:1024
    interested_signal = filtered_signal(1 /2 * Fs/dataRate + (i - 1) * Fs/dataRate);
    if interested_signal > 0.5
        decoded_signal(i) = 1;
    else
        decoded_signal(i) = 0;
    end
end

figure;

ts1 = timeseries(sampled_input,time);
ts1.Name = 'Data waveform';
subplot(5, 1, 1);
plot(ts1);

ts2 = timeseries(sampled_ook,time);
ts2.Name = 'Modulated Signal';
subplot(5, 1, 2);
plot(ts2);

ts3 = timeseries(received_signal,time);
ts3.Name = 'Received Signal';
subplot(5, 1, 3);
plot(ts3);

ts4 = timeseries(demodulated_signal,time);
ts4.Name = 'Demodulated signal';
subplot(5, 1, 4);
plot(ts4);

decoded_output = kron(decoded_signal, extension_vector);
ts5 = timeseries(decoded_output,time);
ts5.Name = 'Decoded signal';
subplot(5, 1, 5);
plot(ts5);
