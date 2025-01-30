/* Object: Pair
 * Creator: Eero Satuvuori
 * Date: 18.8.2016
 * Version: 1.0
 * Purpose: 
 */

#ifndef Pair_H
#define Pair_H
#include "Spiketrain.h"

class Pair
{
private:
    
    Spiketrain* one;
    Spiketrain* two;
    
    
    double AdaptiveISIintegral(double time1,double time2,double threshold);
    double AdaptiveSPIKEintegral(double time1,double time2,double threshold);
    double AdaptiveRateIndependentSPIKEintegral(double time1,double time2,double threshold);
public:
    
    Pair(Spiketrain* one, Spiketrain* two);
    double ClosestSpike(Spiketrain* spikes, double time);
    double ClosestRealSpike(Spiketrain* spikes, double time);
    
    double AdaptiveISIdistance(double time,double threshold);
    double AdaptiveISIdistance(double time1,double time2,double threshold);
    
    double AdaptiveSPIKEdistance(double time,double threshold);
    double AdaptiveSPIKEdistance(double time1,double time2,double threshold);
    
    double AdaptiveRateIndependentSPIKEdistance(double time,double threshold);
    double AdaptiveRateIndependentSPIKEdistance(double time1,double time2,double threshold);
    
    void AdaptiveISIprofile(double time1,double time2, std::vector<double> &X, std::vector<double> &Y,double threshold);
    void AdaptiveSPIKEprofile(double time1,double time2, std::vector<double> &X, std::vector<double> &Y, double threshold);
    void AdaptiveRateIndependentSPIKEprofile(double time1,double time2, std::vector<double> &X, std::vector<double> &Y, double threshold);

};


#endif