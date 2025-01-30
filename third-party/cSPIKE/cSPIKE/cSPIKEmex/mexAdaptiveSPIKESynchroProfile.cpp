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
 * Function: mexAdaptiveSPIKESynchroProfile
 * Input: SpikeData, threshold, RecordingStartTime, RecordingEndTime, startTime, endTime
 * output: A-SPIKE-Synchronization spike values, 
 *         SPIKE-order spike values,
 *         spike train order spike values 
 *
 * Other: -
 */
void mexFunction(int outputN, mxArray* output[], int inputN, const mxArray* input[] )
{
    int* valueIn;
    double* Handle;
    
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
    double D = 100;
    double* T1 = mxGetPr(start);
    double* T2 = mxGetPr(end);
    double* T3 = mxGetPr(time3);
    double* T4 = mxGetPr(time4);
    double* T5 = mxGetPr(MAX_DIST);
    const mxArray* Data = DATA;
    
    DataReader* Reader = new DataReader;
    
    Spiketrains* STs = Reader->ReadSpiketrains(Data);
    
    std::vector<std::vector<double> > profile1,profile2,profile3;
    
    // SUBSTITUTE WITH THE FUNCTIONS THAT READ ALL OF THESE
    profile1 = STs->AdaptiveSPIKEsynchroProfile(T1[0],T2[0],T3[0],T4[0],THR[0],T5[0]);
    profile2 = STs->SPIKEorderProfile(T1[0],T2[0],T3[0],T4[0]);
    profile3 = STs->SPIKEtrainOrderProfile(T1[0],T2[0],T3[0],T4[0]);
    
#define output1 output[0]
#define output2 output[1]
#define output3 output[2]
    // One dimensional cell arrays for the values
    
    //int NOST = profile1.size();                           // ######## changed following Eero's suggestion ######## 
    const unsigned long int NOST = profile1.size();
    output1 = mxCreateCellArray(1, &NOST);
    output2 = mxCreateCellArray(1, &NOST);
    output3 = mxCreateCellArray(1, &NOST);
    OutN = 3;
    
    // Fill the first output with the values of spike synch
    for(int STindex = 0; STindex < NOST ;STindex++)
    {
        double Length = profile1.at(STindex).size();
        mxArray* spiketrain = mxCreateDoubleMatrix(1,Length, mxREAL);
        Handle = (double *)mxGetPr(spiketrain);
        
        for(int Sindex = 0; Sindex < Length ; Sindex++)
        {
            Handle[Sindex] = profile1.at(STindex).at(Sindex); 
        }
        mxSetCell(output1,STindex,spiketrain);
    }
    // Fill the second output with the values of spikes in spike order
    for(int STindex = 0; STindex < NOST ;STindex++)
    {
        double Length = profile2.at(STindex).size();
        mxArray* spiketrain = mxCreateDoubleMatrix(1,Length, mxREAL);
        Handle = (double *)mxGetPr(spiketrain);
        
        for(int Sindex = 0; Sindex < Length ; Sindex++)
        {      
            Handle[Sindex] = profile2.at(STindex).at(Sindex);  
        }
        mxSetCell(output2,STindex,spiketrain);
    }
    
    // Fill the third output with the values of spikes in spike order
    for(int STindex = 0; STindex < NOST ;STindex++)
    {
        double Length = profile3.at(STindex).size();
        mxArray* spiketrain = mxCreateDoubleMatrix(1,Length, mxREAL);
        Handle = (double *)mxGetPr(spiketrain);
        
        for(int Sindex = 0; Sindex < Length ; Sindex++)
        {       
            Handle[Sindex] = profile3.at(STindex).at(Sindex);   
        }
        mxSetCell(output3,STindex,spiketrain);
    }
    
    
    delete Reader;
    delete STs;
    
}
