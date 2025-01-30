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
 * Function: mexAdaptiveSPIKEDistance
 * Input: SpikeData,threshold,startTime, endTime
 * output: A-SPIKE-Distance
 *  
 * Other: if endTime is missing the function returns point evaluation at
 *        startTime
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
#define time1 input[2]
    
    double D;
    double* T1 = mxGetPr(time1);
    double* T2;

    
    if (InN == 4)
    {
#define time2 input[3]
        T2 = mxGetPr(time2);
    }
#define output1 output[0]
    
    const mxArray* Data = DATA;
    
    DataReader* Reader = new DataReader;
    Spiketrains* STs = Reader->ReadSpiketrains(Data);
    
    output1 = mxCreateDoubleMatrix(1,1, mxREAL);
    valueOut = (double *)mxGetPr(output1);
    
    if (InN == 3)
    {
        
        D = STs->AdaptiveSPIKEdistance(T1[0],THR[0]);
    }
    else
    {
        
        D = STs->AdaptiveSPIKEdistance(T1[0],T2[0],THR[0]);
    }
    
    valueOut[0] = D;
    
    delete Reader;
    delete STs;
    
}