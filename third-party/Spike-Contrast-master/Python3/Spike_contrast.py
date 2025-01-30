# -*- coding: utf-8 -*-
"""
Created on Tue Apr 25 17:59:39 2017

@author: Manuel Ciba
"""

import numpy as np

def generateRandomTestData(num_trains, num_spikes, T):
    spike_trains = np.random.random((num_trains, num_spikes))   # random values between 0 and 1
    spike_trains = np.sort(spike_trains)                        # sort values
    spike_trains = spike_trains * T
    return spike_trains

def generateTestData():                       
    #spike_trains = np.array([[1, 1 ,1], [2, 3, 1.5], [5, 8, 6], [9, 10, 9]])
    spike_trains = np.array([[1, 1 ,1], [2, 2, 2], [3, 3, 2.5], [9, 9, 9]])
    T = 11
    return spike_trains, T

def get_Theta_and_n_perBin(spike_trains, time_start, time_end, binSize):
   
    # init
    binStep = binSize/2
    edges = np.arange(time_start, time_end, binStep)
    tmp = spike_trains.shape                                    # number of spike trains
    N = tmp[1]
    hist = np.zeros((len(edges)-1,N));
    # calculate histogram for every spike train
    for i in range(0, N):                                       # for all spike trains
        y = spike_trains[:,i]
        y = y[~np.isnan(y)]                                     # only use non-nan values
        hist[:,i] = binning_halfOverlap(y, time_start, time_end, binSize)
    # calculate parameter over all spike trains
    theta = np.sum(hist, 1)                                      # number of spikes per bin 
    mask = hist != 0
    n = np.sum(mask, 1)                                          # number of active spike trains
        
    return theta, n

def binning_halfOverlap(y, time_start, time_end, binSize, flag_binary=False):
    binStep = binSize/2
    edges = np.arange(time_start, time_end, binStep)
    hist, bin_edges = np.histogram(y, edges)
    hist[0:len(hist)-1] = hist[0:len(hist)-1] + hist[1:len(hist)] 
    return hist

"""
Main Function: SpikeContrast
"""

def SpikeContrast(spike_trains, T):    
    # delete all columns containing only zeros
    #spike_trains = spike_trains[~np.all(spike_trains == 0, axis=0)]    # does not work yet
    
    # set zeros to NaN (zero-padding)
    spike_trains = np.where(spike_trains == 0, np.nan, spike_trains)    # set all zeros to NaN
    mask = np.isnan(spike_trains)
    spike_trains_ma = np.ma.MaskedArray(spike_trains, mask)             # also make a masked array
    
    tmp = spike_trains_ma.shape                                         # number of spike trains
    N = tmp[1]
    
    # parameter
    binShrinkFactor = 0.9                                       # bin size decreases by factor 0.9 for each iteration
    binStepFactor = 2                                           # bin overlap of 50 % (not used/variable in this version)
    binMax = T/2
    isi = np.diff(spike_trains_ma, axis=0)
    isiMin = np.min(isi)
    binMin = np.max([isiMin/2, 0.01])
    
    
    
    # initialization
    numIterations = np.ceil(np.log(binMin / binMax) / np.log(binShrinkFactor))
    numIterations = int(numIterations)
    ActiveST = np.zeros((numIterations, 1))
    Contrast = np.zeros((numIterations, 1))
    C = np.zeros((numIterations, 1))
    
    numAllSpikes = spike_trains_ma.count()
    binSize = binMax
    
    for i in range(0, numIterations):                           # for 0, 1, 2, ... numIterations
             
        # calculate Theta and n
        time_start = -isiMin
        time_end = T + isiMin 
        Theta_k, n_k = get_Theta_and_n_perBin(spike_trains, time_start, time_end, binSize)
        
        # calcuate C= Contrast * ActiveST
        ActiveST[i] = ((np.sum(n_k*Theta_k))/(np.sum(Theta_k))-1) / (N-1)
        Contrast[i] = (np.sum(np.abs(np.diff(Theta_k)))/ (numAllSpikes*2))                    # Contrast: sum(|derivation|) / (2*#Spikes)
        C[i] = Contrast[i] * ActiveST[i]                                                      # Synchrony curve "C"
        
        binSize *= binShrinkFactor                              # new bin size
    
    # Sync value is maximum of cost function C
    S = np.max(C)
    return S


"""
Main Program (example)
"""

#spike_trains, T = generateTestData()
#spike_trains = generateRandomTestData(3, 5, 60)
#S = SpikeContrast(spike_trains, T)
#print(S)
