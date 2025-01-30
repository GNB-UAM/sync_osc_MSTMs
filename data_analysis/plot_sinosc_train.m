function output_struct=plot_sinosc_train(stringa,par)
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
sigma=Rp_dt; % ksdensity kernel width



[mean_ISI_vect,std_ISI_vect,mean_ISI,std_ISI,nspikes]=spiketimes_stat(spiketimes);

if contains(stringa,'seq')
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

mystyle = hgexport('factorystyle');
mystyle.Units='normalized';
mystyle.FontMode='none';

dist_colors = distinguishable_colors(50);

cmap_winter=colormap(winter(eval(['size(r_ts,1)'])));

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
plot(0:Rp_dt:sim_time,spikeks,'b');
xlim([0 xlim_max]);
set(ca,'XTick',[]);
ylh=ylabel('network spikes');
set(ca, 'YTickLabel', get(ca, 'YTick'));

ca=axes('Position', [0.1 0.81 0.87 0.13]);
try
    plot(0:inct*10:(sim_time-inct*10),r_ts); % plotting different phases in different colors for the case of seq trains
catch
    plot(0:inct*10:(sim_time-inct*10),r_ts(:,1:end-1)); % plotting different phases in different colors for the case of seq trains
end
colororder(cmap_winter);
xlim([0 xlim_max]);
set(ca,'XTick',[]);

if contains(stringa,'G') % dual-scale
    ylabel('1+sin($\phi$)','Interpreter','latex');
else % single-scale
    ylabel('r');
end

set(gcf,'Position',[1          25        1280         669]);
if PLOT_print
    figure_name=strcat('lfp_pointraster_ks_zoom_v4','.png');
    if ~isdeployed
        hgexport(fh,figure_name,mystyle,'Format','png');
    else
        fullfile(pwd,stringa,figure_name)
        hgexport(fh,fullfile(pwd,stringa,figure_name),mystyle,'Format','png');
    end
end

if ~isdeployed
    cd ..
end

return;
