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

  //const double Edrift = 0.273; // in kV/cm
  //const double dEdx = 2.1; // in MeV/cm
  //const double ModBoxA = 0.930;
  //const double ModBoxB = 0.212;

  SpaceChargeMicroBooNE SCE(argv[4]); // for 273 V/cm by default
  //SpaceChargeMicroBooNE SCE("SCEoffsets_MicroBooNE_E500.root"); // if you want to try different E fields (shown for 500 V/cm), though must change Edrfit constant above to match!

  ////  Example to obtain spatial offsets (just for your information)
  ////////////
  //float x = (float)argv[1];
  //float y = (float)argv[2];
  //float z = (float)argv[3];
  vector<double> mySoffsets = SCE.GetPosOffsets(x,y,z); // returns {dX, dY, dZ} at given point
  cout << mySoffsets.at(0) << " " << mySoffsets.at(1) << " " << mySoffsets.at(2) << endl; // values in cm
  ////////////

  //vector<double> myEoffsets = SCE.GetEfieldOffsets(256.0,0.0,518.0); // returns {Ex/|E_drift|, Ey/|E_drift|, Ez/|E_drift|} at given point (example here: middle of cathode)
  //cout << 1000.0*Edrift*myEoffsets.at(0) << " " << 1000.0*Edrift*myEoffsets.at(1) << " " << 1000.0*Edrift*myEoffsets.at(2) << endl; // values in V/cm

  //double EfieldMag = sqrt(pow(Edrift*(1.0+myEoffsets.at(0)),2.0) + pow(Edrift*myEoffsets.at(1),2.0) + pow(Edrift*myEoffsets.at(2),2.0));

  //double Xi = (ModBoxB * dEdx) / EfieldMag;
  //double recomb = log(ModBoxA + Xi) / Xi;

  //cout << "Recombination Factor at Cathode with SCE:  " << recomb << endl;

  //double Xi_nominal = (ModBoxB * dEdx) / Edrift;
  //double recomb_nominal = log(ModBoxA + Xi_nominal) / Xi_nominal;

  //cout << "Recombination Factor w/o SCE (entire TPC):  " << recomb_nominal << endl;

  return 0;
}
