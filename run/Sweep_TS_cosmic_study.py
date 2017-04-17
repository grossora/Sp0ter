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
method_name = 'Stitch_cosmic_TS'
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
#k_radius = 20
k_radius = 10
min_pdelta = 5
#AE = .18
AE = .08
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
    jcount +=1
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


    jdir = os.getcwd() + '/Bjson/'+drun_dir+ '/'+str(jcount)   # This still is global and can be used later
    if make_jsons:
        if not os.path.isdir(jdir):
            print 'NO DIR.... making one for you'
            os.makedirs(jdir)

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
    #trackidx_holder = []
    #showeridx_holder = []

    #wlabels = pc.walker(dataset,8,20) # Runs clustering and returns labels list 
    labels = pc.walker(dataset,nn_dist,mincluster) # Runs clustering and returns labels list 

    datasetidx_holder = lh.label_to_idxholder(labels,mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  


    if make_jsons:
        dh.MakeJson_Objects(dataset,datasetidx_holder,labels,jdir,jcount,'Walker', mc_dl)

    d, labels = st.Track_Stitcher_epts(dataset,datasetidx_holder,labels,gap_dist,k_radius,min_pdelta,AE,min_clust_length )
    datasetidx_holder = lh.label_to_idxholder(labels,mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  

    if make_jsons:
        dh.MakeJson_Objects(dataset,datasetidx_holder,labels,jdir,jcount,'Stitcher', mc_dl)


    # Now run T_S and see how things look... do we need a sweep... and if so what do we sweep on 
    fshoweridx_holder , ftrackidx_holder = tss.cluster_first_length(dataset,datasetidx_holder, 0.998, 20, 10)
    # Use the tracks to make volumes

    
    
    ell = mr.make_extend_lines_list(dataset,ftrackidx_holder,labels)
    Sshoweridx_holder, Strackidx_holder, labels = mr.TrackExtend_sweep_holders(dataset,fshoweridx_holder,labels,ell,5)

    lshoweridx_holder , ltrackidx_holder = tss.cluster_lhull_cut(dataset,Sshoweridx_holder,25)
    csshoweridx_holder , cstrackidx_holder = tss.cluster_second_length(dataset,lshoweridx_holder, 0.002, 20, 20)
    asshoweridx_holder , astrackidx_holder = tss.cluster_second_length(dataset,csshoweridx_holder, 0.0002, 20, 20)

    finshoweridx_holder , fintrackidx_holder = tss.clusterlength_sep(dataset,asshoweridx_holder,90)

    fidshoweridx_holder , fidtrackidx_holder = tss.exiting_tracks_fid(dataset,finshoweridx_holder,10,10,10,10,10,10)
    #fidshoweridx_holder , fidtrackidx_holder = tss.exiting_tracks_fid(dataset,finshoweridx_holder,3,3,3,3,3,3)
    #fidshoweridx_holder , fidtrackidx_holder = tss.exiting_tracks_fid(dataset,finshoweridx_holder,1,1,1,1,1,1)
 

    if make_jsons:
        dh.MakeJson_Objects(dataset,fidtrackidx_holder+fintrackidx_holder+astrackidx_holder+cstrackidx_holder+ftrackidx_holder+ltrackidx_holder+Strackidx_holder,labels,jdir,jcount,'track', mc_dl)
        dh.MakeJson_Objects(dataset,fidshoweridx_holder,labels,jdir,jcount,'shower', mc_dl)


    start_Rtime = datetime.now()

    ROI_list = Es.CorrelatedObjectsROI(dataset, fidshoweridx_holder , labels)
    rebase_dataset = Erc.rebase_spts(f,dataset,fidshoweridx_holder, ROI_list ,6, 1000.)
    rebase_labels = [ 5 for x in range(len(rebase_dataset))]
    rebaseidx_holder = [[ x for x in range(len(rebase_dataset))]]

    end_Rtime = datetime.now()
    delta_Rt = end_Rtime-start_Rtime
    print 'RTIME' ,str(delta_Rt.seconds)+' rebase_dataset'
    start_Rtime = datetime.now()

    if make_jsons:
        dh.MakeJson_Objects(rebase_dataset,rebaseidx_holder,rebase_labels,jdir,jcount,'REBASE_ROI', mc_dl)


    showeridx_holder , fidtrackidx_holder = tss.exiting_tracks_fid(rebase_dataset,rebaseidx_holder,1,1,1,1,1,1)
    if make_jsons:
        dh.MakeJson_Objects(rebase_dataset,showeridx_holder,rebase_labels,jdir,jcount,'REBASE_ROI_shower', mc_dl)
    continue

    
    if make_jsons:
        dh.MakeJson_Objects(dataset,ftrackidx_holder+Strackidx_holder+ltrackidx_holder,labels,jdir,jcount,'track', mc_dl)
        #dh.MakeJson_Objects(dataset,ftrackidx_holder+trackidx_holder,labels,jdir,jcount,'track', mc_dl)
        dh.MakeJson_Objects(dataset,lshoweridx_holder,labels,jdir,jcount,'shower', mc_dl)
    continue
    
    






    for gap_dist in xrange(30,150,30):
        for k_radius in xrange(10,40,10):
            for angle_error in xrange(8,25,8):
                for min_pdelta in xrange(2,5,3):
		    # Make a fresh labels and dataholder 
                    labels = [ x for x in wlabels]
                    datasetidx_holder = [ x for x in wdatasetidx_holder]

	            # STICH :  dataset,datasetidx_holder,labels,gap_dist,k_radius,min_pdelta, angle_error,min_clust_length
		    AE =  angle_error/100.
                    d, labels = st.Track_Stitcher_epts(dataset,datasetidx_holder,labels,gap_dist,k_radius,min_pdelta,AE,min_clust_length )
                    #d, labels = st.Track_Stitcher_epts(dataset,datasetidx_holder,labels,100,20,2.0,0.16,10 )
                    datasetidx_holder = lh.label_to_idxholder(labels,mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  
		    Ea.Ana_Object(dataset, datasetidx_holder, jcount, mc_dl, filename='{}/AnaCosmic_object_gap_{}_krad_{}_ae_{}_pdelta_{}_'.format(method_name,str(gap_dist),str(k_radius),str(angle_error),str(min_pdelta) ))

	            #Ea.Ana_Object_photons(dataset, datasetidx_holder, jcount,mcinfo,mcqdep, filename = '{}/photon_ana_obj_nn_{}_mspt_{}'.format(method_name,str(nn_dist),str(mincluster)))
                    if make_jsons:
                        dh.MakeJson_Objects(dataset,datasetidx_holder,labels,jdir,jcount,'Alg_g{}_kr{}_ae{}_pd{}'.format(str(gap_dist),str(k_radius),str(angle_error),str(min_pdelta)), mc_dl)

		print 'AT THE END for gap={} and krad={} and ae={} and pdelta={}'.format(str(gap_dist),str(k_radius),str(angle_error),str(min_pdelta) )


