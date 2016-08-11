function backoff_new = recover(backoff, channel_win, contention_time, t_slot)
% This function helps ensure that every client has an integer time of
% t_slot as the backoff time before the contention of each round.
m = floor(contention_time/t_slot);
n = length(backoff);
k = length(channel_win);
win = 0;
backoff_new = zeros(1,n);
for i = 1:n
    for j = 1:k
        if (i == channel_win(j))
            win = 1;
        end
    end
    if (win == 0)
        backoff_new(i) = backoff(i) + contention_time - m*t_slot;
    end
    win = 0;
end
