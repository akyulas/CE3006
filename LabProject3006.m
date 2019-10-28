%Seed creation
% rng();
% s=rng;
% 
% rng(s);

%Generate 0 and 1 bit where N = 1024
NumOfBits = 1024;
input = randi([0, 1], [1, 1024]);
tempInput = input;
%Convert binary digits to +1 and -! 
input(input==0) = [-1];
bitErrorRateOutput = zeros(1,11)
counter=1;
SNRAxis = zeros(1,11);
for i = 0:5:50
    SNRAxis(counter) = i;
    bitErrorRate = calculate_error_rate(input, tempInput, i)
    bitErrorRateOutput(counter)=bitErrorRate;
    counter = counter +1;
end
plot(SNRAxis, bitErrorRateOutput);
function bitErrorRate = calculate_error_rate(input, tempInput, SNR)
    %Generate noise having normal distribution with zero mean 
    b = 0; %mean
    NumOfBits = 1023;

    NoiseVariance = 1/ power(10,SNR/10);
    NoiseSTD = sqrt(NoiseVariance); %SD
    noise = NoiseSTD.*randn(1,1024) + b;
    stats = [mean(noise) std(noise) var(noise)];

    %Add noise sample with input data
    output = input + noise; 

    %Fix the threshold value as 0 (the transmitted data is +1 and -1, and 0 is
    %the mid value. if >=0, 1 else 0.
    output(output>=0) = [1];
    output(output<0) = [0];

    %Compute p(e) 
    bitError = biterr(tempInput,output);
    bitErrorRate= bitError/NumOfBits;
end





