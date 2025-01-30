function output_struct=generate_sinpleseq_train(stringa,par)
% generates spike trains as poisson processes with a refractory period and a piecewise linear firing rate with inter node interval

t_refr=4.;
n_neu=400;    % number of neurons
rate=12.; % avg firing rate [Hz]
r_osc_ampl=0.5;    % relative amplitude of the sinusoidal modulation (between 0 and 1)
f_osc=12.; % network frequency (alpha frequency by default) - here it determines the parameter for the INI distribution
% pop_t_refr=20.; % population refractory period
transient=0.0;
sim_time=10000;
seed=0;
inct=0.01;        % simulation time step
Rp_dt=10.*inct; % time step for population spike binning
% sigma_omega=0.2*2.*pi*f_osc./1000.; % SD of the population osc angular frequency taken to be 1/5th of its average value. f_osc scaled because time and time constants are in ms - not used here
tau_OUnoise=10.; % not used here
duty_cycle=0.1;

% par_string={'t_refr','n_neu','rate','r_osc_ampl','f_osc','transient','sim_time','seed','inct','Rp_dt','sigma_omega','tau_OUnoise','pop_t_refr'};
% par_string={'t_refr','n_neu','rate','r_osc_ampl','f_osc','transient','sim_time','seed','inct','Rp_dt','tau_OUnoise','pop_t_refr'};
par_string={'t_refr','n_neu','rate','r_osc_ampl','f_osc','transient','sim_time','seed','inct','Rp_dt','tau_OUnoise','duty_cycle'};


for i=1:length(par_string)
    if(isfield(par,par_string(i)))
        eval([char(par_string(i)) '=par.' char(par_string(i)) ';']);
    end
end


for i=1:length(par_string)
    eval(['par.' char(par_string(i)) '=' char(par_string(i)) ';']);
end

pop_t_refr=0.1*(1000./(2*f_osc)); % we set this to 1/10th of the population cycle (average ini)

previous_spike=-999999999*ones(n_neu,1);

r_avg=inct*rate/1000.*exp(t_refr*rate/1000.);  % probability of firing for an exc neuron (avg number of spikes in inct interval) - correction for refractoriness in exp pdf
r_osc=r_avg*r_osc_ampl;
r_max=r_avg*(1+r_osc_ampl);
r_min=r_avg*(1-r_osc_ampl);

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

r_vect=zeros(1,n_neu);
ini_vect=zeros(1,n_neu);
going_up=ones(n_neu,1);
ini_avg=(1000./(2*f_osc))./exp(pop_t_refr*(2*f_osc)./1000); % nodes occur at twice the population modulation frequency
n_node=linspace(-ini_avg*duty_cycle,0,n_neu); % next node
p_node=linspace(-ini_avg*duty_cycle,0,n_neu); % previous node

while (time<transient)
    if time >= n_node(1) % INI updated when the first (most phase advanced) neu updates its n_node
        % if time >= n_node(end) % INI updated when the last (most phase delayed) neu updates its n_node
        ini=exprnd(ini_avg);
        while ini<pop_t_refr
            ini=exprnd(ini_avg);
        end
    end

    for i=1:n_neu
        if time >= n_node(i)
            p_node(i)=n_node(i);
            % n_node(i)=n_node(i)+ini*(1.-duty_cycle*(n_neu-i)/(n_neu-1)); % i=1: n=n+ini*(1-D)   % %  i=n_neu: n=n+ini*(1-0)
            % n_node(i)=n_node(1)+ini*(1.+duty_cycle*((i-1)/(n_neu-1)-.5)); % i=1: n=n+ini*(1-D/2)   % %  i=n_neu: n=n+ini*(1+D/2)
            n_node(i)=n_node(end)+ini*(1.-duty_cycle*(n_neu-i)/(n_neu-1)); % i=1: n=n+ini*(1-D)   % %  i=n_neu: n=n+ini*(1-0)
            going_up(i)=1-going_up(i);
            ini_vect(i)=n_node(i)-p_node(i);
        end
        if going_up(i)
            % r_vect(i)=((r_max-r_min)./ini_vect(i)).*(time-p_node(i))+r_min;
            osc_phase(i)=(pi/ini_vect(i))*(time-p_node(i))-pi/2.; % mapping linearly from -pi/2 to pi/2
        else
            % r_vect(i)=((r_min-r_max)./ini_vect(i)).*(time-p_node(i))+r_max;  % going down
            osc_phase(i)=(pi/ini_vect(i))*(time-p_node(i))+pi/2.; % mapping linearly from pi/2 to 3*pi/2
        end
    end
    r_vect=r_avg+r_osc*sin(osc_phase);
    rand_this=rand(n_neu,1);
    ind_spike=(rand_this'<r_vect & time>(previous_spike'+t_refr));
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
    if time >= n_node(1)
        ini=exprnd(ini_avg);
        while ini<pop_t_refr
            ini=exprnd(ini_avg);
        end
    end

    for i=1:n_neu
        if time >= n_node(i)
            p_node(i)=n_node(i);
            % n_node(i)=n_node(i)+ini*(1.-duty_cycle*(n_neu-i)/(n_neu-1)); % i=1: n=n+ini*(1-D)   % %  i=n_neu: n=n+ini*(1-0)
            % n_node(i)=n_node(1)+ini*(1.+duty_cycle*((i-1)/(n_neu-1)-.5)); % i=1: n=n+ini*(1-D/2)   % %  i=n_neu: n=n+ini*(1+D/2)
            n_node(i)=n_node(end)+ini*(1.-duty_cycle*(n_neu-i)/(n_neu-1)); % i=1: n=n+ini*(1-D)   % %  i=n_neu: n=n+ini*(1-0)
            going_up(i)=1-going_up(i);
            ini_vect(i)=n_node(i)-p_node(i);
        end
        if going_up(i)
            % r_vect(i)=((r_max-r_min)./ini_vect(i)).*(time-p_node(i))+r_min;
            osc_phase(i)=(pi/ini_vect(i))*(time-p_node(i))-pi/2.; % mapping linearly from -pi/2 to pi/2
        else
            % r_vect(i)=((r_min-r_max)./ini_vect(i)).*(time-p_node(i))+r_max;  % going down
            osc_phase(i)=(pi/ini_vect(i))*(time-p_node(i))+pi/2.; % mapping linearly from pi/2 to 3*pi/2
        end
    end
    r_vect=r_avg+r_osc*sin(osc_phase);
    r_ts=[r_ts r_vect(ind_neu_2save)']; % saving inst rate for a subset of neurons

    rand_this=rand(n_neu,1);
    ind_spike=(rand_this'<r_vect & time>(previous_spike'+t_refr));
    spiking_neu=find(ind_spike);

    for i=1:length(spiking_neu)
        % spiketimes{1,spiking_neu(i)}=[spiketimes{1,spiking_neu(i)} time];
        spiketimes(spiking_neu(i)).t=[spiketimes(spiking_neu(i)).t; time-transient];   % for compatibility with ei_hetnet sims
    end

    previous_spike(spiking_neu)=time;
    time=time+inct;
end

r_ts=r_ts(:,1:10:end);

system(['mkdir ' stringa]);
eval(['cd ' stringa ';']);

save(stringa,'par', 'spiketimes','r_ts');

cd ..
output_struct=[];