function [vR,vRn]=vanRossumv_allpairs(spiketimes,n_exc,vR_tau)
% function [vR,vRE,vRI,vR_mat]=vanRossumv_allpairs(spiketimes,n_exc,vR_tau)

n_neu=length(spiketimes);

vR_mat=nan(n_neu);
vRn_mat=nan(n_neu);

for i=1:n_neu
    for j=(i+1):n_neu % symmetric measure
        % vR_mat(i,j)=vanRossum(spiketimes(i).t,spiketimes(j).t,vR_tau); % gives NaN
        % vR_mat(i,j)=vanRossum(spiketimes(i).t',spiketimes(j).t',vR_tau); % still gives NaN
        % vR_mat(i,j)=SPIKY_vanRossum(spiketimes(i).t',spiketimes(j).t',vR_tau); % there are a couple of missing functions
        [vR_mat(i,j),vRn_mat(i,j)]=myvanRossumv(spiketimes(i).t,spiketimes(j).t,vR_tau);
    end
end

vR=nanmean(nanmean(vR_mat));
% vRE=nanmean(nanmean(vR_mat(1:n_exc,1:n_exc)));
% vRI=nanmean(nanmean(vR_mat(n_exc+1:end,n_exc+1:end)));

vRn=nanmean(nanmean(vRn_mat));
