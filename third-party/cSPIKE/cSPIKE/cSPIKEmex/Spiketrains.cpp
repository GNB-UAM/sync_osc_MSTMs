/* Object: Spiketrains
 * Creator: Eero Satuvuori
 * Date: 18.8.2016
 * Version: 1.0
 * Purpose: 
 */

#include "Spiketrains.h"
#include "Spiketrain.h"
#include <cstdlib>
#include <mex.h>
#include <sstream>
#include <string>
#include <cmath>
#include "ISIProfile.h"
#include "SPIKEProfile.h"

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Constructor
 * Input: -
 * output: -
 *
 * Other: -
 */ 
Spiketrains::Spiketrains()
{
    
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Destructor
 * Input: -
 * output: -
 *
 * Other: deleting all spike trains assiciated with the spike trains object
 */
Spiketrains::~Spiketrains()
{
    for (unsigned int i = 0; i < STs.size(); i++)
    {
        delete STs.at(i);
    }
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Second constructor
 * Input: vector of spiketrain pointers
 * output: -
 *
 * Other: Spike trains are only stored as pointers. Deleting the spike 
 *        trains is the responsibility of this object.
 */
Spiketrains::Spiketrains(std::vector<Spiketrain*> STvector):STs(STvector){}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Add a spike train 
 * Input: spike train pointer
 * output: -
 *
 * Other: Spike trains are only stored as pointers. Deleting the spike 
 *        trains is the responsibility of this object.
 */
void Spiketrains::AddSpiketrain(Spiketrain* ST)
{

    STs.push_back(ST);

}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: get pointer to spike train at index
 * Input: index
 * output: spike train pointer
 *
 * Other: no checks are made if index exists. 
 */
Spiketrain* Spiketrains::GetST(int index)
{
    return STs.at(index);
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-ISI-distance
 * Input: time at, threshold
 * output: distance
 *
 * Other: A-ISI-distance of the whole set. Forms pairs and computes average
 */
double Spiketrains::AdaptiveISIdistance( double time,double threshold)
{

    int pairs = 0;
    double sum = 0;
    
    for (int i = 0; i < STs.size();i++)
    {
        for(int i2 = i+1;i2 < STs.size(); i2++)
        {
            pairs++;
            Pair tmp(STs.at(i),STs.at(i2));  
            sum += tmp.AdaptiveISIdistance(time,threshold);

        }
    }
   
    double out = sum/(double)pairs;

    return out;
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-ISI-distance
 * Input: timefrom, time to, threshold
 * output: distance
 *
 * Other: A-ISI-distance of the whole set. Forms pairs and computes average
 */
double Spiketrains::AdaptiveISIdistance( double from, double to ,double threshold)
{	
    int pairs = 0;
    double sum = 0;
    for (int i = 0; i < STs.size()-1;i++)
    {
        for(int i2 = i+1;i2 < STs.size(); i2++)
        {
            pairs++;
            Pair tmp(STs.at(i),STs.at(i2));
            sum += tmp.AdaptiveISIdistance(from, to,threshold);
        }
    }
    return sum/(double)pairs;   
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-SPIKE-synchronization of the set
 * Input: time from, time to, recording start, recording end, threshold
 * output: A-SPIKE-synchronization value
 *
 * Other: -
 */
double Spiketrains::AdaptiveSPIKEsynchro(double start,double end,double T1,double T2,double threshold,double MAX_DIST)
{	
    std::vector<std::vector < double> > Synchronized = 
                               AdaptiveSPIKEsynchroProfile(start,end,T1,T2,threshold,MAX_DIST);
    bool allEmpty = true;
    double sum = 0;
    double Spikes = 0;
    for(int i = 0; i < Synchronized.size();i++)
    {
        if (!Synchronized.at(i).empty())
        {
            allEmpty = false;
        }        
        for(int ii = 0; ii < Synchronized.at(i).size(); ii++)
        {
            sum += Synchronized.at(i).at(ii);
        }
        Spikes += Synchronized.at(i).size();
    }
    if (allEmpty)
    {
        return 1;
    }
    else
    {
        return sum/Spikes;
    }
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-SPIKE-synchronization profile 
 * Input: time from, time to, recording start, recording end, threshold
 * output: vector<vector> containing the synchronization values of each spike
 *
 * Other: The formation of the profile is left to the user.       
 */
std::vector< std::vector<double> > Spiketrains::AdaptiveSPIKEsynchroProfile(double T1,double T2,double T3,double T4,double threshold,double MAX_DIST)
{
    std::vector< std::vector<double> > Synchronized;
    for (int i = 0; i < STs.size();i++)
    {
            Synchronized.push_back( AdaptiveSynchro(i,T1,T2,T3,T4,threshold,MAX_DIST) );
    }
    return Synchronized;
    
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: SPIKE-order profile 
 * Input: time from, time to, recording start, recording end, threshold
 * output: vector<vector> containing the order values of each spike
 *
 * Other: The formation of the profile is left to the user.       
 */
std::vector< std::vector<double> > Spiketrains::SPIKEorderProfile(double T1,double T2,double T3,double T4)
{
    std::vector< std::vector<double> > Synchronized;
    for (int i = 0; i < STs.size();i++)
    {
            Synchronized.push_back( spikeOrder(i,T1,T2,T3,T4) );
    }
    return Synchronized;
    
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: spiketrain-order profile 
 * Input: time from, time to, recording start, recording end, threshold
 * output: vector<vector> containing the order values of each spike
 *
 * Other: The formation of the profile is left to the user.       
 */
std::vector< std::vector<double> > Spiketrains::SPIKEtrainOrderProfile(double T1,double T2,double T3,double T4)
{
    std::vector< std::vector<double> > Synchronized;
    for (int i = 0; i < STs.size();i++)
    {
            Synchronized.push_back( spikeTrainOrder(i,T1,T2,T3,T4) );
    }
    return Synchronized;
    
}    

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-SPIKE-synchronization of a single spike train in the set 
 * Input: time from, time to, recording start, recording end, threshold
 * output: vector<vector> containing the synchronization values of each spike
 *
 * Other: -      
 */
std::vector<double> Spiketrains::AdaptiveSynchro(int spiketrainINDEX,double T1,double T2,double T3,double T4,double threshold,double MAX_DIST)
{
    double maxwindow = T2-T1;
    std::vector<double> coincidencevalues;   
    if (!STs.at(spiketrainINDEX)->isempty(T1,T2))
    {
        for (int spike = 1; spike < STs.at(spiketrainINDEX)->Length()-1;spike++)
        {
            double spiketime = STs.at(spiketrainINDEX)->GiveSpikeAtIndex(spike);

            if (T3 <= spiketime && spiketime <= T4)
            { 
                double sum = 0;
                for (int otherSTINDEX = 0;otherSTINDEX < STs.size();otherSTINDEX++)
                {
                    if (!STs.at(otherSTINDEX)->isempty(T1,T2) && otherSTINDEX != spiketrainINDEX)
                    {
                        sum += AdaptiveCoincidence(spike, spiketrainINDEX,otherSTINDEX,maxwindow,threshold,MAX_DIST);
                    }
                }
                // For each spike push one value or no value at all
                coincidencevalues.push_back(sum/(STs.size()-1));
            }
        }
    }
    return coincidencevalues;   
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: SPIKE-order of a single spike train in the set 
 * Input: time from, time to, recording start, recording end, threshold
 * output: vector<vector> containing the order values of each spike
 *
 * Other: -      
 */
std::vector<double> Spiketrains::spikeOrder(int spiketrainINDEX,double T1,double T2,double T3,double T4)
{
    double maxwindow = T2-T1;
    std::vector<double> coincidencevalues;
    if (!STs.at(spiketrainINDEX)->isempty(T1,T2))
    {
        for (int spike = 1; spike < STs.at(spiketrainINDEX)->Length()-1;spike++)
        {
            double spiketime = STs.at(spiketrainINDEX)->GiveSpikeAtIndex(spike);
            
            if (T3 <= spiketime && spiketime <= T4)
            {
                double sum = 0;
                for (int otherSTINDEX = 0;otherSTINDEX < STs.size();otherSTINDEX++)
                {
                    if (!STs.at(otherSTINDEX)->isempty(T1,T2) && otherSTINDEX != spiketrainINDEX)
                    {
                        sum += OrderOfSpikes(spike, spiketrainINDEX,otherSTINDEX,maxwindow);
                    }
                }
                // For each spike push one value or no value at all
                coincidencevalues.push_back(sum/(STs.size()-1));
            }
        }
    }
    return coincidencevalues;
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: SPIKE-order of a single spike train in the set 
 * Input: time from, time to, recording start, recording end, threshold
 * output: vector<vector> containing the order values of each spike
 *
 * Other: -      
 */
std::vector<double> Spiketrains::spikeTrainOrder(int spiketrainINDEX,double T1,double T2,double T3,double T4)
{
    double maxwindow = T2-T1;
    std::vector<double> coincidencevalues;
    if (!STs.at(spiketrainINDEX)->isempty(T1,T2))
    {
        for (int spike = 1; spike < STs.at(spiketrainINDEX)->Length()-1;spike++)
        {
            double spiketime = STs.at(spiketrainINDEX)->GiveSpikeAtIndex(spike);
            
            if (T3 <= spiketime && spiketime <= T4)
            {
                double sum = 0;
                for (int otherSTINDEX = 0;otherSTINDEX < STs.size();otherSTINDEX++)
                {
                    if (!STs.at(otherSTINDEX)->isempty(T1,T2) && otherSTINDEX != spiketrainINDEX)
                    {
                        sum += OrderOfSpikeTrains(spike, spiketrainINDEX,otherSTINDEX,maxwindow);
                    }
                }
                // For each spike push one value or no value at all
                coincidencevalues.push_back(sum/(STs.size()-1));
            }
        }
    }
    return coincidencevalues;
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Coincidence detection
 * Input: spike index of spike train 1, spiketrain 1 index, spiketrain 2
 *        index, maximum window size, threshold
 * output: 1 if coincidence exists between spike trains. 0 if not
 *
 * Other: -
 */
double Spiketrains::AdaptiveCoincidence(int NthSpike, int STindex1, int STindex2,double maxwindow,double thr,double MAX_DIST)
{
    double window = maxwindow;
    
    double spike11 = STs.at(STindex1)->GiveSpikeAtIndex(NthSpike-1);
    double spike12 = STs.at(STindex1)->GiveSpikeAtIndex(NthSpike);
    double spike13 = STs.at(STindex1)->GiveSpikeAtIndex(NthSpike+1);
    
    double spiketime = spike12;
    double closestSpike = STs.at(STindex2)->GiveSpikeAtIndex(1);
    int closestSpikeINDEX = 1;
    
    for( int spike = 1; spike < STs.at(STindex2)->Length()-1; spike++)
    {
        double candidateSpike = STs.at(STindex2)->GiveSpikeAtIndex(spike);
        if ( std::abs(candidateSpike-spiketime) < std::abs(closestSpike-spiketime))
        {
            closestSpike = candidateSpike;
            closestSpikeINDEX = spike;
        }
    }
    
    if (closestSpike == spiketime)
    {
        return (double)1;
    }
    else
    {
        double spike21 = STs.at(STindex2)->GiveSpikeAtIndex(closestSpikeINDEX-1);
        double spike22 = STs.at(STindex2)->GiveSpikeAtIndex(closestSpikeINDEX);
        double spike23 = STs.at(STindex2)->GiveSpikeAtIndex(closestSpikeINDEX+1);
        
        double ISI11 = spike12 - spike11;
        double ISI12 = spike13 - spike12;
        double ISI21 = spike22 - spike21;
        double ISI22 = spike23 - spike22;
        

        // Not using the first and last interval
        if( NthSpike-1 == 0)
        {
            ISI11 = maxwindow;
        }
        if( NthSpike+1 == STs.at(STindex1)->Length()-1)
        {
            ISI12 = maxwindow;
        }
        if( closestSpikeINDEX-1 == 0)
        {
            ISI21 = maxwindow;
        }
        if( closestSpikeINDEX+1 == STs.at(STindex2)->Length()-1)
        {
            ISI22 = maxwindow;
        }
        
        
        double TAUij = 0;
        double tau1 = std::min(ISI11,ISI12)/2;
        double tau2 = std::min(ISI21,ISI22)/2;
        
        if (spike12 <= spike22){
            
            double tau1F = std::min(std::max(thr/2,tau1),ISI12/2);
            double tau2P = std::min(std::max(thr/2,tau2),ISI21/2);
            TAUij = std::min(tau1F,tau2P);
            
        }else{
            
            double tau1P = std::min(std::max(thr/2,tau1),ISI11/2);
            double tau2F = std::min(std::max(thr/2,tau2),ISI22/2);
            TAUij = std::min(tau1P,tau2F);
            
        }

        if( std::abs(spiketime-closestSpike) < TAUij )
        {
			if(MAX_DIST < 0)
			{
				return (double)1;
			}
			else if(std::abs(spiketime-closestSpike) < MAX_DIST)
			{
				return (double)1;	
			}
			else
			{
				return 0;
			}   
        }
        else
        {
            return 0;
        }   
    }   
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Coincidence detection
 * Input: spike index of spike train 1, spiketrain 1 index, spiketrain 2
 *        index, maximum window size, threshold
 * output: 1 if coincidence exists between spike trains and it is leading, 
 *         -1 if not and 0 if they are at the same time or there is no 
 *         coincidence.
 *
 * Other: -
 */
double Spiketrains::OrderOfSpikes(int NthSpike, int STindex1, int STindex2,double maxwindow)
{
    double window = maxwindow;
    
    double spike11 = STs.at(STindex1)->GiveSpikeAtIndex(NthSpike-1);
    double spike12 = STs.at(STindex1)->GiveSpikeAtIndex(NthSpike);
    double spike13 = STs.at(STindex1)->GiveSpikeAtIndex(NthSpike+1);
    
    double spiketime = spike12;
    double closestSpike = STs.at(STindex2)->GiveSpikeAtIndex(1);
    int closestSpikeINDEX = 1;
    
    for( int spike = 1; spike < STs.at(STindex2)->Length()-1; spike++)
    {
        double candidateSpike = STs.at(STindex2)->GiveSpikeAtIndex(spike);
        if ( std::abs(candidateSpike-spiketime) < std::abs(closestSpike-spiketime))
        {
            closestSpike = candidateSpike;
            closestSpikeINDEX = spike;
        }
    }
    
    if (closestSpike == spiketime)
    {
        //mexPrintf("Spikes at the same time \n");
        return (double)0;                                                   // ############
    }
    else
    {
        double spike21 = STs.at(STindex2)->GiveSpikeAtIndex(closestSpikeINDEX-1);
        double spike22 = STs.at(STindex2)->GiveSpikeAtIndex(closestSpikeINDEX);
        double spike23 = STs.at(STindex2)->GiveSpikeAtIndex(closestSpikeINDEX+1);
        
        double ISI11 = spike12 - spike11;
        double ISI12 = spike13 - spike12;
        double ISI21 = spike22 - spike21;
        double ISI22 = spike23 - spike22;
        
        // Not using the first and last interval
        if( NthSpike-1 == 0)
        {
            ISI11 = maxwindow;
        }
        if( NthSpike+1 == STs.at(STindex1)->Length()-1)
        {
            ISI12 = maxwindow;
        }
        if( closestSpikeINDEX-1 == 0)
        {
            ISI21 = maxwindow;
        }
        if( closestSpikeINDEX+1 == STs.at(STindex2)->Length()-1)
        {
            ISI22 = maxwindow;
        }       
        window = std::min(window, std::min(std::min(ISI11,ISI12),std::min(ISI21,ISI22)))/2;
        
        if( std::abs(spiketime-closestSpike) < window)
        {
            if (spiketime == closestSpike)
            {
                return 0;
            }
            else if(spiketime < closestSpike)
            {
                //mexPrintf("1 \n");
                return (double)1;
            }
            else
            {
                //mexPrintf("-1 \n");
                return (double)-1;
            }
        }
        else
        {
            //mexPrintf("Out of window \n");
            return 0;
        }   
    }   
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Coincidence detection
 * Input: spike index of spike train 1, spiketrain 1 index, spiketrain 2
 *        index, maximum window size, threshold
 * output: 1 if coincidence exists between spike trains and they are in the 
 *         correct order, -1 if not and 0 if the are at the same time or 
 *         there is no coincidence.
 *
 * Other: -
 */
double Spiketrains::OrderOfSpikeTrains(int NthSpike, int STindex1, int STindex2,double maxwindow)
{
    double window = maxwindow;
    
    double spike11 = STs.at(STindex1)->GiveSpikeAtIndex(NthSpike-1);
    double spike12 = STs.at(STindex1)->GiveSpikeAtIndex(NthSpike);
    double spike13 = STs.at(STindex1)->GiveSpikeAtIndex(NthSpike+1);
    
    double spiketime = spike12;
    double closestSpike = STs.at(STindex2)->GiveSpikeAtIndex(1);
    int closestSpikeINDEX = 1;
    
    for( int spike = 1; spike < STs.at(STindex2)->Length()-1; spike++)
    {
        double candidateSpike = STs.at(STindex2)->GiveSpikeAtIndex(spike);
        if ( std::abs(candidateSpike-spiketime) < std::abs(closestSpike-spiketime))
        {
            closestSpike = candidateSpike;
            closestSpikeINDEX = spike;
        }
    }
    
    if (closestSpike == spiketime)
    {
        //mexPrintf("Spikes at the same time \n");
        return (double)0;                                                   // ############
    }
    else
    {
        double spike21 = STs.at(STindex2)->GiveSpikeAtIndex(closestSpikeINDEX-1);
        double spike22 = STs.at(STindex2)->GiveSpikeAtIndex(closestSpikeINDEX);
        double spike23 = STs.at(STindex2)->GiveSpikeAtIndex(closestSpikeINDEX+1);
        
        double ISI11 = spike12 - spike11;
        double ISI12 = spike13 - spike12;
        double ISI21 = spike22 - spike21;
        double ISI22 = spike23 - spike22;
        
        // Not using the first and last interval
        if( NthSpike-1 == 0)
        {
            ISI11 = maxwindow;
        }
        if( NthSpike+1 == STs.at(STindex1)->Length()-1)
        {
            ISI12 = maxwindow;
        }
        if( closestSpikeINDEX-1 == 0)
        {
            ISI21 = maxwindow;
        }
        if( closestSpikeINDEX+1 == STs.at(STindex2)->Length()-1)
        {
            ISI22 = maxwindow;
        }       
        window = std::min(window, std::min(std::min(ISI11,ISI12),std::min(ISI21,ISI22)))/2;
        
       if( std::abs(spiketime-closestSpike) < window)
        {
            if (spiketime == closestSpike)
            {
                return 0;
            }
            else if(spiketime < closestSpike)
            {
                if (STindex1 < STindex2)
                {
                    return (double)1;
                }
                else
                {
                    return (double)-1;
                }
            }
            else
            {
                if (STindex1 > STindex2)
                {
                    return (double)1;
                }
                else
                {
                    return (double)-1; 
                }
            }
        }
        else
        {
            return 0;
        }   
    }   
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-SPIKE-distance
 * Input: time at, threshold
 * output: distance
 *
 * Other: A-SPIKE-distance of the whole set. Forms pairs and computes average
 */
double Spiketrains::AdaptiveSPIKEdistance( double time ,double threshold)
{

    int pairs = 0;
    double sum = 0;
    
    for (int i = 0; i < STs.size();i++)
    {
        for(int i2 = i+1;i2 < STs.size(); i2++)
        {
            
            pairs++;
            Pair tmp(STs.at(i),STs.at(i2));
            sum += tmp.AdaptiveSPIKEdistance(time,threshold);
        }
    }
   
    double out = sum/(double)pairs;

    return out;
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-SPIKE-distance
 * Input: timefrom, time to, threshold
 * output: distance
 *
 * Other: A-SPIKE-distance of the whole set. Forms pairs and computes average
 */
double Spiketrains::AdaptiveSPIKEdistance( double from, double to,double threshold)
{	

    int pairs = 0;
    double sum = 0;

    for (int i = 0; i < STs.size()-1;i++)
    {
        for(int i2 = i+1;i2 < STs.size(); i2++)
        {
           
            pairs++;
            Pair tmp(STs.at(i),STs.at(i2)); 
            sum += tmp.AdaptiveSPIKEdistance(from, to, threshold);
        }
    }
    
    double out = sum/(double)pairs;
    
    return out;
    
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: ARI-SPIKE-distance
 * Input: time at, threshold
 * output: distance
 *
 * Other: ARI-SPIKE-distance of the whole set. Forms pairs and computes average
 */
double Spiketrains::AdaptiveRateIndependentSPIKEdistance( double time ,double threshold)
{

    int pairs = 0;
    double sum = 0;
    
    for (int i = 0; i < STs.size();i++)
    {
        for(int i2 = i+1;i2 < STs.size(); i2++)
        {
            
            pairs++;
            Pair tmp(STs.at(i),STs.at(i2));
            sum += tmp.AdaptiveRateIndependentSPIKEdistance(time,threshold);
        }
    }
   
    double out = sum/(double)pairs;

    return out;
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: ARI-SPIKE-distance
 * Input: timefrom, time to, threshold
 * output: distance
 *
 * Other: ARI-SPIKE-distance of the whole set. Forms pairs and computes average
 */
double Spiketrains::AdaptiveRateIndependentSPIKEdistance( double from, double to,double threshold)
{	

    int pairs = 0;
    double sum = 0;

    for (int i = 0; i < STs.size()-1;i++)
    {
        for(int i2 = i+1;i2 < STs.size(); i2++)
        {
           
            pairs++;
            Pair tmp(STs.at(i),STs.at(i2)); 
            sum += tmp.AdaptiveRateIndependentSPIKEdistance(from, to, threshold);
        }
    }
    
    double out = sum/(double)pairs;
    
    return out;
    
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Give numver of spiketrains in teh set
 * Input: -
 * output: the number
 *
 * Other: -
 */
int Spiketrains::NumberOfSpikeTrains()
{
    return STs.size();
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-ISI-distance matrix
 * Input: reference to matrix, time from, time to, threshold
 * output: -
 *
 * Other: output through reference to the matrix.
 */
void Spiketrains::AdaptiveISIDistanceMatrix(double* &matrix, double T1,double T2,double threshold)
{
    bool point = (T1==T2);
    int pairs = 0;
    int nroSTs = STs.size();
    for (int n = 0; n < nroSTs-1;n++)
    {
        for(int m = n+1;m < nroSTs; m++)
        {
            double distance;
            
            Pair tmp(STs.at(n),STs.at(m));
            
            if(point)
            {
                distance = tmp.AdaptiveISIdistance(T1,threshold);
            }
            else
            {
                distance = tmp.AdaptiveISIdistance(T1, T2,threshold);
            }
            matrix[n + nroSTs*m] = distance;
            matrix[m + nroSTs*n] = distance;
        }
    }

}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-SPIKE-distance matrix
 * Input: reference to matrix, time from, time to, threshold
 * output: -
 *
 * Other: output through reference to the matrix.
 */
void Spiketrains::AdaptiveSPIKEDistanceMatrix(double* &matrix, double T1,double T2,double threshold)
{
    bool point = (T1==T2);
    int pairs = 0;
    int nroSTs = STs.size();
    for (int n = 0; n < nroSTs-1;n++)
    {
        for(int m = n+1;m < nroSTs; m++)
        {
            double distance;
            
            Pair tmp(STs.at(n),STs.at(m));
            
            if(point)
            {
                distance = tmp.AdaptiveSPIKEdistance(T1,threshold);
            }
            else
            {
                distance = tmp.AdaptiveSPIKEdistance(T1, T2,threshold);
            }
            
            matrix[n + nroSTs*m] = distance;
            matrix[m + nroSTs*n] = distance;
        }
    }

}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-ISI-distance profile
 * Input: reference to X values, reference to Y values,  from time, to time
 *        threshold
 * output: -
 *
 * Other: output is given through reference variables
 */
void Spiketrains::AdaptiveISIDistanceProfile(std::vector<double> &Xprofile,std::vector<double> &Yprofile, double T1,double T2,double threshold)
{
    std::vector<ISIProfile*> PairwiseProfiles;
    int nroSTs = STs.size();
    for (int n = 0; n < nroSTs-1;n++)
    {
        for(int m = n+1;m < nroSTs; m++)
        {       
            std::vector<double>  Y ,X;
            Pair tmpPair(STs.at(n),STs.at(m));
            // Returns profile in X and Y
            tmpPair.AdaptiveISIprofile(T1,T2,X,Y,threshold);
            
            ISIProfile* tmpProfile = new ISIProfile(X,Y);
            
            PairwiseProfiles.push_back(tmpProfile);    
        }   
    }

    ISIProfile* Combined = PairwiseProfiles.at(0);
    for(int i = 1; i < PairwiseProfiles.size();i++)
    {
        Combined->AddISIprofile( PairwiseProfiles.at(i) );
    }
    Xprofile = Combined->GetProfileX();
    Yprofile = Combined->GetProfileY();

    for (int i = 0; i < PairwiseProfiles.size();i++)
    {
        delete PairwiseProfiles.at(i);
    }
    
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-SPIKE-distance profile
 * Input: reference to X values, reference to Y values,  from time, to time
 *        threshold
 * output: -
 *
 * Other: output is given through reference variables
 */
void Spiketrains::AdaptiveSPIKEDistanceProfile(std::vector<double> &Xprofile,std::vector<double> &Yprofile, double T1,double T2, double threshold)
{
    std::vector<SPIKEProfile*> PairwiseProfiles;
    int nroSTs = STs.size();
    for (int n = 0; n < nroSTs-1;n++)
    {
        for(int m = n+1;m < nroSTs; m++)
        {
            
            std::vector<double>  Y ,X;
            Pair tmpPair(STs.at(n),STs.at(m));
           
            // Returns profile in X and Y
            tmpPair.AdaptiveSPIKEprofile(T1,T2,X,Y,threshold);
           
            SPIKEProfile* tmpProfile = new SPIKEProfile(X,Y);
            
            PairwiseProfiles.push_back(tmpProfile);
           
        }
      
    }

    SPIKEProfile* Combined = PairwiseProfiles.at(0);
    for(int i = 1; i < PairwiseProfiles.size();i++)
    {
        Combined->AddSPIKEprofile( PairwiseProfiles.at(i) );
    }
    Xprofile = Combined->GetProfileX();
    Yprofile = Combined->GetProfileY();

    for (int i = 0; i < PairwiseProfiles.size();i++)
    {
        delete PairwiseProfiles.at(i);
    }
    
}

/* Date: 16.1.2018
 * Version: 1.0
 *
 * Function: RIA-SPIKE-distance profile
 * Input: reference to X values, reference to Y values,  from time, to time
 *        threshold
 * output: -
 *
 * Other: output is given through reference variables
 */
void Spiketrains::AdaptiveRateIndependentSPIKEDistanceProfile(std::vector<double> &Xprofile,std::vector<double> &Yprofile, double T1,double T2, double threshold)
{
    std::vector<SPIKEProfile*> PairwiseProfiles;
    int nroSTs = STs.size();
    for (int n = 0; n < nroSTs-1;n++)
    {
        for(int m = n+1;m < nroSTs; m++)
        {
            
            std::vector<double>  Y ,X;
            Pair tmpPair(STs.at(n),STs.at(m));
           
            // Returns profile in X and Y
            tmpPair.AdaptiveRateIndependentSPIKEprofile(T1,T2,X,Y,threshold);
           
            SPIKEProfile* tmpProfile = new SPIKEProfile(X,Y);
            
            PairwiseProfiles.push_back(tmpProfile);
           
        }
      
    }

    SPIKEProfile* Combined = PairwiseProfiles.at(0);
    for(int i = 1; i < PairwiseProfiles.size();i++)
    {
        Combined->AddSPIKEprofile( PairwiseProfiles.at(i) );
    }
    Xprofile = Combined->GetProfileX();
    Yprofile = Combined->GetProfileY();

    for (int i = 0; i < PairwiseProfiles.size();i++)
    {
        delete PairwiseProfiles.at(i);
    }
    
}