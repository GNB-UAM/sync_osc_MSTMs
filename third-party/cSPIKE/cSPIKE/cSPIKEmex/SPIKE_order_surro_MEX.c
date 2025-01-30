/*
 * Creates surrogates for the calculation of the statistical significance of SPIKE-order
 */

#include "mex.h"
#include "matrix.h"
#include <stdlib.h>
#include <string.h>

// http://stackoverflow.com/questions/11758809/what-is-the-optimal-algorithm-for-generating-an-unbiased-random-integer-within-a?answertab=votes#tab-top
int rangeRandomAlg2(int max)
{
    if (max == 0)
        return 0;
    
    max--;
    int min = 0;
    int n = max - min + 1;
    int remainder = RAND_MAX % n;
    int x;
    do
    {
        x = rand();
    } while (x >= RAND_MAX - remainder);
    return min + x % n;
}

void mexFunction(int nlhs, mxArray *plhs[],
int nrhs, const mxArray *prhs[])

{
    #define indies2_out plhs[0]
    #define error_count_out plhs[1]
            
    #define indies1_in prhs[0]
    #define firsts_in prhs[1]
    #define seconds_in prhs[2]
    #define num_swaps_in prhs[3]

    double *indies1, *firsts, *seconds, num_swaps;
    double *indies2, *error_count;
    int num_pairs, num_rows, num_coins, rc, cc, sc, coin, brk, train1, train2, pos1, pos2, fc11, fc21, fc12, fc22, fcu, fc, pc, sedc, occ;
    double new_trains[2];
    
    indies1 = (double *)mxGetPr(indies1_in);
    firsts = (double *)mxGetPr(firsts_in);
    seconds = (double *)mxGetPr(seconds_in);

    num_swaps = mxGetScalar(num_swaps_in);
    //mexPrintf("num_swaps=%.0f\n",num_swaps);
    
    num_pairs = mxGetM(firsts_in);   // number of pairs
    //mexPrintf("num_pairs=%li\n",num_pairs);
    num_rows = mxGetM(indies1_in);   // number of rows
    //mexPrintf("num_rows=%li\n",num_rows);
    num_coins = mxGetN(indies1_in);   // number of coincidences
    //mexPrintf("num_coins=%li\n",num_coins);
    
    int fiu[num_coins], fi11[num_coins], fi21[num_coins], fi12[num_coins], fi22[num_coins], sed[num_coins];
    
    indies2_out = mxCreateNumericArray(0, 0, mxDOUBLE_CLASS, mxREAL);
    mxSetM(indies2_out, num_rows);
    mxSetN(indies2_out, num_coins);    
    mxSetData(indies2_out, mxMalloc(sizeof(double)*num_rows*num_coins));
    indies2 = (double *)mxGetPr(indies2_out);
    error_count_out = mxCreateDoubleScalar(0);
    error_count = (double *)mxGetPr(error_count_out);
            
    num_rows = mxGetM(indies2_out);   // number of rows
    //mexPrintf("num_rows=%li\n",num_rows);
    num_coins = mxGetN(indies2_out);   // number of coincidences
    //mexPrintf("num_coins=%li\n",num_coins);
    
//     mexPrintf("\nfirsts & seconds:\n");
//     for (rc=0; rc<num_pairs; rc++)
//         mexPrintf("%2.0f %2.0f\n",firsts[rc],seconds[rc]);
//     mexPrintf("\n\n");

//     mexPrintf("indies1:\n");
//     for (rc=0; rc<num_rows; rc++) {
//         for (cc=0; cc<num_coins; cc++)
//             mexPrintf("%2.0f ",indies1[cc*num_rows+rc]);
//         mexPrintf("\n");
//     }
//     mexPrintf("\n\n");
    
//     num_swaps=1;
//     int coins[4];
//     coins[0]=8;
//     coins[1]=3;
//     coins[2]=1;
//     coins[3]=12;
    
    sc=0;
    error_count[0]=0;
    while (sc<num_swaps) {
        brk=0;
    
        coin=rangeRandomAlg2(num_coins)+1;    // get random integer
        //coin=coins[sc];
        //mexPrintf("coin=%li\n",coin);
        
        for (rc=0; rc<num_rows*num_coins; rc++)
            indies2[rc]=indies1[rc];
                                
        train1=indies1[(coin-1)*num_rows+1];   // important, don't use indies directly !
        train2=indies1[(coin-1)*num_rows+2];
        pos1=indies1[(coin-1)*num_rows+3];
        pos2=indies1[(coin-1)*num_rows+4];
        //mexPrintf("\ncoin=%d; train1=%d; train2=%d; pos1=%d; pos2=%d\n\n\n",coin,train1,train2,pos1,pos2);
        
        fcu=0;
        fc11=0;
        //mexPrintf("\nfi11: ");
        for (cc=0; cc<num_coins; cc++)
            if (indies1[cc*num_rows+3]==pos1) {
                fi11[fc11]=cc+1;
                //mexPrintf("%2d ",fi11[fc11]);
                fc11++;
                fiu[fcu]=cc+1;
                fcu++;
            }

        fc21=0;
        //mexPrintf("\nfi21: ");
        for (cc=0; cc<num_coins; cc++)
            if (indies1[cc*num_rows+4]==pos1) {
                fi21[fc21]=cc+1;
                //mexPrintf("%2d ",fi21[fc21]);
                fc21++;
                fiu[fcu]=cc+1;
                fcu++;
            }

        fc12=0;
        //mexPrintf("\nfi12: ");
        for (cc=0; cc<num_coins; cc++)
            if (indies1[cc*num_rows+3]==pos2) {
                fi12[fc12]=cc+1;
                //mexPrintf("%2d ",fi12[fc12]);
                fc12++;
                fiu[fcu]=cc+1;
                fcu++;
            }

        fc22=0;
        //mexPrintf("\nfi22: ");
        for (cc=0; cc<num_coins; cc++)
            if (indies1[cc*num_rows+4]==pos2) {
                fi22[fc22]=cc+1;
                //mexPrintf("%2d ",fi22[fc22]);
                fc22++;
                if (cc!=coin) {
                    fiu[fcu]=cc+1;
                    fcu++;
                }
            }
        //mexPrintf("\nfcs: %2d %2d %2d %2d %2d\n",fc11,fc21,fc12,fc22,fcu);
        //mexPrintf("\nfiu: ");
        //for (fc=0; fc<fcu; fc++)
        //   mexPrintf("%2d ",fiu[fc]);
        //mexPrintf("\n");
        
        for (fc=0; fc<fc11; fc++)
            indies1[(fi11[fc]-1)*num_rows+1]=train2;
        for (fc=0; fc<fc21; fc++)
            indies1[(fi21[fc]-1)*num_rows+2]=train2;
        for (fc=0; fc<fc12; fc++)
            indies1[(fi12[fc]-1)*num_rows+1]=train1;
        for (fc=0; fc<fc22; fc++)
            indies1[(fi22[fc]-1)*num_rows+2]=train1;

        //mexPrintf("\n\nfiu & new_train:\n");
        for (fc=0; fc<fcu; fc++) {
            if (indies1[(fiu[fc]-1)*num_rows+1]<=indies1[(fiu[fc]-1)*num_rows+2]) {    // switch train numbers
                new_trains[0]=indies1[(fiu[fc]-1)*num_rows+1];
                new_trains[1]=indies1[(fiu[fc]-1)*num_rows+2];
            }
            else {
                new_trains[0]=indies1[(fiu[fc]-1)*num_rows+2];                
                new_trains[1]=indies1[(fiu[fc]-1)*num_rows+1];
            }
            for (pc=0; pc<num_pairs; pc++) {                                           // update pair as well
                if (firsts[pc]==new_trains[0] && seconds[pc]==new_trains[1]) {
                    indies1[(fiu[fc]-1)*num_rows]=pc+1;
                    //mexPrintf("%2d %2.0f %2.0f %2d\n",fiu[fc],new_trains[0],new_trains[1],pc+1);
                    break;
                }
            }
        }

//         mexPrintf("indies1:\n");
//         for (rc=0; rc<num_rows; rc++) {
//             for (cc=0; cc<num_coins; cc++)
//                 mexPrintf("%2.0f ",indies1[cc*num_rows+rc]);
//             mexPrintf("\n");
//         }
//         mexPrintf("\n\n");
        
        for (fc=0; fc<fcu; fc++) {   // loop over all changed pairs
            sedc=0;
            for (cc=0; cc<num_coins; cc++) {      
                if (indies1[cc * num_rows]==indies1[(fiu[fc]-1)*num_rows] && (cc+1)!=fiu[fc]) { // all other coincidences from that pair of spike trains
                    sed[sedc]=cc+1;                                                                         // sed-difference between the two sets (setdiff)
                    sedc++;
                    //mexPrintf("%2d ",cc+1);
                }
            }
            //mexPrintf("\n");
            for (occ=0; occ<sedc; occ++) {
                if (indies1[fiu[fc]*num_rows+3]==indies1[sed[occ]*num_rows+3] || indies1[fiu[fc]*num_rows+3]==indies1[sed[occ]*num_rows+4] || indies1[fiu[fc]*num_rows+4]==indies1[sed[occ]*num_rows+3] || indies1[fiu[fc]*num_rows+4]==indies1[sed[occ]*num_rows+4]) {
                    error_count[0]++;
                    //if (error_count[0]==1) {
                        //mexPrintf("##### ec = %2.0f ######\n",error_count[0]);
                        //mexPrintf("%2.0f %2.0f %2.0f %2.0f\n\n\n",indies1[fiu[fc]*num_rows+3],indies1[fiu[fc]*num_rows+4],indies1[sed[occ]*num_rows+3],indies1[sed[occ]*num_rows+4]);                    
                    //}
                    for (rc=0; rc<num_rows*num_coins; rc++)
                        indies1[rc]=indies2[rc];
                    brk=1;
                    break;
                }
            }
            if (brk==1)
                break;
        }
        if (brk==1) {
            if (error_count[0]<=num_coins)
                continue;
            else
                sc=num_swaps;
        }
        sc++;
        
//         mexPrintf("indies1:\n");
//         for (rc=0; rc<num_rows; rc++) {
//             for (cc=0; cc<num_coins; cc++)
//                 mexPrintf("%2.0f ",indies1[cc*num_rows+rc]);
//             mexPrintf("\n");
//         }
//         mexPrintf("\n\n");

    }

    for (rc=0; rc<num_rows*num_coins; rc++)
        indies2[rc]=indies1[rc];
    //mexPrintf("returning \n");
    return;
}

