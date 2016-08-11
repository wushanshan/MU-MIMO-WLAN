function [network_throughput, client_throughput, delay] = CCMA_opp_main(network_size, total_time, t_slot, t_frame, threshold, BW, tx_power)
% This function calculates the network throughput and the throughput of 
% each client of a 802.11 MU-MIMO system. The network_size is the total
% number of clients in the system. The total_time is the time we are
% considering, with a time unit of 1 us. t_slot is the slot time needed to
% reduce the backoff counter. t_frame is the time used to
% transmit a frame by the first client who wins the channel. The Access
% Point has 2 antennas, and the network_size>2.  Client joining
%the second contention period if its effective SNR is larger than threshold*SNRorig. 
network_throughput = 0;
AP_antenna = 2;
freeze_client = [];
client_throughput = zeros(1, network_size);
channel_vector = Channel_Allocation(network_size);
client_tx = zeros(1,network_size); % number of successful transmissions performed by each client
channel_win = []; % clients that have won the channel in a round
count =[];% number of concurrent clients in a round
tx_time_count = []; % time of clients in each round
% CWmin = 15;
% CWmax = 1023;
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
        backoff = decrease_one_opp(backoff, channel_win, freeze_client);
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
            if (parallel_counter==1)
                freeze_client = freeze(backoff, channel_vector, threshold, channel_win, BW, tx_power, t_frame);
            end
            if (parallel_counter == 1)
                data_counter = t_frame;
                %rate = parallel_rate(channel_win, network_size); 
                %backoff = prefer(backoff, channel_win, rate, network_size, C); % backoff time is changed after the first client winning the channel
                %rate = Rate(channel_win(1),:);            
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
%             freeze_client
            freeze_client = []; %release the freezed clients after each round
            if (Is_collide(channel_win,AP_antenna) == 1 || is_collision == 1)
                channel_state = 'DIFS';
                state_time = DIFS - SIFS;
                retry_counter = increase_retry(retry_counter, channel_win);
                backoff = retry_backoff (backoff, channel_win, retry_counter, CWmin, t_slot, CWmax);
                %BO = [BO backoff];used for debugging
            else
                channel_state = 'aACK';
                state_time = ACK;
            end
        end
    elseif (channel_state == 'aACK')
        state_time = state_time - 1;
        if (state_time == 0)
            %rate = Rate_Allocation(channel_win, channel_vector, BW, tx_power);
%             rate = zeros(1, network_size);
%             rate_opp = log_chi(BW, tx_power, threshold);
%             rate(channel_win(1)) = rate_opp(1);
%             if (length(channel_win)>1)
%                 rate(channel_win(2)) = rate_opp(2);
%             end
            rate = ZF_SIC(channel_vector, channel_win, BW, tx_power, t_frame);
            client_throughput = client_throughput + tx_time.*rate;% this round's tx rate
%             tx_time
%               rate (channel_win(2))
            backoff = increase_CWmin(backoff, channel_win, CWmin, t_slot); % backoff at least CWmin before next trasmission
            %BO = [BO backoff];used for debugging
            retry_counter = reset_retry_counter (retry_counter, channel_win);
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
            %channel_win
            channel_win = [];
            channel_vector = Channel_Allocation(network_size);
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
% count
% tx_time_count
network_throughput  = sum(client_throughput)/total_time;      
delay = total_time/mean(client_tx); %unit: us