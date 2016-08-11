function backoff_new = decrease_one_opp(backoff, channel_win, freeze_client)
% this function decrease one backoff period for clients that haven't won
% the channel
network_size = length(backoff);
backoff_new = backoff - 1;
if (isempty(channel_win) == 0)
    m = length(channel_win);
    n = length(freeze_client);
    for i = 1: network_size
        for j = 1:m
            if (i==channel_win(j))
                backoff_new(i) = backoff_new(i)+1;
            end
        end
        for k = 1:n
            if (i==freeze_client(k))
                backoff_new(i) = backoff_new(i)+1;
            end
        end   
    end
end