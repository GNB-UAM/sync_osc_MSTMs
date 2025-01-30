function [IR_ISI_vect,IR_ISI]=spiketimes_stat_ir(spiketimes)
% returns ISI IR of each neuron, and mean IR across neurons. IR pulling all ISIs together is meaningless since these measures capture serial correlations
n_neu=length(spiketimes);
IR_ISI_vect=zeros(1,n_neu);
for neu=1:n_neu
    spikes_this=spiketimes(neu).t;
    isi_vect_this=spikes_this(2:end)-spikes_this(1:end-1);
    
    IR_val=abs(log(isi_vect_this(2:end)./isi_vect_this(1:end-1)));
    
    IR_ISI_vect(neu)=mean(IR_val);
end
IR_ISI=nanmean(IR_ISI_vect);
