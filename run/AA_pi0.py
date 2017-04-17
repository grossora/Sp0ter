import sys, os
import numpy as np
import Utils.datahandle as dh

#import Clustering.protocluster as pc
import Utils.labelhanle as lh
import Merging.stitcher as st
import Merging.merger as mr
import Utils.mchandle as mh
import TS_Qual.ts_separation as tss
import Utils.mchandle as mh
import Geo_Utils.axisfit as axfi
import SParams.selpizero as selpz
import Selection.Select_NeutralPion as Es
import Selection.Ana_Clusters as Ea
import Selection.ROI_Cluster as Erc

import pyximport
pyximport.install(pyimport = True)
#import Selection.Reco_Clusters as Er
from Selection import cReco_Clusters as Er
from Selection import Select_NeutralPion as Es

from datetime import datetime


#######################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#######################################
#Global Calls
debug = True
make_jsons = False
#make_jsons = True
make_ana = True 
#make_ana = False 
Charge_thresh = 2500 # Need to be set better This is used to mask over low charge spacepoints when bringing them into the Dataset
#Charge_thresh = 4000 # Need to be set better This is used to mask over low charge spacepoints when bringing them into the Dataset
method_name = 'AA_pi0'
drun_dir = method_name
jcount = -1


#######################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#######################################

for f in sys.argv[1:]:
    jcount +=1

    # This is for checking process time for things
    start = datetime.now()

    ########################
    # Check if the File is good
    ########################
    file_info = dh.F_Info_Cosmic(f)
    #file_info = dh.F_Info(f)

    ########################
    # File info
    ########################
    if debug:
        print 'Current Event -->  Event Run SubRun : ',file_info[1]

    ########################
    # Is this a Signal Event  AKA One neutron induced pi0
    ########################
    #SigEVT =  mh.mc_neutron_induced_contained(f)
    #print ' Is this a signal'
    #if not SigEVT:
#	continue
 #   print '^^^^ this is signal '

    ########################
    # mc_datalabel info
    # Call this once and get the mc info for the jsons for later
    ########################
    mc_dl =  mh.mc_Obj_points(mh.mc_neutron_induced_OBJ(f))

    ########################
    # if the file is bad then continue and fill 
    ########################
    if not file_info[0]:
        continue

    ########################
    # make the data dir for json 
    ########################
    jdir = os.getcwd() + '/Bjson/'+drun_dir+ '/'+str(jcount)   # This still is global and can be used later
    if make_jsons:
        if not os.path.isdir(jdir):
            print 'NO DIR.... making one for you'
            os.makedirs(jdir)

    ########################
    # Print out all the MC Spacepts 
    # Print out all the WC-Reco Spacepts 
    ########################
    if make_jsons:
        dh.MakeJsonMC(f,jdir,jcount,'AlgMC',mc_dl)

    if make_jsons:
        dh.MakeJsonReco(f,jdir,jcount,'AlgSPT',mc_dl)

    ########################
    #Bring in  Dataset 
    ########################
    dataset = dh.ConvertWC_InTPC_thresh('{}'.format(f),Charge_thresh)

    #continue
#######################################################################################

    #####################################################################
    #####################################################################
    ###########  Make the reconsutcion section here   ###################
    #####################################################################
    #####################################################################
    # Input will be dataset.... output will be selected pi0 clusters
    trackidx_holder , showeridx_holder , labels =Er.Reco_trackshower(dataset,mc_dl,jdir,jcount,make_jsons)

    #####################################################################

#######################################################################################
    #####################################################################
    #####################################################################
    ###########  Recluster some of the showers     ######################
    #####################################################################
    #####################################################################


    #print ' length of shower holder before ' , str( len(showeridx_holder))
    showeridx_holder , labels =Er.Reco_showerReCluster(dataset,showeridx_holder,labels,mc_dl,jdir,jcount,make_jsons)
    #print ' length of shower holder after ' , str( len(showeridx_holder))

 
#######################################################################################

    #####################################################################
    #####################################################################
    ###########  Make the selection section here   ######################
    #####################################################################
    #####################################################################

    # Input will be clusters .... output will be matched pairs
    #selidx_holder = Es.CorrelatedObjects(dataset, showeridx_holder,labels)
    #if make_jsons:
    #    dh.MakeJson_Objects(dataset,selidx_holder,labels,jdir,jcount,'SELshower', mc_dl)

    #####################################################################
    #####################################################################

#######################################################################################

    #####################################################################
    #####################################################################
    ###########  Make the ana output here    ############################
    #####################################################################
    #####################################################################

    # This is ana
    if make_ana:
        #Ea.Ana_CutPi0_mc_pair_vtx(f,Charge_thresh,dataset,  jcount, selidx_holder, trackidx_holder,mc_dl, filename='Full_Ana_SelectedPi0_pair')
        Ea.Ana_Pi0_mc_pair_vtx(f,Charge_thresh,dataset,  jcount, showeridx_holder, trackidx_holder,mc_dl, filename='lPi0_pair')
        Ea.Pi0_Ana_Object(f, Charge_thresh,dataset, showeridx_holder, trackidx_holder, jcount, mc_dl,ts='shower', filename='lhullShower_pi0')
        Ea.Pi0_Ana_Object(f, Charge_thresh,dataset, showeridx_holder, trackidx_holder, jcount, mc_dl,ts='track', filename='lhullTrack_pi0')
        #Ea.Ana_CutPi0_mc_pair_vtx(f,Charge_thresh,dataset,  jcount, showeridx_holder, trackidx_holder,mc_dl, filename='WTEST_Ana_SelectedPi0_pair')
        #Ea.Pi0_Ana_Object(f, Charge_thresh,dataset, showeridx_holder, trackidx_holder, jcount, mc_dl,ts='shower', filename='WTEST_Ana_Shower_pi0')
        #Ea.Pi0_Ana_Object(f, Charge_thresh,dataset, showeridx_holder, trackidx_holder, jcount, mc_dl,ts='track', filename='WTEST_Ana_Track_pi0')

#######################################################################################

    end = datetime.now()
    delta = end-start
    print 'time for an event :'
    print delta.seconds
    #time_h.append(delta.seconds)
    continue


