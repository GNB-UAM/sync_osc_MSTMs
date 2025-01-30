/* Object: MEX-file
 * Creator: Eero Satuvuori
 * Date: 18.8.2016
 * Version: 1.0
 * Purpose: This is a MEX function interfacing Matlab variables into C++
 *          back end implementing the method and gating the result back to
 *          Matlab.
 */

#include <mex.h>
#include <matrix.h>
#include <vector>
#include "Spiketrains.h"
#include "DataReader.h"

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: mexAdaptiveISIDistanceProfile
 * Input: SpikeData,threshold,RecordingStartTime, RecordingEndTime, startTime, endTime
 * output: A-SPIKE-Synchronization spike values,
 *         SPIKE-order spike values,
 *         spike train order spike values
 *
 * Other: -
 */
void mexFunction(int outputN, mxArray* output[], int inputN, const mxArray* input[] )
{
    
    int* valueIn;
    double* valueOut;
    // Defining input and output
#define InN inputN
#define OutN outputN
#define DATA input[0]
#define thr input[1]
    double* THR = mxGetPr(thr);
    
#define start input[2]
#define end input[3]
#define time3 input[4]
#define time4 input[5]
#define spikes input[6]
#define indices input[7]
    double* T1 = mxGetPr(start);
    double* T2 = mxGetPr(end);
    double* T3 = mxGetPr(time3);
    double* T4 = mxGetPr(time4);
    const mxArray* Data = DATA;
    double* Spikes = mxGetPr(spikes);
    double* SpikeTrainOfASpike = mxGetPr(indices);
    
    DataReader* Reader = new DataReader;
    
    Spiketrains* STs = Reader->ReadSpiketrains(Data);
    
    const int M = mxGetNumberOfElements(spikes);
    const int N = STs->NumberOfSpikeTrains()*(STs->NumberOfSpikeTrains()-1)/2;
    //mexPrintf("M %d N %d \n",M,N);
    //mexPrintf("T1 %f T2 %f \n",T1[0],T2[0]);
    std::vector< unsigned int > Counters;
    std::vector< std::vector < double > > Matrix;
    
    // Initializing counters
    for (unsigned int Index = 0;Index < N; Index++)
    {
        Counters.push_back(1);
    }
    
    for (unsigned int spikeIndex = 0;spikeIndex < M; spikeIndex++)
    {
        unsigned int FromSpikeTrain = SpikeTrainOfASpike[spikeIndex]-1;
        std::vector <double> spikeValues;
        double maxwindow = T2[0]-T1[0];
        //mexPrintf("maxwindow %f \n",maxwindow);
        
        for (unsigned int Train1 = 0;Train1 < STs->NumberOfSpikeTrains()-1; Train1++)
        {
            for (unsigned int Train2 = Train1+1;Train2 < STs->NumberOfSpikeTrains(); Train2++)
            {
                //mexPrintf("Trains %d and %d with spike at spike train %d\n",Train1,Train2,FromSpikeTrain);
                unsigned int NthSpike = Counters.at(FromSpikeTrain);
                if (Train1 == FromSpikeTrain)
                {
                    double Order = STs->OrderOfSpikes(NthSpike,Train1,Train2,maxwindow);
                    spikeValues.push_back(Order);
                    //mexPrintf("order %f for trains %d %d \n",Order,Train1,Train2);
                }
                else if (Train2 == FromSpikeTrain)
                {
                    double Order = STs->OrderOfSpikes(NthSpike,Train2,Train1,maxwindow);
                    spikeValues.push_back(Order);
                    //mexPrintf("order %f for trains %d %d \n",Order,Train1,Train2);
                }
                else
                {
                    //mexPrintf("spike not involved \n");
                    spikeValues.push_back(0.0);
                }
            }
        }
        
        Counters.at(FromSpikeTrain)++;
        Matrix.push_back(spikeValues);
    }

#define output1 output[0]
    
    // One dimensional cell arrays for the values
    output1 = mxCreateDoubleMatrix(N,M, mxREAL);
    
    valueOut = (double *)mxGetPr(output1);
    //mexPrintf("SO matrix\n\n");
    unsigned int index = 0;
    for (unsigned int m = 0;m < M; m++)
    {
        for (unsigned int n = 0;n < N; n++)
        {
            valueOut[index] = Matrix.at(m).at(n);
            index++;
            //mexPrintf("| %f",Matrix.at(m).at(n));
        }
        //mexPrintf("\n");
    }
    
    
    delete Reader;
    delete STs;
    
}