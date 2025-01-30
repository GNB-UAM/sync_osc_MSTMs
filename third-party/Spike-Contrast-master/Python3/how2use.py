# -*- coding: utf-8 -*-
"""
Created on Tue Jul 25 13:56:53 2017

@author: Manuel Ciba
"""

import numpy as np
import Spike_contrast as SC

# create test spike train data: 
# - each column contains a spike train, shorter spike trains are filled with zeros ("zero-padding"))
# - each value is the spike time in seconds    
# - in this example three spike trains are generated 
# - spike train 1 contains 4 spikes
# - spike train 2 contains 4 spikes
# - spike train 3 contains 3 spikes (last array position is filled with zero)
spike_trains = np.array([[1, 1 ,1], [2, 2, 2], [3, 3, 2.5], [9, 9, 0]]) 
T = 11      # entire signal length in seconds

# measure synchrony
S = SC.SpikeContrast(spike_trains, T) 
print(S)
