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
 * Function: mexAdaptiveSPIKESynchro
 * Input: SpikeData,threshold,RecordingStartTime, RecordingEndTime, startTime, endTime
 * output: A-SPIKE-Synchronization
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
#define MAX_DIST input[6]
    double* T1 = mxGetPr(start);
    double* T2 = mxGetPr(end);  
    double* T3 = mxGetPr(time3);
    double* T4 = mxGetPr(time4);  
    double* T5 = mxGetPr(MAX_DIST);
	
#define output1 output[0]
    
    const mxArray* Data = DATA;
    
    DataReader* Reader = new DataReader;
    Spiketrains* STs = Reader->ReadSpiketrains(Data);
    
    output1 = mxCreateDoubleMatrix(1,1, mxREAL);
    valueOut = (double *)mxGetPr(output1);

    valueOut[0] = STs->AdaptiveSPIKEsynchro(T1[0],T2[0],T3[0],T4[0],THR[0],T5[0]);

    delete Reader;
    delete STs;

}