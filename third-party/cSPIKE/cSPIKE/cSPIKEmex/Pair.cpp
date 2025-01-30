/* Object: Pair
 * Creator: Eero Satuvuori
 * Date: 18.8.2016
 * Version: 1.0
 * Purpose: 
 */

#include "Pair.h"
#include <cstdlib>
#include <mex.h>
#include <algorithm>
#include <cmath>

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Constructor
 * Input: two spike trains
 * output: -
 *
 * Other: -
 */
Pair::Pair(Spiketrain* firstST, Spiketrain* secondST)
: one(firstST),two(secondST){}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-ISI-distance
 * Input: double time,double threshold
 * output: dissimilarity value
 *
 * Other: -
 */
double Pair::AdaptiveISIdistance(double time,double threshold)
{
    double ISI1, ISI2;
    double ST1P, ST2P, ST1F, ST2F;
    one->GiveCornerSpikes(ST1P,time,ST1F);
    two->GiveCornerSpikes(ST2P,time,ST2F);
    
    ISI1 = ST1F-ST1P;
    ISI2 = ST2F-ST2P;
    return std::abs(ISI2-ISI1)/std::max(threshold,std::max(ISI1,ISI2));
    
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-ISI-Integral
 * Input: time from, time to, threshold value
 * output: A-ISI-integral value
 *
 * Other: Recursive algorithm. Starts from beginning time and is called for
 *        every interval between spikes in pooled spike train. 
 */
double Pair::AdaptiveISIintegral(double time1,double time2,double threshold)
{
    
    double previous1, previous2, following1, following2, length, ISI1, ISI2;
    one->GiveCornerSpikes(previous1,time1,following1);
    two->GiveCornerSpikes(previous2,time1,following2);
    ISI1 = following1 - previous1;
    ISI2 = following2 - previous2;
    // Taking the closest spike
    double closest = std::min(following1,following2);
    
    // the length of the interval is the distance to the
    // closest spike or to the end boundary if it is closer
    length = std::min(closest, time2) - time1;
    double D = length * std::abs(ISI2-ISI1)/std::max(threshold,std::max(ISI1,ISI2));
    
    //If the boundary is closer than both the spikes this is the final round.
    if ( time2 <= closest)
    {
        return D;
    }
    // If not calculate the value for the interval and continue recursion
    
    return D + AdaptiveISIintegral(closest, time2,threshold);
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-ISI-distance
 * Input: time from, time to, threshold value
 * output: A-ISI-distance
 *
 * Other: Calling function for the recursive integral and taking average over the time
 */
double Pair::AdaptiveISIdistance(double time1,double time2,double threshold)
{
    return AdaptiveISIintegral(time1,time2,threshold)/(time2-time1);
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-SPIKE-distance
 * Input: double time,double threshold
 * output: dissimilarity value
 *
 * Other: -
 */
double Pair::AdaptiveSPIKEdistance(double time, double threshold)
{
    double ISI1, ISI2 ,meanISI,S1,S2,S;
    double ST1P, ST2P, ST1F, ST2F, xp1, xp2, xf1, xf2, dpt1, dpt2, dft1, dft2;
    
    one->GiveCornerSpikes(ST1P,time,ST1F);
    two->GiveCornerSpikes(ST2P,time,ST2F);
    
    ISI1 = ST1F-ST1P;
    ISI2 = ST2F-ST2P;
    meanISI = (ISI1+ISI2)/2;
    
    xp1 = time - ST1P;
    xp2 = time - ST2P;
    xf1 = ST1F - time;
    xf2 = ST2F - time;
    
    // Searching for the closest real spikes of the corner
    // spikes from the other spike trains.
    dpt1 = std::abs(ST1P - ClosestSpike(two, ST1P));
    dpt2 = std::abs(ST2P - ClosestSpike(one, ST2P));
    dft1 = std::abs(ST1F - ClosestSpike(two, ST1F));
    dft2 = std::abs(ST2F - ClosestSpike(one, ST2F));
    
    // Edge correction for SPIKE-d
    if( ST1P == one->FirstSpike())
    {
        dpt1 = dft1;
    }
    if( ST1F == one->LastSpike())
    {
        dft1 = dpt1;
    }
    if( ST2P == two->FirstSpike())
    {
        dpt2 = dft2;
    }
    if( ST2F == two->LastSpike())
    {
        dft2 = dpt2;
    }

    
    S1 = (dpt1*xf1+dft1*xp1)/(ISI1);
    S2 = (dpt2*xf2+dft2*xp2)/(ISI2);
    
    S = (S1*ISI2 + S2*ISI1)/(2*meanISI*std::max(meanISI,threshold));
    
    return S;
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: ARI-SPIKE-distance
 * Input: double time,double threshold
 * output: dissimilarity value
 *
 * Other: -
 */
double Pair::AdaptiveRateIndependentSPIKEdistance(double time, double threshold)
{
    double ISI1, ISI2 ,meanISI,S1,S2,S;
    double ST1P, ST2P, ST1F, ST2F, xp1, xp2, xf1, xf2, dpt1, dpt2, dft1, dft2;
    
    one->GiveCornerSpikes(ST1P,time,ST1F);
    two->GiveCornerSpikes(ST2P,time,ST2F);
    
    ISI1 = ST1F-ST1P;
    ISI2 = ST2F-ST2P;
    meanISI = (ISI1+ISI2)/2;
    
    xp1 = time - ST1P;
    xp2 = time - ST2P;
    xf1 = ST1F - time;
    xf2 = ST2F - time;
    
    // Searching for the closest real spikes of the corner
    // spikes from the other spike trains.
    dpt1 = std::abs(ST1P - ClosestSpike(two, ST1P));
    dpt2 = std::abs(ST2P - ClosestSpike(one, ST2P));
    dft1 = std::abs(ST1F - ClosestSpike(two, ST1F));
    dft2 = std::abs(ST2F - ClosestSpike(one, ST2F));
    
    // Edge correction for SPIKE-d
    if( ST1P == one->FirstSpike())
    {
        dpt1 = dft1;
    }
    if( ST1F == one->LastSpike())
    {
        dft1 = dpt1;
    }
    if( ST2P == two->FirstSpike())
    {
        dpt2 = dft2;
    }
    if( ST2F == two->LastSpike())
    {
        dft2 = dpt2;
    }

    S1 = (dpt1*xf1+dft1*xp1)/(ISI1);
    S2 = (dpt2*xf2+dft2*xp2)/(ISI2);
    
    S = (S1*ISI2 + S2*ISI1)/(2*std::max(meanISI,threshold));
    
    return S;
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-SPIKE-Integral
 * Input: time from, time to, threshold value
 * output: A-SPIKE-integral value
 *
 * Other: Recursive algorithm. Starts from beginning time and is called for
 *        every interval between spikes in pooled spike train. 
 */
double Pair::AdaptiveSPIKEintegral(double time1,double time2, double threshold)
{
    
    /*First using single point dissimilarity to
     * figure out the beginning. Then since the
     * find functions do not work for the end,
     * the value forthe end of the interval is
     * calculated here*/
    
    double STARTinterval, ENDinterval;
    
    double ISI1, ISI2 ,meanISI,S1,S2,S,length;
    double ST1P, ST2P, ST1F, ST2F, xp1, xp2, xf1, xf2, dpt1, dpt2, dft1, dft2;
    
    /* Using the ISI of the interval we are in.
     * Thus taking the ISIs based on time 1. Taking
     * it based on time 2 would give the beginning
     * of the next interval.
     */
    
    one->GiveCornerSpikes(ST1P,time1,ST1F);
    two->GiveCornerSpikes(ST2P,time1,ST2F);
    
    ISI1 = ST1F-ST1P;
    ISI2 = ST2F-ST2P;
    meanISI = (ISI1+ISI2)/2;
    // Taking the closest spike or end of the interval
    double closest = std::min(ST1F,ST2F);
    closest = std::min(closest,time2);
    // the length of the interval is the distance to the
    // closest spike or to the end boundary if it is closer
    length = closest - time1;
    
    // Searching for the closest real spikes of the corner
    // spikes from the other spike trains.
    dpt1 = std::abs(ST1P - ClosestSpike(two, ST1P));
    dpt2 = std::abs(ST2P - ClosestSpike(one, ST2P));
    dft1 = std::abs(ST1F - ClosestSpike(two, ST1F));
    dft2 = std::abs(ST2F - ClosestSpike(one, ST2F));
    
// Edge correction for SPIKE-d
    if( ST1P == one->FirstSpike())
    {
        dpt1 = dft1;
    }
    if( ST1F == one->LastSpike())
    {
        dft1 = dpt1;
    }
    if( ST2P == two->FirstSpike())
    {
        dpt2 = dft2;
    }
    if( ST2F == two->LastSpike())
    {
        dft2 = dpt2;
    }

    // For beginning
    xp1 = time1 - ST1P;
    xp2 = time1 - ST2P;
    xf1 = ST1F - time1;
    xf2 = ST2F - time1;
    S1 = (dpt1*xf1+dft1*xp1)/(ISI1);
    S2 = (dpt2*xf2+dft2*xp2)/(ISI2);
    
    STARTinterval = (S1*ISI2 + S2*ISI1)/(2*meanISI*std::max(meanISI,threshold));
    
    // For end
    xp1 = closest - ST1P;
    xp2 = closest - ST2P;
    xf1 = ST1F - closest;
    xf2 = ST2F - closest;
    S1 = (dpt1*xf1+dft1*xp1)/(ISI1);
    S2 = (dpt2*xf2+dft2*xp2)/(ISI2);
    
    ENDinterval = (S1*ISI2 + S2*ISI1)/(2*meanISI*std::max(meanISI,threshold));
    
    // Distance over the interval
    S = (STARTinterval+ENDinterval)/2 * length;
    
    //If the boundary is closer than both the spikes this is the final round.
    if ( time2 <= closest)
    {
        return S;
    }
    // If not calculate the value for the interval and continue recursion
    
    return S + AdaptiveSPIKEintegral(closest, time2,threshold);
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: ARI-SPIKE-Integral
 * Input: time from, time to, threshold value
 * output: ARI-SPIKE-integral value
 *
 * Other: Recursive algorithm. Starts from beginning time and is called for
 *        every interval between spikes in pooled spike train. 
 */
double Pair::AdaptiveRateIndependentSPIKEintegral(double time1,double time2, double threshold)
{
    
    /*First using single point dissimilarity to
     * figure out the beginning. Then since the
     * find functions do not work for the end,
     * the value forthe end of the interval is
     * calculated here*/
    
    double STARTinterval, ENDinterval;
    
    double ISI1, ISI2 ,meanISI,S1,S2,S,length;
    double ST1P, ST2P, ST1F, ST2F, xp1, xp2, xf1, xf2, dpt1, dpt2, dft1, dft2;
    
    /* Using the ISI of the interval we are in.
     * Thus taking the ISIs based on time 1. Taking
     * it based on time 2 would give the beginning
     * of the next interval.
     */
    
    one->GiveCornerSpikes(ST1P,time1,ST1F);
    two->GiveCornerSpikes(ST2P,time1,ST2F);
    
    ISI1 = ST1F-ST1P;
    ISI2 = ST2F-ST2P;
    meanISI = (ISI1+ISI2)/2;
    // Taking the closest spike or end of the interval
    double closest = std::min(ST1F,ST2F);
    closest = std::min(closest,time2);
    // the length of the interval is the distance to the
    // closest spike or to the end boundary if it is closer
    length = closest - time1;
    
    // Searching for the closest real spikes of the corner
    // spikes from the other spike trains.
    dpt1 = std::abs(ST1P - ClosestSpike(two, ST1P));
    dpt2 = std::abs(ST2P - ClosestSpike(one, ST2P));
    dft1 = std::abs(ST1F - ClosestSpike(two, ST1F));
    dft2 = std::abs(ST2F - ClosestSpike(one, ST2F));
    
// Edge correction for SPIKE-d
    if( ST1P == one->FirstSpike())
    {
        dpt1 = dft1;
    }
    if( ST1F == one->LastSpike())
    {
        dft1 = dpt1;
    }
    if( ST2P == two->FirstSpike())
    {
        dpt2 = dft2;
    }
    if( ST2F == two->LastSpike())
    {
        dft2 = dpt2;
    }

    // For beginning
    xp1 = time1 - ST1P;
    xp2 = time1 - ST2P;
    xf1 = ST1F - time1;
    xf2 = ST2F - time1;
    S1 = (dpt1*xf1+dft1*xp1)/(ISI1);
    S2 = (dpt2*xf2+dft2*xp2)/(ISI2);
    
    STARTinterval = (S1 + S2)/(2*std::max(meanISI,threshold));
    
    // For end
    xp1 = closest - ST1P;
    xp2 = closest - ST2P;
    xf1 = ST1F - closest;
    xf2 = ST2F - closest;
    S1 = (dpt1*xf1+dft1*xp1)/(ISI1);
    S2 = (dpt2*xf2+dft2*xp2)/(ISI2);
    
    ENDinterval = (S1 + S2)/(2*std::max(meanISI,threshold));
    
    // Distance over the interval
    S = (STARTinterval+ENDinterval)/2 * length;
    
    //If the boundary is closer than both the spikes this is the final round.
    if ( time2 <= closest)
    {
        return S;
    }
    // If not calculate the value for the interval and continue recursion
    
    return S + AdaptiveRateIndependentSPIKEintegral(closest, time2,threshold);
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-SPIKE-distance
 * Input: time from, time to, threshold value
 * output: A-SPIKE-distance
 *
 * Other: Calling function for the recursive integral and taking average over the time
 */
double Pair::AdaptiveSPIKEdistance(double time1,double time2, double threshold)
{
    return AdaptiveSPIKEintegral(time1,time2, threshold)/(time2-time1);
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: ARI-SPIKE-distance
 * Input: time from, time to, threshold value
 * output: ARI-SPIKE-distance
 *
 * Other: Calling function for the recursive integral and taking average over the time
 */
double Pair::AdaptiveRateIndependentSPIKEdistance(double time1,double time2, double threshold)
{
    return AdaptiveRateIndependentSPIKEintegral(time1,time2, threshold)/(time2-time1);
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Closest Spike
 * Input: spiketrain, closest to this time
 * output: spike time
 *
 * Other: Can also be an auxiliary spike
 */
double  Pair::ClosestSpike(Spiketrain* spikes, double time)
{
    if (time <= spikes->FirstSpike())
    {
        return spikes->FirstSpike();
    }
    if (time >= spikes->LastSpike())
    {
        return spikes->LastSpike();
    }
    double preceeding,following;
    spikes->GiveCornerSpikes(preceeding,time,following);
    
    if (time - preceeding < following-time)
    {
        return preceeding;
    }
    else
    {
        return following;
    }
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Closest Spike
 * Input: spiketrain, closest to this time
 * output: spike time
 *
 * Other: Can only be a real spike. Caller must check if one exists. If 
 *        there is no real spike the behaiour of the function is not 
 *        defined.
 */
double  Pair::ClosestRealSpike(Spiketrain* spikes, double time)
{
    double FirstRealSpike = spikes->GiveSpikeAtIndex(1);
    double LastRealSpike = spikes->GiveSpikeAtIndex(spikes->Length()-2);
    if (time <= FirstRealSpike)
    {
        return FirstRealSpike;
    }
    if (time >= LastRealSpike)
    {
        return LastRealSpike;
    }
    double preceeding,following;
    spikes->GiveCornerSpikes(preceeding,time,following);
    
    if (time - preceeding < following-time)
    {
        return preceeding;
    }
    else
    {
        return following;
    }
}

// a function for forming overall ISI profile
/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-ISI-profile
 * Input: from time, to time, output for X values, output for Y values, threshold
 * output: -
 *
 * Other: using references to X and Y vectors for output.
 */
void Pair::AdaptiveISIprofile(double time1,double time2, std::vector<double> &X, std::vector<double> &Y,double threshold)
{
    double ST1F, ST2F;
    // Taking only first interval up to next spike.
    ST1F = one->GiveFollowingSpike(time1);
    ST2F = two->GiveFollowingSpike(time1);
    // Taking the closest spike or end of the interval
    double closest = std::min(ST1F,ST2F);
    closest = std::min(closest,time2);
    // Taking the ISI at halfway point and saving for both ends.
    double ISItime = (time1+closest)/2;
    double ISId = AdaptiveISIdistance( ISItime ,threshold);
    
    Y.push_back(ISId);
    Y.push_back(ISId);
    X.push_back(time1);
    X.push_back(closest);
    
    // When at end stop, but while not take the next interval.
    if ( !(time2 == closest))
    {
        AdaptiveISIprofile(closest,time2,X,Y,threshold);
    }
}

// a function for forming overall ISI profile
/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-SPIKE-profile
 * Input: from time, to time, output for X values, output for Y values, threshold
 * output: -
 *
 * Other: using references to X and Y vectors for output.
 */
void Pair::AdaptiveSPIKEprofile(double time1,double time2, std::vector<double> &X, std::vector<double> &Y, double threshold)
{
    double STARTinterval, ENDinterval;
    double ISI1, ISI2 ,meanISI,S1,S2,S;
    double ST1P, ST2P, ST1F, ST2F, xp1, xp2, xf1, xf2, dpt1, dpt2, dft1, dft2;
    
    /* Using the ISI of the interval we are in.
     * Thus taking the ISIs based on time 1. Taking
     * it based on time 2 would give the beginning
     * of the next interval.
     */
    one->GiveCornerSpikes(ST1P,time1,ST1F);
    two->GiveCornerSpikes(ST2P,time1,ST2F);
    ISI1 = ST1F-ST1P;
    ISI2 = ST2F-ST2P;
    
    meanISI = (ISI1+ISI2)/2;
    
    // Taking the closest spike or the end of the interval
    double closest = std::min(ST1F,ST2F);
    closest = std::min(closest,time2);
    
    // Searching for the closest real spikes of the corner
    // spikes from the other spike trains.
    dpt1 = std::abs(ST1P - ClosestSpike(two, ST1P));
    dpt2 = std::abs(ST2P - ClosestSpike(one, ST2P));
    dft1 = std::abs(ST1F - ClosestSpike(two, ST1F));
    dft2 = std::abs(ST2F - ClosestSpike(one, ST2F));
    
    // For beginning
    xp1 = time1 - ST1P;
    xp2 = time1 - ST2P;
    xf1 = ST1F - time1;
    xf2 = ST2F - time1;
    
    // Edge correction for SPIKE-d
    if( ST1P == one->FirstSpike())
    {
        dpt1 = dft1;
    }
    if( ST1F == one->LastSpike())
    {
        dft1 = dpt1;
    }
    if( ST2P == two->FirstSpike())
    {
        dpt2 = dft2;
    }
    if( ST2F == two->LastSpike())
    {
        dft2 = dpt2;
    }

    S1 = (dpt1*xf1+dft1*xp1)/(ISI1);
    S2 = (dpt2*xf2+dft2*xp2)/(ISI2);
    
    STARTinterval = (S1*ISI2 + S2*ISI1)/(2*meanISI*std::max(meanISI,threshold));
    
    // For end
    xp1 = closest - ST1P;
    xp2 = closest - ST2P;
    xf1 = ST1F - closest;
    xf2 = ST2F - closest;
    
    S1 = (dpt1*xf1+dft1*xp1)/(ISI1);
    S2 = (dpt2*xf2+dft2*xp2)/(ISI2);
    
    ENDinterval = (S1*ISI2 + S2*ISI1)/(2*meanISI*std::max(meanISI,threshold));
    
    Y.push_back(STARTinterval);
    Y.push_back(ENDinterval);
    X.push_back(time1);
    X.push_back(closest);
    
    // When at end stop, but while not take the next interval.
    if ( !(time2 == closest))
    {
        AdaptiveSPIKEprofile(closest,time2,X,Y,threshold);
    }
    
}

// a function for forming overall ISI profile
/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: A-SPIKE-profile
 * Input: from time, to time, output for X values, output for Y values, threshold
 * output: -
 *
 * Other: using references to X and Y vectors for output.
 */
void Pair::AdaptiveRateIndependentSPIKEprofile(double time1,double time2, std::vector<double> &X, std::vector<double> &Y, double threshold)
{
    double STARTinterval, ENDinterval;
    double ISI1, ISI2 ,meanISI,S1,S2,S;
    double ST1P, ST2P, ST1F, ST2F, xp1, xp2, xf1, xf2, dpt1, dpt2, dft1, dft2;
    
    /* Using the ISI of the interval we are in.
     * Thus taking the ISIs based on time 1. Taking
     * it based on time 2 would give the beginning
     * of the next interval.
     */
    one->GiveCornerSpikes(ST1P,time1,ST1F);
    two->GiveCornerSpikes(ST2P,time1,ST2F);
    ISI1 = ST1F-ST1P;
    ISI2 = ST2F-ST2P;
    
    meanISI = (ISI1+ISI2)/2;
    
    // Taking the closest spike or the end of the interval
    double closest = std::min(ST1F,ST2F);
    closest = std::min(closest,time2);
    
    // Searching for the closest real spikes of the corner
    // spikes from the other spike trains.
    dpt1 = std::abs(ST1P - ClosestSpike(two, ST1P));
    dpt2 = std::abs(ST2P - ClosestSpike(one, ST2P));
    dft1 = std::abs(ST1F - ClosestSpike(two, ST1F));
    dft2 = std::abs(ST2F - ClosestSpike(one, ST2F));
    
    // For beginning
    xp1 = time1 - ST1P;
    xp2 = time1 - ST2P;
    xf1 = ST1F - time1;
    xf2 = ST2F - time1;
    
    // Edge correction for SPIKE-d
    if( ST1P == one->FirstSpike())
    {
        dpt1 = dft1;
    }
    if( ST1F == one->LastSpike())
    {
        dft1 = dpt1;
    }
    if( ST2P == two->FirstSpike())
    {
        dpt2 = dft2;
    }
    if( ST2F == two->LastSpike())
    {
        dft2 = dpt2;
    }

    S1 = (dpt1*xf1+dft1*xp1)/(ISI1);
    S2 = (dpt2*xf2+dft2*xp2)/(ISI2);
    
    STARTinterval = (S1 + S2)/(2*std::max(meanISI,threshold));
    
    // For end
    xp1 = closest - ST1P;
    xp2 = closest - ST2P;
    xf1 = ST1F - closest;
    xf2 = ST2F - closest;
    
    S1 = (dpt1*xf1+dft1*xp1)/(ISI1);
    S2 = (dpt2*xf2+dft2*xp2)/(ISI2);
    
    ENDinterval = (S1 + S2)/(2*std::max(meanISI,threshold));
    
    Y.push_back(STARTinterval);
    Y.push_back(ENDinterval);
    X.push_back(time1);
    X.push_back(closest);
    
    // When at end stop, but while not take the next interval.
    if ( !(time2 == closest))
    {
        AdaptiveRateIndependentSPIKEprofile(closest,time2,X,Y,threshold);
    }
    
}