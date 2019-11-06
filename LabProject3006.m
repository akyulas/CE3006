%Generate 0 and 1 bit where N = 1024
NumOfBits = 1024;
input = randi([0, 1], [1, NumOfBits]);
tempInput = input;
%Convert binary digits to +1 and -1
input(input==0) = [-1];
bitErrorRateOutput = zeros(1,11)
counter=1;
SNRAxis = zeros(1,11);

for i = 0:5:50
    SNRAxis(counter) = i;
    bitErrorRate = calculate_error_rate(input, tempInput, i);
    bitErrorRateOutput(counter)=bitErrorRate;
    counter = counter +1;
end
semilogy(SNRAxis, bitErrorRateOutput);
axis([0 50 -1 1])
title("Plot of Bit Error Rate vs Signal to Noise Ratio");
xlabel('E_{b}/N_{0}') ;
ylabel('P_{e}') ;

function bitErrorRate = calculate_error_rate(input, tempInput, SNR)
    %Generate noise having normal distribution with zero mean 
    b = 0; %mean
    NumOfBits = 1024;
    threshold = 0;
    NoiseVariance = 1/ 10^(SNR/10);
    NoiseSTD = sqrt(NoiseVariance); %SD
    noise = NoiseSTD.*randn(1,1024) + b;
    %stats = [mean(noise) std(noise) var(noise)];

    %Add noise sample with input data
    output = input + noise; 

    %Fix the threshold value as 0 (the transmitted data is +1 and -1, and 0 is
    %the mid value. if >=0, 1 else 0.
    output(output>=0) = [1];
    output(output<0) = [0];

    %Compute p(e) 
    bitError = 0
    for i=1 : length(output)
        if (tempInput(i) > threshold && output(i) == 0) || (tempInput(i) <= threshold && output(i) == 1)
            bitError = bitError + 1;
        end
    %bitError = biterr(tempInput,output);
    bitErrorRate= bitError/NumOfBits;
    end
end





