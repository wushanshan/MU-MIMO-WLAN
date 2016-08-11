function backoff_new = increase_CWmin(backoff, channel_win, CWmin, t_slot)
% this function gives a CWmin backoff time to clients who have successfully
% transmitted their data.
m = length(channel_win);
backoff_new = backoff;
for i = 1:m
    backoff_new(channel_win(i)) = (unidrnd(CWmin+1)-1)*t_slot;
end
    