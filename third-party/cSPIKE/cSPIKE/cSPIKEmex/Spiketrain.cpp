/* Object: Spiketrain
 * Creator: Eero Satuvuori
 * Date: 18.8.2016
 * Version: 1.0
 * Purpose: 
 */

#include "Spiketrain.h"
#include <cstdlib>
#include <mex.h>

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Constructor
 * Input: -
 * output: -
 *
 * Other: -
 */ 
Spiketrain::Spiketrain()
{

}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Second constructor
 * Input: spikes vector
 * output: -
 *
 * Other: -
 */
Spiketrain::Spiketrain(std::vector<double> spikesGiven):spikes(spikesGiven){}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Give the following spike to time t
 * Input: time t
 * output: time of the spike
 *
 * Other: if there is a spike at time t, the next one is given.
 */
double Spiketrain::GiveFollowingSpike(double time)
{
    
    unsigned int index = GiveFollowingSpikeIndex(time);
    double SPIKEt = spikes.at(index);
    return SPIKEt;
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Give the following spike index to time t
 * Input: time t
 * output: index of the spike
 *
 * Other: if there is a spike at time t, the next one is given.
 */
unsigned int Spiketrain::GiveFollowingSpikeIndex(double time)
{
    unsigned int index = 0;
    double SPIKEt = spikes.at(index);
    
    while (SPIKEt <= time && index != spikes.size()-1)
    {
        index++;
        SPIKEt = spikes.at(index);
    }
    return index;
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: checks if the spike train is empty
 * Input: start and end times of the analysis interval
 * output: boolean 1:empty, 0: not empty
 *
 * Other: An empty spike train has corner spikes AND two auxiliaries. The
 *        corner spikes MUST be at the edges for the spike train to be 
 *        empty. 
 */
bool Spiketrain::isempty(double T1,double T2)
{
    bool empty = false;
    if(Length() == 4 )
    {
        double firstRealSpike = GiveSpikeAtIndex(1);
        double SecondRealSpike = GiveSpikeAtIndex(2);
        empty = (firstRealSpike == T1 && SecondRealSpike == T2);
    }
    return empty;
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Give the preceeding spike to time t
 * Input: time t
 * output: time of the spike
 *
 * Other: if there is a spike at time t, it is given.
 */
double Spiketrain::GivePreceedingSpike(double time)
{
  
    unsigned int index = GivePreceedingSpikeIndex(time);  
    double SPIKEt = spikes.at(index);
    return SPIKEt;
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Give the preceeding spike index to time t
 * Input: time t
 * output: time of the spike
 *
 * Other: if there is a spike at time t, it's index is given.
 */
unsigned int Spiketrain::GivePreceedingSpikeIndex(double time)
{
   
    unsigned int index = spikes.size()-1;
    double SPIKEt = spikes.at(index);
    
    while (SPIKEt > time)
    {
        index--;
        SPIKEt = spikes.at(index);
    }

    return index;
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: give spike time of spike at index
 * Input: index
 * output: spike time
 *
 * Other: No checks are made. If no spike at index exists outindexing happens.
 */
double Spiketrain::GiveSpikeAtIndex(unsigned int index)
{
    return spikes.at(index);
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Return first spike time
 * Input: -
 * output: first spikes time.
 *
 * Other: Is always the first auxiliary.
 */
double Spiketrain::FirstSpike()
{
    return spikes.at(0);
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: return the spike time of the last spike
 * Input: -
 * output: time of the last spike
 *
 * Other: Is always the second auxiliary
 */
double Spiketrain::LastSpike()
{
    return spikes.at(spikes.size()-1);
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: give length of the spike train
 * Input: -
 * output: length as integer
 *
 * Other: -
 */
int Spiketrain::Length()
{
    return spikes.size();
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: get all spike times
 * Input: -
 * output: array of spike times
 *
 * Other: -
 */
double* Spiketrain::GetSpikes()
{
    double* spikeTimes = 0;
    for (int i  = 0 ; i < spikes.size(); i++)
    {
        spikeTimes[i] = spikes.at(i);
    }
    return spikeTimes;
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Get the cornering spike's indexes of time t
 * Input: reference to previous spike, time to which the corners are 
 *        searched, following reference
 * output: -
 *
 * Other: References are used for output. Does halving search for the spike
 *        train. If the search time is at a spike time that spike's index 
 *        will end up being previous spike index and following will be the 
 *        next one.
 *
 */
void Spiketrain::GiveCornerSpikesIndexes(unsigned int &previous,double time,unsigned int &following)
{
    unsigned int start = 0;
    unsigned int end = spikes.size()-1;
    while (end-start !=1)        
    {
        unsigned int middle = (start+end)/2;
        if (spikes.at(middle) > time)
        {
            end = middle;
        }
        else
        {
            start = middle;
        }
    }
    previous = start;
    following = end;
    
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Get the cornering spike's times of time t
 * Input: reference to previous spike, time to which the corners are 
 *        searched, following reference
 * output: -
 *
 * Other: References are used for output. Does halving search for the spike
 *        train. If the search time is at a spike time that spike will end
 *        up being previous spike and following will be the next one.
 *
 */
void Spiketrain::GiveCornerSpikes(double &previous,double time,double &following)
{
    unsigned int previousINDEX,followingINDEX;
    GiveCornerSpikesIndexes(previousINDEX,time,followingINDEX);
    previous = spikes.at(previousINDEX);
    following = spikes.at(followingINDEX);
}


