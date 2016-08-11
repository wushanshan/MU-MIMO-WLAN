function tx_time_new = increase_one(tx_time, channel_win)
% this function increases the transmission time for the clients who has won
% the channel
m = length(channel_win);
tx_time_new = tx_time;
for i = 1:m
    tx_time_new(channel_win(i)) = tx_time_new(channel_win(i)) +1;
end