function output_struct=generate_expG_train(stringa,par)
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
p_fail=0.;
sigmaGpercent=0.1; % SD of Gaussian distribution determining relative spike times within a population event taken to be 1/10th of the population period

% par_string={'t_refr','n_neu','rate','r_osc_ampl','f_osc','transient','sim_time','seed','inct','Rp_dt','sigma_omega','tau_OUnoise','p_fail','sigmaGpercent'};
par_string={'t_refr','n_neu','rate','r_osc_ampl','f_osc','transient','sim_time','seed','inct','Rp_dt','tau_OUnoise','p_fail','sigmaGpercent'};


for i=1:length(par_string)
    if(isfield(par,par_string(i)))
        eval([char(par_string(i)) '=par.' char(par_string(i)) ';']);
    end
end


for i=1:length(par_string)
    eval(['par.' char(par_string(i)) '=' char(par_string(i)) ';']);
end

sigmaG=sigmaGpercent*1000./par.f_osc;

pop_t_refr=0.1*(1000./f_osc); % we set this to 1/10th of the population cycle

previous_spike=-999999999*ones(n_neu,1);
pop_spike=-999999999;

r_avg=inct*rate/1000.*exp(t_refr*rate/1000.);  % probability of firing for an exc neuron (avg number of spikes in inct interval) - correction for refractoriness in exp pdf
r_osc=r_avg*r_osc_ampl;

rand('state',seed);       % initialize random number generator

cont_write=1;
% spiketimes=cell(1,n_neu);
spiketimes=struct();
for i=1:n_neu
    spiketimes(i).t=[];
end

time=0;

n_event=0; % next event
p_event=0; % previous event
iei_avg=(1000./(f_osc))./exp(pop_t_refr*(f_osc)./1000); % population events occur at the population modulation frequency

while (time<transient)
    if time >= n_event
        iei=exprnd(iei_avg);
        while iei<pop_t_refr
            iei=exprnd(iei_avg);
        end
        p_event=n_event;
        n_event=n_event+iei;
        pop_spike=n_event;
        
        rel_spiketimes=sigmaG*randn(1,n_neu);
        fail_neu=rand(1,n_neu)<p_fail;
        
        for i=1:n_neu
            if ~fail_neu(i)
                spike_this=pop_spike+rel_spiketimes(i)-transient;
                % if (spike_this>=0 && (isempty(spiketimes(i).t) || spike_this>spiketimes(i).t(end)+t_refr))
                if (spike_this>=0 && spike_this<sim_time && (isempty(spiketimes(i).t) || min(abs(spike_this-spiketimes(i).t))>t_refr))
                    spiketimes(i).t=[spiketimes(i).t; spike_this];   % for compatibility with ei_hetnet sims
                end
            end
        end
        
    end
    time=time+inct;
end


r_ts=[];
while (time<transient+sim_time)
    if time >= n_event
        iei=exprnd(iei_avg);
        while iei<pop_t_refr
            iei=exprnd(iei_avg);
        end
        p_event=n_event;
        n_event=n_event+iei;
        pop_spike=n_event;
        
        rel_spiketimes=sigmaG*randn(1,n_neu);
        fail_neu=rand(1,n_neu)<p_fail;
        
        for i=1:n_neu
            if ~fail_neu(i)
                spike_this=pop_spike+rel_spiketimes(i)-transient;
                % if (spike_this>=0 && spike_this<sim_time && (isempty(spiketimes(i).t) || spike_this>spiketimes(i).t(end)+t_refr))
                if (spike_this>=0 && spike_this<sim_time && (isempty(spiketimes(i).t) || min(abs(spike_this-spiketimes(i).t))>t_refr))
                    spiketimes(i).t=[spiketimes(i).t; spike_this];   % for compatibility with ei_hetnet sims
                end
            end
        end
        
    end
    
    % r_vect=r_avg+r_osc*sin(osc_phase);
    osc_phase=2*pi*(time-p_event)./iei;
    r_vect=1+cos(osc_phase); % in expG trains, this is for illustration purposes only
    r_ts=[r_ts r_vect];
    
    time=time+inct;
end

r_ts=r_ts(1:10:end);

% sorting spike times
for i=1:n_neu
    if ~isempty(spiketimes(i).t)
        spiketimes(i).t=sort(spiketimes(i).t);
    end
end

system(['mkdir ' stringa]);
eval(['cd ' stringa ';']);

save(stringa,'par', 'spiketimes','r_ts');

cd ..
output_struct=[];