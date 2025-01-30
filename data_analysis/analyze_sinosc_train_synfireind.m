function output_struct=analyze_sinosc_train_synfireind(stringa,par)
% analyzes spike trains

% PLOT_print=1;

par_this=par; % probably unused

if ~isdeployed
    eval(['cd ' stringa ';']);
    load(stringa, 'spiketimes','r_ts');
else
    fullfile(pwd,stringa,stringa)
    load(fullfile(pwd,stringa,stringa),'spiketimes','r_ts');
end

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
tau_vect=[2.^[0:6]];

par_string={'t_refr','n_neu','rate','r_osc_ampl','f_osc','transient','sim_time','seed','inct','Rp_dt','PLOT_print','tau_vect'};


for i=1:length(par_string)
    if(isfield(par,par_string(i)))
        eval([char(par_string(i)) '=par.' char(par_string(i)) ';']);
    end
end


for i=1:length(par_string)
    eval(['par.' char(par_string(i)) '=' char(par_string(i)) ';']);
end

dt=inct;

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
spikes=cell(1,spiky_neu);
% for neu=1:n_neu
for neu=1:spiky_neu % trying with just the first spiky_neu neurons ...
    spikes{neu}=spiketimes(neu).t'; % need to be row vectors
end

% % InitializecSPIKE
% STS=SpikeTrainSet(spikes,para.tmin,para.tmax);
% 
% tic
% SPIKY_ISI = STS.ISIdistance(para.tmin, para.tmax);
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



ind_neu_with_spikes=0;
silent_neurons=0;
for neu=1:spiky_neu
    if ~isempty(spiketimes(neu).t)
        ind_neu_with_spikes=ind_neu_with_spikes+1;
        spikes_with_spikes{ind_neu_with_spikes}=spiketimes(neu).t'; % need to be row vectors
    else
        silent_neurons=silent_neurons+1;
    end
end

% InitializecSPIKE
STS=SpikeTrainSet(spikes_with_spikes,para.tmin,para.tmax);

% the values given by these measures are actually different from those returned if spikes_with_spikes is used instead of spikes
%
% tic
% SPIKY_ISI_with_spikes = STS.ISIdistance(para.tmin, para.tmax);
% fprintf('SPIKY_ISI takes\n');
% toc
%
% tic
% SPIKY_SPIKE_with_spikes = STS.SPIKEdistance(para.tmin, para.tmax);
% fprintf('SPIKY_SPIKE takes\n');
% toc
%
% tic
% SPIKY_SPIKE_synchro_with_spikes = STS.SPIKEsynchro(para.tmin,para.tmax);
% fprintf('SPIKY_SPIKE_synchro takes\n');
% toc

tic
% SPIKY_SPIKE_order = STS.SpikeTrainOrderWithSurrogates(0); % this gives an error if there are neurons with no spikes
% SPIKY_SPIKE_order=SPIKY_SPIKE_order.SynfireIndicatorF;
[initialIteration,optimalIteration] = STS.SpikeTrainOrderWithSurrogates(0); % this gives an error if there are neurons with no spikes
synfire_ind=optimalIteration.SynfireIndicatorF;
fprintf('SPIKY_SPIKE_order takes\n');
toc


output_struct=[];

clear initialIteration optimalIteration;
clear layout v_out gsyn_out spiketimes network_spikes network_spikes_inh mean_ISI_evol std_ISI_evol mean_ISI_inh_evol std_ISI_inh_evol;
clear f_vect_65536 f_vect_all network_spikes* spiketimes network_spikes_inh_*;
clear pcd_rows pcd_cols phase_coherence_inh_sub fh ca;
clear isi_vect isi_vect_inh isi_vect_high isi_vect_low isi_vect_mid isi_vect_this;
clear phase_coherence_mat ppc_mat; % too heavy to save for each sim
clear r_ts STS spikes spikes_with_spikes;
% close all;
whos

if ~isdeployed
    save output_all_synfireind;
    cd ..
else
    fullfile(pwd,stringa,'output_all_synfireind')
    save(fullfile(pwd,stringa,'output_all_synfireind'));
end
return;
