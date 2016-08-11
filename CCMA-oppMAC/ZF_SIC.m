function rate = ZF_SIC(chan, channel_win, BW, tx_power, t_frame)
%this function computes the transmission rates for concurrent clients
%according to their channel vectors and the orders of transmission
[network_size,AP_antenna] = size(chan);
concurrent_tx = length(channel_win);
rate = zeros(1, network_size);
H = zeros(AP_antenna, concurrent_tx);
for i = 1:concurrent_tx
    H(:,i) = chan(channel_win(i),:).';
end
no_symbol = BW*t_frame; % number of symbols in one frame
noise = channel_generation(AP_antenna, no_symbol);
noise = noise.';
for i = 1:(concurrent_tx)
    pseudo_inv = pinv(H);
    noise_variance = pseudo_inv * noise;
    noise_power = abs(noise_variance(concurrent_tx-i+1,:)).*abs(noise_variance(concurrent_tx-i+1,:));
    temp = 0;
    for j = 1:no_symbol
        temp = temp + BW*log2(1+tx_power/noise_power(j));
    end
    %rate(channel_win(concurrent_tx-i+1)) = BW*log2(1+tx_power/mean(noise_power));
    rate(channel_win(concurrent_tx-i+1)) = temp/no_symbol;
    if i~=concurrent_tx
        H = H(:,1:(concurrent_tx-i));
    end
end