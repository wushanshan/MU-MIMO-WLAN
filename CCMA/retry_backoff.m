function backoff_new = retry_backoff(backoff, channel_win, retry_counter, CWmin, t_slot, CWmax)
%this function returns the backoff time for collided clients.
backoff_new = backoff;
m = length(channel_win);
for  i =1:m
    CW = (CWmin+1)*2^(retry_counter(channel_win(i)))-1;
    if (CW>CWmax)
        CW = CWmax;
    end
    backoff_new(channel_win(i)) = (unidrnd(CW+1)-1)*t_slot + 4*t_slot; % set ACK_timeout as 70us, a value that is larger enough to cover a SIFS and ACK time.
end 