% LogMAP与MAXLogMAP的比较
% 交织器长度：4000
% 迭代次数：5
%

clear

% 参数设置
frame_size=4000;    % 帧长=交织器长度
interation_number=5;
ispunctured=0;      % 0 unpunctured, rate 1/3 ; 1 punctured, rate 1/2
decodermethod=1;    % 1 logMAP ; 2 Max-log-MAP

g=[1 0 1 1;1 1 0 1];  % 生成器向量，用于UMTS和LTE

[~,K] = size(g);
m = K - 1; 
L_info = frame_size;
L_total = L_info + m; 
rate=1/(3-ispunctured);      % rate
times=ceil(10^7/frame_size); % 总传输位需要大于10^7
Tx_times=[ceil(times/10),ceil(times/10),ceil(times/10),...
    ceil(times/10),ceil(times/10),times,times,times]; % 快速仿真
%Tx_times=[5 5 5 5 5 5 5 5]; % for test

[laststate,nextstate,lastoutputpar]=gen_trellis(g);    % 生成网格

EbN0_Vec=0.2:0.2:1.6;

errs=zeros(interation_number,length(EbN0_Vec)); % (interation_number,EbN0)
errsproLog=zeros(interation_number,length(EbN0_Vec));

for i=1:length(EbN0_Vec)
    fprintf('Hello %d\n',i)                    % 程序跟踪
    
    EbN0=EbN0_Vec(i);
    Lc=4*rate*10^(EbN0/10);                    % 信道可靠性系数
    sigma=1/sqrt(2*rate*10^(EbN0/10));         % AWGN噪声标准差

    for j=1:Tx_times(i)
        x=round(rand(1,frame_size));           % data sequence
        [~,alpha]=sort(rand(1,L_total));       % random interleaver
        y=encoder(x,g,alpha,ispunctured);      % turbo output
        n=sigma*randn(size(y));                % 噪声项
        r=y+n;                                 % receive signal
        soft_out=decoder(r,g,ispunctured,Lc,alpha,interation_number,decodermethod,laststate,nextstate,lastoutputpar);
        hard_decision=(sign(soft_out)+1)/2;
        for k=1:interation_number
            errs(k,i)=errs(k,i)+length(find(hard_decision(k,:)~=x));
        end
    end
end

for k=1:length(EbN0_Vec)
    errsproLog(:,k)=errs(:,k)/(Tx_times(k)*frame_size);
end

savefile='method_Log_eg.mat';
save(savefile,'EbN0_Vec','errsproLog')

figure
semilogy(EbN0_Vec,errsproLog(interation_number,:)','-bo')
%**************************************************************************
clock
