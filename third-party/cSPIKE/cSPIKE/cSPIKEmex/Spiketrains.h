/* Object: Spiketrains
 * Creator: Eero Satuvuori
 * Date: 18.8.2016
 * Version: 1.0
 * Purpose: 
 */

#ifndef Spiketrains_H
#define Spiketrains_H

#include <vector>
#include <cmath>
#include "Spiketrain.h"
#include "Pair.h"
#include "ISIProfile.h"
#include "SPIKEProfile.h"

class Spiketrains
{
private:
    std::vector<Spiketrain*> STs;
    
    std::vector<double> AdaptiveSynchro(int spiketrain,double T1,double T2,double T3,double T4,double threshold,double MAX_DIST);
    std::vector<double> spikeTrainOrder(int spiketrainINDEX,double T1,double T2,double T3,double T4);
    std::vector<double> spikeOrder(int spiketrainINDEX,double T1,double T2,double T3,double T4);
    
    double AdaptiveCoincidence(int NthSpike, int STindex1, int STindex2,double maxwindow,double threshold,double MAX_DIST);

public:
    Spiketrains();
    ~Spiketrains();
    
    Spiketrains(std::vector<Spiketrain*> STvector);
    
    void AddSpiketrain(Spiketrain* ST);
    int NumberOfSpikeTrains();
    
    void AdaptiveISIDistanceMatrix(double* &matrix ,double T1,double T2,double threshold);
    void AdaptiveSPIKEDistanceMatrix(double* &matrix ,double T1,double T2,double threshold);
    
    void AdaptiveISIDistanceProfile(std::vector<double> &Xprofile,std::vector<double> &Yprofile ,double T1,double T2, double threshold);
    void AdaptiveSPIKEDistanceProfile(std::vector<double> &Xprofile,std::vector<double> &Yprofile ,double T1,double T2, double threshold);
    void AdaptiveRateIndependentSPIKEDistanceProfile(std::vector<double> &Xprofile,std::vector<double> &Yprofile ,double T1,double T2, double threshold);
    
    double AdaptiveSPIKEsynchro(double start,double end ,double T1,double T2,double threshold,double MAX_DIST);
    
    std::vector< std::vector<double> > AdaptiveSPIKEsynchroProfile(double start, double end,double T1,double T2,double threshold,double MAX_DIST);
    std::vector< std::vector<double> > SPIKEorderProfile(double start, double end,double T1,double T2);
    std::vector< std::vector<double> > SPIKEtrainOrderProfile(double start, double end,double T1,double T2);
    
    double AdaptiveISIdistance(double time, double threshold);
    double AdaptiveISIdistance(double from, double to, double threshold);
    
    double AdaptiveSPIKEdistance(double time, double threshold);
    double AdaptiveSPIKEdistance(double from, double to, double threshold);
    
    double AdaptiveRateIndependentSPIKEdistance(double time, double threshold);
    double AdaptiveRateIndependentSPIKEdistance(double from, double to, double threshold);
    
    double OrderOfSpikeTrains(int NthSpike, int STindex1, int STindex2,double maxwindow);
    double OrderOfSpikes(int NthSpike, int STindex1, int STindex2,double maxwindow);
    
    
    Spiketrain* GetST(int index);
};
#endif