spike_trains = [[1, 1 ,1]; [2, 2, 2]; [3, 3, 2.5]; [9, 9, 9]];  % generate example spike train
T = 11;                                                         % signal length

S=SpikeContrast(spike_trains, T)                                % calculate synchrony value S