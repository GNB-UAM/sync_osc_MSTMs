function [mean_ISI_vect,std_ISI_vect,mean_ISI,std_ISI,nspikes]=spiketimes_stat(spiketimes)
% returns mean and std ISI of each neuron, and mean and std of ISIs pulling
% all ISIs together
n_neu=length(spiketimes);
isi_vect=[];
mean_ISI_vect=zeros(1,n_neu);
std_ISI_vect=zeros(1,n_neu);
nspikes=zeros(1,n_neu);
for neu=1:n_neu
    spikes_this=spiketimes(neu).t;
    nspikes(neu)=length(spikes_this);
    isi_vect_this=spikes_this(2:end)-spikes_this(1:end-1);
    isi_vect=[isi_vect;isi_vect_this];
    mean_ISI_vect(neu)=mean(isi_vect_this);
    std_ISI_vect(neu)=std(isi_vect_this);
end
%size(isi_vect)
mean_ISI=mean(isi_vect);
std_ISI=std(isi_vect);