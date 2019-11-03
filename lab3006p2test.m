%define carrier frequency
Fc = 10000; %10kHz
%Assume carrier signal is 16 times oversampled
%define sampling frequency
Fs = 16 * Fc;
%define data rate
dataRate = 1000; %10kbps
%Define Signal length
Num_Bit = 1024;
%define num bit after encoding
Enc_Num_Bit = 1792;
%Define Amplitude
Amplitude = 5;

%low pass butterworth filter
%6th order, 0.2 cutoff frequency
[b, a] = butter(6, 0.2);

%high pass butterworth filter
[d, c] = butter(6, 0.2, 'high');

%time
t = 0: 1/Fs : Enc_Num_Bit/dataRate;

%Carrier
Carrier = Amplitude .* cos(2*pi*Fc*t);

%signal length
SignalLength = Fs*Enc_Num_Bit/dataRate + 1;

%SNR_dB = 10 log (Signal_Power/Noise_Power)                 
SNR_dB = 0:1:20;
%==> SNR = Signal_Power/Noise_Power = 10^(SNR_dB/10)
SNR = (10.^(SNR_dB/10));

% Set run times
Total_Run = 20;

Error_RateOOK = zeros(length(SNR));

%Different SNR value
for i = 1 : length(SNR)
	Avg_ErrorOOK = 0;
    
    
	for j = 1 : Total_Run
        %Generate Data
        Data = round(rand(1,Num_Bit));
        %encode
        EncodeHamming= encode(Data,7,4,'hamming/fmt');

        ContinuousData = zeros(1, SignalLength);
        for k = 1: SignalLength - 1
            ContinuousData(k) = EncodeHamming(ceil(k*dataRate/Fs));
        end
        ContinuousData(SignalLength) = ContinuousData(SignalLength - 1);

        %on-off keying
        SignalOOK = Carrier .* ContinuousData;

    
        Signal_Power_OOK = (norm(SignalOOK)^2)/SignalLength;
        
        %Generate Noise OOK
		Noise_Power_OOK = Signal_Power_OOK ./SNR(i);
		NoiseOOK = sqrt(Noise_Power_OOK/2) .*randn(1,SignalLength);
		%Received Signal OOK
		ReceiveOOK = SignalOOK+NoiseOOK;
        
        %OOK detection
        SquaredOOK = ReceiveOOK .* ReceiveOOK;
        %low pass filter
        FilteredOOK = filtfilt(b, a, SquaredOOK);
        
        %demodulate
        %sampling AND threshold
        samplingPeriod = Fs / dataRate;
        [sampledOOK, resultOOK] = sample_and_threshold(FilteredOOK, samplingPeriod, Amplitude/2, Enc_Num_Bit);
        
		%Calculate the average error for every runtime
		%Avg_ErrorOOK = num_error(resultOOK, EncodeHamming, Num_Bit) + Avg_ErrorOOK;                   
        %Avg_ErrorBPSK = num_error(resultBPSK, EncodeHamming, Num_Bit) + Avg_ErrorBPSK;
        
        decodedOOK = decode(resultOOK,7,4,'hamming/fmt');
        
        ErrorOOK = 0;
        for k = 1: Num_Bit - 1
            if(decodedOOK(k) ~= Data(k))
                ErrorOOK = ErrorOOK + 1;
            end
        end
        Avg_ErrorOOK = ErrorOOK + Avg_ErrorOOK;
    
	end
	Error_RateOOK(i) = Avg_ErrorOOK / Total_Run;
end

figure(1)
semilogy (SNR_dB,Error_RateOOK,'k-*');
hold on
ylabel('Pe');
xlabel('Eb/No')


figure(2)
title('Received Signal OOK');
plot(ReceiveOOK, 'k')

figure(3)
title('Squared OOK');
plot(SquaredOOK, 'k');

figure(4)
title('Filtered Signal OOK');
plot(FilteredOOK, 'k');

figure(5)
title('Captured Data');
plot(sampledOOK);
function [sampled, result] = sample_and_threshold(x, sampling_period, threshold, num_bit)
    sampled = zeros(1, num_bit);
    result = sampled;
    for n = 1: num_bit
        sampled(n) = x((2 * n - 1) * sampling_period / 2);
        if(sampled(n) > threshold)
            result(n) = 1;
        else
            result(n) = 0;
        end
    end
end
function error = num_error(a, b, n)
    error = 0;
    for i=1: n
        if(a(i) ~= b(i))
            error = error + 1;
        end
    end
    error = error ./ n;
end
