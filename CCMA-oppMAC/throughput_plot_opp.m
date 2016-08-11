function [network_throughput, delay] = throughput_plot_opp(total_time, t_slot, t_frame, BW, tx_power)
% this function plots the network_throughput versus network_size, with
% different theta_threshold, under the opportunistic MAC, AP_antenna = 2 
network_size = [10 15 20 25 30 40];
%network_size = [30];
%theta_th = [pi/8 pi/4 5*pi/16 3*pi/8];
%theta_th = [pi/4 3*pi/8];
threshold = [0.5 1 1.5];
network_throughput = zeros(length(threshold),length(network_size));
delay = network_throughput;
for i = 1:length(threshold)    
    for j = 1:length(network_size)
        %[network_throughput, client_throughput, delay] = CSMA_CA_opp(network_size, total_time, t_slot, t_frame, threshold)
        [network_throughput(i,j), ~, delay(i,j)] = CSMA_CA_opp(network_size(j), total_time, t_slot, t_frame, threshold(i), BW, tx_power);    
    end
    plot(network_size, network_throughput(i,:),'ro');
    hold on;
end
network_throughput_analysis = zeros(1, 46);
for i = 1:length(threshold)
    %rate_opp = log_chi(BW, tx_power, threshold(i));
    for j = 5:50
        network_throughput_analysis(j-4) = CSMA_CA_model_opp_20131229(j,t_slot,t_frame, 20, 128, 3, BW, tx_power, threshold(i));
    end
    plot(5:50, network_throughput_analysis,'b-');
    hold on;
end
fileID = fopen('simulation_opp.txt','w');
fprintf(fileID,'%20s %20f\n', 'total time = ', total_time);
fprintf(fileID,'%20s %20f\n', 't_slot = ', t_slot);
fprintf(fileID,'%20s %20f\n', 't_frame = ', t_frame);
fprintf(fileID,'%20s %20f\n', 'BW (MHz) = ', BW);
fprintf(fileID,'%20s %20f\n', 'tx_power/noise = ', tx_power);
fprintf(fileID,'%20s\n', 'network throughput');
fprintf(fileID,'%12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f\n',network_throughput');
fprintf(fileID,'%20s\n', 'average delay');
fprintf(fileID,'%12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f\n',delay');
%fprintf(fileID,'%20s\n', 'retry number');
%fprintf(fileID,'%12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f %12.8f\n',retry_no');
fclose(fileID);