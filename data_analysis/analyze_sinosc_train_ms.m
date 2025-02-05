function output_struct=analyze_sinosc_train_ms(stringa,par)
% analyzes spike trains

PLOT_print=1;

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

mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';


[mean_ISI_vect,std_ISI_vect,mean_ISI,std_ISI,nspikes]=spiketimes_stat(spiketimes);

if contains(stringa,'seq')
    indexes=1:n_neu;
else
    [nspikes_sorted,indexes]=sort(nspikes);
end

network_spikes=network_spiketimes(spiketimes,Rp_dt,sim_time);

% Mean firing rate
f_rate=1000.*mean(nspikes)./sim_time;

% ISI CV
cv_ISI=std_ISI./mean_ISI;

% ISI CV2
[cv2_ISI_vect cv2_ISI]=spiketimes_stat_cv2(spiketimes);

% Local variation
[Lv_ISI_vect,Lv_ISI]=spiketimes_stat_lv(spiketimes);

% Revised local variation
[LvR_ISI_vect,LvR_ISI]=spiketimes_stat_lvr(spiketimes,t_refr);

% ISI log CV
[LCV_ISI_vect,LCV_ISI]=spiketimes_stat_lcv(spiketimes);

% Irregularity
[IR_ISI_vect,IR_ISI]=spiketimes_stat_ir(spiketimes);

% Log ISI entropy
[ent_ISI_vect,ent_ISI]=spiketimes_stat_entropy(spiketimes);

% Miura ISI irregularity
[SM_ISI_vect,SM_ISI]=spiketimes_stat_SMiura(spiketimes);

% Tiesinga--Sejnowski synchrony
bursty=burstiness(spiketimes);

params=struct('tapers',[5 9],'pad',0,'Fs',1000./Rp_dt,'fpass',[0.1 120],'err',0,'trialave',0);
[power_spectrum_mt,f_vect_mt]=mtspectrumc((network_spikes-mean(network_spikes))./std(network_spikes),params);

[psd_max psd_max_ind]=max(power_spectrum_mt);
psd_max_f=f_vect_mt(psd_max_ind);


f_high=30;
[psd_max_high psd_max_high_ind]=max(power_spectrum_mt.*(f_vect_mt'>=f_high));
psd_max_high_f=f_vect_mt(psd_max_high_ind);


% Mean Phase Coherence
tic
[MPC,MPCE,MPCI,phase_coherence_mat]=phase_coherence_ei(spiketimes,n_neu);
fprintf('phase_coherence takes\n');
toc

% Pairwise phase consistency
tic
[PPC,PPCE,PPCI,ppc_mat]=pairwise_phase_consistency_ei(spiketimes,n_neu);
fprintf('pairwise_phase_consistency takes\n');
toc

% Victor--Purpura distance
% Normalized Victor--Purpura distance
tic
% VPq=1.;
for tau_ind=1:length(tau_vect)
    tau=tau_vect(tau_ind);
    [VP(tau_ind),VPN(tau_ind)]=VictorPurpuramex_allpairs(spiketimes,n_neu,1./tau);
    eval(['VP' num2str(tau) '=VP(tau_ind);']);
    eval(['VPN' num2str(tau) '=VPN(tau_ind);']);
end
fprintf('VictorPurpuramex_allpairs takes\n');
toc

% Van Rossum distance
% Normalized van Rossum distance
tic
for tau_ind=1:length(tau_vect)
    tau=tau_vect(tau_ind);
    [vR(tau_ind),vRn(tau_ind)]=vanRossumv_allpairs(spiketimes,n_neu,tau);
    eval(['vR' num2str(tau) '=vR(tau_ind);']);
    eval(['vRn' num2str(tau) '=vRn(tau_ind);']);
end
fprintf('vanRossumv_allpairs takes\n');
toc

% Hunter--Milton similarity
tic
for tau_ind=1:length(tau_vect)
    tau=tau_vect(tau_ind);
    [HM(tau_ind)]=HunterMilton_allpairs(spiketimes,n_neu,tau);
    eval(['HM' num2str(tau) '=HM(tau_ind);']);
end
fprintf('HunterMilton_allpairs takes\n');
toc

% Quian Quiroga event synchronization
% Quian Quiroga delay asymmetry
tic
for tau_ind=1:length(tau_vect)
    tau=tau_vect(tau_ind);
    [QQ(tau_ind),qq(tau_ind)]=QuianQuiroga_allpairs(spiketimes,n_neu,tau);
    eval(['QQ' num2str(tau) '=QQ(tau_ind);']);
    eval(['qq' num2str(tau) '=qq(tau_ind);']);
end
fprintf('QuianQuiroga_allpairs takes\n');
toc

% Quian Quiroga event synchronization, timescale adaptive version
% Quian Quiroga delay asymmetry, timescale adaptive version
tic
[QQA,qqa]=QuianQuirogaA_allpairs(spiketimes,n_neu);
fprintf('QuianQuirogaA_allpairs takes\n');
toc

% Earth Mover’s Distance
% Normalized Earth Mover’s Distance
tic
[emd,emdn]=Wasserstein_allpairs(spiketimes,n_neu,par.sim_time);
fprintf('Wasserstein_allpairs takes\n');
toc


% the part below fits a Gaussian to the PSD peak. The resulting measures were not included in the final version of the article, since FOOOF fitting was used instead

gauss_fun_h=fittype('((ampl_gauss./sqrt(2*pi*sigma_gauss*sigma_gauss)).*exp(-((x-mean_gauss)*(x-mean_gauss))/(2*sigma_gauss*sigma_gauss)))');

ampl_gauss_0=0.01;
mean_gauss_0=f_osc; % easy, we know it
sigma_gauss_0=1.;

ampl_gauss_l=0.;
mean_gauss_l=0.7*mean_gauss_0; % I think this should not go beyond the limits considered for the fit (we only care about fitting the peak, not so much the tails)
sigma_gauss_l=0.;

ampl_gauss_u=1000.;
mean_gauss_u=1.3*mean_gauss_0;
sigma_gauss_u=100.;

opts = fitoptions(gauss_fun_h);
opts = fitoptions(opts,'Startpoint',[ampl_gauss_0 mean_gauss_0 sigma_gauss_0]);
opts = fitoptions(opts,'DiffMinChange',1e-24); % this might take a bit longer but that's ok
opts = fitoptions(opts,'TolFun',1e-36,'TolX',1e-36);
opts = fitoptions(opts,'MaxFunEvals',10000,'MaxIter',10000);
opts = fitoptions(opts,'Lower',[ampl_gauss_l mean_gauss_l sigma_gauss_l]);
opts = fitoptions(opts,'Upper',[ampl_gauss_u mean_gauss_u sigma_gauss_u]);
% opts = fitoptions(opts,'Algorithm','Levenberg-Marquardt');
% this algorithm sometimes returns a straight line instead of a gaussian
opts = fitoptions(opts,'Algorithm','Trust-Region');

min_freq=mean_gauss_l;
max_freq=mean_gauss_u;
index_fit_start=find(f_vect_mt>min_freq,1);
index_fit_stop=find(f_vect_mt>max_freq,1);
if isempty(index_fit_stop)
    index_fit_stop=length(f_vect_mt);
end
[fittedmodel fit_quality]=fit(f_vect_mt(index_fit_start:index_fit_stop)',power_spectrum_mt(index_fit_start:index_fit_stop),gauss_fun_h,opts);





ampl_gauss_0=psd_max;
mean_gauss_0=psd_max_f;
sigma_gauss_0=1.;

ampl_gauss_l=0.;
mean_gauss_l=0.7*mean_gauss_0;
sigma_gauss_l=0.;

ampl_gauss_u=1000.;
mean_gauss_u=1.3*mean_gauss_0;
sigma_gauss_u=100.;

win_increase_inc=0;

while (mean_gauss_u-mean_gauss_l)<2.4    % this limit corresponds to fit1 for f_osc=4
    win_increase_inc=win_increase_inc+1;
    mean_gauss_l=max(0.,0.1*(7-win_increase_inc)*mean_gauss_0);
    mean_gauss_u=0.1*(13+win_increase_inc)*mean_gauss_0;
end

opts = fitoptions(opts,'Startpoint',[ampl_gauss_0 mean_gauss_0 sigma_gauss_0]);
opts = fitoptions(opts,'Lower',[ampl_gauss_l mean_gauss_l sigma_gauss_l]);
opts = fitoptions(opts,'Upper',[ampl_gauss_u mean_gauss_u sigma_gauss_u]);

min_freq=mean_gauss_l;
max_freq=mean_gauss_u;
index_fit_start=find(f_vect_mt>min_freq,1);
index_fit_stop=find(f_vect_mt>max_freq,1);
if isempty(index_fit_stop)
    index_fit_stop=length(f_vect_mt);
end
[fittedmodel2 fit_quality2]=fit(f_vect_mt(index_fit_start:index_fit_stop)',power_spectrum_mt(index_fit_start:index_fit_stop),gauss_fun_h,opts);

if fit_quality.rmse<fit_quality2.rmse

    ampl_gauss=fittedmodel.ampl_gauss;
    mean_gauss=fittedmodel.mean_gauss;
    sigma_gauss=fittedmodel.sigma_gauss;
    spec_beta=fittedmodel.ampl_gauss*fittedmodel.mean_gauss/fittedmodel.sigma_gauss;
    spec_rmse=fit_quality.rmse;
    fit1=1; % success with fit1

else

    ampl_gauss=fittedmodel2.ampl_gauss;
    mean_gauss=fittedmodel2.mean_gauss;
    sigma_gauss=fittedmodel2.sigma_gauss;
    spec_beta=fittedmodel2.ampl_gauss*fittedmodel2.mean_gauss/fittedmodel2.sigma_gauss;
    spec_rmse=fit_quality2.rmse;
    fit1=0;

end

% Golomb--Rinzel synchrony
for tau_ind=1:length(tau_vect)
    tau=tau_vect(tau_ind);
    golomb_sync(tau_ind)=golomb_synchrony(spiketimes,sim_time,tau,10.*inct); % 10.*inct is the discretization resolution, no need to change it
    eval(['golomb_sync' num2str(tau) '=golomb_sync(tau_ind);']);
end

% Schreiber correlation
% Kruskal correlation
for tau_ind=1:length(tau_vect)
    tau=tau_vect(tau_ind);
    [schreiber_c(tau_ind), kruskal_c(tau_ind)]=schreiber_corr(spiketimes,sim_time,tau,10.*inct); % 10.*inct is the discretization resolution, no need to change it
    eval(['schreiber_c' num2str(tau) '=schreiber_c(tau_ind);']);
    eval(['kruskal_c' num2str(tau) '=kruskal_c(tau_ind);']);
end

% Spike time tiling coefficient
tic
for tau_ind=1:length(tau_vect)
    tau=tau_vect(tau_ind);
    sttc(tau_ind)=spike_time_tiling_coefficient_wrapper(spiketimes,sim_time,tau);
    eval(['sttc' num2str(tau) '=sttc(tau_ind);']);
end
fprintf('sttc takes\n');
toc

% Correlation index
tic
for tau_ind=1:length(tau_vect)
    tau=tau_vect(tau_ind);
    corr_ind(tau_ind)=correlation_index_wrapper(spiketimes,sim_time,tau);
    eval(['corr_ind' num2str(tau) '=corr_ind(tau_ind);']);
end
fprintf('corr ind takes\n');
toc

% Modulus-Metric Distance
% Normalized Modulus-Metric Distance
tic
modulus_m=modulus_metric_wrapper(spiketimes,sim_time);
modulus_mn=modulus_m./sim_time;
fprintf('modulus metric takes\n');
toc

% Spike-Contrast
tic
Sc=SpikeContrastWrapper(spiketimes,sim_time);
fprintf('SpikeContrast takes\n');
toc

% LZ-distance
tic
LZdist=LZ_distance(spiketimes,sim_time,1.); % one order of magnitude larger
fprintf('LZ_distance takes\n');
toc


% m_para.all_measures_string={'ISI';'SPIKE';'SPIKE_realtime';'SPIKE_forward';'SPIKE_synchro';'SPIKE_order';'PSTH'};  % order of select_measures
para.select_measures      =[1 1 0 0 1 1 0];  % Select measures (0-calculate,1-do not calculate)
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
for neu=1:spiky_neu % trying with just the first spiky_neu neurons ...
    spikes{neu}=spiketimes(neu).t'; % need to be row vectors
end

% InitializecSPIKE
STS=SpikeTrainSet(spikes,para.tmin,para.tmax);

% ISI-distance
tic
SPIKY_ISI = STS.ISIdistance(para.tmin, para.tmax);
fprintf('SPIKY_ISI takes\n');
toc

% SPIKE-distance
tic
SPIKY_SPIKE = STS.SPIKEdistance(para.tmin, para.tmax);
fprintf('SPIKY_SPIKE takes\n');
toc

% SPIKE-synchronization
tic
SPIKY_SPIKE_synchro = STS.SPIKEsynchro(para.tmin,para.tmax);
fprintf('SPIKY_SPIKE_synchro takes\n');
toc



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

% Synfire indicator corresponding to the original neuron index ordering - not used in the paper
% Synfire indicator as used in the paper (corresponding to the optimal ordering of neurons from leaders to followers) is calculated in analyze_sinosc_train_synfireind.m
tic
SPIKY_SPIKE_order = STS.SpikeTrainOrderWithSurrogates(0); % this gives an error if there are neurons with no spikes
SPIKY_SPIKE_order=SPIKY_SPIKE_order.SynfireIndicatorF;
fprintf('SPIKY_SPIKE_order takes\n');
toc


fh=figure();
plot(f_vect_mt,power_spectrum_mt,'r');
hold on;
plot(fittedmodel,'k');
plot(fittedmodel2,'g');
% plot(fittedmodel2,'Color',0.7*ones(1,3));
legend('mt','fit1','fit2');
xlabel('f [Hz]');
ylabel('power');
title(['fit1=' num2str(fit1,'%i')],'FontWeight','normal');
if PLOT_print
    figure_name=strcat('LFP_mtspec_zoom','.png');
    if ~isdeployed
        hgexport(fh,figure_name,mystyle,'Format','png');
    else
        fullfile(pwd,stringa,figure_name)
        hgexport(fh,fullfile(pwd,stringa,figure_name),mystyle,'Format','png');
    end
end



xlim_max=1000;
xlim_max=min([xlim_max,sim_time]);
fh=figure();
set(gcf,'Color',[1 1 1]);
ca=axes('Position', [0.1 0.12 0.87 0.5]);
for i=1:n_neu
    plot(spiketimes(indexes(i)).t,i*ones(length(spiketimes(indexes(i)).t),1),'b.','MarkerSize',6);
    hold on;
end
xlim([0 xlim_max]);
xlabel('t [ms]');
ylabel('neuron index');

ca=axes('Position', [0.1 0.65 0.87 0.13]);
plot(0:Rp_dt:sim_time,network_spikes,'b');
xlim([0 xlim_max]);
set(ca,'XTick',[]);
ylabel('network spikes');

ca=axes('Position', [0.1 0.81 0.87 0.13]);
try
    plot(0:inct*10:(sim_time-inct*10),r_ts); % plotting different phases in different colors for the case of seq trains
catch
    plot(0:inct*10:(sim_time-inct*10),r_ts(:,1:end-1)); % plotting different phases in different colors for the case of seq trains
end
xlim([0 xlim_max]);
set(ca,'XTick',[]);
ylabel('r');

set(gcf,'Position',[1          25        1280         669]);
if PLOT_print
    figure_name=strcat('lfp_pointraster_zoom_v3','.png');
    if ~isdeployed
        hgexport(fh,figure_name,mystyle,'Format','png');
    else
        fullfile(pwd,stringa,figure_name)
        hgexport(fh,fullfile(pwd,stringa,figure_name),mystyle,'Format','png');
    end
end
output_struct=[];

clear layout v_out gsyn_out spiketimes network_spikes network_spikes_inh mean_ISI_evol std_ISI_evol mean_ISI_inh_evol std_ISI_inh_evol;
clear f_vect_65536 f_vect_all network_spikes* spiketimes network_spikes_inh_*;
clear pcd_rows pcd_cols phase_coherence_inh_sub fh ca;
clear isi_vect isi_vect_inh isi_vect_high isi_vect_low isi_vect_mid isi_vect_this;
clear phase_coherence_mat ppc_mat; % too heavy to save for each sim
clear r_ts STS spikes spikes_with_spikes;
% close all;
whos

if ~isdeployed
    save output_all_ms;
    cd ..
else
    fullfile(pwd,stringa,'output_all_ms')
    save(fullfile(pwd,stringa,'output_all_ms'));
end
return;
