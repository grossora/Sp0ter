from datetime import datetime
start_Rtime = datetime.now()

#LoadTime
import sys, os
sys.path.insert(0, "../")
import numpy as np

import lib.utility.Geo_Utils.detector as detector
import lib.utility.Utils.mchandle as mh
import lib.utility.Utils.datahandle as dh
import lib.Selection.Reco_Clusters as Er
import lib.Selection.Select_NeutralPion as Es
import lib.Selection.ROI_Cluster as Erc


#####################
# Import for special tests
#####################
import shutil 
import lib.Clustering.protocluster as pc
import lib.Merging.stitcher as st 
import lib.Merging.merger as mr 
import lib.utility.Utils.labelhanle as lh
import lib.Selection.Ana_Clusters as Ea
import lib.Selection.Select_NeutralPion as Es
import lib.TS_Qual.ts_separation as tss 
#####################
####################



#end_Rtime = datetime.now()
#delta_Rt = end_Rtime-start_Rtime
#print 'RTIME' ,str(delta_Rt.seconds)+' loadtime'
#start_Rtime = datetime.now()

#############################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# About this script
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 
#  This script will look at
#  reconsturction of showers assuming 
# we are past the ROI stage useing a lower q
#############################################
#Global Calls
debug = True
#make_jsons = False
make_jsons = True
#make_ana = True 
make_ana = False 
Charge_thresh = 3000 
method_name = 'Stitch_cosmic_VTX'
drun_dir = method_name
jcount = -1



############################################
# ``````````````````````
#        Params
# ``````````````````````

#---Walker-----
mincluster = 20
#nn_dist = 7
nn_dist = 8

#---stitcher-----
min_clust_length = 10
gap_dist = 120
k_radius = 10
min_pdelta = 5
AE = .08

#---stitcher-----

############################################




jdir = os.getcwd() + '/Out_text/'+method_name+'/'   # This still is global and can be used later
if os.path.isdir(jdir):
    shutil.rmtree(jdir)

if not os.path.isdir(jdir):
    print 'NO DIR.... making one for you'
    os.makedirs(jdir)



#######################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
    # Is this a Signal Event  AKA One neutron induced pi0
    ########################
    SigEVT =  mh.mc_neutron_induced_contained(f)

    if not SigEVT:
        print 'This is not signal'
        continue

    ########################
    # mc_datalabel info
    # Call this once and get the mc info for the jsons for later
    ########################
    mc_dl =  mh.mc_Obj_points(mh.mc_neutron_induced_OBJ(f))

    # # # # # # # # # # # # #
    # # # # # # # # # # # # #
    # # # # # # # # # # # # #
    # Hack For Fiducial # # #

    pi0_pt = mh.mc_neutron_induced_OBJ(f)[1]
    if not detector.In_TPC_Fid(pi0_pt, fid_xlo=30, fid_xhi=30, fid_ylo=20, fid_yhi=20, fid_zlo=200, fid_zhi=50):
    #if not In_TPC_Fid(spt, fid_xlo=20, fid_xhi=20, fid_ylo=10, fid_yhi=10, fid_zlo=20, fid_zhi=20)
        print 'pi0 is outside of fiducial volume' 
        continue
    #In_TPC_Fid(spt, fid_xlo=20, fid_xhi=20, fid_ylo=10, fid_yhi=10, fid_zlo=20, fid_zhi=20)
    #print ' this is piz  : ' , str(pi0z)
    #zhi = detector.GetZ_Bounds()[1]
    #if pi0z<zhi/2:
    #    continue
    # # # # # # # # # # # # #
    # # # # # # # # # # # # #
    # # # # # # # # # # # # #

    jcount +=1
    jdir = os.getcwd() + '/Bjson/'+drun_dir+ '/'+str(jcount)   # This still is global and can be used later
    if make_jsons:
        if not os.path.isdir(jdir):
            print 'NO DIR.... making one for you'
            os.makedirs(jdir)


    if make_jsons:
        dh.MakeJsonMC(f,jdir,jcount,'AlgMC',mc_dl)

    ########################
    # Build the reco testing here 
    ########################
    dataset = dh.ConvertWC_InTPC_thresh('{}'.format(f),Charge_thresh)
    if len(dataset)==0:
	continue

    if make_jsons:
        dh.MakeJsonReco(f,jdir,jcount,'AlgSPT',mc_dl)

    #######
    labels = []

    labels = pc.walker(dataset,nn_dist,mincluster) # Runs clustering and returns labels list 

    datasetidx_holder = lh.label_to_idxholder(labels,mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  


    if make_jsons:
        dh.MakeJson_Objects(dataset,datasetidx_holder,labels,jdir,jcount,'Walker', mc_dl)

    d, labels = st.Track_Stitcher_epts(dataset,datasetidx_holder,labels,gap_dist,k_radius,min_pdelta,AE,min_clust_length )
    datasetidx_holder = lh.label_to_idxholder(labels,mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  

    #if make_jsons:
    #    dh.MakeJson_Objects(dataset,datasetidx_holder,labels,jdir,jcount,'Stitcher', mc_dl)


    # Now run T_S and see how things look... do we need a sweep... and if so what do we sweep on 
    showeridx_holder , trackidx_holder = tss.cluster_first_length(dataset,datasetidx_holder, 0.998, 20, 10)
    
    # Now do the volume sweep 
    ell = mr.make_extend_lines_list(dataset,trackidx_holder,labels)

    showeridx_holder, Strackidx_holder, labels = mr.TrackExtend_sweep_holders(dataset,showeridx_holder,labels,ell,5)
    trackidx_holder = trackidx_holder+Strackidx_holder

    showeridx_holder , Strackidx_holder = tss.cluster_lhull_cut(dataset,showeridx_holder,25)
    trackidx_holder = trackidx_holder+Strackidx_holder

    showeridx_holder , Strackidx_holder = tss.cluster_second_length(dataset,showeridx_holder, 0.002, 20, 20)
    trackidx_holder = trackidx_holder+Strackidx_holder

    showeridx_holder , Strackidx_holder = tss.cluster_second_length(dataset,showeridx_holder, 0.0002, 20, 20)
    trackidx_holder = trackidx_holder+Strackidx_holder

    showeridx_holder , Strackidx_holder = tss.clusterlength_sep(dataset,showeridx_holder,90)
    trackidx_holder = trackidx_holder+Strackidx_holder

    showeridx_holder , Strackidx_holder = tss.exiting_tracks_fid(dataset,showeridx_holder,3,3,3,3,3,3)
    #showeridx_holder , Strackidx_holder = tss.exiting_tracks_fid(dataset,showeridx_holder,10,10,10,10,10,10)
    trackidx_holder = trackidx_holder+Strackidx_holder

    #fidshoweridx_holder , fidtrackidx_holder = tss.exiting_tracks_fid(dataset,finshoweridx_holder,3,3,3,3,3,3)
    #fidshoweridx_holder , fidtrackidx_holder = tss.exiting_tracks_fid(dataset,finshoweridx_holder,1,1,1,1,1,1)
 

    #if make_jsons:
    #    dh.MakeJson_Objects(dataset,trackidx_holder,labels,jdir,jcount,'track', mc_dl)
        #dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'shower', mc_dl)

    # First make showers a little bigger


    start_Rtime = datetime.now()
    bloat_list = Es.bloat_showers_ROI(dataset, showeridx_holder , labels)
    bloat_dataset, roi_id_list = Erc.bloat_showers(f,dataset,showeridx_holder, bloat_list ,10, 1000.)

    # Run right NN on these
    start_Rtime = datetime.now()
    b_nn_dist = 2
    b_mincluster = 10
    # THere is a fast way to do this... cluster in the VOI
    #for ind in range(len(roi_id_list)):
        #ktempidx = [idx for idx in roi_id_list.index if idx==ind]
    bloat_labels = pc.walker(bloat_dataset,b_nn_dist,b_mincluster) # Runs clustering and returns labels list 
    bloatidx_holder = lh.label_to_idxholder(bloat_labels,b_mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  
    end_Rtime = datetime.now()
    delta_Rt = end_Rtime-start_Rtime
    print 'bloat TIME' ,str(delta_Rt.seconds)+' bloat_dataset'



    #bloat_labels = [ 5 for x in range(len(bloat_dataset))]
    #bloatidx_holder = [[ x for x in range(len(bloat_dataset))]]
    
    #if make_jsons:
    #    dh.MakeJson_Objects(bloat_dataset,bloatidx_holder,bloat_labels,jdir,jcount,'bloat_showers', mc_dl)


    #ell = mr.make_extend_lines_list(dataset,trackidx_holder,labels)
    bloat_showeridx_holder, bloat_trackidx_holder, bloat_labels = mr.TrackExtend_sweep_holders(bloat_dataset,bloatidx_holder,bloat_labels,ell,10)


    #bloat_showeridx_holder , bloat_trackidx_holder = tss.exiting_tracks_fid(bloat_dataset,bloatidx_holder,1,1,1,1,1,1)

    if make_jsons:
        dh.MakeJson_Objects(bloat_dataset,bloat_showeridx_holder,bloat_labels,jdir,jcount,'roi_hres', mc_dl)


    continue








    # Run right NN on these
    b_nn_dist = 3
    b_mincluster = 10
    blabels = pc.walker(bloat_dataset,b_nn_dist,b_mincluster) # Runs clustering and returns labels list 
    bdatasetidx_holder = lh.label_to_idxholder(blabels,b_mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  
    



    start_Rtime = datetime.now()
    ROI_list = Es.CorrelatedObjectsROI(dataset, showeridx_holder , labels)
    rebase_dataset = Erc.rebase_spts(f,dataset,showeridx_holder, ROI_list ,6, 1000.)
    rebase_labels = [ 5 for x in range(len(rebase_dataset))]
    rebaseidx_holder = [[ x for x in range(len(rebase_dataset))]]

    end_Rtime = datetime.now()
    delta_Rt = end_Rtime-start_Rtime
    print 'RTIME' ,str(delta_Rt.seconds)+' rebase_dataset'
    start_Rtime = datetime.now()

    if make_jsons:
        dh.MakeJson_Objects(rebase_dataset,rebaseidx_holder,rebase_labels,jdir,jcount,'REBASE_ROI', mc_dl)

    continue
