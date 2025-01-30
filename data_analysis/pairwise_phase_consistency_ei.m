function [MPC,MPCE,MPCI,phase_coherence_mat]=pairwise_phase_consistency_ei(spiketimes,n_exc)

n_neu=length(spiketimes);

phase_coherence_mat=nan(n_neu);

for i=1:n_neu
    for j=1:n_neu
        if i~=j
            phase_coherence_mat(i,j)=pairwise_phase_consistency_pairs(spiketimes(i).t,spiketimes(j).t);
        end
    end
end

MPC=nanmean(nanmean(phase_coherence_mat));
MPCE=nanmean(nanmean(phase_coherence_mat(1:n_exc,1:n_exc)));
MPCI=nanmean(nanmean(phase_coherence_mat(n_exc+1:end,n_exc+1:end)));