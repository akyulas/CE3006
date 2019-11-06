%Define carrier frequency in Hz
Fc = 10000; 
%Given 16 times over-sampled Fs = Fc * 16
Fs = Fc * 16;
%Data rate 1kpbs
dataRate = 1000;
%Signal length
numOfBits = 1024;
actualNumberOfBits = 1024 * 7 / 4;

%Define amp
amplitude = 1;

%low pass butter filter, 6th order with cut of freq of 0.2
[b, a] = butter(6, 0.2);

%sampling time
time = 1/(2 * Fs): 1/Fs: actualNumberOfBits/dataRate;

%carrier
carrier = cos(2 * pi * Fc * time);

%input
input = randi([0, 1], [1, 1024]);

%sampling rate is larger than data rate
%need to extend 1s and 0s by the ratio of the sampling rate and the data
%rate
extension_vector = ones(1, Fs/dataRate);
sampled_input = encode(input, 7, 4, 'hamming/fmt');
sampled_input = kron(sampled_input, extension_vector);

sampled_BPSK = (2 * sampled_input -1) .* carrier;

SNRAxis = zeros(1,11);
AverageEncodedOutput = zeros(1,11);

for runs = 1:20
    bitErrorRateOutput = zeros(1,11);
    counter=1;
    for SNR = 0:5:50
        SNRAxis(counter) = SNR;
        noise_variance = 1 / 10^(SNR/10);
        noise_std = sqrt(noise_variance);
        noise = noise_std .* randn(1, 1024 * Fs/dataRate * 7 / 4);
        received_signal = sampled_BPSK + noise;
        demodulated_signal = received_signal .* (2 * carrier);
        filtered_signal = filtfilt(b, a, demodulated_signal);
        decoded_signal = zeros(1,actualNumberOfBits);
        for i = 1:1:actualNumberOfBits
            interested_signal = filtered_signal(1 /2 * Fs/dataRate + (i - 1) * Fs/dataRate);
            if interested_signal > 0
                decoded_signal(i) = 1;
            else
                decoded_signal(i) = 0;        
            end
        end
        decoded_signal = decode(decoded_signal,7,4,'hamming/fmt');
        bitErrorRate = calculate_error_rate(decoded_signal, input);
        bitErrorRateOutput(counter)=bitErrorRate;
        AverageEncodedOutput(counter) = AverageEncodedOutput(counter) + bitErrorRateOutput(counter);
        counter = counter +1;
    end
end

AverageEncodedOutput = AverageEncodedOutput ./ 20;
semilogy(SNRAxis, AverageEncodedOutput);
axis([0 50 -1 1]);
hold on;
% semilogy(SNRAxis, bitErrorRateOutput);
% axis([0 50 -1 1]);
% hold on;

clear all;
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

sampled_BPSK = (2* sampled_input -1) .* carrier;

SNRAxis = zeros(1,11);
AverageNonEncdoded = zeros(1,11);

for runs = 1:20
    bitErrorRateOutput = zeros(1,11);
    counter=1;
    for SNR = 0:5:50
        SNRAxis(counter) = SNR;
        noise_variance = 1 / 10^(SNR/10);
        noise_std = sqrt(noise_variance);
        noise = noise_std .* randn(1, 1024 * Fs/dataRate);
        received_signal = sampled_BPSK + noise;
        demodulated_signal = received_signal .* (2 * carrier);
        filtered_signal = filtfilt(b, a, demodulated_signal);
        decoded_signal = zeros(1,1024);
        for i = 1:1:1024
            interested_signal = filtered_signal(1 /2 * Fs/dataRate + (i - 1) * Fs/dataRate);
            if interested_signal > 0
                decoded_signal(i) = 1;
            else
                decoded_signal(i) = 0;        
            end
        end
        bitErrorRate = calculate_error_rate(decoded_signal, input);
        bitErrorRateOutput(counter)=bitErrorRate;
        AverageNonEncdoded(counter) = AverageNonEncdoded(counter) + bitErrorRateOutput(counter);
        counter = counter +1;
    end
end

AverageNonEncdoded = AverageNonEncdoded ./ 20;


semilogy(SNRAxis, AverageNonEncdoded);
axis([0 50 -1 1]);
hold on;
% semilogy(SNRAxis, bitErrorRateOutput);
% axis([0 50 -1 1])
title('Plot of Bit Error vs SNR for Encoded vs Non-Encoded Signals');
xlabel('Signal to Noise Ratio') ;
ylabel('Log 10 Bit Error Rate') ;
legend({'y = Encoded','y = Non-Encoded'},'Location','southeast')




function bitErrorRate = calculate_error_rate(input, tempInput)
    %Generate noise having normal distribution with zero mean
    error = 0;
    numOfBits= 1024;
    for i = 1:1:numOfBits
        if input(i) ~= tempInput(i)
            error = error + 1;
        end
    end
    bitErrorRate = error/numOfBits;
end