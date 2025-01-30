function output_struct=analyze_osc_train_fooof_fun_plot(spiketimes,par,field_names)
% analyzes spike trains

addpath('~/libraries/fooof_mat-main/fooof_mat/');

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

dt=inct;
sigma=Rp_dt; % ksdensity kernel width



[mean_ISI_vect,std_ISI_vect,mean_ISI,std_ISI,nspikes]=spiketimes_stat(spiketimes);
% fprintf('spiketimes_stat takes\n');
% toc

if contains(par.stringa,'seq')
    indexes=1:n_neu;
else
    [nspikes_sorted,indexes]=sort(nspikes);
end



% t_vect=0:inct:sim_time; % we probably don't need such a high res
t_vect=0:Rp_dt:sim_time;
n_neu=length(spiketimes);
spikeks=zeros(n_neu,length(t_vect)); % spike density
for neu=1:n_neu
    spikes_this=spiketimes(neu).t;

    if isempty(spikes_this)
        spikeks(neu,:)=zeros(1,length(t_vect));
    else
        spikeks(neu,:)=ksdensity(spikes_this,t_vect,'Bandwidth',sigma);
    end
end
spikeks=mean(spikeks);

% spikeks_1ms=zeros(n_neu,length(t_vect)); % spike density
% for neu=1:n_neu
%     spikes_this=spiketimes(neu).t;
%
%     if isempty(spikes_this)
%         spikeks_1ms(neu,:)=zeros(1,length(t_vect));
%     else
%         spikeks_1ms(neu,:)=ksdensity(spikes_this,t_vect,'Bandwidth',10.*sigma);
%     end
% end
% spikeks_1ms=mean(spikeks_1ms);


% params=struct('tapers',[5 9],'pad',0,'Fs',1000./Rp_dt,'fpass',[0.1 120],'err',0,'trialave',0); % make sure sampling frequency corresponds with t_vect above
% [power_spectrum_mt,f_vect_mt]=mtspectrumc((spikeks-mean(spikeks))./std(spikeks),params);

params_10_19=struct('tapers',[10 19],'pad',0,'Fs',1000./Rp_dt,'fpass',[0.1 120],'err',0,'trialave',0); % make sure sampling frequency corresponds with t_vect above
[power_spectrum_mt_10_19,f_vect_mt_10_19]=mtspectrumc((spikeks-mean(spikeks))./std(spikeks),params_10_19);

% [power_spectrum_mt_10_19_1ms,f_vect_mt_10_19_1ms]=mtspectrumc((spikeks_1ms-mean(spikeks_1ms))./std(spikeks_1ms),params_10_19);

mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

dist_colors = distinguishable_colors(50);
orange=dist_colors(21,:); % orange
cyan=dist_colors(23,:); % cyan

% fh=figure();
% set(gcf,'Color',[1 1 1]);
% plot(f_vect_mt,power_spectrum_mt,'r');
% hold on;
% % plot(fittedmodel,'k');
% % plot(fittedmodel2,'g');
% % % plot(fittedmodel2,'Color',0.7*ones(1,3));
% % legend('mt','fit1','fit2');
% xlabel('f [Hz]');
% ylabel('power');
% % title(['fit1=' num2str(fit1,'%i')],'FontWeight','normal');
% if PLOT_print
%     figure_name=strcat('LFP_mtspec_ks_zoom','.png');
%     if ~isdeployed
%         hgexport(fh,figure_name,mystyle,'Format','png');
%     else
%         fullfile(pwd,stringa,figure_name)
%         hgexport(fh,fullfile(pwd,stringa,figure_name),mystyle,'Format','png');
%     end
% end

% fh=figure();
% set(gcf,'Color',[1 1 1]);
% plot(f_vect_mt_10_19,power_spectrum_mt_10_19,'r');
% hold on;
% % plot(fittedmodel,'k');
% % plot(fittedmodel2,'g');
% % % plot(fittedmodel2,'Color',0.7*ones(1,3));
% % legend('mt','fit1','fit2');
% xlabel('f [Hz]');
% ylabel('power');
% % title(['fit1=' num2str(fit1,'%i')],'FontWeight','normal');
% if PLOT_print
%     figure_name=strcat('LFP_mtspec_10_19_ks_zoom','.png');
%     if ~isdeployed
%         hgexport(fh,figure_name,mystyle,'Format','png');
%     else
%         fullfile(pwd,stringa,figure_name)
%         hgexport(fh,fullfile(pwd,stringa,figure_name),mystyle,'Format','png');
%     end
% end


% fh=figure();
% set(gcf,'Color',[1 1 1]);
% plot(f_vect_mt_10_19_1ms,power_spectrum_mt_10_19_1ms,'r');
% hold on;
% % plot(fittedmodel,'k');
% % plot(fittedmodel2,'g');
% % % plot(fittedmodel2,'Color',0.7*ones(1,3));
% % legend('mt','fit1','fit2');
% xlabel('f [Hz]');
% ylabel('power');
% % title(['fit1=' num2str(fit1,'%i')],'FontWeight','normal');
% if PLOT_print
%     figure_name=strcat('LFP_mtspec_10_19_1ms_ks_zoom','.png');
%     if ~isdeployed
%         hgexport(fh,figure_name,mystyle,'Format','png');
%     else
%         fullfile(pwd,stringa,figure_name)
%         hgexport(fh,fullfile(pwd,stringa,figure_name),mystyle,'Format','png');
%     end
% end

if ~par.PLOT
    clear spiketimes spikeks r_ts; % to save some memory ... only if we do not plot, otherwise we need it later
else
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
    %     plot(0:Rp_dt:sim_time,30*network_spikes+n_neu+n_neu/8,'b');
    %     hold on;
    %     plot(0:Rp_dt:sim_time,30*network_spikes_inh+n_neu+2.5*n_neu/8,'r');
    plot(0:Rp_dt:sim_time,spikeks,'b');
    xlim([0 xlim_max]);
    set(ca,'XTick',[]);
    ylabel('network spikes');

    ca=axes('Position', [0.1 0.81 0.87 0.13]);
    %     plot(0:Rp_dt:sim_time,30*network_spikes+n_neu+n_neu/8,'b');
    %     hold on;
    %     plot(0:Rp_dt:sim_time,30*network_spikes_inh+n_neu+2.5*n_neu/8,'r');
    % plot(0:inct*10:(sim_time-inct*10),r_ts,'b');
    % try
    %     plot(0:inct*10:(sim_time-inct*10),r_ts); % plotting different phases in different colors for the case of seq trains
    % catch
    %     plot(0:inct*10:(sim_time-inct*10),r_ts(:,1:end-1)); % plotting different phases in different colors for the case of seq trains
    % end
    xlim([0 xlim_max]);
    set(ca,'XTick',[]);
    ylabel('r');

    set(gcf,'Position',[1          25        1280         669]);
    figure_name=strcat(par.figDir,filesep,par.stringa,'_lfp_pointraster_ks_zoom_v3','.png');
    hgexport(fh,figure_name,mystyle,'Format','png');
    clear spiketimes spikeks r_ts; % to save some memory
end

% fh=figure();
% set(gcf,'Color',[1 1 1]);
% ca=axes('Position', [0.1 0.12 0.87 0.5]);
% for i=1:n_neu
%     plot(spiketimes(indexes(i)).t,i*ones(length(spiketimes(indexes(i)).t),1),'b.','MarkerSize',6);
%     hold on;
% end
% xlim([0 xlim_max]);
% xlabel('t [ms]');
% ylabel('neuron index');
%
% ca=axes('Position', [0.1 0.65 0.87 0.13]);
% %     plot(0:Rp_dt:sim_time,30*network_spikes+n_neu+n_neu/8,'b');
% %     hold on;
% %     plot(0:Rp_dt:sim_time,30*network_spikes_inh+n_neu+2.5*n_neu/8,'r');
% plot(0:Rp_dt:sim_time,spikeks_1ms,'b');
% xlim([0 xlim_max]);
% set(ca,'XTick',[]);
% ylabel('network spikes');
%
% ca=axes('Position', [0.1 0.81 0.87 0.13]);
% %     plot(0:Rp_dt:sim_time,30*network_spikes+n_neu+n_neu/8,'b');
% %     hold on;
% %     plot(0:Rp_dt:sim_time,30*network_spikes_inh+n_neu+2.5*n_neu/8,'r');
% % plot(0:inct*10:(sim_time-inct*10),r_ts,'b');
% try
%     plot(0:inct*10:(sim_time-inct*10),r_ts); % plotting different phases in different colors for the case of seq trains
% catch
%     plot(0:inct*10:(sim_time-inct*10),r_ts(:,1:end-1)); % plotting different phases in different colors for the case of seq trains
% end
% xlim([0 xlim_max]);
% set(ca,'XTick',[]);
% ylabel('r');
%
% set(gcf,'Position',[1          25        1280         669]);
% %    keyboard;
% if PLOT_print
%     figure_name=strcat('lfp_pointraster_1ms_ks_zoom_v3','.png');
%     if ~isdeployed
%         hgexport(fh,figure_name,mystyle,'Format','png');
%     else
%         fullfile(pwd,stringa,figure_name)
%         hgexport(fh,fullfile(pwd,stringa,figure_name),mystyle,'Format','png');
%     end
% end


% pyenv_out=pyenv;
% if strcmp(pyenv_out.Status,'NotLoaded')
%     try
%         pyenv(ExecutionMode="OutOfProcess"); % this might help avoiding crashes - does not seem necessary if pyenv is called at the start
%     catch
%         pyenv
%         return;
%     end
% end
terminate(pyenv);
pyenv(ExecutionMode="OutOfProcess"); % this might help avoiding crashes - does not seem necessary if pyenv is called at the start
% % import py.module.fooof; % incorrect
% fooof_mod = py.importlib.import_module('matplotlib');
% fooof_mod = py.importlib.import_module('fooof');
% fm = fooof_mod.FOOOF(max_n_peaks=1);
% % py.fm.report(freqs, spectrum, [0.1 120]); % conflict with matlab's freqs
% % py.fm.report(f_vect_mt, power_spectrum_mt, [0.1 120]); % Unable to resolve the name 'py.fm.report'.
% % fm.report(f_vect_mt, power_spectrum_mt, [0.1 120]); % Python Error: DataError: Input data must be numpy arrays.
% fm.report(py.numpy.array(f_vect_mt), py.numpy.array(power_spectrum_mt), [0.1 120]); % conflict with matlab's freqs


% FOOOF settings
% settings = struct('max_n_peaks',1,'peak_threshold',3,'peak_width_limits',[0.5 120]); % note that this sets the limits for peak width = 2* gaussian width
settings = struct('max_n_peaks',1,'peak_threshold',3,'peak_width_limits',[0.5 240]); % note that this sets the limits for peak width = 2* gaussian width
% settings = struct('max_n_peaks',1,'peak_threshold',4,'peak_width_limits',[0.5 240]); % note that this sets the limits for peak width = 2* gaussian width
% settings = struct('max_n_peaks',1,'peak_threshold',3.5,'peak_width_limits',[0.5 240]); % note that this sets the limits for peak width = 2* gaussian width

% Run FOOOF, also returning the model
% fooof_results = fooof(f_vect_mt, power_spectrum_mt, [0.1 120], settings, true);
% fooof_plot(fooof_results);

fooof_results_10_19 = fooof(f_vect_mt_10_19, power_spectrum_mt_10_19, [0.1 120], settings, true);
fooof_1p_offset=fooof_results_10_19.aperiodic_params(1);
fooof_1p_exp=fooof_results_10_19.aperiodic_params(2);
if size(fooof_results_10_19.gaussian_params,1)==1 % if not, no peaks were found
    fooof_1p_f=fooof_results_10_19.gaussian_params(1);
    fooof_1p_pw=fooof_results_10_19.gaussian_params(2);
    fooof_1p_sigma=fooof_results_10_19.gaussian_params(3);
    fooof_1p_beta=fooof_1p_f*fooof_1p_pw/fooof_1p_sigma;
else
    fooof_1p_f=NaN;
    fooof_1p_pw=NaN;
    fooof_1p_sigma=NaN;
    fooof_1p_beta=NaN;
end
fooof_1p_err=fooof_results_10_19.error;
fooof_1p_r_squared=fooof_results_10_19.r_squared;

% fooof_plot(fooof_results_10_19);
% xlabel('f [Hz]');
% ylabel('log_{10} power');
% if PLOT_print
%     figure_name=strcat('LFP_mtspec_fooof_1p','.png');
%     if ~isdeployed
%         hgexport(fh,figure_name,mystyle,'Format','png');
%     else
%         fullfile(pwd,stringa,figure_name)
%         hgexport(fh,fullfile(pwd,stringa,figure_name),mystyle,'Format','png');
%     end
% end


% fooof_results_10_19_1ms = fooof(f_vect_mt_10_19_1ms, power_spectrum_mt_10_19_1ms, [0.1 120], settings, true);
% fooof_plot(fooof_results_10_19_1ms);

% settings_2peaks = struct('max_n_peaks',2,'peak_threshold',3,'peak_width_limits',[0.5 120]);
settings_2peaks = struct('max_n_peaks',2,'peak_threshold',3,'peak_width_limits',[0.5 240]);
% settings_2peaks = struct('max_n_peaks',2,'peak_threshold',4,'peak_width_limits',[0.5 240]);
% settings_2peaks = struct('max_n_peaks',2,'peak_threshold',3.5,'peak_width_limits',[0.5 240]);
fooof_results_10_19_2peaks = fooof(f_vect_mt_10_19, power_spectrum_mt_10_19, [0.1 120], settings_2peaks, true);
fooof_2p_offset=fooof_results_10_19_2peaks.aperiodic_params(1);
fooof_2p_exp=fooof_results_10_19_2peaks.aperiodic_params(2);
if size(fooof_results_10_19_2peaks.gaussian_params,1)==2 % if not, only one or no peaks were found
    % we order peaks so that 2p_f1 is closer to 1p_f than 2p_f2
    if ( abs(fooof_results_10_19_2peaks.gaussian_params(1,1)-fooof_results_10_19.gaussian_params(1)) < abs(fooof_results_10_19_2peaks.gaussian_params(2,1)-fooof_results_10_19.gaussian_params(1))) % 2p_f1 closer to 1p_f than 2p_f2
        fooof_2p_f1=fooof_results_10_19_2peaks.gaussian_params(1,1);
        fooof_2p_pw1=fooof_results_10_19_2peaks.gaussian_params(1,2);
        fooof_2p_sigma1=fooof_results_10_19_2peaks.gaussian_params(1,3);
        fooof_2p_beta1=fooof_2p_f1*fooof_2p_pw1/fooof_2p_sigma1;

        fooof_2p_f2=fooof_results_10_19_2peaks.gaussian_params(2,1);
        fooof_2p_pw2=fooof_results_10_19_2peaks.gaussian_params(2,2);
        fooof_2p_sigma2=fooof_results_10_19_2peaks.gaussian_params(2,3);
        fooof_2p_beta2=fooof_2p_f2*fooof_2p_pw2/fooof_2p_sigma2;
    else
        fooof_2p_f1=fooof_results_10_19_2peaks.gaussian_params(2,1);
        fooof_2p_pw1=fooof_results_10_19_2peaks.gaussian_params(2,2);
        fooof_2p_sigma1=fooof_results_10_19_2peaks.gaussian_params(2,3);
        fooof_2p_beta1=fooof_2p_f1*fooof_2p_pw1/fooof_2p_sigma1;

        fooof_2p_f2=fooof_results_10_19_2peaks.gaussian_params(1,1);
        fooof_2p_pw2=fooof_results_10_19_2peaks.gaussian_params(1,2);
        fooof_2p_sigma2=fooof_results_10_19_2peaks.gaussian_params(1,3);
        fooof_2p_beta2=fooof_2p_f2*fooof_2p_pw2/fooof_2p_sigma2;
    end
else
    fooof_2p_f1=NaN;
    fooof_2p_pw1=NaN;
    fooof_2p_sigma1=NaN;
    fooof_2p_beta1=NaN;

    fooof_2p_f2=NaN;
    fooof_2p_pw2=NaN;
    fooof_2p_sigma2=NaN;
    fooof_2p_beta2=NaN;
end
fooof_2p_err=fooof_results_10_19_2peaks.error;
fooof_2p_r_squared=fooof_results_10_19_2peaks.r_squared;
fooof_r_squared_ratio=fooof_2p_r_squared/fooof_1p_r_squared; % a measure of fit improvement when considering 2 vs 1 peaks:1 - no improment   ~0 - great improvement

if par.PLOT
    % fooof_plot(fooof_results_10_19_2peaks);
    fh=figure;
    set(gcf,'Color',[1 1 1]);
    data = plot(fooof_results_10_19.freqs, fooof_results_10_19.power_spectrum, 'black');
    hold on;
    model = plot(fooof_results_10_19.freqs, fooof_results_10_19.fooofed_spectrum, 'red'); % Plot the full model fit
    ap_fit = plot(fooof_results_10_19.freqs, fooof_results_10_19.ap_fit, 'b'); % Plot the aperiodic fit
    model_2p = plot(fooof_results_10_19_2peaks.freqs, fooof_results_10_19_2peaks.fooofed_spectrum, 'Color',orange); % Plot the full model fit
    ap_fit_2p = plot(fooof_results_10_19_2peaks.freqs, fooof_results_10_19_2peaks.ap_fit, 'Color',cyan); % Plot the aperiodic fit
    xlabel('f [Hz]');
    ylabel('log_{10} power');
    legend('data', 'full model', 'aperiodic');
    % title([stringa ' : ' 'p1f=' num2str(fooof_1p_f,'%.1f') ' p2f1=' num2str(fooof_2p_f1,'%.1f') ' p2f2=' num2str(fooof_2p_f2,'%.1f')],'FontSize',10,'FontWeight','normal','Interpreter','none');
    title({[par.stringa],['p1f=' num2str(fooof_1p_f,'%.1f') ' p2f1=' num2str(fooof_2p_f1,'%.1f') ' p2f2=' num2str(fooof_2p_f2,'%.1f')]},'FontSize',14,'FontWeight','normal','Interpreter','none'); % better in 2 rows
    figure_name=strcat(par.figDir,filesep,par.stringa,'_LFP_mtspec_fooof','.png');
    hgexport(fh,figure_name,mystyle,'Format','png');
end

[psd_max psd_max_ind]=max(log10(power_spectrum_mt_10_19)); % log10 as with fooof estimates
psd_max_f=f_vect_mt_10_19(psd_max_ind);

for kk=1:length(field_names)
    eval(['output_struct.' field_names{kk} '=' field_names{kk} ';']);
end

return;
