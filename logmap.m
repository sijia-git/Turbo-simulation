function [soft_out,ex_info]=logmap(in,g,Lc,pri_info,lstate,nstate,lparoutput)
%turbo decoder -logMAP algorithm
%Input:
% in           --2 by N matrix.
%              --row1 information bits,including terminating bits
%              --row2 parity bits
% g            --generator vectors
% Lc           --channel reliability factor 
% pri_info     --priori information. not including terminating bits
% lstate       --last state
% nstate       --next state
% lparoutput   --last parity output
%Output:
% soft_out     --soft output,not including termianting bits
% ex_info      --external information, not including terminating bits


[~,L_total]=size(in); % total number of bits
[~,K]=size(g); 
m=K-1;
nstates=2^m; % number of states in the trellis
infinity=1000;

% alpha initialization
alpha(1,1)=0; 
alpha(1,2:nstates)=-infinity*ones(1,nstates-1);

% beta initialization
% no terminate
beta(L_total+1,1:nstates)=log(1/nstates);

% compute gamma
gamma=zeros(L_total,nstates,2); %preallocate for speed

for i=1:L_total
    for st=1:nstates
        gamma(i,st,1)=(-1)*pri_info(i)/2+Lc/2*([-1 lparoutput(1,st)]*in(:,i)); % a trasition by 0
        gamma(i,st,2)=pri_info(i)/2+Lc/2*([1 lparoutput(2,st)]*in(:,i)); % a trasition by 1
    end
end

% Trace forward, compute alpha
for i=2:L_total
    for st=1:nstates
        alpha(i,st)=max(gamma(i-1,st,1)+alpha(i-1,lstate(1,st)),...
            gamma(i-1,st,2)+alpha(i-1,lstate(2,st)))+...
            log(1+exp(-abs(gamma(i-1,st,1)+alpha(i-1,lstate(1,st))-...
            gamma(i-1,st,2)-alpha(i-1,lstate(2,st))))); % look up table is better
    end
end

% Trace backward, compute beta
for i=L_total:-1:2
    for st=1:nstates
        beta(i,st)=max(gamma(i,nstate(1,st),1)+beta(i+1,nstate(1,st)),...
            gamma(i,nstate(2,st),2)+beta(i+1,nstate(2,st)))+...
            log(1+exp(-abs(gamma(i,nstate(1,st),1)+beta(i+1,nstate(1,st))-...
            gamma(i,nstate(2,st),2)-beta(i+1,nstate(2,st))))); % look up table is better
    end
end

% Compute the soft output, log-likelihood ratio of symbols in the frame
temp0=zeros(1,nstates); %preallocate for speed
temp1=zeros(1,nstates); %preallocate for speed
soft_out=zeros(1,L_total); %preallocate for speed
for i=1:L_total
    for st=1:nstates
        temp0(st)=gamma(i,st,1)+alpha(i,lstate(1,st))+beta(i+1,st);
        temp1(st)=gamma(i,st,2)+alpha(i,lstate(2,st))+beta(i+1,st);
    end
    soft1=max(temp1(2),temp1(1))+log(1+exp(-abs(temp1(2)-temp1(1))));
    soft0=max(temp0(2),temp0(1))+log(1+exp(-abs(temp0(2)-temp0(1))));
    for j=3:nstates
        soft1=max(temp1(j),soft1)+log(1+exp(-abs(temp1(j)-soft1)));
        soft0=max(temp0(j),soft0)+log(1+exp(-abs(temp0(j)-soft0)));
    end
    soft_out(i)=soft1-soft0;
end
ex_info=soft_out-pri_info-Lc*in(1,:);