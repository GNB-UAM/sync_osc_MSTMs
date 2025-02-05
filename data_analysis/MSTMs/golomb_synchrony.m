function [golomb_sync]=golomb_synchrony(spiketimes,sim_time,sigma,inct)
% returns golomb_synchrony
% http://www.scholarpedia.org/article/Neuronal_synchrony_measures
t_vect=0:inct:sim_time;
n_neu=length(spiketimes);
spikeks=zeros(n_neu,length(t_vect)); % spike density
var_spikeks=zeros(1,n_neu); % variance of the spike density across time for each neuron
for neu=1:n_neu
    spikes_this=spiketimes(neu).t;
    
    if isempty(spikes_this)
        spikeks(neu,:)=zeros(1,length(t_vect));
    else
        spikeks(neu,:)=ksdensity(spikes_this,t_vect,'Bandwidth',sigma);
    end
    %     max_y=max(spikeks(neu,:));
    %     figure
    %     plot(t_vect,spikeks(neu,:));
    %     hold on;
    %     plot(spiketimes(neu).t,1.05*max_y*ones(length(spiketimes(neu).t),1),'rx','MarkerSize',6);
    %     xlim([0 300]);
    %     keyboard;
    var_spikeks(neu)=var(spikeks(neu,:)); % variance over time
end

mean_spikeks=mean(spikeks); % mean over neurons

var_mean_spikeks=var(mean_spikeks); % variance over time

golomb_sync=sqrt(var_mean_spikeks/mean(var_spikeks));