%% bin a sequence of events (e.g. time stamps of spikes) with a bin overlap of 1/2*binSize
% Input:    y: signal (e.g. time stamps)
%           time_start:         time where first bin starts (in seconds)
%           time_end:           time where last bin ends (in seconds)
%           bin:                binsize in seconds to discretize spiketrain
%           flag_binary=1:      frequencies can be only 0 or 1, flag_binary=0: normal mode
% Output:   y_binned:           binned signal
%           x_step:             corresponding x values (=bin center) of y_binned
%           edges_step:         edges of bins
%
% written by Manuel Ciba, 2016/2017

function [y_binned,x_step,edges_step]=f_SC_binning_halfOverlap(y,time_start,time_end,binsize,flag_binary) 

    %% 1) binning half overlap
    step=binsize/2;
    edges_step=time_start:step:time_end; 
    x_step=edges_step(1:end-1)+step;
    y_binned = histcounts(y,edges_step);    
    y_binned_temp = [y_binned, 0];
    y_binned(1:end)= y_binned(1:end) + y_binned_temp(2:end);
       
    %% 2) if flag_binary is true set all values >0 to 1
    if flag_binary
       y_binned(y_binned>0)=1; 
    end

end