function soft_out=decoder(r,g,ispunctured,Lc,alpha,iterate_num,algorithm,lstate,nstate,lparoutput)
%turbo decoder
%仅应用于 g=[1 0 1 1;1 1 0 1].否则应修改网格
%Input:
% r            --收到的序列，向量
% g            --生成矩阵
% ispunctured  --0 unpunctured,rate 1/3 ; 1 punctured,  rate 1/2
% Lc           --信道可靠性系数 
% alpha        --随机交织器
% iterate_num  --迭代次数
% algorithm    --1 log-map
%              --2 max-log-map
% lstate       --last state
% nstate       --next state
% lparoutput   --上一个奇偶校验输出
%


[~,K]=size(g); 
m=K - 1; 
n=3-ispunctured;
L_total=length(r)/n;
L_info=L_total-m;     % 数据序列长度

if(ispunctured) % punctured
    in1(2,:)=zeros(1,L_total);
    in2(2,:)=zeros(1,L_total);
    % data to decoder1
    in1(1,:)=r(1:n:end);
    in1(2,1:2:end)=r(2:2*n:end);
    
    % data to decoder1
    in2(1,:)=in1(1,alpha);
    in2(2,2:2:end)=r(4:2*n:end);
else % unpunctured
    % data to decoder1
    in1(1,:)=r(1:3:end);
    in1(2,:)=r(2:3:end);

    % data to decoder2
    in2(1,:)=in1(1,alpha); %interleave
    in2(2,:)=r(3:3:end);
end

e_info=zeros(1,L_total);                  % 外部信息
die_info=zeros(1,L_total);                % 解交织或交织外部信息
soft_out_t=zeros(size(alpha));            
soft_out=zeros(iterate_num,L_info);      
for it=1:iterate_num
    die_info(alpha)=e_info;                % 解交织外部信息
    switch algorithm
        case 1
            [~,e_info]=algorithm_logmap(in1,g,Lc,die_info,lstate,nstate,lparoutput);
        case 2
            [~,e_info]=algorithm_maxlogmap(in1,g,Lc,die_info,lstate,nstate,lparoutput);
    end
    die_info=e_info(alpha);               % 交织外部信息
    switch algorithm
        case 1
            [so,e_info]=algorithm_logmap(in2,g,Lc,die_info,lstate,nstate,lparoutput);
        case 2
            [so,e_info]=algorithm_maxlogmap(in2,g,Lc,die_info,lstate,nstate,lparoutput);
    end
    soft_out_t(alpha)=so;
    soft_out(it,:)=soft_out_t(1:L_info);   % 软输出
end
