/* Object: Spiketrain
 * Creator: Eero Satuvuori
 * Date: 18.8.2016
 * Version: 1.0
 * Purpose: 
 */

#ifndef Spiketrain_H
#define Spiketrain_H
#include <vector>

class Spiketrain 
{
	private:
	std::vector<double> spikes;
	
	public:
	Spiketrain();
	Spiketrain(std::vector<double> spikesGiven);
    bool isempty(double T1,double T2);// Needs start and end time to verify
    
    double GivePreceedingSpike(double time);
    double GiveFollowingSpike(double time);
    void GiveCornerSpikes(double &previous,double time,double &following);
    
    double FirstSpike();
    double LastSpike();
    int Length();
    
    unsigned int GivePreceedingSpikeIndex(double time);
    unsigned int GiveFollowingSpikeIndex(double time);
    void GiveCornerSpikesIndexes(unsigned int &previous,double time,unsigned int &following);
    // Does not check if exists Ude previous and following spikes to interpolate
    double GiveSpikeAtIndex(unsigned int index);
    double* GetSpikes();
};
#endif