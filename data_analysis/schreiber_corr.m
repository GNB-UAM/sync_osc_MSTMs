function [schreiber_c kruskal_c]=schreiber_corr(spiketimes,sim_time,sigma,inct)
% returns the reliability metrics from Schreiber et al 2002 Neurocomputing and Kruskal 2007 Statistics in Medicine
t_vect=0:inct:sim_time;
n_neu=length(spiketimes);
spikeks=zeros(n_neu,length(t_vect)); % spike density
norm_vect=zeros(1,n_neu); % norm of the spike density for each neuron
for neu=1:n_neu
    spikes_this=spiketimes(neu).t;

    if isempty(spikes_this)
        spikeks(neu,:)=zeros(1,length(t_vect));
    else
        spikeks(neu,:)=ksdensity(spikes_this,t_vect,'Bandwidth',sigma);
    end
    norm_vect(neu)=norm(spikeks(neu,:));
    %     max_y=max(spikeks(neu,:));
    %     figure
    %     plot(t_vect,spikeks(neu,:));
    %     hold on;
    %     plot(spiketimes(neu).t,1.05*max_y*ones(length(spiketimes(neu).t),1),'rx','MarkerSize',6);
    %     xlim([0 300]);
    %     keyboard;
end

schreiber_mat=nan(n_neu);
kruskal_mat=nan(n_neu);
for i=1:n_neu
    for j=(i+1):n_neu
    % for j=i:n_neu % diagonal is 1, so normalization is ok
        schreiber_mat(i,j)=(spikeks(i,:)*spikeks(j,:)')/(norm_vect(i)*norm_vect(j)); % note that this is different from Pearson correlation: we do not subtract out the mean
        kruskal_mat(i,j)=corr(spikeks(i,:)',spikeks(j,:)');
    end
end

schreiber_c=nanmean(nanmean(schreiber_mat));
kruskal_c=nanmean(nanmean(kruskal_mat));
% schreiber_cE=nanmean(nanmean(schreiber_mat(1:n_exc,1:n_exc)));
% schreiber_cI=nanmean(nanmean(schreiber_mat(n_exc+1:end,n_exc+1:end)));
