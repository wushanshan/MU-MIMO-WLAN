function rate = log_exp(degree,BW, tx_power)
% this function computes the average transmission rate for each concurrent
% client, based on the fact that the channel gain is chi-squared
% distributed with degree degrees of freedom
x = 0:0.01:1000;
y = chi2pdf(x,degree);
rate = 0;
for i = 1: length(x)
    rate = rate + BW*log2(1+tx_power*x(i))*y(i)*0.01;
end