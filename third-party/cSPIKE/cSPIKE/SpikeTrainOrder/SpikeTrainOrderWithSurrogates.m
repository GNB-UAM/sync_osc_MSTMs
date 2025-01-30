function  [initialIteration,optimalIteration,synf,so_profs,sto_profs] = SpikeTrainOrderWithSurrogates(obj,numberOfSurrogates, time1, time2)

if nargin < 4
    time1 = obj.timeStart;
    time2 = obj.timeEnd;
else
    time1 = obj.InputTimeShift(time1);
    time2 = obj.InputTimeShift(time2);
end
% if nargin < 5
THR = 0;
% end
if nargin < 2
    numberOfSurrogates = 19;
end

% Creating pooled spike train and info on what spike train
% a spike belongs to
obj.HaveData(1);
obj.CheckTime(time1,time2);
STs = obj.giveDATA{1};
num_trains = size(STs,1);
% Removing auxiliary spikes
for i = 1:num_trains
    if size(STs{i},2) == 2
        STs{i} = [];
    else
        STs{i} = STs{i}(2:end-1);
    end
end

indices = [];
spikes = [];
for ST = 1:num_trains
    indices = [indices ones(size(STs{ST},2),1)'*ST];
    spikes = [spikes STs{ST}];
end
[OrderedSpikeTrains,order] = sort(spikes);
SpikeTrainOfASpike = indices(order);

% Creating the auxiliary matrices for spike order and spike
% train order


so_profs = mexFind_so_profs(obj.DataArray{1},THR/2,obj.timeStart,obj.timeEnd,time1, time2, OrderedSpikeTrains, SpikeTrainOfASpike);
sto_profs = mexFind_sto_profs(obj.DataArray{1},THR/2,obj.timeStart,obj.timeEnd,time1, time2, OrderedSpikeTrains, SpikeTrainOfASpike);


% Calculating surrogates
num_surros = numberOfSurrogates;
if numberOfSurrogates > 0
    %disp('Start surrogates')
    synfNotNormalized = SPIKY_f_generate_surros_np_cSPIKE(sto_profs,so_profs,num_surros);
    %disp('Surrogates ready')
else
    synfNotNormalized = [];
end
% Calculating synfire indicator for original
[Synch,SO,STO] = obj.AdaptiveSPIKEsynchroProfile(time1, time2,THR);
SYNCsum = 0;
STOsum = 0;
num_all_spikes  = 0;
for i = 1:num_trains
    num_all_spikes = num_all_spikes + size(STs{i},2);
    STOsum = STOsum + sum(STO{i});
    SYNCsum = SYNCsum + sum(Synch{i});
end


% Normalizing the synfire indicators of the surrogates
synf = synfNotNormalized*2/(num_trains-1)/num_all_spikes;

% Calculating the optimal order by pairwise matrix
matr_entries=sum(sto_profs,2)/2;
matr = tril(ones(num_trains),-1);
matr(~~matr) = matr_entries';
matr=matr'-matr;
%disp('Start simulated annealing')
[st_indy_simann,~,~]=SPIKE_order_sim_ann_MEX(matr);
%disp('Simulated annealing done')
% Calculating the pairwise matrix for optimal order
for i = 1:num_trains
    OPTorderSpikes{i} = STs{st_indy_simann(i)};
    OPTOrderWithAUX{i} = obj.DataArray{1}{st_indy_simann(i)};
end
STs_opt = OPTorderSpikes;
opt_indices = [];
opt_spikes = [];
for ST = 1:num_trains
    opt_indices = [opt_indices ones(size(STs_opt{ST},2),1)'*ST];
    opt_spikes = [opt_spikes STs_opt{ST}];
end
[opt_OrderedSpikeTrains,opt_order] = sort(opt_spikes);
opt_SpikeTrainOfASpike = opt_indices(opt_order);
%disp('Start mexFind_sto_profs')
sto_profs_opt = mexFind_sto_profs(OPTOrderWithAUX,THR/2,obj.timeStart,obj.timeEnd,time1, time2, opt_OrderedSpikeTrains, opt_SpikeTrainOfASpike);
%disp('EndmexFind_sto_profs')

matr_entries_opt=sum(sto_profs_opt,2)/2;
matrOpt = tril(ones(num_trains),-1);
matrOpt(~~matrOpt) = matr_entries_opt';
matrOpt=matrOpt'-matrOpt;


% Synfire indocator of the optimal order
STS = SpikeTrainSet(OPTorderSpikes,obj.timeStart,obj.timeEnd);
[~,SOopt,STOopt] = STS.AdaptiveSPIKEsynchroProfile(time1, time2,THR);
STOoptsum = 0;
for i = 1:num_trains
    STOoptsum = STOoptsum + sum(STOopt{i});
    sum(STOopt{i});
end

% Calculate the synfire indicator values
ini = STOsum/num_all_spikes;
fin = STOoptsum/num_all_spikes;
SYNCvalue = SYNCsum/num_all_spikes;

% Pooling STO values
initPool = [];
optPool = [];
SyncPool = [];
for i = 1:num_trains
    initPool = [initPool STO{i}];
    SyncPool = [SyncPool Synch{i}];
    
    %Concatenate optimal in original order for profile
    optPool = [optPool STOopt{st_indy_simann(i)}];
end

profile(1,: ) = initPool(order);
profile(2,: ) = OrderedSpikeTrains;
OPTprofile(1,: ) = optPool(order);
OPTprofile(2,: ) = OrderedSpikeTrains;
SpikeSynchroProfile(1,: ) = SyncPool(order);
SpikeSynchroProfile(2,: ) = OrderedSpikeTrains;

% Construct output
initialIteration = Iteration;
initialIteration.Name = 'Initial';
initialIteration.Order = 1:num_trains;
initialIteration.SpikeTrains = STs';
initialIteration.SynfireIndicatorF = ini;
initialIteration.SynchronizationValueC = SYNCvalue;
initialIteration.SynchronizationProfile = SpikeSynchroProfile;
initialIteration.SpikeTrainOrderSpikeValues = STO;
initialIteration.SpikeOrderSpikeValues = SO;
initialIteration.TimeProfileE = profile;
initialIteration.PairwiseMatrixD = matr;

optimalIteration = Iteration;
optimalIteration.Name = 'optimal';
optimalIteration.Order = st_indy_simann;
optimalIteration.SpikeTrains = OPTorderSpikes;
optimalIteration.SynfireIndicatorF = fin;
optimalIteration.SynchronizationValueC = SYNCvalue;
optimalIteration.SynchronizationProfile = SpikeSynchroProfile;
optimalIteration.SpikeTrainOrderSpikeValues = STOopt;
optimalIteration.SpikeOrderSpikeValues = SOopt;
optimalIteration.TimeProfileE = OPTprofile;
optimalIteration.PairwiseMatrixD = matrOpt;
end