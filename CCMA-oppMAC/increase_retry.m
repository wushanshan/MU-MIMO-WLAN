function retry_counter_new = increase_retry(retry_counter, channel_win)
%this function increase the retry_counter for clients who has won the
%channel
retry_counter_new = retry_counter;
m = length(channel_win);
for  i = 1:m
    retry_counter_new(channel_win(i)) = retry_counter_new(channel_win(i)) + 1;
end