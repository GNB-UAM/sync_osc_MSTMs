function output_struct=generate_sinple_train(stringa,par)
% generates spike trains as poisson processes with a refractory period and a piecewise linear firing rate with inter node interval

t_refr=4.;
n_neu=400;    % number of neurons
rate=12.; % avg firing rate [Hz]
r_osc_ampl=0.5;    % relative amplitude of the sinusoidal modulation (between 0 and 1)
f_osc=12.; % network frequency (alpha frequency by default) - here it determines the parameter for the INI distribution
transient=0.0;
sim_time=10000;
seed=0;
inct=0.01;        % simulation time step
Rp_dt=10.*inct; % time step for population spike binning
tau_OUnoise=10.; % not used here

par_string={'t_refr','n_neu','rate','r_osc_ampl','f_osc','transient','sim_time','seed','inct','Rp_dt','tau_OUnoise'};


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
spiketimes=struct();
for i=1:n_neu
    spiketimes(i).t=[];
end

time=0;

n_node=0; % next node
p_node=0; % previous node
going_up=1;
ini_avg=(1000./(2*f_osc))./exp(pop_t_refr*(2*f_osc)./1000); % nodes occur at twice the population modulation frequency

sin_fun = @(x) (1+cos(x))./2;

while (time<transient)
    if time >= n_node
        ini=exprnd(ini_avg);
        while ini<pop_t_refr
        ini=exprnd(ini_avg);          
        end
        p_node=n_node;
        n_node=n_node+ini;
        going_up=1-going_up;
    end
    
    if going_up
        osc_phase=(pi/ini)*(time-p_node)-pi/2.; % mapping linearly from -pi/2 to pi/2
    else
        osc_phase=(pi/ini)*(time-p_node)+pi/2.; % mapping linearly from pi/2 to 3*pi/2        
    end
    
    r_vect=r_avg+r_osc*sin(osc_phase);

    rand_this=rand(n_neu,1);
    ind_spike=(rand_this<r_vect & time>(previous_spike+t_refr));
    spiking_neu=find(ind_spike);
    
    previous_spike(spiking_neu)=time;
    time=time+inct;
end


r_ts=[];
while (time<transient+sim_time)
    if time >= n_node
        ini=exprnd(ini_avg);
        while ini<pop_t_refr
        ini=exprnd(ini_avg);          
        end
        p_node=n_node;
        n_node=n_node+ini;
        going_up=1-going_up;
    end
    
    if going_up
        osc_phase=(pi/ini)*(time-p_node)-pi/2.; % mapping linearly from -pi/2 to pi/2
    else
        osc_phase=(pi/ini)*(time-p_node)+pi/2.; % mapping linearly from pi/2 to 3*pi/2        
    end
    r_vect=r_avg+r_osc*sin(osc_phase);
    r_ts=[r_ts r_vect];
    
    rand_this=rand(n_neu,1);
    ind_spike=(rand_this<r_vect & time>(previous_spike+t_refr));
    spiking_neu=find(ind_spike);
    
    for i=1:length(spiking_neu)
        spiketimes(spiking_neu(i)).t=[spiketimes(spiking_neu(i)).t; time-transient];
    end
    
    previous_spike(spiking_neu)=time;
    time=time+inct;
end

r_ts=r_ts(1:10:end);

eval(['mkdir ' stringa]);
eval(['cd ' stringa ';']);

save(stringa,'par', 'spiketimes','r_ts');

cd ..
output_struct=[];