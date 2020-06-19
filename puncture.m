% Comparison of unpunctured & punctured
% interleaver size 1000
% 5 interations
% LogMAP
%

clear

load('interation_eg.mat')

figure
semilogy(EbN0_Vec,errspro(5,:)','-bo')  % unpunctured

clear

% parameters
frame_size=1000; % also interleaver size
interation_number=5;
ispunctured=1; % 0 unpunctured, rate 1/3 ; 1 punctured, rate 1/2
decodermethod=1; % 1 logMAP ; 2 Max-log-MAP

g=[1 0 1 1;1 1 0 1];  % generator vectors,using in UMTS and LTE

[~,K] = size(g);
m = K - 1;  % determine the memory
L_info = frame_size;
L_total = L_info + m; 
rate=1/(3-ispunctured); % rate
times=ceil(10^7/frame_size); % the total transmisson bits need to be larger than 10^7
Tx_times=[ceil(times/10),ceil(times/10),ceil(times/10),...
    ceil(times/10),ceil(times/10),times,times,times]; % fast simulation
%Tx_times=[5 5 5 5 5 5 5 5]; % for test

[laststate,nextstate,lastoutputpar]=gen_trellis(g); % generate trellis

EbN0_Vec=0.2:0.2:1.6;

errs=zeros(interation_number,length(EbN0_Vec)); % (interation_number,EbN0)
errspropun=zeros(interation_number,length(EbN0_Vec));

for i=1:length(EbN0_Vec)
    fprintf('Hello %d\n',i) % trace program
    
    EbN0=EbN0_Vec(i);
    Lc=4*rate*10^(EbN0/10); % channel reliability factor
    sigma=1/sqrt(2*rate*10^(EbN0/10)); % standard deviation of AWGN noise

    for j=1:Tx_times(i)
        x=round(rand(1,frame_size)); % data sequence
        [~,alpha]=sort(rand(1,L_total)); % random interleaver
        y=encoder(x,g,alpha,ispunctured); % turbo output
        n=sigma*randn(size(y)); % noise term
        r=y+n; % receive signal
        soft_out=decoder(r,g,ispunctured,Lc,alpha,interation_number,decodermethod,laststate,nextstate,lastoutputpar);
        hard_decision=(sign(soft_out)+1)/2;
        for k=1:interation_number
            errs(k,i)=errs(k,i)+length(find(hard_decision(k,:)~=x));
        end
    end
end

for k=1:length(EbN0_Vec)
    errspropun(:,k)=errs(:,k)/(Tx_times(k)*frame_size);
end

savefile='punctured_eg.mat';
save(savefile,'EbN0_Vec','errspropun')

hold on
semilogy(EbN0_Vec,errspropun(interation_number,:)','-gs')
xlabel('dB')
ylabel('BER')
legend('unpunctured','punctured')
title('Comparison of Unpunctured & Punctured')
%**************************************************************************
clock
