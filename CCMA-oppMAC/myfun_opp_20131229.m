function F = myfun_opp_20131229(x,network_size, CWmin, backoff_stage,p_join)
concurrent_num = 2;
p_success_1 = (network_size)*x(1)*(1-x(1))^(network_size - 1)/(1-(1-x(1))^(network_size)); % success probability of 1st contention
temp = (1-p_join)^(network_size-1);
for N_join = 1:(network_size-1)
    N_join_prob = nchoosek(network_size-1, N_join)*p_join^N_join*(1-p_join)^(network_size-1-N_join);
    temp = temp + N_join*x(1)*(1-x(1))^(N_join - 1)/(1-(1-x(1))^N_join)*N_join_prob;
end
N_join_0 = p_success_1*(1-p_join)^(network_size-1);
p_success = p_success_1*temp; % probability of successful transmission 
network_size_new = network_size - 1;
p_success_1_new = (network_size_new)*x(1)*(1-x(1))^(network_size_new - 1)/(1-(1-x(1))^(network_size_new)); % success probability of 1st contention
temp_new = (1-p_join)^(network_size_new-1);
for N_join = 1:(network_size_new-1)
    N_join_prob = nchoosek(network_size_new-1, N_join)*p_join^N_join*(1-p_join)^(network_size_new-1-N_join);
    temp_new = temp_new + N_join*x(1)*(1-x(1))^(N_join - 1)/(1-(1-x(1))^N_join)*N_join_prob;
end
%N_join_0_new = p_success_1_new*(1-p_join)^(network_size_new-1);
p_success_new = p_success_1_new*temp_new; % probability of successful transmission 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%two nonlinear equations%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p_success_include_i = concurrent_num/network_size * (p_success-N_join_0) + 1/network_size*N_join_0;
p_success_not_include_i = (1-concurrent_num/network_size) * (p_success-N_join_0) + (1-1/network_size)*N_join_0;
%eq2_pre = concurrent_num/network_size * p_success*p_success_new/(p_success_new - (1-concurrent_num/network_size)*p_success);
eq2_pre = p_success_include_i*p_success_new/(p_success_new-p_success_not_include_i);
eq1 = x(1) - 2*(1-2*x(2))/((1-2*x(2))*(CWmin+1)+x(2)*CWmin*(1-(2*x(2))^backoff_stage));
eq2 = x(2) - 1 + eq2_pre;
F = [eq1 eq2];