function [en_ISI_vect,en_ISI]=spiketimes_stat_entropy(spiketimes)
% returns ISI entropy of each neuron, and en of ISIs pulling all ISIs together
n_neu=length(spiketimes);
log_isi_vect=[];
en_ISI_vect=zeros(1,n_neu);
for neu=1:n_neu
    spikes_this=spiketimes(neu).t;
    isi_vect_this=spikes_this(2:end)-spikes_this(1:end-1);
    log_isi_vect_this=log10(isi_vect_this);
        
    en_ISI_vect(neu)=ISIentropy(log_isi_vect_this);
    
    log_isi_vect=[log_isi_vect;log_isi_vect_this];        
end
en_ISI=ISIentropy(log_isi_vect);
