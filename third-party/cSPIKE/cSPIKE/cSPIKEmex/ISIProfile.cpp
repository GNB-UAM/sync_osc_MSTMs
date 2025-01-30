/* Object: ISIProfile
 * Creator: Eero Satuvuori
 * Date: 18.8.2016
 * Version: 1.0 
 * Purpose: This class is used to store and combine ISI-profiles. 
 */

#include "ISIProfile.h"
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
ISIProfile::ISIProfile(std::vector<double> X, std::vector<double> Y)
{
    Xvalues = X;
    Yvalues = Y;
    NumberOfProfilesInProfile = 1;
}


/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: adds two profiles together
 * Input: ISIProfile*
 * output: -
 *
 * Other: This profile becomes the joined profile. The other remain unchanged.
 */
void ISIProfile::AddISIprofile(ISIProfile* second)
{     
    unsigned int index1 = 0;
    unsigned int index2 = 0;
    std::vector<double> newY ;
    std::vector<double> newX ;
    double N1 = NumberOfProfilesInProfile;
    double N2 = second->NumberOfProfilesInProfile;
    bool done = false;
    
    /* The while loop goes over both profiles and when the integration is over
     * exits with done flag. The integration moves always forwards in the profile
     * that is lagging. So if the first interval has two different next spikes,
     * the next interval will start at the closer one of those. If they are exactly
     * the same the integration starts after those spikes so both are moved. Thus 
     * while() is used in stead of for loops.
     *
     * The values of the integrated profiles are weighted by their number of profiles 
     * already included to keep averaging correct.
     */
    while(!done)
    {
        
        double ISIprof11Y = Yvalues.at(index1);
        double ISIprof11X = Xvalues.at(index1);
        double ISIprof12Y = Yvalues.at(index1+1);
        double ISIprof12X = Xvalues.at(index1+1);
        
        double ISIprof21Y = second->Yvalues.at(index2);
        double ISIprof21X = second->Xvalues.at(index2);
        double ISIprof22Y = second->Yvalues.at(index2+1);
        double ISIprof22X = second->Xvalues.at(index2+1);
        
        // First border
        
        double X = std::max(ISIprof11X,ISIprof21X);
        newX.push_back(X);
        double Y1 = ISIprof11Y;
        double Y2 = ISIprof21Y;
        
        newY.push_back((Y1*N1 + Y2*N2)/(N1+N2));

        // Same for the following spikes.
        if (ISIprof12X == ISIprof22X)
        {
            newX.push_back(ISIprof12X);
            newY.push_back((ISIprof12Y*N1 + ISIprof22Y*N2)/(N1+N2));
            
            //Moving both forwards if they are the same
            index1 = index1 + 2;
            index2 = index2 + 2;
        }
        else
        {
            double X = std::min(ISIprof12X,ISIprof22X);
            newX.push_back(X);
            double Y1 = ISIprof11Y;
            double Y2 = ISIprof21Y;
            newY.push_back((Y1*N1 + Y2*N2)/(N1+N2));
            
            // Moving only the index with the closest following 
            // spike to the next interval
            if (ISIprof12X < ISIprof22X)
            {
                index1 = index1 + 2;
            }
            else
            {
                index2 = index2 + 2;
            }
            
        }
        // When at the end exit
        if ( index1 == Xvalues.size() && index2 == second->Xvalues.size())
        {
            done = true;
        }
    }
    // Setting the profile to the joined values.
    this->Xvalues.swap(newX);
    this->Yvalues.swap(newY);
    NumberOfProfilesInProfile++;
  
}
/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Returns profile's Y coordinates
 * Input: -
 * output: std::vector<double>
 *
 * Other: -
 */
std::vector<double> ISIProfile::GetProfileY()
{   
    return Yvalues;
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: Returns profile's X coordinates
 * Input: -
 * output: std::vector<double>
 *
 * Other: -
 */
std::vector<double> ISIProfile::GetProfileX()
{   
    return Xvalues;
}