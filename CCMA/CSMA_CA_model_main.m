function [network_throughput, delay, retry_no] = CSMA_CA_model_main(network_size,concurrent_tx,t_slot,t_frame, t_pre, CWmin, backoff_stage, BW, tx_power)
% this function calculates the throughput of a CSMA/CA-based MU-MIMO WLAN,
% by considering the case that there may be less than concurrent_tx clients
% transmitting in a successful round.
if (concurrent_tx > network_size)
    concurrent_num = network_size;
else
    concurrent_num = concurrent_tx;
end
tau = equal_solve_20131219(network_size, concurrent_num, CWmin, backoff_stage,t_frame,t_slot,t_pre,concurrent_tx);% probability that one STA transmits in each slot time
%tau = 0.011;
payload = zeros(1, concurrent_num); % average number of transmitted data if one has won the m's concurrent transmission opportunity
payload(1) = t_frame;
SIFS = 16;
ACK = 39;
DIFS = 34;
temp = t_frame;
if (concurrent_num >1)
    for m = 2:concurrent_num
        no_tx = (1-tau)^(network_size+1-m);
        temp = temp - t_pre - t_slot*1/(1-no_tx);
%         if (temp <0)
%             temp = 0;
%         end
        payload(m) = temp; %average transmission time for each pkt
    end
end
%payload
rate = zeros(1, concurrent_num); % average transmission rate for each concurrent client
%rate(1) = BW*log2(1+AP_antenna*tx_power);
for i = 1:concurrent_num
    degree = 2*(concurrent_tx - i+1);
    rate(i) = log_exp(degree,BW, tx_power);
end
p_success = zeros(1, concurrent_num); % probability that a random chosen round is a successful round with i clients (1<= i <= concurrent_num)
waiting_time = zeros(1, concurrent_num); % if clients will not join a round with i preamble pauses, it has to wait for waiting_time(i) time
waiting_time(1) = t_frame;
for i = 2:concurrent_num
    waiting_time(i) = waiting_time(i-1) - t_pre;
end
temp = 1;
for m = 1:concurrent_num
  if (m==1)
      temp = temp * (network_size-m+1)*tau*(1-tau)^(network_size - m)/(1-(1-tau)^(network_size+1-m));
  else
      temp = temp * (network_size-m+1)*(1-tau)^((payload(m-1)-t_pre-payload(m))/t_slot*(network_size-m+1))*tau*(1-tau)^(network_size-m);
  end
  if (m~=concurrent_num)
      p_success(m) = temp * nchoosek(ceil(waiting_time(m)/t_slot)-1,m-1)*(1-tau)^((payload(m)/t_slot)*(network_size-m));
  else
      p_success(m) = temp * nchoosek(ceil(waiting_time(m)/t_slot)-1,m-1);
  end
end
p_success_include_i = zeros(1, concurrent_num);
p_success_not_include_i = zeros(1, concurrent_num);
for i = 1:concurrent_num
    p_success_include_i(i) = i/network_size*p_success(i);
    p_success_not_include_i(i) = (network_size-i)/network_size*p_success(i);
end
network_size_new = network_size - 1;
if (concurrent_tx > network_size_new)
    concurrent_num_new = network_size_new;
else
    concurrent_num_new = concurrent_tx;
end
p_success_new = zeros(1, concurrent_num_new); % probability that a random chosen round is a successful round with i clients (1<= i <= concurrent_num)
waiting_time_new = zeros(1, concurrent_num_new); % if clients will not join a round with i preamble pauses, it has to wait for waiting_time(i) time
waiting_time_new(1) = t_frame;
for i = 2:concurrent_num_new
    waiting_time_new(i) = waiting_time_new(i-1) - t_pre;
end
temp = 1;
for m = 1:concurrent_num_new
  if (m==1)
      temp = temp * (network_size_new-m+1)*tau*(1-tau)^(network_size_new - m)/(1-(1-tau)^(network_size_new+1-m));
  else
      temp = temp * (network_size_new-m+1)*(1-tau)^((payload(m-1)-t_pre-payload(m))/t_slot*(network_size_new-m+1))*tau*(1-tau)^(network_size_new-m);
  end
  if (m~=concurrent_num_new)
      p_success_new(m) = temp * nchoosek(ceil(waiting_time_new(m)/t_slot)-1,m-1)*(1-tau)^((payload(m)/t_slot)*(network_size_new-m));
  else
      p_success_new(m) = temp * nchoosek(ceil(waiting_time_new(m)/t_slot)-1,m-1);
  end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% p_a1 = tau*(1-tau)^(network_size-1)/(1-(1-tau)^network_size);
% s = ceil(t_frame/t_slot);
% for i = 2:concurrent_num
%     waiting_time(i) = waiting_time(i-1) - t_pre;
% end
% for i = 1:concurrent_num
%     if (waiting_time(i) <= 0)
%         p_success(i) = 0;
%     else
%         p_success(i) = nchoosek(network_size,i)*factorial(i)*p_a1*(1-(1-tau)^s)^(i-1)*nchoosek(s,m)/s^m*(1-tau)^(ceil(waiting_time(i)/t_slot)*(network_size-i));
%         %p_success(i) = nchoosek(network_size,i)*factorial(i)*(1-tau)^(ceil(waiting_time(i)/t_slot)*(network_size-i))*tau^i;
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% p_win = (1-tau)^ceil(t_frame/t_slot); % probability that a client wins the transmission opportunity before the first contention winner finishes
% p_success(1) = network_size*tau*(1-tau)^(network_size - 1)/(1-(1-tau)^network_size)*p_win^(network_size-1);
% for j = 2:concurrent_num
%     p_success(j) = p_success(j-1)*(1-p_win)/p_win*(j-1)*tau*(1-tau)^(j-2)/(1-(1-tau)^(j-1));
% end
% temp = 1;
% for j = 1:concurrent_num
%   temp = temp * (network_size-j+1)*tau*(1-tau)^(network_size - j)/(1-(1-tau)^(network_size+1-j));
%   if (j~=concurrent_num)
%       %p_success(j) = temp * (1-payload(j)/t_slot*(network_size-j)*tau);
%       p_success(j) = temp * (1-tau)^(ceil(payload(j)/t_slot)*(network_size-j));
%   else
%       p_success(j) = temp;
%   end
% end
for i = 1:concurrent_num
    if (payload(i)<0)
        payload(i)=0;
    end
end
success_payload = zeros(1, concurrent_num); % the transmitted data in a successful round, with i clients/round (1<= i <= concurrent_num)
temp = 0;
for i = 1:concurrent_num
    temp = temp + payload(i)*rate(i);
    success_payload(i) = p_success(i)*temp/sum(p_success);
end
N_coll = (1-sum(p_success))/sum(p_success); % average number of collisions before one successful transmission
%t_coll = t_slot*1/(1-(1-tau)^network_size) + t_pre + t_frame + DIFS;
t_coll = t_slot*(1-tau)^network_size/(1-(1-tau)^network_size) + t_pre + t_frame + DIFS; % average time of one collision
%t_success = t_slot*(1-tau)^network_size/(1-(1-tau)^network_size) + t_pre + t_frame + SIFS + ACK + DIFS; % average time of one successful transmission
t_success = t_slot*1/(1-(1-tau)^network_size)*(1-1/CWmin)^concurrent_num + t_pre + t_frame + SIFS + ACK + DIFS;
network_throughput = sum(success_payload)/(N_coll * t_coll + t_success); %unit: mbps
delay = (N_coll * t_coll + t_success)*sum(p_success)/sum(p_success_include_i); %unit:micro-second
p_include_i = 1-sum(p_success_not_include_i)/sum(p_success_new);
retry_no = N_coll*p_include_i*sum(p_success)/sum(p_success_include_i);
% payload_new = zeros(1, concurrent_num_new); % average number of transmitted data if one has won the m's concurrent transmission opportunity
% payload_new(1) = t_frame;
% temp = t_frame;
% if (concurrent_num_new >1)
%     for m = 2:concurrent_num_new
%         no_tx = (1-tau)^(network_size_new+1-m);
%         temp = temp - t_pre - t_slot*1/(1-no_tx);
%         if (temp <0)
%             temp = 0;
%         end
%         payload_new(m) = temp;
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for i = 1:concurrent_num_new
%     if (waiting_time_new(i) <= 0)
%         p_success_new(i) = 0;
%     else
%         p_success_new(i) = nchoosek(network_size_new,i)*factorial(i)*(1-tau)^(ceil(waiting_time_new(i)/t_slot)*(network_size_new-i))*tau^i;
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% p_win_new = (1-tau)^ceil(t_frame/t_slot); % probability that a client wins the transmission opportunity before the first contention winner finishes
% p_success_new(1) = network_size_new*tau*(1-tau)^(network_size_new - 1)/(1-(1-tau)^network_size_new)*p_win_new^(network_size_new-1);
% for j = 2:concurrent_num_new
%     p_success_new(j) = p_success_new(j-1)*(1-p_win_new)/p_win_new*(j-1)*tau*(1-tau)^(j-2)/(1-(1-tau)^(j-1));
% end
% temp = 1;
% for j = 1:concurrent_num_new
%   temp = temp * (network_size_new-j+1)*tau*(1-tau)^(network_size_new - j)/(1-(1-tau)^(network_size_new+1-j));
%   if (j~=concurrent_num_new)
%       %p_success(j) = temp * (1-payload(j)/t_slot*(network_size-j)*tau);
%       p_success_new(j) = temp * (1-tau)^(ceil(payload_new(j)/t_slot)*(network_size_new-j));
%   else
%       p_success_new(j) = temp;
%   end
% end