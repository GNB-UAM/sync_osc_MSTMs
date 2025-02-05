function corr_ind = correlation_index_wrapper(spiketimes,sim_time,inct)
% returns the corr ind measure of synchrony as implemented in Cutts 14

n_neu=length(spiketimes);

corr_ind_mat=nan(n_neu);

for i_neu=1:n_neu
    % printf(['i_neu=' num2str(i_neu)]);
    spikes_this_i=spiketimes(i_neu).t;
    for j_neu=(i_neu+1):n_neu % symmetric measure
        % printf(['j_neu=' num2str(j_neu)]);
        % if i_neu~=j_neu
        spikes_this_j=spiketimes(j_neu).t;
%         if (isempty(spikes_this_i) || isempty(spikes_this_j))
%             keyboard; % in this case correlation_index_mex returns NaN, as expected (because of dividing by zero)
%         end
        corr_ind_mat(i_neu,j_neu)=correlation_index_mex(int32(length(spikes_this_i)),int32(length(spikes_this_j)),inct,[0 sim_time],spikes_this_i,spikes_this_j);
        % end
    end
end

corr_ind=nanmean(nanmean(corr_ind_mat));

