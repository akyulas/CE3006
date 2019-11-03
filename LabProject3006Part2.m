%Define carrier frequency in Hz
Fc = 10000; 
%Given 16 times over-sampled Fs = Fc * 16
Fs = Fc * 16;
%Data rate 1kpbs
dataRate = 1000;
%Signal length
numOfBits = 1024;

%total numbers of bits after encoding 
eBits = 1792;
%Define amp
amplitude = 5;

%low pass butter filter, 6th order with cut of freq of 0.2
[b, a] = butter(6, 0.2);

%sampling time
time = 0: 1/Fs: eBits/dataRate;

%carrier
carrier = amplitude .*cos(2*pi*Fc*time);

%signal length = no of times samples
numOfSamples = Fs* eBits/dataRate;

SNR_DB = 0: 5 : 50;
SNR = power(10, SNR_DB/10);

errorRateOOk = zeros(length(SNR));

%obtain different SNR values
for i = 0:5:50 
    
    %generate data
    input = randi([0, 1], [1, 1024]);
    %encode 
    encodeHamming = encode(input, 7, 4, 'hamming/fmt');
    continueData = zeros(1, numOfSamples);
    
    for k = 1: numOfSamples -1
        continueData(k) = encodeHamming(ceil(k*dataRate/Fs));
    end
   
    
    %on-off keying 
    signalOOK = carrier .* continueData;
    signalPowerOOK = (norm(signalOOK)^2)/numOfSamples;
    
    %Generate noise OOK
    noisePowerOOK = signalPowerOOK ./SNR(i);
    noiseOOK = sqrt(noisePowerOOK/2) .* randn(1,numOfSamples);
    
    %Received Signal OOK
    receiveSignalOOK = signalOOK + noiseOOK;
    
    %OOK detection
    squaredOOK = receivedSignalOOK .* receivedSignalOOK;
    
    %Low pass filter
    filteredOOK = filtfilt(b,a,squaredOOK);
    sampledPeriod = Fs/dataRate;
    [sampledOOK, resultOOK] = sample_and_threshold(FilteredOOK, samplingPeriod, Amplitude/2, Enc_Num_Bit);
   
    decodedOOK = decode(resultOOK,7,4,'hamming/fmt');
    errorOOK = 0;
    
    for k = 1: numOfSamples-1
        if(decodedOOK(k) ~= input(k))
            ErrorOOK = ErrorOOK +1 ;
        end
    end
    
    
    
    
    
    
    
end

figure(1)
semilogy(SNR_DB,errorRateOOK,'k-*');
ylabel('Pe');
xlabel('Eb/No');



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





