function [tau, p] = equal_solve_20131219(network_size, concurrent_num, CWmin, backoff_stage,t_frame,t_slot,t_pre,concurrent_tx)
% this function calculates the transmission probability (tau) in a 802.11
% CSMA/CA based MU-MIMO system
% c = zeros(1,4);
% c(1) = network_size;
% c(2) = concurrent_tx;
% c(3) = CWmin;
% c(4) = backoff_stage;
x0 = [0.04; 0.4]; 
x = fsolve(@(x) myfun_20131219(x,network_size, concurrent_num, CWmin, backoff_stage, t_frame,t_slot,t_pre,concurrent_tx), x0);
tau = x(1);
p = x(2);