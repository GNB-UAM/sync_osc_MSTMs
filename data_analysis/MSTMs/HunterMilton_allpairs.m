function [HM]=HunterMilton_allpairs(spiketimes,n_exc,tau)
% function [HM,HME,HMI,hm_mat]=HunterMilton_allpairs(spiketimes,n_exc,tau)

n_neu=length(spiketimes);

hm_mat=nan(n_neu);

for i=1:n_neu
    if isempty(spiketimes(i).t)
        continue
    end
    for j=1:n_neu
        if isempty(spiketimes(j).t)
            continue
        end
        if i~=j
            hm_mat(i,j)=HunterMilton(spiketimes(i).t,spiketimes(j).t,tau);
        end
    end
end

HM=nanmean(nanmean(hm_mat));
% HME=nanmean(nanmean(hm_mat(1:n_exc,1:n_exc)));
% HMI=nanmean(nanmean(hm_mat(n_exc+1:end,n_exc+1:end)));