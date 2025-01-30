%% Spike-contrast 
% Purpose:  Measure synchrony between two or more spike trains
%
% Input:    TS:         time stamps of spikes in seconds, 
%                       input as matrix (dim: maxNumOfSpikesPerSpiketrain x numOfSpiketrains)
%                       (NaN-Padding)
%           T:          signal length in seconds
%
% Output:   S:          Synchrony index (0: min. synchrony, 1: max. synchrony) 
%           PREF:       Used preferences/parameter to calculate Spike-contrast
%
% needed functions:     [AllSpikesPerBin,ActiveSTperBin,edges,xvalues]=f_SC_get_Theta_and_n_perBin(TS,time_start,time_end,bin);
%                       [y_binned,x_step,edges_step]=binning(y,time_start,time_end,binsize,step,flag_binary) 
%
% written by Manuel Ciba, 2016/2017



function [S,PREF] = SpikeContrast(TS,T)
    
    tic

    %% FORMATTING
    TS(TS==0)=NaN;                          % force NaN patting (Note: not correct if spike time stamp is exactly zero seconds)
    TS=sort(TS);    
    if any(any(TS<0))
        error('negative time stamps are not allowed')
    end
    
    %% PARAMETER:
    % bin size decrease factor:
    binShrinkFactor=0.9;           
    % max. bin size:
    maxBin=T/2;                                              
    % min. bin size:
    ISI=diff(TS);
    ISImin= min(min(ISI));
    minBin=max([ISImin/2, 0.001]); % minBin is not smaller than 1 ms   
    % bin overlap:
    binStepFactor = 2; % this variable is not used in this version   

    if maxBin <= minBin
        error('min. bin size is greater or equal to max. bin size')
    end
    
    %% 0) N = number of spike trains
    N=sum(max(~isnan(TS))); % if no spikes on spike train, than every element is NaN

    %% 1) Binning

    % initialization:
    numIterations = ceil(log(minBin/maxBin)/log(binShrinkFactor)); % maxBin * binShrinkFactor^numIterations >= minBin
    ActiveST=zeros(numIterations,1); 
    Contrast=zeros(numIterations,1); 
    s=zeros(numIterations,1); % s = ActiveST * Contrast
    bins=zeros(numIterations,1);
    
    % calc all histograms
    numAllSpikes = sum(~isnan(TS(:))); % number of all spikes in TS
    bin = maxBin; % first bin size
    for i=1:numIterations
        
        %% Calculate Theta and n  
        time_start = -ISImin;
        time_end = T+ISImin;
        [Theta_k,n_k]=f_SC_get_Theta_and_n_perBin(TS,time_start,time_end,bin);
        
        %% Calculate: C = Contrast * ActiveST          
        ActiveST(i) = ((sum(n_k.*Theta_k))/(sum(Theta_k))-1) / (N-1);
        Contrast(i)=(sum(abs(diff(Theta_k)))/ (numAllSpikes*2)) ; % Contrast: sum(|derivation|) / (2*#Spikes)
        s(i)=Contrast(i) * ActiveST(i); % Synchrony curve "C"
        
        bins(i)=bin; % safe bins
        bin=bin*binShrinkFactor; % new decreased bin size

    end

    %% 2) Sync value is maximum of synchrony curve s
    S= max(s);
    PREF.s = s;
    PREF.Contrast = Contrast;
    PREF.ActiveST = ActiveST;
    PREF.bins = bins;
    PREF.maxBin = maxBin;
    PREF.minBin = minBin;
    PREF.binStepFactor = binStepFactor;
    PREF.binShrinkFactor = binShrinkFactor;
    PREF.T = T;
    PREF.t = toc; % calculation time
    
end