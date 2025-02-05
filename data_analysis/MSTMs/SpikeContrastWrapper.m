function Sc = SpikeContrastWrapper(spiketimes,sim_time)
% returns the SpikeContrast measure of synchrony
% Ciba, Manuel, Takuya Isomura, Yasuhiko Jimbo, Andreas Bahmer, and Christiane Thielemann. 2018. “Spike-Contrast: A Novel Time Scale Independent and Multivariate Measure of Spike Train Synchrony.” Journal of Neuroscience Methods 293 (January): 136–43. https://doi.org/10.1016/j.jneumeth.2017.09.008.

n_neu=length(spiketimes);
length_this=zeros(1,n_neu);

for i_neu=1:n_neu
    length_this(i_neu)=length(spiketimes(i_neu).t);
end

max_length=max(length_this);

spiketimes_mat=nan(max_length,n_neu);

for i_neu=1:n_neu
    spiketimes_mat(1:length(spiketimes(i_neu).t),i_neu)=spiketimes(i_neu).t./1000.; % SpikeContrast wants spike times in seconds
end

Sc=SpikeContrast(spiketimes_mat, sim_time./1000.); % SpikeContrast wants times in seconds
