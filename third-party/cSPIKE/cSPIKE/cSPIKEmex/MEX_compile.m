%% Compile file for MEX functions.
% The file compiles the MEXes and the C++ classes mplementing the MEXes.

% First run as it is, if you get an error message that involves the two
% variable types "char16_t"  and "unsigned short" please set problem to 1
% and try again. There are some known compiler incompatabilities but one
% of these two variants should usually work.

problem=0;

if problem==0
    
    %% Distance measure functions
    mex mexAdaptiveISIDistance.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex mexAdaptiveSPIKEDistance.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex mexAdaptiveSPIKESynchro.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex mexAdaptiveRateIndependentSPIKEDistance.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    %% Matrix functions
    mex mexAdaptiveISIDistanceMatrix.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex mexAdaptiveSPIKEDistanceMatrix.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    
    %% Profile functions
    mex mexAdaptiveISIDistanceProfile.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex mexAdaptiveSPIKEDistanceProfile.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex mexAdaptiveRateIndependentSPIKEDistanceProfile.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex mexAdaptiveSPIKESynchroProfile.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    %% Surrogate auxiliary functions
    
    mex mexFind_so_profs.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex mexFind_sto_profs.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex SPIKE_order_sim_ann_MEX.c
    
    mex SPIKE_order_surro_MEX.c

else
    
    %% Distance measure functions
    mex -Dchar16_t=uint16_T mexAdaptiveISIDistance.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex -Dchar16_t=uint16_T mexAdaptiveSPIKEDistance.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex -Dchar16_t=uint16_T mexAdaptiveSPIKESynchro.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex -Dchar16_t=uint16_T mexAdaptiveRateIndependentSPIKEDistance.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    %% Matrix functions
    mex -Dchar16_t=uint16_T mexAdaptiveISIDistanceMatrix.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex -Dchar16_t=uint16_T mexAdaptiveSPIKEDistanceMatrix.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    
    %% Profile functions
    mex -Dchar16_t=uint16_T mexAdaptiveISIDistanceProfile.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex -Dchar16_t=uint16_T mexAdaptiveSPIKEDistanceProfile.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex -Dchar16_t=uint16_T mexAdaptiveRateIndependentSPIKEDistanceProfile.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex -Dchar16_t=uint16_T mexAdaptiveSPIKESynchroProfile.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    %% Surrogate auxiliary functions
    
    mex -Dchar16_t=uint16_T mexFind_so_profs.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex -Dchar16_t=uint16_T mexFind_sto_profs.cpp Spiketrain.cpp DataReader.cpp Spiketrains.cpp Pair.cpp ISIProfile.cpp SPIKEProfile.cpp
    
    mex -Dchar16_t=uint16_T SPIKE_order_sim_ann_MEX.c
    
    mex -Dchar16_t=uint16_T SPIKE_order_surro_MEX.c
    
end

