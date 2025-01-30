/* Object: SPIKEProfile
 * Creator: Eero Satuvuori
 * Date: 18.8.2016
 * Version: 1.0 
 * Purpose: This class is used to store and combine SPIKE-profiles. 
 */

#ifndef SPIKEProfile_H
#define SPIKEProfile_H
#include <vector>
#include "Spiketrain.h"

class SPIKEProfile
{
private:
    
    std::vector<double> Xvalues;
    std::vector<double> Yvalues;
    unsigned int NumberOfProfilesInProfile;
    
public:
    SPIKEProfile(std::vector<double> X, std::vector<double> Y);
    void AddSPIKEprofile(SPIKEProfile* second);
    unsigned int NumberOfProfiles();
    std::vector<double> GetProfileX();
    std::vector<double> GetProfileY();
};


#endif