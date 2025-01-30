function output_struct=generate_oscseq_train(stringa,par)
% generates spike trains as poisson processes with a refractory period and an oscillatory firing rate

t_refr=4.;
n_neu=400;    % number of neurons
rate=12.; % avg firing rate [Hz]
r_osc_ampl=0.5;    % relative amplitude of the sinusoidal modulation (between 0 and 1)
f_osc=12.; % network frequency (alpha frequency by default)
transient=0.0;
sim_time=10000;
seed=0;
inct=0.01;        % simulation time step
Rp_dt=10.*inct; % time step for population spike binning
% sigma_omega=0.2*2.*pi*f_osc./1000.; % SD of the population osc angular frequency taken to be 1/5th of its average value. f_osc scaled because time and time constants are in ms
tau_OUnoise=10.;
duty_cycle=0.1;

% par_string={'t_refr','n_neu','rate','r_osc_ampl','f_osc','transient','sim_time','seed','inct','Rp_dt','sigma_omega','tau_OUnoise'};
par_string={'t_refr','n_neu','rate','r_osc_ampl','f_osc','transient','sim_time','seed','inct','Rp_dt','tau_OUnoise','duty_cycle'};


for i=1:length(par_string)
    if(isfield(par,par_string(i)))
        eval([char(par_string(i)) '=par.' char(par_string(i)) ';']);
    end
end


for i=1:length(par_string)
    eval(['par.' char(par_string(i)) '=' char(par_string(i)) ';']);
end

sigma_omega=0.2*2.*pi*par.f_osc./1000.;

previous_spike=-999999999*ones(n_neu,1);

active_win=duty_cycle.*(1000./f_osc);
seq_t_vect=linspace(-active_win/2.,active_win./2,n_neu);
seq_vect=linspace(-duty_cycle*2.,duty_cycle*.2,n_neu); % is D=0.5, this goes from -1 to 1 and seq_rad_vect goes from -pi/2 to pi/2 (half of a cycle)
% seq_rad_vect=asin(seq_vect); % not really a good idea to use asin, it just decreases concentration at the edges if D is close to 0.5, has little effect if D is small. See train_prova_range_3_3_5_1_oscseq/lfp_pointraster_zoom_v3_080722.png for an example using asin
% seq_rad_vect=linspace(-pi*duty_cycle,pi*duty_cycle,n_neu); % is D=0.5, this goes from -pi/2 to pi/2 (half of a cycle) - 1st is the most phase delayed
seq_rad_vect=linspace(pi*duty_cycle,-pi*duty_cycle,n_neu); % is D=0.5, this goes from -pi/2 to pi/2 (half of a cycle) - 1st is the most phase advanced

r_avg=inct*rate/1000.*exp(t_refr*rate/1000.);  % probability of firing for an exc neuron (avg number of spikes in inct interval) - correction for refractoriness in exp pdf
r_osc=r_avg*r_osc_ampl;

rand('state',seed);       % initialize random number generator

cont_write=1;
% spiketimes=cell(1,n_neu);
spiketimes=struct();
for i=1:n_neu
    spiketimes(i).t=[];
end

ind_neu_2save=round(0:n_neu/4:n_neu);
ind_neu_2save(1)=1;

time=0;

osc_phase=rand*2.*pi-pi; % random number between -pi and pi
osc_phase_ant=osc_phase;
omega_OUnoise=sigma_omega*randn;
omega_OUnoise_ant=sigma_omega*randn;

while (time<transient)
    omega_OUnoise=omega_OUnoise_ant*exp(-inct/tau_OUnoise)+sigma_omega*sqrt(1-exp(-2*inct/tau_OUnoise)).*randn; % we use the same auto-correlation time constant as for the background additive noise, for simplicity.
    osc_phase=osc_phase_ant+inct*(2.*pi*f_osc./1000.+omega_OUnoise);
    osc_phase_ant=osc_phase;
    omega_OUnoise_ant=omega_OUnoise;

    % r_vect=[(r_avg+r_osc*sin(osc_phase))*ones(n_neu,1)];
    % r_vect=r_avg+r_osc*sin(osc_phase);
    r_vect=r_avg+r_osc*sin(osc_phase+seq_rad_vect');
    rand_this=rand(n_neu,1);
    ind_spike=(rand_this<r_vect & time>(previous_spike+t_refr));
    spiking_neu=find(ind_spike);

    %     for i=1:length(spiking_neu)
    %         % spiketimes{1,spiking_neu(i)}=[spiketimes{1,spiking_neu(i)} time];
    %         spiketimes(spiking_neu(i)).t=[spiketimes(spiking_neu(i)).t; time];   % for compatibility with ei_hetnet sims
    %     end

    previous_spike(spiking_neu)=time;
    time=time+inct;
end


r_ts=[];
while (time<transient+sim_time)
    omega_OUnoise=omega_OUnoise_ant*exp(-inct/tau_OUnoise)+sigma_omega*sqrt(1-exp(-2*inct/tau_OUnoise)).*randn; % we use the same auto-correlation time constant as for the background additive noise, for simplicity.
    osc_phase=osc_phase_ant+inct*(2.*pi*f_osc./1000.+omega_OUnoise);
    osc_phase_ant=osc_phase;
    omega_OUnoise_ant=omega_OUnoise;

    % r_vect=[(r_avg+r_osc*sin(osc_phase))*ones(n_neu,1)];
    % r_vect=r_avg+r_osc*sin(osc_phase);
    r_vect=r_avg+r_osc*sin(osc_phase+seq_rad_vect');

    r_ts=[r_ts r_vect(ind_neu_2save)]; % saving inst rate for a subset of neurons

    rand_this=rand(n_neu,1);
    ind_spike=(rand_this<r_vect & time>(previous_spike+t_refr));
    spiking_neu=find(ind_spike);

    for i=1:length(spiking_neu)
        % spiketimes{1,spiking_neu(i)}=[spiketimes{1,spiking_neu(i)} time];
        spiketimes(spiking_neu(i)).t=[spiketimes(spiking_neu(i)).t; time-transient];   % for compatibility with ei_hetnet sims
    end

    previous_spike(spiking_neu)=time;
    time=time+inct;
end

r_ts=r_ts(:,1:10:end);

if ~isdeployed
    system(['mkdir ' stringa]);
    eval(['cd ' stringa ';']);

    save(stringa,'par', 'spiketimes','r_ts');

    cd ..
else
    %     fullfile(ctfroot,stringa,stringa) % ans = '/home/baroni/.mcrCache9.7/script1/train_prova_range_1_1_1_osc/train_prova_range_1_1_1_osc' not what we want
    %     load(fullfile(ctfroot,stringa,stringa),'par', 'spiketimes','r_ts');
    mkdir(fullfile(pwd,stringa));
    save(fullfile(pwd,stringa,stringa),'par', 'spiketimes','r_ts');
end

output_struct=[];