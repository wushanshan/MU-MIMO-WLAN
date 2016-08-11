function channel_vector = channel_generation(AP_antenna, network_size)
% this function randomly generates the channels, each term follows a
% circularly symmetrical distribution CN(0,1).
h = raylrnd(1/sqrt(2),network_size,AP_antenna);
theta = rand(network_size, AP_antenna)*2*pi;
temp = complex(cos(theta), sin(theta));
channel_vector = h.*temp;
