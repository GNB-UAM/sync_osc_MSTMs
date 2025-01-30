clearvars
load('spiketimes')

num_trains=size(spiketimes,2);
spikes=cell(1,num_trains);
for stc=1:num_trains
    spikes{stc}=spiketimes(stc).t';
end
tmin=0;
tmax=400000;

% InitializecSPIKE
STS=SpikeTrainSet(spikes,tmin,tmax);

isi   = STS.ISIdistance(tmin, tmax)

spike = STS.SPIKEdistance(tmin, tmax)

spike_sync = STS.SPIKEsynchro(tmin,tmax)

tic
spike_order = STS.SpikeTrainOrderWithSurrogates; % this crashes in delf
fprintf('SPIKE_order with default arguments takes\n');
toc

tic
spike_order_nosurr = STS.SpikeTrainOrderWithSurrogates(0);
fprintf('SPIKE_order with 0 surrogates takes\n');
toc

keyboard;