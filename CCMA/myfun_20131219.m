function F = myfun_20131219(x,network_size, concurrent_num, CWmin, backoff_stage, t_frame, t_slot,t_pre,concurrent_tx)
payload = zeros(1, concurrent_num); % average number of transmitted data if one has won the m's concurrent transmission opportunity
payload(1) = t_frame;
temp = t_frame;
if (concurrent_num >1)
    for m = 2:concurrent_num
        no_tx = (1-x(1))^(network_size+1-m);
        temp = temp - t_pre - t_slot*1/(1-no_tx);
%         if (temp <0)
%             temp = 0;
%         end
        payload(m) = temp;
    end
end
p_success = zeros(1, concurrent_num); % probability that a random chosen round is a successful round with i clients (1<= i <= concurrent_num)
waiting_time = zeros(1, concurrent_num); % if clients will not join a round with i preamble pauses, it has to wait for waiting_time(i) time
waiting_time(1) = t_frame;
for i = 2:concurrent_num
    waiting_time(i) = waiting_time(i-1) - t_pre;
end
temp = 1;
for m = 1:concurrent_num
  %temp = temp * (network_size-m+1)*x(1)*(1-x(1))^(network_size - m)/(1-(1-x(1))^(network_size+1-m));
  if (m==1)
      temp = temp * (network_size-m+1)*x(1)*(1-x(1))^(network_size - m)/(1-(1-x(1))^(network_size+1-m));
  else
      temp = temp * (network_size-m+1)*(1-x(1))^((payload(m-1)-t_pre-payload(m))/t_slot*(network_size-m+1))*x(1)*(1-x(1))^(network_size-m);
      %temp = temp * (network_size-m+1)*x(1)*(1-x(1))^(network_size - m);
  end
  if (m~=concurrent_num)
      %p_success(j) = temp * (1-payload(j)/t_slot*(network_size-j)*x(1));
      %p_success(m) = temp * nchoosek(ceil(waiting_time(m)/t_slot)-1,m-1)*(1-x(1))^(ceil((waiting_time(m)-payload(m))/t_slot)*(network_size-m))*(1-x(1))^(abs(payload(m)/t_slot)*(network_size-m));
      %p_success(m) = temp * nchoosek(ceil(waiting_time(m)/t_slot)-1,m-1)*(1-x(1))^(ceil(waiting_time(m)/t_slot)*(network_size-m));
      p_success(m) = temp * nchoosek(ceil(waiting_time(m)/t_slot)-1,m-1)*(1-x(1))^((payload(m)/t_slot)*(network_size-m));
  else
      %p_success(m) = temp * nchoosek(ceil(waiting_time(m)/t_slot)-1,m-1)*(1-x(1))^(ceil((waiting_time(m)-payload(m))/t_slot)*(network_size-m));
      p_success(m) = temp * nchoosek(ceil(waiting_time(m)/t_slot)-1,m-1);
  end
end
p_success_include_i = 0;
p_success_not_include_i = 0;
for j = 1:concurrent_num
    p_success_include_i = p_success_include_i + p_success(j)*j/network_size;
    p_success_not_include_i = p_success_not_include_i + p_success(j)*(1-j/network_size);
end
%----- calculate the probability conditioned on the Client i does not tx in round r -----% 
network_size_new = network_size - 1; 
if (concurrent_num > network_size_new)
    concurrent_num_new = network_size_new;
else
    concurrent_num_new = concurrent_num;
end
p_success_new = zeros(1, concurrent_num_new); % probability that a random chosen round is a successful round with i clients (1<= i <= concurrent_num)
%p_a1_new = x(1)*(1-x(1))^(network_size_new-1)/(1-(1-x(1))^network_size_new);
waiting_time_new = zeros(1, concurrent_num_new); % if clients will not join a round with i preamble pauses, it has to wait for waiting_time(i) time
waiting_time_new(1) = t_frame;
for i = 2:concurrent_num_new
    waiting_time_new(i) = waiting_time_new(i-1) - t_pre;
end
temp = 1;
for m = 1:concurrent_num_new
  %temp = temp * (network_size_new-m+1)*x(1)*(1-x(1))^(network_size_new - m)/(1-(1-x(1))^(network_size_new+1-m));
  if (m==1)
      temp = temp * (network_size_new-m+1)*x(1)*(1-x(1))^(network_size_new - m)/(1-(1-x(1))^(network_size_new+1-m));
  else
      temp = temp * (network_size_new-m+1)*(1-x(1))^((payload(m-1)-t_pre-payload(m))/t_slot*(network_size_new-m+1))*x(1)*(1-x(1))^(network_size_new-m);
  end
  if (m~=concurrent_num_new)
      %p_success(j) = temp * (1-payload(j)/t_slot*(network_size-j)*x(1));
      %p_success_new(m) = temp * nchoosek(ceil(waiting_time_new(m)/t_slot)-1,m-1)*(1-x(1))^(ceil((waiting_time_new(m)-payload(m))/t_slot)*(network_size_new-m))*(1-x(1))^(abs(payload(m)/t_slot)*(network_size_new-m));
      p_success_new(m) = temp * nchoosek(ceil(waiting_time_new(m)/t_slot)-1,m-1)*(1-x(1))^((payload(m)/t_slot)*(network_size_new-m));
  else
      %p_success_new(m) = temp * nchoosek(ceil(waiting_time_new(m)/t_slot)-1,m-1)*(1-x(1))^(ceil((waiting_time_new(m)-payload(m))/t_slot)*(network_size_new-m));
      p_success_new(m) = temp * nchoosek(ceil(waiting_time_new(m)/t_slot)-1,m-1);
  end
end

%-------------- construct the two nonlinear equations in tau and p --------------% 
eq1 = x(1) - 2*(1-2*x(2))/((1-2*x(2))*(CWmin+1)+x(2)*CWmin*(1-(2*x(2))^backoff_stage));
eq2_pre = p_success_include_i/(1-p_success_not_include_i/sum(p_success_new));
%eq2_pre = p_success_include_i/(1-(1-x(1))^(floor(t_frame/t_slot)));
eq2 = x(2) - 1 + eq2_pre;
F = [eq1 eq2];