function output_struct=analyze_osc_train_ms_fun_plot(spiketimes,par,field_names)
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

mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';


[mean_ISI_vect,std_ISI_vect,mean_ISI,std_ISI,nspikes]=spiketimes_stat(spiketimes);
% fprintf('spiketimes_stat takes\n');
% toc

[nspikes_sorted,indexes]=sort(nspikes);

% sim_time=min(sim_time,3000); % this prevents memory problems
% tic
% Rp_dt=4*dt; % too fine when n_neu=100
network_spikes=network_spiketimes(spiketimes,Rp_dt,sim_time);
% fprintf('network_spiketimes takes\n');
% toc

f_rate=1000.*mean(nspikes)./sim_time;
cv_ISI=std_ISI./mean_ISI;

[cv2_ISI_vect cv2_ISI]=spiketimes_stat_cv2(spiketimes);

[Lv_ISI_vect,Lv_ISI]=spiketimes_stat_lv(spiketimes);

[LvR_ISI_vect,LvR_ISI]=spiketimes_stat_lvr(spiketimes,t_refr);

[LCV_ISI_vect,LCV_ISI]=spiketimes_stat_lcv(spiketimes);

[IR_ISI_vect,IR_ISI]=spiketimes_stat_ir(spiketimes);

[ent_ISI_vect,ent_ISI]=spiketimes_stat_entropy(spiketimes);

[SM_ISI_vect,SM_ISI]=spiketimes_stat_SMiura(spiketimes);

% bursty_exc=burstiness(network_spikes_exc,n_exc,Rp_dt); % old way, using burstiness_040720.m, obsolete

bursty=burstiness(spiketimes);

params=struct('tapers',[5 9],'pad',0,'Fs',1000./Rp_dt,'fpass',[0.1 120],'err',0,'trialave',0);
[power_spectrum_mt,f_vect_mt]=mtspectrumc((network_spikes-mean(network_spikes))./std(network_spikes),params);

if ~par.PLOT
    clear network_spikes; % to save some memory ... only if we do not plot, otherwise we need it later
end

[psd_max psd_max_ind]=max(power_spectrum_mt);
psd_max_f=f_vect_mt(psd_max_ind);


f_high=30;
[psd_max_high psd_max_high_ind]=max(power_spectrum_mt.*(f_vect_mt'>=f_high));
psd_max_high_f=f_vect_mt(psd_max_high_ind);



tic
[MPC,MPCE,MPCI,phase_coherence_mat]=phase_coherence_ei(spiketimes,n_neu);
fprintf('phase_coherence takes\n');
toc

tic
[PPC,PPCE,PPCI,ppc_mat]=pairwise_phase_consistency_ei(spiketimes,n_neu);
fprintf('pairwise_phase_consistency takes\n');
toc

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


tic
%vR_tau=1.;
for tau_ind=1:length(tau_vect)
    tau=tau_vect(tau_ind);
    [vR(tau_ind),vRn(tau_ind)]=vanRossumv_allpairs(spiketimes,n_neu,tau);
    eval(['vR' num2str(tau) '=vR(tau_ind);']);
    eval(['vRn' num2str(tau) '=vRn(tau_ind);']);
end
fprintf('vanRossumv_allpairs takes\n');
toc


tic
for tau_ind=1:length(tau_vect)
    tau=tau_vect(tau_ind);
    % [HM(tau_ind),HME,HMI,HM_mat]=QuianQuiroga_allpairs(spiketimes,n_neu,tau);
    [QQ(tau_ind),qq(tau_ind)]=QuianQuiroga_allpairs(spiketimes,n_neu,tau);
    eval(['QQ' num2str(tau) '=QQ(tau_ind);']);
    eval(['qq' num2str(tau) '=qq(tau_ind);']);
end
fprintf('QuianQuiroga_allpairs takes\n');
toc

tic
[QQA,qqa]=QuianQuirogaA_allpairs(spiketimes,n_neu);
fprintf('QuianQuirogaA_allpairs takes\n');
toc

tic
[emd,emdn]=Wasserstein_allpairs(spiketimes,n_neu,par.sim_time);
fprintf('Wasserstein_allpairs takes\n');
toc

gauss_fun_h=fittype('((ampl_gauss./sqrt(2*pi*sigma_gauss*sigma_gauss)).*exp(-((x-mean_gauss)*(x-mean_gauss))/(2*sigma_gauss*sigma_gauss)))');

ampl_gauss_0=0.01;
mean_gauss_0=f_osc; % easy, we know it
sigma_gauss_0=1.;

ampl_gauss_l=0.;
% mean_gauss_l=0.1*mean_gauss_0;
mean_gauss_l=0.7*mean_gauss_0; % I think this should not go beyond the limits considered for the fit (we only care about fitting the peak, not so much the tails)
sigma_gauss_l=0.;

ampl_gauss_u=1000.;
% mean_gauss_u=10.*mean_gauss_0;
% mean_gauss_u=min(10.*mean_gauss_0,120);
mean_gauss_u=1.3*mean_gauss_0;
sigma_gauss_u=100.;

opts = fitoptions(gauss_fun_h);
opts = fitoptions(opts,'Startpoint',[ampl_gauss_0 mean_gauss_0 sigma_gauss_0]);
%     opts = fitoptions(opts,'DiffMinChange',1e-14);
%     opts = fitoptions(opts,'TolFun',1e-18,'TolX',1e-18);
opts = fitoptions(opts,'DiffMinChange',1e-24); % this might take a bit longer but that's ok
opts = fitoptions(opts,'TolFun',1e-36,'TolX',1e-36);
opts = fitoptions(opts,'MaxFunEvals',10000,'MaxIter',10000);
opts = fitoptions(opts,'Lower',[ampl_gauss_l mean_gauss_l sigma_gauss_l]);
opts = fitoptions(opts,'Upper',[ampl_gauss_u mean_gauss_u sigma_gauss_u]);
% opts = fitoptions(opts,'Algorithm','Levenberg-Marquardt');
% this algorithm sometimes returns a straight line instead of a gaussian
opts = fitoptions(opts,'Algorithm','Trust-Region');

% min_freq=max(0.,mean_gauss_0-5.);
% max_freq=mean_gauss_0+5.;
min_freq=mean_gauss_l;
max_freq=mean_gauss_u;
index_fit_start=find(f_vect_mt>min_freq,1);
index_fit_stop=find(f_vect_mt>max_freq,1);
if isempty(index_fit_stop)
    index_fit_stop=length(f_vect_mt);
end

while (index_fit_stop-index_fit_start<5)
%     min_freq=max(0.,mean_gauss_0-10.);
%     max_freq=mean_gauss_0+10.;
    min_freq=max(0.,min_freq-3.);
    max_freq=max_freq+3.;
    index_fit_start=find(f_vect_mt>min_freq,1);
    index_fit_stop=find(f_vect_mt>max_freq,1);
    if isempty(index_fit_stop)
        index_fit_stop=length(f_vect_mt);
    end
end

[fittedmodel fit_quality]=fit(f_vect_mt(index_fit_start:index_fit_stop)',power_spectrum_mt(index_fit_start:index_fit_stop),gauss_fun_h,opts);

ampl_gauss=fittedmodel.ampl_gauss;
mean_gauss=fittedmodel.mean_gauss;
sigma_gauss=fittedmodel.sigma_gauss;
spec_beta=fittedmodel.ampl_gauss*fittedmodel.mean_gauss/fittedmodel.sigma_gauss;
spec_rmse=fit_quality.rmse;





% if endswith(stringa,'ple') % let's do this for both ple and osc to see what happens
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

% min_freq=max(0.,mean_gauss_0-5.);
% max_freq=mean_gauss_0+5.;
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


% sigma_golomb=1.;
for tau_ind=1:length(tau_vect)
    tau=tau_vect(tau_ind);
    golomb_sync(tau_ind)=golomb_synchrony(spiketimes,sim_time,tau,10.*inct); % 10.*inct is the discretization resolution, no need to change it
    eval(['golomb_sync' num2str(tau) '=golomb_sync(tau_ind);']);
end

for tau_ind=1:length(tau_vect)
    tau=tau_vect(tau_ind);
    [schreiber_c(tau_ind), kruskal_c(tau_ind)]=schreiber_corr(spiketimes,sim_time,tau,10.*inct); % 10.*inct is the discretization resolution, no need to change it
    eval(['schreiber_c' num2str(tau) '=schreiber_c(tau_ind);']);
    eval(['kruskal_c' num2str(tau) '=kruskal_c(tau_ind);']);
end

tic
for tau_ind=1:length(tau_vect)
    tau=tau_vect(tau_ind);
    sttc(tau_ind)=spike_time_tiling_coefficient_wrapper(spiketimes,sim_time,tau);
    eval(['sttc' num2str(tau) '=sttc(tau_ind);']);
end
fprintf('sttc takes\n');
toc

tic
for tau_ind=1:length(tau_vect)
    tau=tau_vect(tau_ind);
    corr_ind(tau_ind)=correlation_index_wrapper(spiketimes,sim_time,tau);
    eval(['corr_ind' num2str(tau) '=corr_ind(tau_ind);']);
end
fprintf('corr ind takes\n');
toc

tic
Sc=SpikeContrastWrapper(spiketimes,sim_time);
fprintf('SpikeContrast takes\n');
toc

tic
% LZdist=LZ_distance(spiketimes,sim_time,10.*inct); % unnecessarily high resolution
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

tic
for tau_ind=1:length(tau_vect)
    tau=tau_vect(tau_ind);
    % [HM(tau_ind),HME,HMI,HM_mat]=HunterMilton_allpairs(spiketimes,n_neu,tau);
    [HM(tau_ind)]=HunterMilton_allpairs(spiketimes_wspikes,n_neu,tau);
    eval(['HM' num2str(tau) '=HM(tau_ind);']);
end
fprintf('HunterMilton_allpairs takes\n');
toc

tic
modulus_m=modulus_metric_wrapper(spiketimes_wspikes,sim_time);
modulus_mn=modulus_m./sim_time;
fprintf('modulus metric takes\n');
toc


% InitializecSPIKE
STS=SpikeTrainSet(spikes,para.tmin,para.tmax);

tic
SPIKY_ISI   = STS.ISIdistance(para.tmin, para.tmax);
fprintf('SPIKY_ISI takes\n');
toc

tic
SPIKY_SPIKE = STS.SPIKEdistance(para.tmin, para.tmax);
fprintf('SPIKY_SPIKE takes\n');
toc

tic
SPIKY_SPIKE_synchro = STS.SPIKEsynchro(para.tmin,para.tmax);
fprintf('SPIKY_SPIKE_synchro takes\n');
toc


tic
SPIKY_SPIKE_order = STS.SpikeTrainOrderWithSurrogates(0);
SPIKY_SPIKE_order=SPIKY_SPIKE_order.SynfireIndicatorF;
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

if par.PLOT
    printf('get(groot, ''DefaultAxesFontSize'') returns %d',get(groot, 'DefaultAxesFontSize'));    
    fh=figure();
    plot(f_vect_mt,power_spectrum_mt,'r');
    hold on;
    plot(fittedmodel,'k');
    legend('mt','fit');
    xlabel('f [Hz]');
    ylabel('power');
    title(['         ' strrep(par.stringa,'_',' ')],'FontWeight','normal','Interpreter','none'); % some spaces to avoid overlap with a yticklabel
    figure_name=strcat(par.figDir,filesep,par.stringa,'_LFP_mtspec_zoom','.png');
    hgexport(fh,figure_name,mystyle,'Format','png');
    
    
    
    fh=figure();
    set(gcf,'Color',[1 1 1]);
    ca=axes('Position', [0.1 0.12 0.87 0.6]);
    for i=1:n_neu
        plot(spiketimes(indexes(i)).t,i*ones(length(spiketimes(indexes(i)).t),1),'b.','MarkerSize',6);
        hold on;
    end
    % xlim([0 300]);
    xlim([0 plot_win_zoom]);
    xlabel('t [ms]');
    ylabel('neuron index');
    
    ca=axes('Position', [0.1 0.75 0.87 0.2]);
    %     plot(0:Rp_dt:sim_time,30*network_spikes+n_neu+n_neu/8,'b');
    %     hold on;
    %     plot(0:Rp_dt:sim_time,30*network_spikes_inh+n_neu+2.5*n_neu/8,'r');
    plot(0:Rp_dt:sim_time,network_spikes,'b');
    % xlim([0 300]);
    xlim([0 plot_win_zoom]);
    set(ca,'XTick',[]);
    ylabel('network spikes');
    title(strrep(par.stringa,'_',' '),'FontWeight','normal','Interpreter','none');
    set(gcf,'Position',[1          25        1280         669]);
    %    keyboard;
    figure_name=strcat(par.figDir,filesep,par.stringa,'_lfp_pointraster_zoom_v2','.png');
    hgexport(fh,figure_name,mystyle,'Format','png');
end

for kk=1:length(field_names)
    eval(['output_struct.' field_names{kk} '=' field_names{kk} ';']);
end

return;
