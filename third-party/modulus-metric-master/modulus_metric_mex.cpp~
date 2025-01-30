#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mex.h"
#include "matrix.h"
#include "modulus_metric.h"
#include <math.h>
//#include <R.h>
//#include <Rmath.h>
#include <time.h>


void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[]){


#define STTC plhs[0]
    
/* #define N_ST_I prhs[0] // number of spikes in spike train i */
/* #define N_ST_J prhs[1] // number of spikes in spike train j */
/* #define INCT prhs[2] // sync window length */
/* #define TIME prhs[3] // avg ISI */
/* #define ST_I prhs[4] // spike train i */
/* #define ST_J prhs[5] // spike train j */

#define ST_I prhs[0] // spike train i
#define ST_J prhs[1] // spike train j
#define A prhs[2] // start time
#define B prhs[3] // end time


  int *a, *b,i;
  double *inct,*time,*index,*sttc,*st_i,*st_j;

//  index = calloc(1, sizeof(double)); // see if this solves the seg fault at *index=0.5*(PA-TB)/(1-TB*PA)+0.5*(PB-TA)/(1-TA*PB); ... yes, of course it does
  index = (double *) calloc(1, sizeof(double)); // explicit cast solves the error: invalid conversion from ‘void*’ to ‘double*’

  //  sttc = mxCreateDoubleScalar(0); // see if this solves the seg fault at *sttc=*index; - warning: assignment from incompatible pointer type
  //  sttc = mxCreateDoubleMatrix(1,1,mxREAL); // see if this solves the seg fault at *sttc=*index; - warning: assignment from incompatible pointer type
  STTC = mxCreateDoubleMatrix(1,1,mxREAL); // see if this solves the seg fault at *sttc=*index; - yes it does
  sttc = (double *)mxGetPr(STTC);
    
  a = (int *)mxGetPr(A);
  b = (int *)mxGetPr(B);
    
  st_i = (double *)mxGetPr(ST_I);
  st_j = (double *)mxGetPr(ST_J);
    
  /* run_pili2_lengths_ruc = (int *)mxGetPr(run_pili2_lengths_ruc_in); */
  /* num_trains = (int *)mxGetPr(num_trains_in); */
  /* previ = (double *)mxGetPr(previ_in); */
  /* prev_indy = (int *)mxGetPr(prev_indy_in); */
    
  /* bi_spike_diffs_realtime_t_out = mxCreateNumericArray(0, 0, mxDOUBLE_CLASS, mxREAL); */
  /* mxSetM(bi_spike_diffs_realtime_t_out, *num_pairs); */
  /* mxSetN(bi_spike_diffs_realtime_t_out, *run_pili2_lengths_ruc); */
  /* mxSetData(bi_spike_diffs_realtime_t_out, mxMalloc(sizeof(double) * *num_pairs * *run_pili2_lengths_ruc)); */
  /* bi_spike_diffs_realtime_t = (double *)mxGetPr(bi_spike_diffs_realtime_t_out); */
    
  /* M  = mxGetM(udists_in); */

  /* printf("n_st_i=%i\n",*n_st_i); */
  /* printf("n_st_j=%i\n",*n_st_j);  */
  /* printf("inct=%f\n",*inct);  */
  /* printf("start time=%f\n",time[0]); */
  /* printf("end time=%f\n",time[1]); */
  /* for(i=0;i<10;i++) */
  /*   printf("st_i[%i]=%f\n",i,st_i[i]); */
  /* printf("\n"); */
  /* for(i=0;i<10;i++) */
  /*   printf("st_j[%i]=%f\n",i,st_j[i]); */
      
//  run_ci(n_st_i,n_st_j,inct,time,index,st_i,st_j);
//  index=do_measure_naive(st_i,st_j); // error: could not convert ‘st_i’ from ‘double*’ to ‘SPIKE_TRAIN {aka std::vector<double>}’
  index=do_measure_naive((SPIKE_TRAIN) st_i, (SPIKE_TRAIN) st_j); // doesn't work

  /* printf("run_sttc terminated\n");  */
  /* printf("index=%f\n",*index);  */

  //    sttc=index; // this seems wrong
  *sttc=*index;

  /* printf("output value assigned to sttc\n");  */
  /* printf("sttc=%f\n",*sttc);  */
  return;
}
