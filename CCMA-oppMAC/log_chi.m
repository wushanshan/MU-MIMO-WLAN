function rate_opp = log_chi(BW, tx_power, threshold)
% this function calculates the rate of the first contention winner and the average rate of the second contention winner
% of the opportunistic MAC when ||Q_kh_k||^2 is chi-squared distributed
% with 2 degrees of freedom
% rate_opp = zeros(1,2);
% rate_opp(1) = BW *log2(1+2*tx_power);
% prob = 1/(pi/2-theta_th);
% dtheta = 0.01;
% for theta = theta_th:dtheta:pi/2
%     rate_opp(2) = rate_opp(2) + BW * log2(1+tx_power*2*sin(theta)*sin(theta))*prob*dtheta;
% end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rate_opp = zeros(1,2);
rate_opp(1) = log_exp(4,BW, tx_power);
x = threshold:0.01:100;
y = chi2pdf(x,2);
norm = 1-chi2cdf(threshold,2);
rate = 0;
for i = 1: length(x)
    rate = rate + BW*log2(1+tx_power*x(i))*y(i)*0.01;
end
rate_opp(2) = rate/norm;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rate_opp = zeros(1,2);
% rate_opp(1) = log_exp(4,BW, tx_power);
% x = threshold:0.1:100;
% norm = PJoin(threshold);
% rate = 0;
% for i=1:(length(x)-1)
%     delta = (PJoin(x(i))-PJoin(x(i+1)))/norm;
%     rate = rate + BW*log2(1+tx_power*x(i))*delta;
% end
% rate_opp(2) = rate;