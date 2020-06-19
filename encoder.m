function en_output = encoder( x, g, alpha, ispuncture )
%Turbo encoder (2,1,K)RSC
%Random interleaver
%Input:
% x           --输入的数据序列
% alpha       --随机交织器
% ispuncture  --1 punctured,  rate 1/2 output
%             --0 unpunctured,rate 1/3 output
% 多路复用器从RSC1中选择奇数校验位，从RSC2中选择偶数校验位
% 确定约束长度(K)、寄存器数目(m)和信息位加尾位的数量
% g:生成多项式

[~,K] = size(g);
m = K - 1;  
L_info = length(x);
L_total = L_info + m;  

% 生成对应于RSC编码器1的码字
% 完全终止
output1 = zeros(1,L_total);
input = [x zeros(1,m)];
state1 = zeros(1,m);
for i=1:L_info
    in1 = xor(rem(g(1,2:end)*state1',2),input(i)); %mode 2 plus
    output1(i) = rem(g(2,:)*[in1 state1]',2);
    state1 = [in1,state1(1:m-1)];
end
for i=L_info+1:L_total                     % 终止网格
    input(i) = rem(g(1,2:end)*state1',2);
    output1(i) = rem(g(2,:)*[0 state1]',2);
    state1 = [0,state1(1:m-1)];
end

% 交织输入到RSC编码器2
input2 = input(alpha);
 
% 生成对应于RSC编码器2的码字
% 未终止
output2 = zeros(1,L_total); 
state2 = zeros(1,m);
for i=1:L_total
    in2 = xor(rem(g(1,2:end)*state2',2),input2(i)); % mode 2 plus
    output2(i) = rem(g(2,:)*[in2 state2]',2);
    state2 = [in2,state2(1:m-1)];
end

%puncture or not
% 并行转串行多路复用以获得输出矢量
if ispuncture ==0		     % 未穿孔，rate=1/3
    output_t = zeros(1,3*L_total); 
    for i = 1:L_total
        output_t(3*(i-1)+1) = input(i);
        output_t(3*(i-1)+2) = output1(i);
        output_t(3*(i-1)+3) = output2(i);
    end
else		                 % 穿孔, rate=1/2
    output_t = zeros(1,2*L_total); 
    for i=1:L_total
        output_t(2*(i-1)+1) = input(i);
        if rem(i,2)           %来自第一个RSC的奇数校验位
            output_t(2*(i-1)+2) = output1(i);
        else                  %来自第二个RSC的偶数校验位
            output_t(2*(i-1)+2) = output2(i);
        end
    end
end

% en_output=output_t; %for test
 
 % 反极性调制：+1/-1
en_output = 2*output_t-ones(size(output_t));
