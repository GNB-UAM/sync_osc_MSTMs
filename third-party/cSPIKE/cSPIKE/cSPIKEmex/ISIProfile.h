/* Object: ISIProfile
 * Creator: Eero Satuvuori
 * Date: 18.8.2016
 * Version: 1.0 
 * Purpose: This class is used to store and combine ISI-profiles. 
 */
#ifndef ISIProfile_H
#define ISIProfile_H
#include <vector>
#include "Spiketrain.h"

class ISIProfile
{
private:
    
    std::vector<double> Xvalues;
    std::vector<double> Yvalues;
    unsigned int NumberOfProfilesInProfile;
    
public:
    ISIProfile(std::vector<double> X, std::vector<double> Y);
    void AddISIprofile(ISIProfile* second);
    unsigned int NumberOfProfiles();
    std::vector<double> GetProfileX();
    std::vector<double> GetProfileY();
};


#endif