#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include "math.h"
#include "stdio.h"
#include<stdlib.h>

#include "SpaceChargeMicroBooNE.h"

using namespace std;

int main(int argc, char* argv[]) {

  std::string sx(argv[1]);
  std::string sy(argv[2]);
  std::string sz(argv[3]);

  float x=std::stof(sx);
  float y=std::stof(sy);
  float z=std::stof(sz);

  // The input argv will have to be x , y , z 
  SpaceChargeMicroBooNE SCE(argv[4]); // for 273 V/cm by default
  //SpaceChargeMicroBooNE SCE("SCEoffsets_MicroBooNE_E500.root"); // if you want to try different E fields (shown for 500 V/cm), though must change Edrfit constant above to match!

  // Get the offsets
  vector<double> mySoffsets = SCE.GetPosOffsets(x,y,z); // returns {dX, dY, dZ} at given point
  cout << mySoffsets.at(0) << " " << mySoffsets.at(1) << " " << mySoffsets.at(2) << endl; // values in cm
  ////////////

  return 0;
}
