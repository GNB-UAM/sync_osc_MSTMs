function bursty=burstiness(spiketimes)
% measure of burstiness derived from
% Tiesinga, P. H., and T. J. Sejnowski. 2004. “Rapid Temporal Modulation of Synchrony by Competition in Cortical Interneuron Networks.” Neural Computation 16 (2): 251–275. https://doi.org/10.1162/089976604322742029.
n_neu=length(spiketimes);
if(n_neu>0)
    spikes=[];
    for neu=1:n_neu
        spikes=[spikes; spiketimes(neu).t];
    end
    
    spikes=sort(spikes);
    
    network_isi=spikes(2:end)-spikes(1:end-1);
        
    mean_isi=mean(network_isi);
    mean_isi2=mean(network_isi.*network_isi);
    
    % bursty=((sqrt(mean_isi2-mean_isi*mean_isi)/mean_isi)-1)/sqrt(n_neu); % incorrect, a sum of Poisson is not Poisson but Gaussian (in ISI) / Uniform (in spike times)
    bursty=((sqrt(mean_isi2-mean_isi*mean_isi)/mean_isi))/sqrt(n_neu);
else
    bursty=[];
end
%keyboard;