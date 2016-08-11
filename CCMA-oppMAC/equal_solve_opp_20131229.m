function [tau, p] = equal_solve_opp_20131229(network_size, CWmin, backoff_stage,p_join)
% this function calculates the transmission probability (tau) in a 802.11
% CSMA/CA based MU-MIMO system
% c = zeros(1,4);
% c(1) = network_size;
% c(2) = concurrent_tx;
% c(3) = CWmin;
% c(4) = backoff_stage;
x0 = [0.04; 0.4]; 
x = fsolve(@(x) myfun_opp_20131229(x,network_size, CWmin, backoff_stage,p_join), x0);
tau = x(1);
p = x(2);