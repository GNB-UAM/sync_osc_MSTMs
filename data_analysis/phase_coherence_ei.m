function [MPC,MPCE,MPCI,phase_coherence_mat]=phase_coherence_ei(spiketimes,n_exc)

n_neu=length(spiketimes);

phase_coherence_mat=nan(n_neu);

for i=1:n_neu
    for j=1:n_neu
        if i~=j
            phase_coherence_mat(i,j)=phase_coherence_pairs_lim(spiketimes(i).t,spiketimes(j).t);
        end
    end
end

MPC=nanmean(nanmean(abs(phase_coherence_mat)));
MPCE=nanmean(nanmean(abs(phase_coherence_mat(1:n_exc,1:n_exc))));
MPCI=nanmean(nanmean(abs(phase_coherence_mat(n_exc+1:end,n_exc+1:end))));