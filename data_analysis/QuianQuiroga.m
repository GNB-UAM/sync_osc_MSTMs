function [QQ qq] = QuianQuiroga(x_spikes,y_spikes,tc)
% this computes the Quian Quiroga measures of synchrony and delay asymmetry between pairs of spike trains (Quian Quiroga et al 2002 Phys Rev E)
% Q is a symmetric measure, q is antisymmetric

x_num_spikes = length(x_spikes);
y_num_spikes = length(y_spikes);

if tc ~=Inf

    c_wrtx_vect=nan(1,x_num_spikes); % vector of coincidences wrt x_spikes
    c_wrty_vect=nan(1,y_num_spikes); % vector of coincidences wrt y_spikes

    y_spikes_left=y_spikes; % spikes left to consider (coincident or greater than the current reference spike x_spikes(i))
    for i=1:x_num_spikes
        y_spikes_left=y_spikes_left(y_spikes_left>=x_spikes(i));
        if isempty(y_spikes_left)
            break; % no more matching pairs
        else
            nnd_this=y_spikes_left(1)-x_spikes(i); % nearest neighbour distance, considering only spikes that are coincident or greater than the current reference spike
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

else                                                                   % tc = Inf --- pure rate code

    QQ = 1;
    qq=0;

end

