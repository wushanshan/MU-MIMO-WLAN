function [is_win, channel_win_new] = Is_win(backoff, channel_win)
%this function determines whether a client and which client has won the channel 
network_size = length(backoff);
channel_win_new = [];
has_won = 0; 
if (isempty(channel_win) == 0)
    m = length(channel_win);
    for i = 1:network_size
        if (backoff(i)==0)
            has_won = 0;
            for j = 1:m
                if (i == channel_win(j))
                    has_won = 1;
                end 
            end
            if(has_won == 0)
                channel_win_new = [channel_win_new i];
            end
        end
    end
else
    for i = 1:network_size
        if (backoff(i)==0)
            channel_win_new = [channel_win_new i];
        end
    end
end
if (isempty(channel_win_new)==1)
    is_win = 0;
else
    is_win = 1;
end