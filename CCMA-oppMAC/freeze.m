function freeze_client = freeze(backoff, channel_vector, threshold, channel_win, BW, tx_power, t_frame)
%this function freezes clients with an probability of p_join, and put the
%freezed clients into freeze_client, the client with backoff=0 will not be
%considered in the freeze operation.
% freeze_client = [];
% for i = 1:length(backoff)
%     if (backoff(i)~=0)
%         if(rand(1,1)>p_join)
%             freeze_client = [freeze_client i];
%         end
%     end
% end
% length(freeze_client)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% freeze_client = [];
% theta_1st = angle(channel_vector(channel_win(1)));
% network_size = length(backoff);
% for i = 1:network_size
%     if (backoff(i)~=0)
%         delta = abs(angle(channel_vector(i)) - theta_1st);
%         if (abs(sin(delta))<threshold)
%             freeze_client = [freeze_client i];
%         end
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% freeze_client = [];
% h1 = channel_vector(channel_win(1),:).';
% network_size = length(backoff);
% for i = 1:network_size    
%     if (backoff(i)~=0)
%         h2 = channel_vector(i,:).';
%         h1_orth = [-h1(2) h1(1)];
%         len = sqrt(h1_orth*h1_orth');
%         h1_unit_orth = h1_orth/len;
%         decorr = abs(h1_unit_orth*h2)^2;
%         if (decorr<threshold)
%             freeze_client = [freeze_client i];
%         end
%     end
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
freeze_client = [];
temp = [complex(0,0) complex(0,0)];
for i = 1: length(channel_win)
    temp = temp + channel_vector(channel_win(i),:);
end
H = zeros(2,2);
H(:,1) = temp.';
network_size = length(backoff);
for i = 1:network_size
    if (backoff(i)~=0)
        H(:,2) = channel_vector(i,:).';
        no_symbol = 5000; % number of symbols in one frame
        noise = channel_generation(2, no_symbol);
        noise = noise.';
        pseudo_inv = pinv(H);
        noise_variance = pseudo_inv * noise;
        noise_power = abs(noise_variance(2,:)).*abs(noise_variance(2,:));
        temp = 0;
        for j = 1:no_symbol
            temp = temp + BW*log2(1+tx_power/noise_power(j));
        end
        rate = temp/no_symbol; 
        if (rate<BW*log2(1+tx_power*threshold))
            freeze_client = [freeze_client i];
        end
    end
end
            	
