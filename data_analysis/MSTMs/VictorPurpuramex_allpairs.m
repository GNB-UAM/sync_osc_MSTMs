function [VP,VPN]=VictorPurpuramex_allpairs(spiketimes,n_exc,VPq)
% function [MPC,MPCE,MPCI,phase_coherence_mat]=VictorPurpuramex_allpairs(spiketimes,n_exc,VPq)
% spiketimes(k).t: column vector of spike times of neuron k, in ms; VPq is the cost per ms of shifting a spike (1/tau, with tau in ms)

n_neu=length(spiketimes);

VP_mat=nan(n_neu);
VPN_mat=nan(n_neu);

for i=1:n_neu
    % printf(['i=' num2str(i)]);            
    ni=length(spiketimes(i).t);
    start_ind=[1 ni+1];
    for j=(i+1):n_neu % symmetric measure
        % printf(['j=' num2str(j)]);            
        nj=length(spiketimes(j).t);
        stime=[spiketimes(i).t;spiketimes(j).t];
        end_ind=[ni ni+nj];
%         if (ni==0 && nj==0)
%             keyboard;
%         end
%         if ((ni==0 && nj==1) || (ni==1 && nj==0))
%             keyboard;
%         end
%         if (i==2 && j==3)
%             stime
%             start_ind
%             end_ind
%             VPq
%         end
        d=spkdl_mex(stime,start_ind,end_ind,VPq);
        VP_mat(i,j)=d(2);
        VPN_mat(i,j)=d(2)./(ni+nj); % Kreiman normalization
    end
end

VP=mean(abs(VP_mat(:)),'omitnan');
% VPE=nanmean(nanmean(abs(VP_mat(1:n_exc,1:n_exc))));
% VPI=nanmean(nanmean(abs(VP_mat(n_exc+1:end,n_exc+1:end))));

VPN=mean(abs(VPN_mat(:)),'omitnan');
