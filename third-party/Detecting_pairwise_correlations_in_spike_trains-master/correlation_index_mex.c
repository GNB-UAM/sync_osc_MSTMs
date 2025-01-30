#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mex.h"
#include "matrix.h"
#include <math.h>
//#include <R.h>
//#include <Rmath.h>
#include <time.h>

//calculates the correlation index

void run_ci(int *N1v,int *N2v,double *dtv,double *Time,double *index,double *spike_times_1,double *spike_times_2){

	
	int i;
	int j;
	int u;
	double dt= *dtv;
	int N1= *N1v;
	int N2= *N2v;
	double T;
	int Nab;
	T=Time[1]-Time[0];	
	
	Nab=0;	
	j=0;
	for(i=0;i<N1;i++){
		
		while(j<N2){
			
			if((spike_times_1[i]-spike_times_2[j])>dt){
				j=j+1;
			
			}
			else if(fabs(spike_times_1[i]-spike_times_2[j])<=dt){
				Nab=Nab+1;
				u=j+1;
				while(fabs(spike_times_1[i]-spike_times_2[u])<=dt){
				
					Nab=Nab+1;
					u=u+1;
				}
				break;
			}
			else{
				
				break;
				
			}
		}
	}
	
	*index=(((double)Nab)*T)/(((double)N1)*((double)N2)*2*dt);
	
		
		
}

void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[]){


#define STTC plhs[0]
    
#define N_ST_I prhs[0] // number of spikes in spike train i
#define N_ST_J prhs[1] // number of spikes in spike train j
#define INCT prhs[2] // sync window length
#define TIME prhs[3] // avg ISI
#define ST_I prhs[4] // spike train i
#define ST_J prhs[5] // spike train j

  int *n_st_i, *n_st_j,i;
  double *inct,*time,*index,*sttc,*st_i,*st_j;

  index = calloc(1, sizeof(double)); // see if this solves the seg fault at *index=0.5*(PA-TB)/(1-TB*PA)+0.5*(PB-TA)/(1-TA*PB); ... yes, of course it does

  //  sttc = mxCreateDoubleScalar(0); // see if this solves the seg fault at *sttc=*index; - warning: assignment from incompatible pointer type
  //  sttc = mxCreateDoubleMatrix(1,1,mxREAL); // see if this solves the seg fault at *sttc=*index; - warning: assignment from incompatible pointer type
  STTC = mxCreateDoubleMatrix(1,1,mxREAL); // see if this solves the seg fault at *sttc=*index; - yes it does
  sttc = (double *)mxGetPr(STTC);
    
  n_st_i = (int *)mxGetPr(N_ST_I);
  n_st_j = (int *)mxGetPr(N_ST_J);
  inct = (double *)mxGetPr(INCT);
  time = (double *)mxGetPr(TIME);
    
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
      
  run_ci(n_st_i,n_st_j,inct,time,index,st_i,st_j);

  /* printf("run_sttc terminated\n");  */
  /* printf("index=%f\n",*index);  */

  //    sttc=index; // this seems wrong
  *sttc=*index;

  /* printf("output value assigned to sttc\n");  */
  /* printf("sttc=%f\n",*sttc);  */
  return;
}
