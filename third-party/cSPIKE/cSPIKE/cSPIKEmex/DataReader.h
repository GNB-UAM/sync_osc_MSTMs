/* Object: DataReader
 * Creator: Eero Satuvuori
 * Date: 18.8.2016
 * Version: 1.0 
 * Purpose: Object class for reading the input and
 *          creating the output class Spiketrains
 */

#ifndef DataReader_H
#define DataReader_H
#include "Spiketrains.h"
#include <mex.h>

class DataReader 
{
	public:
	DataReader();
	
	Spiketrains* ReadSpiketrains(const mxArray* Data);
	
};


#endif