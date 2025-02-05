function network_spikes=network_spiketimes(spiketimes,dt,time_max,varargin)
% returns network spike vector (with integration time resolution)
% I use round. Shall dt be different than the integration time constant
% everything should still work
network_spikes=zeros(1,ceil(time_max/dt)+1);
n_neu=length(spiketimes);

if nargin==3
    t_offset=0.;
else
    t_offset=varargin{1};
end

for neu=1:n_neu
    try
        spikes_this=spiketimes(neu).t-t_offset;
    catch
        keyboard;
    end
    for spike=1:length(spikes_this)
        try
            network_spikes(round(spikes_this(spike)/dt)+1)=network_spikes(round(spikes_this(spike)/dt)+1)+1;
        catch
            keyboard;
        end
    end
    
end