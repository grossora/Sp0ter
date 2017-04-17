from datetime import datetime
start_Rtime = datetime.now()

#LoadTime
import sys, os
sys.path.insert(0, "../")
import numpy as np

import lib.utility.Geo_Utils.detector as detector
#import lib.utility.Utils.mchandle as mh
import lib.utility.Utils.datahandle as dh
import lib.Selection.Reco_Clusters as Er
import lib.Selection.Select_NeutralPion as Es
import lib.Selection.ROI_Cluster as Erc


end_Rtime = datetime.now()
delta_Rt = end_Rtime-start_Rtime 
print 'RTIME' ,str(delta_Rt.seconds)+' loadtime'
start_Rtime = datetime.now()

#######################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#######################################
#Global Calls
debug = True
#make_jsons = False
make_jsons = True
make_ana = True
#make_ana = False 
#Charge_thresh = 0 # Need to be set better This is used to mask over low charge spacepoints when bringing them into the Dataset
Charge_thresh = 500 # Need to be set better This is used to mask over low charge spacepoints when bringing them into the Dataset
#Charge_thresh = 4000 # Need to be set better This is used to mask over low charge spacepoints when bringing them into the Dataset
method_name = 'Data_cosmic'
drun_dir = method_name
jcount = -1
mc_dl = []

# This is data so... mc_dl = False


#######################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#######################################

for f in sys.argv[1:]:

    # This is for checking process time for things

    ########################
    # Check if the File is good
    ########################
    #file_info = dh.F_Info_Cosmic(f)
    #file_info = dh.F_Info_Cosmic(f)
    #file_info = dh.F_Info(f)

    #end_Rtime = datetime.now()
    #delta_Rt = end_Rtime-start_Rtime 
    #print 'RTIME' ,str(delta_Rt.seconds)+' comsmicinfo'
    start_Rtime = datetime.now()
    event_start_Rtime = datetime.now()
    ########################
    # File info
    ########################
    #if debug:
    #    print 'Current Event -->  Event Run SubRun : ',file_info[1]

    ########################
    # Is this a Signal Event  AKA One neutron induced pi0
    ########################
    #SigEVT =  mh.mc_neutron_induced_contained(f)

    #if not SigEVT:
    #    print 'This is not signal'
    #    continue
    #print 'This a signal'

    #end_Rtime = datetime.now()
    #delta_Rt = end_Rtime-start_Rtime 
    #print 'RTIME' ,str(delta_Rt.seconds)+' neutroninducedinfo'
    #start_Rtime = datetime.now()

    ########################
    # mc_datalabel info
    # Call this once and get the mc info for the jsons for later
    ########################
    #mc_dl =  mh.mc_Obj_points(mh.mc_neutron_induced_OBJ(f))

    #end_Rtime = datetime.now()
    #delta_Rt = end_Rtime-start_Rtime 
    #print 'RTIME' ,str(delta_Rt.seconds)+' mcobjpoints'
    #start_Rtime = datetime.now()
    # # # # # # # # # # # # #
    # # # # # # # # # # # # #
    # # # # # # # # # # # # #
 
    # Hack For Fiducial # # #

    
    #pi0z = mh.mc_neutron_induced_OBJ(f)[1][2] 
    #print ' this is piz  : ' , str(pi0z)
    #zhi = detector.GetZ_Bounds()[1]
    #if pi0z<zhi/2:
    #    continue
    # # # # # # # # # # # # #
    # # # # # # # # # # # # #
    # # # # # # # # # # # # #

    ########################
    # if the file is bad then continue and fill 
    ########################
    #if not file_info[0]:
    #    continue

    ########################
    # make the data dir for json 
    ########################
    # Magic Jcount
    jcount +=1
    jdir = os.getcwd() + '/Bjson/'+drun_dir+ '/'+str(jcount)   # This still is global and can be used later
    if make_jsons:
        if not os.path.isdir(jdir):
            print 'NO DIR.... making one for you'
            os.makedirs(jdir)

    end_Rtime = datetime.now()
    delta_Rt = end_Rtime-start_Rtime 
    print 'RTIME' ,str(delta_Rt.seconds)+' make_directories'
    start_Rtime = datetime.now()
    # # # # # # # # # # # # #
    ########################
    # Print out all the MC Spacepts 
    # Print out all the WC-Reco Spacepts 
    ########################
    #if make_jsons:
    #    dh.MakeJsonMC(f,jdir,jcount,'AlgMC',mc_dl)

    #end_Rtime = datetime.now()
    #delta_Rt = end_Rtime-start_Rtime 
    #print 'RTIME' ,str(delta_Rt.seconds)+' make_mcjson'
    #start_Rtime = datetime.now()
    if make_jsons:
        dh.MakeJsonReco(f,jdir,jcount,'AlgSPT',mc_dl)

    end_Rtime = datetime.now()
    delta_Rt = end_Rtime-start_Rtime 
    print 'RTIME' ,str(delta_Rt.seconds)+' make_algsptjson'
    start_Rtime = datetime.now()
    ########################
    #Bring in  Dataset 
    ########################
    dataset = dh.ConvertWC_InTPC_thresh('{}'.format(f),Charge_thresh)
    end_Rtime = datetime.now()
    delta_Rt = end_Rtime-start_Rtime 
    print 'RTIME' ,str(delta_Rt.seconds)+' make_tpcpoints'
    start_Rtime = datetime.now()
    print 'size of dataset ' , str(len(dataset))

#######################################################################################

    #####################################################################
    #####################################################################
    ###########  Make the reconsutcion section here   ###################
    #####################################################################
    #####################################################################
    # Input will be dataset.... output will be selected pi0 clusters

    trackidx_holder , showeridx_holder , labels =Er.Reco_trackshower(dataset,mc_dl,jdir,jcount,True)
    #trackidx_holder , showeridx_holder , labels =Er.Reco_trackshower(dataset,mc_dl,jdir,jcount,make_jsons)
    #trackidx_holder , showeridx_holder , labels =Er.Reco_trackshower(dataset,mc_dl,jdir,jcount,make_jsons)
    end_Rtime = datetime.now()
    delta_Rt = end_Rtime-start_Rtime 
    print 'RTIME' ,str(delta_Rt.seconds)+' runfirstpass_reco'
    start_Rtime = datetime.now()
    #####################################################################

    # hack to get out
    continue 
#######################################################################################

    #####################################################################
    #####################################################################
    ###########  Make the selection section here   ######################
    #####################################################################
    #####################################################################

    # Input will be clusters .... output will be matched pairs
    #selidx_holder = Es.CorrelatedObjects(dataset, showeridx_holder,labels)
    #selidx_holder = Es.CorrelatedObjects(dataset, showeridx_holder,labels)
    ROI_list = Es.CorrelatedObjectsROI(dataset, showeridx_holder , labels)
    end_Rtime = datetime.now()
    delta_Rt = end_Rtime-start_Rtime 
    print 'RTIME' ,str(delta_Rt.seconds)+' runROI'
    start_Rtime = datetime.now()
    #if make_jsons:
        #dh.MakeJson_Objects(dataset,selidx_holder,labels,jdir,jcount,'SELshower', mc_dl)
    #####################################################################
    #####################################################################

#######################################################################################

    #####################################################################
    #####################################################################
    ###########  Make the ana output here    ############################
    #####################################################################
    #####################################################################

    #if make_ana:
        #Ea.Ana_CPi0_mc_pair_vtx(f,Charge_thresh,dataset,  jcount, showeridx_holder, trackidx_holder,mc_dl, filename='lhull_Ana_pair_Cosmic_pair{}'.format(str(Charge_thresh)))
        #Ea.Ana_CPi0_mc_pair_vtx(f,Charge_thresh,dataset,  jcount, showeridx_holder, trackidx_holder,mc_dl, filename='lhull_Ana_pair_Cosmic_pair')
        #Ea.Ana_CutPi0_mc_pair_vtx(f,Charge_thresh,dataset,  jcount, selidx_holder, trackidx_holder,mc_dl, filename='Full_Ana_SelectedCosmic_pair')
        #Ea.Ana_Object(dataset, showeridx_holder, jcount, mc_dl, filename='lhull_Ana_Shower_cosmic')
        #Ea.Ana_Object(dataset, trackidx_holder, jcount, mc_dl, filename='lhull_Ana_Track_cosmic')

    #####################################################################
    #####################################################################
    ###########    Rebase the dataset for reclustering    ###############
    #####################################################################
    #####################################################################

    rebase_dataset = Erc.rebase_spts(f,dataset,showeridx_holder, ROI_list ,6, 1000.)    
    rebase_labels = [ 5 for x in range(len(rebase_dataset))]
    rebaseidx_holder = [[ x for x in range(len(rebase_dataset))]]

    end_Rtime = datetime.now()
    delta_Rt = end_Rtime-start_Rtime 
    print 'RTIME' ,str(delta_Rt.seconds)+' rebase_dataset'
    start_Rtime = datetime.now()

    if make_jsons:
        dh.MakeJson_Objects(rebase_dataset,rebaseidx_holder,rebase_labels,jdir,jcount,'REBASE_ROI', mc_dl)

    end_Rtime = datetime.now()
    delta_Rt = end_Rtime-start_Rtime 
    print 'RTIME' ,str(delta_Rt.seconds)+' make_rebasejson'
    start_Rtime = datetime.now()


    rtrackidx_holder , rshoweridx_holder , rlabels =Er.rebase_Full_reco(rebase_dataset,mc_dl,jdir,jcount)
    #rtrackidx_holder , rshoweridx_holder , rlabels =Er.rebase_Full_reco(rebase_dataset,mc_dl,jdir,jcount,make_jsons,timer=True)
    end_Rtime = datetime.now()
    delta_Rt = end_Rtime-start_Rtime 
    print 'RTIME ' ,str(delta_Rt.seconds)+' run_rebase_Full_reco'
    start_Rtime = datetime.now()
    #print rebase_dataset 

    end_Rtime = datetime.now()
    delta_Rt = end_Rtime-event_start_Rtime 
    print 'ERTIME' ,str(delta_Rt.seconds)+' FullTimeForEvent'

    '''
    if len(ROI_list)==1:
        rebase_dataset = Erc.rebase_spts(f,dataset,showeridx_holder, ROI_list ,0.1, 100.)    
	# Rebase Params are ( f , dataset ,showeridx, ROI_list , Buffer , Theshold  
        print 'How long is the rebase ? ? / ?? // '
        print len(rebase_dataset)
        
        # Quick labels to view
        rebase_labels = [ 5 for x in range(len(rebase_dataset))]
        rebaseidx_holder = [[ x for x in range(len(rebase_dataset))]]

        if make_jsons:
            dh.MakeJson_Objects(rebase_dataset,rebaseidx_holder,rebase_labels,jdir,jcount,'REBASE_ROI', mc_dl)

        end2 = datetime.now()
        delta2 = end2-start2

        print 'time for the recluster :'
        print delta2.seconds

        #rebase cluster
        #trackidx_holder , showeridx_holder , labels =Er.rebase_Full_reco(rebase_dataset,mc_dl,jdir,jcount,make_jsons,timer=True)

    '''
#######################################################################################
