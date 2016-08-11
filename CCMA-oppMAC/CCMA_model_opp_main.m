function [network_throughput, delay] = CCMA_model_opp_main(network_size,t_slot,t_frame, t_pre, CWmin, backoff_stage, BW, tx_power, threshold)
%this function provides the analytically derived network throughput for a
%802.11 CSMA/CA based MU-MIMO system, with a 2-antenna AP, and client joining
%the second contention period at probability p_join. We assume that the total
%number of clients is larger than 2.
SIFS = 16;
ACK = 39;
DIFS = 34;
p_join = PJoin(threshold);
%p_join = (14-9.2)/14;
tau = equal_solve_opp_20131229(network_size, CWmin, backoff_stage,p_join);% probability that one STA transmits in each slot time
payload = zeros(1, 2); % average number of transmitted data if one has won the m's concurrent transmission opportunity
payload(1) = t_frame;
for N_join = 1:(network_size-1)
    no_tx = (1-tau)^(N_join);
    N2 = 1/(1-no_tx);
    N2_prob = nchoosek(network_size-1, N_join)*p_join^N_join*(1-p_join)^(network_size-1-N_join);
    payload(2) = payload(2) + (t_frame - t_pre - t_slot*N2)*N2_prob;
end
rate_opp = log_chi(BW, tx_power, threshold); % unit:Mbps
success_payload = zeros(1,2);
for i = 1:2
    success_payload(i) = payload(i)*rate_opp(i);
end
p_success_1 = (network_size)*tau*(1-tau)^(network_size - 1)/(1-(1-tau)^(network_size)); % success probability of 1st contention
temp = (1-p_join)^(network_size-1);%probability that a successful round contains only one client
for N_join = 1:(network_size-1)
    N_join_prob = nchoosek(network_size-1, N_join)*p_join^N_join*(1-p_join)^(network_size-1-N_join);
    temp = temp + N_join*tau*(1-tau)^(N_join - 1)/(1-(1-tau)^N_join)*N_join_prob;
end
p_success = p_success_1*temp; % probability of successful transmission 
N_coll = (1-p_success)/p_success; % average number of collisions before one successful transmission
t_coll = t_slot*(1-tau)^network_size/(1-(1-tau)^network_size) + t_pre + t_frame + DIFS; % average time of one collision
t_success = t_slot*(1-tau)^network_size/(1-(1-tau)^network_size) + t_pre + t_frame + SIFS + ACK + DIFS; % average time of one successful transmission
N_join_0 = p_success_1*(1-p_join)^(network_size-1);
network_throughput = sum(success_payload)/(N_coll * t_coll + t_success);
p_success_include_i = 2/network_size * (p_success-N_join_0) + 1/network_size*N_join_0;
delay = (N_coll * t_coll + t_success)*p_success/p_success_include_i; %unit:us
%delay = network_size*(N_coll * t_coll + t_success)/2; %unit:us