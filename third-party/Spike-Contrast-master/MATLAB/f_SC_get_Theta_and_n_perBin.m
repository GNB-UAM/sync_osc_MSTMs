%% Bin time stamps and calculate number of spikes per bin and number of active spike trains per bin
% Input:    TS:                 time stamps of spikes in seconds (dim: maxNumOfSpikesPerEl x numOfElectrodes)
%           time_start:         time where first bin starts (in seconds)
%           time_end:           time where last bin ends (in seconds)
%           bin:                bin size in seconds to discretize spiketrain
% Output:   AllSpikesPerBin:    array with number of spikes per bin 
%           actElPerBin:        array with number of active electrodes per bin
%           edges:              bin edges
%           x:                  bin centers
%
% needed functions: [y_binned,x_step,edges_step]=binning(y,rec_dur,binsize,step,flag_binary) 
%
% written by Manuel Ciba, 2016/2017

function [AllSpikesPerBin,ActiveSTperBin,edges,x]=f_SC_get_Theta_and_n_perBin(TS,time_start,time_end,bin)

    %% 0) init  
    binStep = bin/2;
    edges=time_start:binStep:time_end;
    x=edges(2:end);
    SPIKEHISTOGRAM=zeros(length(x),size(TS,2));
       
    %% 1) calculate histogram for each electrode
    for n=1:size(TS,2)
        SPIKEHISTOGRAM(:,n)=f_SC_binning_halfOverlap(nonzeros(TS(:,n)),time_start,time_end,bin,0);   % y_binned=binning(y,rec_dur,binsize,step,flag_binary)  
    end
    if size(SPIKEHISTOGRAM,1)==1                                            % in case only one El is active the size of hist would be [1,numberOfbins]
        SPIKEHISTOGRAM=SPIKEHISTOGRAM';
    end           

    %% 2) calculate parameter over all electrodes 
    AllSpikesPerBin=sum(SPIKEHISTOGRAM,2)';                                 % number of spikes per bin over all electrodes
    mask=SPIKEHISTOGRAM~=0;
    ActiveSTperBin=sum(mask,2)';                                               % number of active electrodes per bin
        
end