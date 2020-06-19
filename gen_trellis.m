function [lstate,nstate,lparoutput]=gen_trellis(g)

[~,K] = size(g);
m = K - 1;              % 寄存器数量
nstate=zeros(2,2^m);    % 预先分配速度
lstate=zeros(2,2^m); 
lparoutput=zeros(2,2^m); 
for i=1:2^m
    state_temp=de2bi(i-1,m); % 十进制转二进制
    
    %input 0
    state=fliplr(state_temp); % state, corresponding to decimal value  1,2,...,2^m
    in=xor(rem(g(1,2:end)*state',2),0); % input 0
    paroutput=rem(g(2,:)*[in state]',2);
    state=[in,state(1:m-1)];
    nstate_index=bi2de(fliplr(state))+1;      % 二进制转换成十进制
    nstate(1,i)=nstate_index;                 % 下一个状态
    lparoutput(1,nstate_index)=2*paroutput-1; % 上一个奇偶校验输出
    lstate(1,nstate_index)=i;                 % 上一个状态
    
    %input 1
    state=fliplr(state_temp);
    in=xor(rem(g(1,2:end)*state',2),1);
    paroutput=rem(g(2,:)*[in state]',2);
    state=[in,state(1:m-1)];
    nstate_index=bi2de(fliplr(state))+1;
    nstate(2,i)=nstate_index; 
    lparoutput(2,nstate_index)=2*paroutput-1;
    lstate(2,nstate_index)=i; 
end