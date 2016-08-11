function channel_vector = Channel_Allocation(network_size)
% this function randomly generates the channels, each term follows a
% circularly symmetrical distribution CN(0,1), Consider a network where the AP has
% two antennas, network_size denote the total number of clients
channel_vector = zeros(network_size,2);
for j = 1: network_size
    h1 = raylrnd(1/sqrt(2));
    theta1 = rand(1,1)*2*pi;
    h2 = raylrnd(1/sqrt(2));
    theta2 = rand(1,1)*2*pi;
    channel_vector(j,1) = h1*complex(cos(theta1),sin(theta1));
    channel_vector(j,2) = h2*complex(cos(theta2),sin(theta2));
end