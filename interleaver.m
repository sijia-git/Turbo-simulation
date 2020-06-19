
clear

load('method_Log_eg.mat')
load('interation_eg.mat')

figure
semilogy(EbN0_Vec,errspro(5,:)','-bo')  % 1000 interleaver
hold on
semilogy(EbN0_Vec,errsproLog(5,:)','-gs') % 4000 interleaver
xlabel('dB')
ylabel('BER')
legend('1000 interleaver','4000')
title('BER of Different Interleavers')
%**************************************************************************
