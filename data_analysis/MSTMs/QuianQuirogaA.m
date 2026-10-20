function [QQ qq] = QuianQuirogaA(x_spikes,y_spikes)
% this computes the Quian Quiroga measures of synchrony and delay asymmetry between pairs of spike trains (Quian Quiroga et al 2002 Phys Rev E)
% Q is a symmetric measure, q is antisymmetric

x_num_spikes = length(x_spikes);
y_num_spikes = length(y_spikes);

c_wrtx_vect=nan(1,x_num_spikes); % vector of coincidences wrt x_spikes
c_wrty_vect=nan(1,y_num_spikes); % vector of coincidences wrt y_spikes

% the local timescale is tau_ij=min{x(i+1)-x(i), x(i)-x(i-1), y(j+1)-y(j), y(j)-y(j-1)}/2 (Quian Quiroga et al 2002 Eq. 4),
% computed from the ISIs around the two spikes being compared: x(i) and its matched spike y(j)
y_spikes_left=y_spikes; % spikes left to consider (coincident or greater than the current reference spike x_spikes(i))
for i=1:x_num_spikes
    y_spikes_left=y_spikes_left(y_spikes_left>=x_spikes(i));
    if isempty(y_spikes_left)
        break; % no more matching pairs
    else
        nnd_this=y_spikes_left(1)-x_spikes(i); % nearest neighbour distance, considering only spikes that are coincident or greater than the current reference spike
        j=y_num_spikes-length(y_spikes_left)+1; % index of the matched spike y_spikes_left(1) in y_spikes
        tc=min([local_isis(x_spikes,i) local_isis(y_spikes,j)])./2;
        if nnd_this==0
            c_wrtx_vect(i)=0.5;
        elseif nnd_this<tc
            c_wrtx_vect(i)=1.;
        else
            c_wrtx_vect(i)=0.;
        end
    end
end

x_spikes_left=x_spikes; % spikes left to consider (coincident or greater than the current reference spike y_spikes(i))
for i=1:y_num_spikes
    x_spikes_left=x_spikes_left(x_spikes_left>=y_spikes(i));
    if isempty(x_spikes_left)
        break;
    else
        nnd_this=x_spikes_left(1)-y_spikes(i); % nearest neighbour distance, considering only spikes that are coincident or greater than the current reference spike
        j=x_num_spikes-length(x_spikes_left)+1; % index of the matched spike x_spikes_left(1) in x_spikes
        tc=min([local_isis(y_spikes,i) local_isis(x_spikes,j)])./2;
        if nnd_this==0
            c_wrty_vect(i)=0.5;
        elseif nnd_this<tc
            c_wrty_vect(i)=1.;
        else
            c_wrty_vect(i)=0.;
        end
    end
end

c_wrtx_sum=sum(c_wrtx_vect,'omitnan');
c_wrty_sum=sum(c_wrty_vect,'omitnan');

norm_f=sqrt(x_num_spikes*y_num_spikes); % normalization factor

QQ=(c_wrtx_sum+c_wrty_sum)./norm_f; % symmetric
qq=(c_wrtx_sum-c_wrty_sum)./norm_f; % antisymmetric: positive if spikes in y_spikes tend to closely follow spikes in x_spikes

end

function isis=local_isis(spikes,k)
% ISIs before and after spike k (inf if spike k is the first or last spike)
isis=[inf inf];
if k>1
    isis(1)=spikes(k)-spikes(k-1);
end
if k<length(spikes)
    isis(2)=spikes(k+1)-spikes(k);
end
end
