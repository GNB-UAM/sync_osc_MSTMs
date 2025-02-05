function [QQ qq] = QuianQuirogaA(x_spikes,y_spikes)
% this computes the Quian Quiroga measures of synchrony and delay asymmetry between pairs of spike trains (Quian Quiroga et al 2002 Phys Rev E)
% Q is a symmetric measure, q is antisymmetric

x_num_spikes = length(x_spikes);
y_num_spikes = length(y_spikes);

c_wrtx_vect=nan(1,x_num_spikes); % vector of coincidences wrt x_spikes
c_wrty_vect=nan(1,y_num_spikes); % vector of coincidences wrt y_spikes

y_spikes_left=y_spikes; % spikes left to consider (coincident or greater than the current reference spike x_spikes(i))
isi_p_y=inf; % previous ISI
isi_p_x=inf;
for i=1:x_num_spikes
    y_spikes_left=y_spikes_left(y_spikes_left>=x_spikes(i));
    if isempty(y_spikes_left)
        break; % no more matching pairs
    else
        nnd_this=y_spikes_left(1)-x_spikes(i); % nearest neighbour distance, considering only spikes that are coincident or greater than the current reference spike
        if (length(y_spikes_left)>1)
            isi_n_y=y_spikes_left(2)-y_spikes_left(1); % next ISI
        else
            isi_n_y=inf;
        end
        if i<x_num_spikes
            isi_n_x=x_spikes(i+1)-x_spikes(i);
        else
            isi_n_x=inf;
        end
        tc=min([isi_p_y isi_p_x isi_n_y isi_n_x])./2;
        if nnd_this==0
            c_wrtx_vect(i)=0.5;
        elseif nnd_this<tc
            c_wrtx_vect(i)=1.;
        else
            c_wrtx_vect(i)=0.;
        end
        isi_p_y=isi_n_y;
        isi_p_x=isi_n_x;
    end
end

x_spikes_left=x_spikes; % spikes left to consider (coincident or greater than the current reference spike y_spikes(i))
isi_p_y=inf; % previous ISI
isi_p_x=inf;
for i=1:y_num_spikes
    x_spikes_left=x_spikes_left(x_spikes_left>=y_spikes(i));
    if isempty(x_spikes_left)
        break;
    else
        nnd_this=x_spikes_left(1)-y_spikes(i); % nearest neighbour distance, considering only spikes that are coincident or greater than the current reference spike
        if (length(x_spikes_left)>1)
            isi_n_x=x_spikes_left(2)-x_spikes_left(1); % next ISI
        else
            isi_n_x=inf;
        end
        if i<y_num_spikes
            isi_n_y=y_spikes(i+1)-y_spikes(i);
        else
            isi_n_y=inf;
        end
        tc=min([isi_p_y isi_p_x isi_n_y isi_n_x])./2;
        if nnd_this==0
            c_wrty_vect(i)=0.5;
        elseif nnd_this<tc
            c_wrty_vect(i)=1.;
        else
            c_wrty_vect(i)=0.;
        end
        isi_p_y=isi_n_y;
        isi_p_x=isi_n_x;
    end
end

c_wrtx_sum=sum(c_wrtx_vect,'omitnan');
c_wrty_sum=sum(c_wrty_vect,'omitnan');

norm_f=sqrt(x_num_spikes*y_num_spikes); % normalization factor

QQ=(c_wrtx_sum+c_wrty_sum)./norm_f; % symmetric
qq=(c_wrtx_sum-c_wrty_sum)./norm_f; % antisymmetric: positive if spikes in y_spikes tend to closely follow spikes in x_spikes
