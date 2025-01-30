/* Object: DataReader
 * Creator: Eero Satuvuori
 * Date: 18.8.2016
 * Version: 1.0
 * Purpose: Object class for reading the input and
 *          creating the output class Spiketrains
 */
#include "DataReader.h"
#include "Spiketrains.h"
#include <cstdlib>
#include <mex.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Constructor
 * Input: -
 * output: -
 *
 * Other: -
 */
DataReader::DataReader(){}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: 
 * Input: mxArray* MEX class of cell array containing spike times
 * output: Spiketrains* to an object created with new
 *
 * Other: Output created with new. Deleting is the 
 *        responsibility of the caller.
 */
Spiketrains* DataReader::ReadSpiketrains(const mxArray* ST)
{
    Spiketrains* STs = new Spiketrains;
    
    // Defining variables used for gating of data
    mwSize N = mxGetNumberOfElements(ST);
    mwIndex STindex, Sindex;

    // Indexing for each spike train and for each spike
    for (STindex = 0 ; STindex < N ; STindex++)
    {
        // getting spiketrain
        mxArray* CellElement = mxGetCell(ST,STindex);
        
        // Getting the length of the spiketrain
        const mwSize* M = mxGetDimensions(CellElement);
        double* spikes = mxGetPr(CellElement);
        // vector for saving the spikes
        std::vector<double> Spikes;
        
        // Create vector array for spikes
        for (Sindex = 0;Sindex < M[1]; Sindex++)
        {
            double spiketime = spikes[Sindex];
            
            Spikes.push_back(spiketime);
            
        }
        // Create new spiketrain
        
        Spiketrain* tmpSTptr = new Spiketrain(Spikes);
        STs->AddSpiketrain(tmpSTptr);
        
    }
    
    return STs;
}


