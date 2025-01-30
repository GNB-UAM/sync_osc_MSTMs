/* Object: SPIKEProfile
 * Creator: Eero Satuvuori
 * Date: 18.8.2016
 * Version: 1.0 
 * Purpose: This class is used to store and combine ISI-profiles. 
 */

#include "SPIKEProfile.h"
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
SPIKEProfile::SPIKEProfile(std::vector<double> X, std::vector<double> Y)
{
    Xvalues = X;
    Yvalues = Y;
    NumberOfProfilesInProfile = 1;
}

/* Date: 18.8.2016
 * Version: 1.0
 *
 * Function: adds two profiles together
 * Input: SPIKEProfile*
 * output: -
 *
 * Other: This profile becomes the joined profile. The other remain unchanged.
 */
void SPIKEProfile::AddSPIKEprofile(SPIKEProfile* second)
{
    
    unsigned int index1 = 0;
    unsigned int index2 = 0;
    std::vector<double> newY ;
    std::vector<double> newX ;
    double N1 = NumberOfProfilesInProfile;
    double N2 = second->NumberOfProfilesInProfile;
    bool done = false;
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
        if (ISIprof11X == ISIprof21X)
        {
            // Same spike time: doesn't matter which one to use and
            // concatenating is simple
            newX.push_back(ISIprof11X);
            newY.push_back((ISIprof11Y*N1 + ISIprof21Y*N2)/(N1+N2));
        }
        else
        {
            /* If they are not the same take the closer one only,
             * since the previous round will have handled the furthest spike
             */
            double X = std::max(ISIprof11X,ISIprof21X);
            newX.push_back(X);
            double x1 = X - ISIprof11X;
            double x2 = ISIprof12X - X;
            double Y1 = (ISIprof11Y*x2 + ISIprof12Y*x1)/(x1+x2);
            
            x1 = X - ISIprof21X;
            x2 = ISIprof22X - X;
            double Y2 = (ISIprof21Y*x2 + ISIprof22Y*x1)/(x1+x2);
            
            newY.push_back((Y1*N1 + Y2*N2)/(N1+N2));
        }
        /* Same for the following spikes.*/
        if (ISIprof12X == ISIprof22X)
        {
            newX.push_back(ISIprof12X);
            newY.push_back((ISIprof12Y*N1 + ISIprof22Y*N2)/(N1+N2));
            
            //Moving both forwards
            index1 = index1 + 2;
            index2 = index2 + 2;
        }
        else
        {
            double X = std::min(ISIprof12X,ISIprof22X);
            newX.push_back(X);
            double x1 = X - ISIprof11X;
            double x2 = ISIprof12X - X;
            double Y1 = (ISIprof11Y*x2 + ISIprof12Y*x1)/(x1+x2);
            
            x1 = X - ISIprof21X;
            x2 = ISIprof22X - X;
            double Y2 = (ISIprof21Y*x2 + ISIprof22Y*x1)/(x1+x2);
            
            newY.push_back((Y1*N1 + Y2*N2)/(N1+N2));
            if (ISIprof12X < ISIprof22X)
            {
                index1 = index1 + 2;
            }
            else
            {
                index2 = index2 + 2;
            }
            
        }
        if ( index1 == Xvalues.size() && index2 == second->Xvalues.size())
        {
            done = true;
        }
    }
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
std::vector<double> SPIKEProfile::GetProfileY()
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
std::vector<double> SPIKEProfile::GetProfileX()
{   
    return Xvalues;
}