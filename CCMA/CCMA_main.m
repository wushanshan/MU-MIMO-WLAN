function [network_throughput, delay] = CCMA_main(network_size, total_time, t_slot, t_frame, AP_antenna, BW, tx_power)
% This function calculates the network throughput and the throughput of 
% each client of a 802.11 MU-MIMO system. The network_size is the total
% number of clients in the system. The total_time is the time we are
% considering, with a time unit of 1 us. t_slot is the slot time needed to
% reduce the backoff counter. t_frame is the time used to
% transmit a frame by the first client who wins the channel. The Access
% Point has AP_antenna number of antennas.
channel_vector = channel_generation(AP_antenna, network_size);
client_tx = zeros(1,network_size); % number of successful transmissions performed by each client
client_throughput = zeros(1, network_size);
channel_win = []; % clients that have won the channel in a round
CWmin = 127;
CWmax = 1023;
SIFS = 16;
ACK = 39;
DIFS = SIFS + 2*t_slot;
preamble = 20;
data_counter = 0;
parallel_counter = 0; %number of ongoing transmission
tx_time= zeros(1, network_size);% how long each client has transmit
retry_counter = zeros(1, network_size);% increment every time collision happens
channel_state = 'idle'; %channel state: idle, prea, data, SIFS, aACK, DIFS
state_time = 0; % how long will the channel state last, except the idle state
contention_time = 0; % how long that the channel has been idle during contention period
backoff = zeros(1, network_size);
is_collision = 0;
for i = 1:network_size
    backoff(i) = (unidrnd(CWmin+1)-1)*t_slot;
end
if (Is_win(backoff, channel_win)==1)
    [is_win, channel_win_new] = Is_win(backoff, channel_win); % the new client who has won the channel
    if (length(channel_win_new)>1)
        is_collision = 1;
    end
    channel_state = 'prea';
    state_time = preamble;
end
for i = 1: total_time
    if (channel_state == 'idle')
        contention_time = contention_time + 1;
        backoff = decrease_one(backoff, channel_win);
        if (Is_win(backoff, channel_win)==1)
            [is_win, channel_win_new] = Is_win(backoff, channel_win); % the new client who has won the channel
            if (length(channel_win_new)>1)
                is_collision = 1;
            end
            channel_state = 'prea';
            state_time = preamble;
            contention_time = 0;
        end
        if (data_counter ~= 0) 
            data_counter = data_counter - 1;
            tx_time = increase_one(tx_time, channel_win);
        end
        if (data_counter == 0 && parallel_counter > 0)
            channel_state = 'SIFS';
            backoff = recover(backoff, channel_win,contention_time,t_slot);
            contention_time = 0;
            state_time = SIFS;
        end
    elseif (channel_state == 'prea')
        state_time = state_time - 1 ;
        if (parallel_counter < AP_antenna && data_counter ~=0)
            data_counter = data_counter - 1;
            tx_time = increase_one(tx_time, channel_win); % channel_win contains the clients who have won the channel
        end
        if (data_counter == 0 && parallel_counter > 0)
            channel_state = 'SIFS';
            state_time = SIFS;
        elseif (state_time == 0)
            parallel_counter = parallel_counter + 1;
            channel_win = [channel_win channel_win_new];
            if (parallel_counter == 1)
                data_counter = t_frame;
        end
            if (parallel_counter == AP_antenna)
                channel_state = 'data';
                state_time = data_counter;
            elseif (parallel_counter < AP_antenna)
                channel_state = 'idle';
                contention_time = 0;
            end
        end      
    elseif (channel_state == 'data')
        state_time = state_time - 1;
        data_counter = data_counter -1;
        tx_time = increase_one(tx_time, channel_win);
        if (state_time == 0 )
            channel_state = 'SIFS';
            state_time = SIFS;
        end
    elseif (channel_state == 'SIFS')
        state_time = state_time - 1;
        if (state_time == 0)
            if (Is_collide(channel_win,AP_antenna) == 1 || is_collision == 1)
                channel_state = 'DIFS';
                state_time = DIFS - SIFS;
                retry_counter = increase_retry(retry_counter, channel_win);
                backoff = retry_backoff(backoff, channel_win, retry_counter, CWmin, t_slot, CWmax);
            else
                channel_state = 'aACK';
                state_time = ACK;
            end
        end
    elseif (channel_state == 'aACK')
        state_time = state_time - 1;
        if (state_time == 0)
            rate = ZF_SIC(channel_vector, channel_win, BW, tx_power, t_frame); % determine the transmission rate according to channel matrix and the tx order
            client_throughput = client_throughput + tx_time.*rate;% this round's tx rate
            backoff = increase_CWmin(backoff, channel_win, CWmin, t_slot); % backoff at least CWmin before next trasmission
            retry_counter = reset_retry_counter(retry_counter, channel_win);
            for p = 1: length(channel_win)
                client_tx(channel_win(p)) = client_tx(channel_win(p)) + 1;
            end
            channel_state = 'DIFS';
            state_time = DIFS;
        end
    elseif (channel_state == 'DIFS')
        state_time = state_time - 1;
        if (state_time == 0)
            is_collision = 0;
            parallel_counter = 0;
            tx_time = zeros(1, network_size);
            channel_win = [];
            channel_vector = channel_generation(AP_antenna, network_size);
            if (Is_win(backoff, channel_win)==1)
                [is_win, channel_win_new] = Is_win(backoff, channel_win);
                if (length(channel_win_new)>1)
                    is_collision = 1;
                end
                channel_state = 'prea';
                state_time = preamble;
                contention_time = 0;
            else
                channel_state = 'idle';
                contention_time = 0;
            end
        end
    end
end
network_throughput  = sum(client_throughput)/total_time; %unit: mbps 
delay = total_time/mean(client_tx); %unit: us 