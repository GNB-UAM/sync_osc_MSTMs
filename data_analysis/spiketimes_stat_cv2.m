function [CV2_ISI_vect,CV2_ISI]=spiketimes_stat_cv2(spiketimes)
% returns ISI CV2 of each neuron, and mean CV2 across neurons. CV2 pulling all ISIs together is meaningless since CV2 captures serial correlations
n_neu=length(spiketimes);
CV2_ISI_vect=zeros(1,n_neu);
for neu=1:n_neu
    spikes_this=spiketimes(neu).t;
    if length(spikes_this)>1 % CV2 cannot be estimated with less than 2 spikes
        CV2_ISI_vect(neu)=CV2(spikes_this);
    else
        CV2_ISI_vect(neu)=NaN;
    end
end
CV2_ISI=nanmean(CV2_ISI_vect);
