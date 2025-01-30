function D = HunterMilton(x_spikes,y_spikes,tc)
% this computes the Hunter-Milton similarity between pairs of spike trains (Hunter & Milton 2003 J Neurophysiol)
% it is not a symmetric measure: for each spike in x_spikes, the nearest neighbour in y_spikes is considered

x_num_spikes = length(x_spikes);
y_num_spikes = length(y_spikes);

if tc ~=Inf

    nnd_vect=nan(1,x_num_spikes); % vector of nearest neighbour distances

    y_spikes_left=y_spikes; % spikes left to consider
    for i=1:x_num_spikes
        [nnd_vect(i),ind]=min(abs(y_spikes_left-x_spikes(i))); % nearest neighbour
        y_spikes_left=y_spikes_left(ind:end);
    end

    D=mean(exp(-nnd_vect./tc));

else                                                                   % tc = Inf --- pure rate code

    D = 1;

end

