function [emd,emdn]=Wasserstein_allpairs(spiketimes,n_exc,sim_time)

n_neu=length(spiketimes);

emd_mat=nan(n_neu);

for i=1:n_neu
    for j=(i+1):n_neu
        emd_mat(i,j)=ws_distance(spiketimes(i).t,spiketimes(j).t);
    end
end

emd=nanmean(nanmean(emd_mat));
emdn=emd/sim_time; % this measure is always included between 0 and 1
% emdE=nanmean(nanmean(emd_mat(1:n_exc,1:n_exc)));
% emdI=nanmean(nanmean(emd_mat(n_exc+1:end,n_exc+1:end)));