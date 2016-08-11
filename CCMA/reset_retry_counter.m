function retry_counter_new = reset_retry_counter (retry_counter, channel_win)
% this function reset the retry_counter to zero for clients that have
% successfully transmitted their data
m = length(channel_win);
retry_counter_new = retry_counter;
for i =1:m
    retry_counter_new(channel_win(i)) = 0;
end
