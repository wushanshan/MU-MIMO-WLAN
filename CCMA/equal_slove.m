function tau = equal_slove(network_size, concurrent_tx, CWmin, backoff_stage)
% this function calculates the transmission probability (tau) in a 802.11
% CSMA/CA based MU-MIMO system
c = zeros(1,4);
c(1) = network_size;
c(2) = concurrent_tx;
c(3) = CWmin;
c(4) = backoff_stage;
x0 = [0.3; 0.3]; 
x = fsolve(@(x) myfun(x,c), x0);
tau = x(1);