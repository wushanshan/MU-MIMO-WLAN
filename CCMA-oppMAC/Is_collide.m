function is_collide = Is_collide(channel_win, AP_antenna)
% this function checks whether collision has happened
m = length(channel_win);
if (m>AP_antenna)
    is_collide = 1;
else
    is_collide = 0;
end
    