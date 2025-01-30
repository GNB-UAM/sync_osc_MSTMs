function output_struct=analyze_osc_train_synfireind_fun_plot(spiketimes,par,field_names)
% analyzes spike trains

t_refr=4.;
n_neu=400;    % number of neurons
rate=12.; % avg rate [Hz]
r_osc_ampl=0.5;    % relative amplitude of the sinusoidal modulation (between 0 and 1)
f_osc=12.; % network frequency (alpha frequency by default)
transient=0.0;
sim_time=10000;
seed=0;
inct=0.01;        % simulation time step
Rp_dt=10.*inct; % time step for population spike binning
plot_win_zoom=300;
tau_vect=[2.^[0:6]];

par_string={'t_refr','n_neu','rate','r_osc_ampl','f_osc','transient','sim_time','seed','inct','Rp_dt','plot_win_zoom','tau_vect'};


for i=1:length(par_string)
    if(isfield(par,par_string(i)))
        eval([char(par_string(i)) '=par.' char(par_string(i)) ';']);
    end
end


for i=1:length(par_string)
    eval(['par.' char(par_string(i)) '=' char(par_string(i)) ';']);
end

% m_para.all_measures_string={'ISI';'SPIKE';'SPIKE_realtime';'SPIKE_forward';'SPIKE_synchro';'SPIKE_order';'PSTH'};  % order of select_measures
% para.select_measures      =[1 1 0 0 1 1 0];  % Select measures (0-calculate,1-do not calculate)
para.select_measures      =[0 0 0 0 0 1 0];  % Select measures (0-calculate,1-do not calculate)
% para.select_measures      =[1 1 0 0 0 1 0];  % Select measures (0-calculate,1-do not calculate) - SPIKE_synchro is giving problems
% para.select_measures      =[1 1 0 0 1 0 0];  % Select measures (0-calculate,1-do not calculate) - SPIKE_order is giving problems ... this takes a loong time (because of SPIKE_synchro I guess)
% para.select_measures      =[1 1 0 0 0 0 0];  % Select measures (0-calculate,1-do not calculate) - also takes a very long time and generates many big mat files...
% para.select_measures      =[1 0 0 0 0 0 0];  % Select measures (0-calculate,1-do not calculate) - this also takes a long time and generates 38 big (~750MB) mat files...

para.tmin=0; para.tmax=sim_time;
para.dts=10.*inct; % this is the discretization resolution, no need to change it
% para.dts=100.*inct; % trying to see if this helps... doesn't seem to help much, also generates 38 big (~750MB) mat files...
spiky_neu=n_neu; % for this with n_neu=400 we need at least 28 GB of RAM. with n_neu=100 it runs fine
% spiky_neu=50; % trying with just the first 50 neurons ... this is actually pretty fast for the 4 measures
% para.num_trains=n_neu;
% spikes=cell(1,n_neu);
para.num_trains=spiky_neu;
% spikes=cell(1,spiky_neu); % we might have to remove some neurons with no spikes
neu_spiky=0; % we will use this to count the neurons that spike in the current window
% for neu=1:n_neu
for neu=1:spiky_neu % trying with just the first spiky_neu neurons ...
    if ~isempty(spiketimes(neu).t)
        neu_spiky=neu_spiky+1;
        spikes{neu_spiky}=spiketimes(neu).t'; % need to be row vectors
        spiketimes_wspikes(neu_spiky).t=spiketimes(neu).t;
    end
end
para.num_trains=neu_spiky;

% InitializecSPIKE
STS=SpikeTrainSet(spikes,para.tmin,para.tmax);

% tic
% SPIKY_ISI   = STS.ISIdistance(para.tmin, para.tmax);
% fprintf('SPIKY_ISI takes\n');
% toc
% 
% tic
% SPIKY_SPIKE = STS.SPIKEdistance(para.tmin, para.tmax);
% fprintf('SPIKY_SPIKE takes\n');
% toc
% 
% tic
% SPIKY_SPIKE_synchro = STS.SPIKEsynchro(para.tmin,para.tmax);
% fprintf('SPIKY_SPIKE_synchro takes\n');
% toc


tic
% SPIKY_SPIKE_order = STS.SpikeTrainOrderWithSurrogates(0);
% SPIKY_SPIKE_order=SPIKY_SPIKE_order.SynfireIndicatorF;
[initialIteration,optimalIteration] = STS.SpikeTrainOrderWithSurrogates(0); % this gives an error if there are neurons with no spikes
synfire_ind=optimalIteration.SynfireIndicatorF;
fprintf('SPIKY_SPIKE_order takes\n');
toc

% these two give identical result
% tic
% SPIKY_SPIKE_order = STS.SpikeTrainOrderWithSurrogates;
% SPIKY_SPIKE_order_val=SPIKY_SPIKE_order.SynfireIndicatorF;
% fprintf('SPIKY_SPIKE_order takes\n');
% toc
% 
% tic
% SPIKY_SPIKE_order_nosurr = STS.SpikeTrainOrderWithSurrogates(0);
% SPIKY_SPIKE_order_nosurr_val=SPIKY_SPIKE_order_nosurr.SynfireIndicatorF;
% fprintf('SPIKY_SPIKE_order with 0 surrogates takes\n');
% toc
% 
% keyboard;

clear STS;

% tic
% SPIKY_loop_results = SPIKY_loop_f_distances(spikes,para); % this does not result very convenient for this number of neurons and this spike train length... see above
% fprintf('SPIKY takes\n');
% toc
% SPIKY_ISI=SPIKY_loop_results.ISI.overall;
% SPIKY_SPIKE=SPIKY_loop_results.SPIKE.overall;
% SPIKY_SPIKE_synchro=SPIKY_loop_results.SPIKE_synchro.overall;
% SPIKY_SPIKE_order=SPIKY_loop_results.SPIKE_order.overall;
% clear SPIKY_loop_results;


for kk=1:length(field_names)
    eval(['output_struct.' field_names{kk} '=' field_names{kk} ';']);
end

return;
