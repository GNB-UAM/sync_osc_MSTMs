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
 * Input: SpikeData,threshold,startTime, endTime
 * output: A-SPIKE-DistanceProfile
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
//#define POOLED input[1]
    #define thr input[1]
    double* THR = mxGetPr(thr);
#define time1 input[2]
#define time2 input[3]
    double D = 100; 
    double* T1 = mxGetPr(time1);
    double* T2 = mxGetPr(time2);
    
#define output1 output[0]
    
    const mxArray* Data = DATA;
    
    //const mxArray* Pooled = POOLED;
    DataReader* Reader = new DataReader;
    
    Spiketrains* STs = Reader->ReadSpiketrains(Data);

    std::vector<double> Yprofile;
    std::vector<double> Xprofile;

    STs->AdaptiveRateIndependentSPIKEDistanceProfile(Xprofile,Yprofile, T1[0],T2[0],THR[0]);

    output1 = mxCreateDoubleMatrix(2,Xprofile.size(), mxREAL);
    valueOut = (double *)mxGetPr(output1);
    
    for(int i = 0; i < Xprofile.size(); i++)
    {        
        valueOut[i*2] = Yprofile.at(i);  
    }
    for(int i = 0; i < Xprofile.size(); i++)
    {        
        valueOut[i*2+1] = Xprofile.at(i);  
    }
    delete Reader;
    delete STs;

}