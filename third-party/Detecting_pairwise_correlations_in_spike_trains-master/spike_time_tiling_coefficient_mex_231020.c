#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mex.h"
#include "matrix.h"
#include <math.h>
//#include <R.h>
//#include <Rmath.h>

//calculates the tiling coefficient

double run_P(int N1,int N2,double dt,double *spike_times_1,double *spike_times_2){

	int i;
	int j;
	int Nab;
		
	Nab=0;
	j=0;
	for(i=0;i<=(N1-1);i++){
		while(j<N2){	
//check every spike in train 1 to see if there's a spike in train 2 within dt  (don't count spike pairs)
// don't need to search all j each iteration
			if(fabs(spike_times_1[i]-spike_times_2[j])<=dt){
				Nab=Nab+1;	
				break;				
			}
			else if(spike_times_2[j]>spike_times_1[i]){			
				break;
			}
			else{
				j=j+1;
			}		
		}
	}
	return Nab;
}



double run_T(int N1v,double dtv,double startv, double endv, double *spike_times_1){
	
	double dt= dtv;
	double start=startv;
	double end=endv;
	int N1= N1v;
	double time_A;
	int i=0;
	double diff;
	
//maximum 
	time_A=2*(double)N1*dt;

// if just one spike in train 
	if(N1==1){
		
	  if((spike_times_1[0]-start)<dt){
	    	time_A=time_A-start+spike_times_1[0]-dt;
	  }
	  else if((spike_times_1[0]+dt)>end){
	   	 time_A=time_A-spike_times_1[0]-dt+end;
	      }
	  
	}
	
//if more than one spike in train
	else{
			

			while(i<(N1-1)){
			
				diff=spike_times_1[i+1]-spike_times_1[i];
				
				if(diff<2*dt){
					//subtract overlap 	
					time_A=time_A-2*dt+diff;

				}
				
				i++;
			}
				
			//check if spikes are within dt of the start and/or end, if so just need to subract
			//overlap of first and/or last spike as all within-train overlaps have been accounted for
			
			
			if((spike_times_1[0]-start)<dt){
				
			  time_A=time_A-start+spike_times_1[0]-dt;
			}


			if((end-spike_times_1[N1-1])<dt){
				
			  time_A=time_A-spike_times_1[N1-1]-dt+end;
			}
              	}
	
	return time_A;	
}
	


void run_sttc(int *N1v,int *N2v,double *dtv,double *Time,double *index,double *spike_times_1,double *spike_times_2){

	double TA;
	double TB;
	double PA;
	double PB;
	int N1= *N1v;
	int N2= *N2v;
	double dt= *dtv;
	double T;

	
	
	if(N1==0 || N2==0){
	  //	*index=R_NaN;
	  *index=NAN; //shoudn't make a difference I guess
	}
	else{
	T=Time[1]-Time[0];
	TA=run_T(N1,dt,Time[0],Time[1], spike_times_1);
	TA=TA/T;
	TB=run_T(N2,dt,Time[0],Time[1], spike_times_2);
	TB=TB/T;
	PA=run_P(N1,N2,dt, spike_times_1, spike_times_2);
	PA=PA/(double)N1;
	PB=run_P(N2,N1,dt, spike_times_2, spike_times_1);
	PB=PB/(double)N2;
	*index=0.5*(PA-TB)/(1-TB*PA)+0.5*(PB-TA)/(1-TA*PB);
	

	}

}



void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[]){


    #define STTC plhs[0]
    
    #define N_ST_I prhs[0]
    #define N_ST_J prhs[1]
    #define INCT prhs[2]
    #define TIME prhs[3]
    #define INDEX prhs[4]
    #define ST_I prhs[5]
    #define ST_J prhs[6]

  int *n_st_i, *n_st_j,i;
  double *inct,*time,*index,*sttc,*st_i,*st_j;

  sttc = (double *)mxGetDoubles(STTC);
    
    n_st_i = (int *)mxGetDoubles(N_ST_I);
    n_st_j = (int *)mxGetDoubles(N_ST_J);
    inct = (double *)mxGetDoubles(INCT);
    time = (double *)mxGetDoubles(TIME);
    
    /* run_pili2_lengths_ruc = (int *)mxGetDoubles(run_pili2_lengths_ruc_in); */
    /* num_trains = (int *)mxGetDoubles(num_trains_in); */
    /* previ = (double *)mxGetDoubles(previ_in); */
    /* prev_indy = (int *)mxGetDoubles(prev_indy_in); */
    
    /* bi_spike_diffs_realtime_t_out = mxCreateNumericArray(0, 0, mxDOUBLE_CLASS, mxREAL); */
    /* mxSetM(bi_spike_diffs_realtime_t_out, *num_pairs); */
    /* mxSetN(bi_spike_diffs_realtime_t_out, *run_pili2_lengths_ruc); */
    /* mxSetData(bi_spike_diffs_realtime_t_out, mxMalloc(sizeof(double) * *num_pairs * *run_pili2_lengths_ruc)); */
    /* bi_spike_diffs_realtime_t = (double *)mxGetDoubles(bi_spike_diffs_realtime_t_out); */
    
    /* M  = mxGetM(udists_in); */

    printf("n_st_i=%i\n",n_st_i[0]); //seg fault
    printf("n_st_j=%i\n",n_st_j); 
    printf("inct=%f\n",inct); 
    printf("time=%f\n",time);
    /* for(i=0;i<10;i++) */
    /*   printf("st_i[%i]=%f\n",i,st_i[i]); */
    /* printf("\n"); */
    /* for(i=0;i<10;i++) */
    /*   printf("st_j[%i]=%f\n",i,st_j[i]); */
      
    //    run_sttc(n_st_i,n_st_j,inct,time,index,st_i,st_j);
    sttc=index;

    printf("index=%f\n",index); 
    return;
}
