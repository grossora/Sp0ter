import sys
from datetime import datetime

#LoadTime
import sys, os
sys.path.insert(0, "../")
import numpy as np

import lib.utility.Geo_Utils.detector as detector
import lib.utility.Utils.mchandle as mh
import lib.utility.Utils.labelhanle as lh
import lib.utility.Utils.datahandle as dh
import lib.Selection.Reco_Clusters as Er
import lib.Selection.ROI_Cluster as EROI
import lib.Selection.Select_NeutralPion as Es
import lib.Selection.Ana_Clusters as Ea

#######################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#######################################
#Global Calls
debug = True
#make_jsons = False
make_jsons = True 
make_ana = False 
#make_ana = False 
Charge_thresh = 500 # Need to be set better This is used to mask over low charge spacepoints when bringing them into the Dataset
#Charge_thresh = 3000 # Need to be set better This is used to mask over low charge spacepoints when bringing them into the Dataset
method_name = 'Friday_Randy'
#method_name = 'june_showerscosmic_pi0'
drun_dir = method_name
jcount = -1
#######################################
#######################################


for f in sys.argv[1:]:

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
    # Is this a Signal Event  AKA One ncutron induced pi0
    ########################
    SigEVT =  mh.mc_neutron_induced_contained_2(f)
    #SigEVT =  mh.mc_neutron_induced_OBJ_2(f)
    if not SigEVT[0]:
        print 'This is not signal'
        continue

    # This is done becuase we have to account for the time offsest 
    #shiftSigEVT = mh.mcpart_tshift_2(SigEVT) ### ORIGINAL
    #shiftSigEVT = mh.mcpart_tshift_2(SigEVT) ### ORIGINAL
    # Real hard hack for test
    tpath = '/home/ryan/Sp0ter'
    shiftSigEVT = mh.mcpart_tshift_sce(SigEVT,tpath)

    ########################
    # mc_datalabel info
    # Call this once and get the mc info for the jsons for later
    ########################
    mc_dl =  mh.mc_Obj_points_2(shiftSigEVT)
    # # # # # # # # # # # # #
    # # # # # # # # # # # # #
    # # # # # # # # # # # # #
    # Hack For Fiducial # # #
    #pi0z = SigEVT[1][2]  # pi0_4vect [2]
    #print ' this is piz  : ' , str(pi0z)
    #zhi = detector.GetZ_Bounds()[1]
    #if pi0z<0:
    #    print ' gotta bail ' 
    #    continue
    # # # # # # # # # # # # #
    # # # # # # # # # # # # #
    # # # # # # # # # # # # #
    #print ' we made it' 

   ########################
    # make the data dir for json 
    ########################
    # Magic Jcount
    jcount +=1
    jdir = os.getcwd() + '/Bjson/'+drun_dir+ '/'+str(jcount)   # This still is global and can be used later
    if True:
    #if make_jsons:
        if not os.path.isdir(jdir):
            print 'NO DIR.... making one for you'
            os.makedirs(jdir)

    ########################
    # Print out all the MC Spacepts 
    # Print out all the WC-Reco Spacepts 
    ########################
    if True:
    #if make_jsons:
        dh.MakeJsonMC(f,jdir,jcount,'AlgMC',mc_dl)

    ########################
    #Bring in  Dataset 
    ########################
    dataset = dh.ConvertWC_FauxTrue_above_thresh('{}'.format(f),Charge_thresh)
    #dataset = dh.ConvertWC_above_thresh('{}'.format(f),Charge_thresh)
    #dataset = dh.ConvertWC_InTPC_thresh('{}'.format(f),Charge_thresh)
    print '======>  THIS IS THE SIZE OF YOUR DATASET!!!!!', str(len(dataset))
    if True:
    #if make_jsons:
        dh.MakeJsonReco_2(f,jdir,jcount,'AlgSPT',mc_dl)


#######################################################################################
    #####################################################################
    #####################################################################
    ###########  Make the reconsutcion section here   ###################
    #####################################################################
    #####################################################################
    start_Rtime = datetime.now()

    # Input will be dataset.... output will be selected pi0 clusters
    #trackidx_holder , showeridx_holder , labels =Er.Reco_FirstPass(dataset , mc_dl , jdir, jcount , make_jsons=False)
    trackidx_holder , showeridx_holder , labels =Er.Reco_FirstPass(dataset , mc_dl , jdir, jcount , make_jsons=make_jsons)

   

    end_Rtime = datetime.now()
    delta_Rt = end_Rtime-start_Rtime
    print 'RTIME' ,str(delta_Rt.seconds)+' runfirstpass_reco'
    start_Rtime = datetime.now()
    #####################################################################
    if True:
        dh.MakeJsonShower_Params(dataset,showeridx_holder,labels,jdir,jcount,"Shower_Params",mc_dl)

#######################################################################################
    


    

    #####################################################################
    #####################################################################
    ###########    Rebase the dataset for reclustering    ###############
    #####################################################################
    #####################################################################

    # Here we can do some merging with showers 
    #bloat_dataset, bloat_trackidx_holder , bloat_showeridx_holder , plabels = Er.rebase_showers_reco(f, dataset,showeridx_holder,track_ell,labels,mc_dl , jdir, jcount , make_jsons=False)




    #print 'do we have any small clusters'
    uncluster_idx_holder = lh.unlabel_from_labels(labels,20)
    #print 'unclusterd' 
    #print len(uncluster_idx_holder)
    

    # Input will be clusters .... output will be matched pairs
    #EROI.pi0_cleanup(f, dataset,showeridx_holder,labels)
    #bloat_dataset, bloat_trackidx_holder , bloat_showeridx_holder , plabels = Er.rebase_showers_reco(f, dataset,showeridx_holder,track_ell,labels,mc_dl , jdir, jcount , make_jsons=False)
    #end_Rtime = datetime.now()
    #delta_Rt = end_Rtime-start_Rtime
    #print 'RTIME' ,str(delta_Rt.seconds)+' runROI'
    #start_Rtime = datetime.now()
    #####################################################################
    #####################################################################

#######################################################################################


    #####################################################################
    #####################################################################
    ###########  Make the selection section here   ######################
    #####################################################################
    #####################################################################
        # Remove any cluster not in the fiducial 
    showeridx_holder_fid_clean = []
    for cl in showeridx_holder:
        # loop over the points in the holder
        # clusters must have less than 10% in dead fiducial
        out_holder = []
        for pt in cl:
            if not detector.In_Range_Fid(dataset[pt], fid_xlo=-10000, fid_xhi=10000, fid_ylo=-10000, fid_yhi=100000, fid_zlo=0, fid_zhi=10000):
            #if not detector.In_Range_Fid(bloat_dataset[pt], fid_xlo=-10000, fid_xhi=10000, fid_ylo=-10000, fid_yhi=100000, fid_zlo=400, fid_zhi=10000):
            # This is a bad hack for now
            #if not detector.In_TPC_Fid(bloat_dataset[pt], fid_xlo=0, fid_xhi=0, fid_ylo=0, fid_yhi=0, fid_zlo=400, fid_zhi=0):
                out_holder.append(pt)
        if 1.0*len(out_holder)/len(cl)>0.1:
            continue
        showeridx_holder_fid_clean.append(cl)

    #if make_jsons:
      #  dh.MakeJson_Objects(dataset,showeridx_holder_fid_clean,plabels,jdir,jcount,'Final_Showers', mc_dl)
        #dh.MakeJson_Objects(dataset,showeridx_holder_fid_clean,plabels,jdir,jcount,'Final_Showers', mc_dl)


    #continue





#######################################################################################

    #####################################################################
    #####################################################################
    ###########  Make the ana output here    ############################
    #####################################################################
    #####################################################################
    Ea.Ana_CosmicPi0_mc_pair_vtx(f,Charge_thresh,dataset,  jcount, showeridx_holder_fid_clean, trackidx_holder,mc_dl, filename='June_Cosmic_pair')
    #Ea.Ana_CosmicPi0_mc_pair_vtx(f,Charge_thresh,bloat_dataset,  jcount, showeridx_holder_fid_clean, trackidx_holder,mc_dl, filename='May_Cosmic_pair')


