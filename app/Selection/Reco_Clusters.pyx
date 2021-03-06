import numpy as np 

import lib.Clustering.protocluster as pc
import lib.TS_Qual.ts_separation as tss
import lib.Merging.stitcher as st
import lib.Merging.merger as mr
import lib.SParams.selpizero as selpz

import lib.utility.Utils.datahandle as dh
import lib.utility.Utils.labelhanle as lh
import lib.utility.Utils.mchandle as mh
import lib.utility.Geo_Utils.axisfit as axfi

import lib.Selection.Select_NeutralPion as Es 
import lib.Selection.ROI_Cluster as Erc

from datetime import datetime


##################################
# ----- list of function ------- #
# --- Reco_FirstPass 

# --- Reco_Showers_FirstStage_2 
# --- Reco_Showers_FirstStage 
# --- Reco_trackshower 
# --- Reco_showerReCluster 
# --- rebase_showers_reco 
# --- rebase_Full_reco 

##################################

def Reco_FirstPass(dataset , mc_dl , jdir, int jcount , make_jsons=False):
    cdef int mincluster, ts_fcl_minsize,min_kept_size, ts_scl_minsize
    cdef float nn_dist, min_clust_length, gap_dist, k_radius, min_pdelta, AE, vari_0,ts_fcl_length, doca_sweep, lcmin, vari_1, ts_scl_length, cmin_length

    # ``````````````````````
    #        Params
    # ``````````````````````
    
    #---MinCluster---
    mincluster = 20

    #---Birch-----
    nn_dist = 2
    #birch_leaf =  1000
    birch_leaf =  10000
    birch_mincluster = 20
    #birch_mincluster = 20


    #---stitcher-----
    ##min_clust_length = 10
    edge_dist = 1
    stitch_mincluster = 100

    #---cluster_first_length-----
    vari_0 = 0.9985
    #vari_0 = 0.998
    ts_fcl_length = 20
    ts_fcl_minsize = 10

    #---doca sweep-----
    doca_sweep = 10
    #doca_sweep = 5

    #---lc length cut-----
    lcmin = 25

    #---cluster_first_length-----
    vari_1 = 0.998
    ts_scl_length = 20
    ts_scl_minsize = 10

    #---cluster hlength cut-----
    cmin_length =80 
    #cmin_length =90 

    #---shower nn Brute merge-----
    snn_dist = 2

    # ``````````````````````
    # ``````````````````````
    ##################################################
    start = datetime.now()
    ##################################################
    #===Run the walker===
    labels = pc.birch_clust(dataset,nn_dist,birch_leaf)
    datasetidx_holder = lh.label_to_idxholder(labels,birch_mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  

    ##################################################
    end = datetime.now()
    print '#$$$$$$$$$$$$$$$$$$$$$$$$$$$$ birch cluster' 
    print end-start
    start = datetime.now()
    ##################################################

    if make_jsons:
        dh.MakeJson_Objects(dataset,datasetidx_holder,labels,jdir,jcount,'Birch', mc_dl)

    #===Run the Stitcher===
    d, labels = st.Track_Stitcher_nn(dataset,datasetidx_holder,labels,edge_dist)
    datasetidx_holder = lh.label_to_idxholder(labels,stitch_mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  
    ##################################################
    end = datetime.now()
    print '#$$$$$$$$$$$$$$$$$$$$$$$$$$$$track NN  stitch  cluster' 
    print end-start
    start = datetime.now()
    ##################################################
    if make_jsons:
        dh.MakeJson_Objects(dataset,datasetidx_holder,labels,jdir,jcount,'Stitcher', mc_dl)

    #===Run trackshower_length_sep===
    # Now run T_S and see how things look... do we need a sweep... and if so what do we sweep on 


    showeridx_holder , trackidx_holder = tss.clusterlength_sep(dataset,datasetidx_holder,cmin_length)
    ##################################################
    end = datetime.now()
    print '#$$$$$$$$$$$$$$$$$$$$$$$$$$$$track length _sep  ' 
    print end-start
    start = datetime.now()
    ##################################################
    #showeridx_holder , trackidx_holder = tss.clusterlength_sep(dataset,showeridx_holder,cmin_length)
    #showeridx_holder , trackidx_holder = tss.cluster_first_length(dataset,datasetidx_holder, vari_0,ts_fcl_length, ts_fcl_minsize)
    if make_jsons:
        dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'Shower_clsuter_fistL', mc_dl)
        dh.MakeJson_Objects(dataset,trackidx_holder,labels,jdir,jcount,'Track_clsuter_fistL', mc_dl)

    
    #===Run the sweep===
    ell = mr.make_extend_lines_list(dataset,trackidx_holder,labels)
    # Now do the volume sweep 
    showeridx_holder, Strackidx_holder, labels = mr.TrackExtend_sweep_holders(dataset,showeridx_holder,labels,ell,doca_sweep)
    trackidx_holder = trackidx_holder+Strackidx_holder
    ##################################################
    end = datetime.now()
    print '#$$$$$$$$$$$$$$$$$$$$$$$$$$$$track sweep   ' 
    print end-start
    start = datetime.now()
    ##################################################

    #===Run trackshower_sep===
    #showeridx_holder , Strackidx_holder = tss.clusterlength_sep(dataset,showeridx_holder,cmin_length)
    showeridx_holder , Strackidx_holder = tss.cluster_first_length(dataset,showeridx_holder, vari_0,ts_fcl_length, ts_fcl_minsize)
    #showeridx_holder , Strackidx_holder = tss.cluster_first_length(dataset,datasetidx_holder, vari_0,ts_fcl_length, ts_fcl_minsize)
    trackidx_holder = trackidx_holder+Strackidx_holder

    ##################################################
    end = datetime.now()
    print '#$$$$$$$$$$$$$$$$$$$$$$$$$$$$track first length   ' 
    print end-start
    start = datetime.now()
    ##################################################

    #===Run Trackshower to remove exiting objects
    showeridx_holder , Strackidx_holder = tss.exiting_tracks_fid(dataset, showeridx_holder , fxlo=-100000, fxhi=-100000, fylo=1, fyhi=1, fzlo=0, fzhi=0 )
    trackidx_holder = trackidx_holder+Strackidx_holder

    #===Run Trackshower to remove exiting objects
    strayidx_holder, showeridx_holder, rlabels = tss.stray_charge_removal(dataset,showeridx_holder,labels,1000000000 , 50)
    trackidx_holder = trackidx_holder+strayidx_holder

    
    ##################################################
    end = datetime.now()
    print '#$$$$$$$$$$$$$$$$$$$$$$$$$$$$track  exit and stray   ' 
    print end-start
    start = datetime.now()
    ##################################################
    #===Run Merging with shower clusters 
    #labels = mr.wpca_merge(dataset,labels,showeridx_holder,0.35, 40)
    #labels = wpca_merge(dataset,labels,showeridx_holder,crit_merge_angle, float wt_dist)
   

    # Remake the labels for the showers
    # This is just to make things pretty


    if True:
        dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'lastShowers', mc_dl)
        dh.MakeJson_Objects(dataset,trackidx_holder,labels,jdir,jcount,'lastTracks', mc_dl)

    # Now we are doing a reclustering
    #showeridx_holder, labels = st.Shower_Brute_nn(dataset,showeridx_holder,labels,snn_dist)

    showerlabels = lh.unique_relabel(labels,showeridx_holder)

    if make_jsons:
        dh.MakeJson_Objects(dataset,showeridx_holder,showerlabels,jdir,jcount,'FinalShowers', mc_dl)
        dh.MakeJson_Objects(dataset,trackidx_holder,labels,jdir,jcount,'FinalTracks', mc_dl)


    return trackidx_holder , showeridx_holder , labels










###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################
###############################################################################





def Reco_May_Showers(dataset , mc_dl , jdir, int jcount , make_jsons=False):
    cdef int mincluster, ts_fcl_minsize,min_kept_size, ts_scl_minsize
    cdef float nn_dist, min_clust_length, gap_dist, k_radius, min_pdelta, AE, vari_0,ts_fcl_length, doca_sweep, lcmin, vari_1, ts_scl_length, cmin_length
    # ``````````````````````
    #        Params
    # ``````````````````````
    
    #---MinCluster---
    mincluster = 20

    #---Birch-----
    nn_dist = 2
    #birch_leaf =  1000
    birch_leaf =  10000


    #---stitcher-----
    ##min_clust_length = 10
    edge_dist = 1

    #---cluster_first_length-----
    vari_0 = 0.998
    ts_fcl_length = 20
    ts_fcl_minsize = 10

    #---stitcher-----
    doca_sweep = 10
    #doca_sweep = 5

    #---lc length cut-----
    lcmin = 25

    #---cluster_first_length-----
    vari_1 = 0.998
    ts_scl_length = 20
    ts_scl_minsize = 10

    #---cluster hlength cut-----
    cmin_length =80 
    #cmin_length =90 

    # ``````````````````````
    # ``````````````````````

    #===Run the walker===
    #labels = pc.walker(dataset,nn_dist,mincluster) # Runs clustering and returns labels list 
    labels = pc.birch_clust(dataset,nn_dist,birch_leaf)
    datasetidx_holder = lh.label_to_idxholder(labels,mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  

    if make_jsons:
        dh.MakeJson_Objects(dataset,datasetidx_holder,labels,jdir,jcount,'Birch', mc_dl)

    #===Run the Stitcher===
    d, labels = st.Track_Stitcher_nn(dataset,datasetidx_holder,labels,edge_dist)
    datasetidx_holder = lh.label_to_idxholder(labels,200) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  
    if make_jsons:
        dh.MakeJson_Objects(dataset,datasetidx_holder,labels,jdir,jcount,'Stitcher', mc_dl)

    #===Run the Stitcher===
    # Now run T_S and see how things look... do we need a sweep... and if so what do we sweep on 
    showeridx_holder , trackidx_holder = tss.cluster_first_length(dataset,datasetidx_holder, vari_0,ts_fcl_length, ts_fcl_minsize)
    if make_jsons:
        dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'Shower_clsuter_fistL', mc_dl)
        dh.MakeJson_Objects(dataset,trackidx_holder,labels,jdir,jcount,'Track_clsuter_fistL', mc_dl)

    #===Run the sweep===
   # ell = mr.make_extend_lines_list(dataset,trackidx_holder,labels)
    # Now do the volume sweep 
    #showeridx_holder, Strackidx_holder, labels = mr.TrackExtend_sweep_holders(dataset,showeridx_holder,labels,ell,doca_sweep)
    #trackidx_holder = trackidx_holder+Strackidx_holder

    #===Run the sweep===
    #showeridx_holder , Strackidx_holder = tss.cluster_lhull_cut(dataset,showeridx_holder,lcmin)
    #trackidx_holder = trackidx_holder+Strackidx_holder

    #showeridx_holder , Strackidx_holder = tss.cluster_second_length(dataset,showeridx_holder, vari_1, ts_scl_length, ts_scl_minsize)
    #trackidx_holder = trackidx_holder+Strackidx_holder

    #if make_jsons:
    #    dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'second_cut', mc_dl)

    showeridx_holder , Strackidx_holder = tss.clusterlength_sep(dataset,showeridx_holder,cmin_length)
    trackidx_holder = trackidx_holder+Strackidx_holder

    if make_jsons:
        dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'FinalShowers', mc_dl)
        dh.MakeJson_Objects(dataset,trackidx_holder,labels,jdir,jcount,'FinalTracks', mc_dl)

    return trackidx_holder , showeridx_holder , labels






##################################
# ----- list of function ------- #

# --- Reco_Showers_FirstStage_2 
# --- Reco_Showers_FirstStage 
# --- Reco_trackshower 
# --- Reco_showerReCluster 
# --- rebase_showers_reco 
# --- rebase_Full_reco 

##################################

def Reco_Showers_FirstStage_2(dataset , mc_dl , jdir, int jcount , make_jsons=False):
    cdef int mincluster, ts_fcl_minsize,min_kept_size, ts_scl_minsize
    cdef float nn_dist, min_clust_length, gap_dist, k_radius, min_pdelta, AE, vari_0,ts_fcl_length, doca_sweep, lcmin, vari_1, ts_scl_length, cmin_length
    # ``````````````````````
    #        Params
    # ``````````````````````

    #---Walker-----
    mincluster = 20
    nn_dist = 8

    #---stitcher-----
    min_clust_length = 10
    gap_dist = 120
    k_radius = 10
    min_pdelta = 5
    AE = .08

    #---cluster_first_length-----
    vari_0 = 0.998
    ts_fcl_length = 20
    ts_fcl_minsize = 10

    #---stitcher-----
    doca_sweep = 10
    #doca_sweep = 5

    #---lc length cut-----
    lcmin = 25

    #---cluster_first_length-----
    vari_1 = 0.998
    ts_scl_length = 20
    ts_scl_minsize = 10

    #---cluster hlength cut-----
    cmin_length =90 

    # ``````````````````````
    # ``````````````````````

    #===Run the walker===
    labels = pc.walker(dataset,nn_dist,mincluster) # Runs clustering and returns labels list 
    datasetidx_holder = lh.label_to_idxholder(labels,mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  

    if make_jsons:
        dh.MakeJson_Objects(dataset,datasetidx_holder,labels,jdir,jcount,'Walker', mc_dl)

    #===Run the Stitcher===
    d, labels = st.Track_Stitcher_epts(dataset,datasetidx_holder,labels,gap_dist,k_radius,min_pdelta,AE,min_clust_length )
    datasetidx_holder = lh.label_to_idxholder(labels,mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  
    if make_jsons:
        dh.MakeJson_Objects(dataset,datasetidx_holder,labels,jdir,jcount,'Stitcher', mc_dl)

    #===Run the Stitcher===
    # Now run T_S and see how things look... do we need a sweep... and if so what do we sweep on 
    showeridx_holder , trackidx_holder = tss.cluster_first_length(dataset,datasetidx_holder, vari_0,ts_fcl_length, ts_fcl_minsize)
    if make_jsons:
        dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'Shower_clsuter_fistL', mc_dl)
        dh.MakeJson_Objects(dataset,trackidx_holder,labels,jdir,jcount,'Track_clsuter_fistL', mc_dl)

    #===Run the sweep===
    ell = mr.make_extend_lines_list(dataset,trackidx_holder,labels)
    # Now do the volume sweep 
    showeridx_holder, Strackidx_holder, labels = mr.TrackExtend_sweep_holders(dataset,showeridx_holder,labels,ell,doca_sweep)
    trackidx_holder = trackidx_holder+Strackidx_holder

    #===Run the sweep===
    showeridx_holder , Strackidx_holder = tss.cluster_lhull_cut(dataset,showeridx_holder,lcmin)
    trackidx_holder = trackidx_holder+Strackidx_holder

    #showeridx_holder , Strackidx_holder = tss.cluster_second_length(dataset,showeridx_holder, vari_1, ts_scl_length, ts_scl_minsize)
    #trackidx_holder = trackidx_holder+Strackidx_holder

    #if make_jsons:
    #    dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'second_cut', mc_dl)

    showeridx_holder , Strackidx_holder = tss.clusterlength_sep(dataset,showeridx_holder,cmin_length)
    trackidx_holder = trackidx_holder+Strackidx_holder

    if make_jsons:
        dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'FinalShowers', mc_dl)
        #dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'clusterlength_cut', mc_dl)

    return trackidx_holder , showeridx_holder , labels, ell


def Reco_Showers_FirstStage_data(dataset , mc_dl , jdir, int jcount , make_jsons=False):
    cdef int mincluster, ts_fcl_minsize,min_kept_size, ts_scl_minsize
    cdef float nn_dist, min_clust_length, gap_dist, k_radius, min_pdelta, AE, vari_0,ts_fcl_length, doca_sweep, lcmin, vari_1, ts_scl_length, cmin_length
    # ``````````````````````
    #        Params
    # ``````````````````````

    #---Walker-----
    mincluster = 20
    nn_dist = 8

    #---stitcher-----
    min_clust_length = 10
    gap_dist = 120
    k_radius = 10
    min_pdelta = 5
    AE = .08

    #---cluster_first_length-----
    vari_0 = 0.998
    ts_fcl_length = 20
    ts_fcl_minsize = 10

    #---stitcher-----
    doca_sweep = 10
    #doca_sweep = 5

    #---lc length cut-----
    lcmin = 25

    #---cluster_first_length-----
    vari_1 = 0.998
    ts_scl_length = 20
    ts_scl_minsize = 10

    #---cluster hlength cut-----
    cmin_length =90 

    # ``````````````````````
    # ``````````````````````

    #===Run the walker===
    labels = pc.walker(dataset,nn_dist,mincluster) # Runs clustering and returns labels list 
    datasetidx_holder = lh.label_to_idxholder(labels,mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  


    if make_jsons:
        dh.MakeJson_Objects(dataset,datasetidx_holder,labels,jdir,jcount,'Walker', mc_dl)

    #===Run the Stitcher===
    d, labels = st.Track_Stitcher_epts(dataset,datasetidx_holder,labels,gap_dist,k_radius,min_pdelta,AE,min_clust_length )
    datasetidx_holder = lh.label_to_idxholder(labels,mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  
    if make_jsons:
        dh.MakeJson_Objects(dataset,datasetidx_holder,labels,jdir,jcount,'Stitcher', mc_dl)

    #===Run the Stitcher===
    # Now run T_S and see how things look... do we need a sweep... and if so what do we sweep on 
    #showeridx_holder , trackidx_holder = tss.cluster_first_length(dataset,datasetidx_holder, vari_0,ts_fcl_length, ts_fcl_minsize)
    #if make_jsons:
    #    dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'Shower_clsuter_fistL', mc_dl)
    #    dh.MakeJson_Objects(dataset,trackidx_holder,labels,jdir,jcount,'Track_clsuter_fistL', mc_dl)

    #===Run the sweep===
    #ell = mr.make_extend_lines_list(dataset,trackidx_holder,labels)
    # Now do the volume sweep 
    #showeridx_holder, Strackidx_holder, labels = mr.TrackExtend_sweep_holders(dataset,showeridx_holder,labels,ell,doca_sweep)
    #trackidx_holder = trackidx_holder+Strackidx_holder

    #===Run the sweep===
    #showeridx_holder , Strackidx_holder = tss.cluster_lhull_cut(dataset,showeridx_holder,lcmin)
    #trackidx_holder = trackidx_holder+Strackidx_holder

    #showeridx_holder , Strackidx_holder = tss.cluster_second_length(dataset,showeridx_holder, vari_1, ts_scl_length, ts_scl_minsize)
    #trackidx_holder = trackidx_holder+Strackidx_holder

    #if make_jsons:
    #    dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'second_cut', mc_dl)

    #showeridx_holder , Strackidx_holder = tss.clusterlength_sep(dataset,showeridx_holder,cmin_length)
    #trackidx_holder = trackidx_holder+Strackidx_holder

    #if make_jsons:
        #dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'FinalShowers', mc_dl)
        #dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'clusterlength_cut', mc_dl)

    return True 
    #return trackidx_holder , showeridx_holder , labels, ell







  
#################################################################################
#################################################################################

#############################################################################################################
########################    Reclustering and merging the shower objects  
#############################################################################################################


def Reco_showerReCluster(dataset,showeridx_holder,labels,mc_dl,jdir,jcount,make_jsons):

    min_spts = 20
    nn_dist = 8

    # First we need to get all the dataset datapoints?
    # First we need to get convext hulls? 
    
    # Start simple and just use points from scratch  

    # put all of the points from the showers into a holder
    ret_showeridx_holder = []
    
    # This will be a list that maps back to the original dataset idx
    mapback_idx = [item for sublist in showeridx_holder for item in sublist]
 
    # Make a dataset to cluster
    temp_dataset = [ dataset[i] for i in mapback_idx]
    # The labels will be with respect to the temp... hence the need for the map back
    templabels = pc.crawlernn(temp_dataset,nn_dist,min_spts) # Runs clustering and returns labels list 
    # Make a holder 
    temp_datasetidx_holder = lh.label_to_idxholder(templabels,min_spts)

    # Now we have them clustered....
    # lets return back the new showeridx_holder and labels 
    newlabelcounter = max(labels)

    for clust in temp_datasetidx_holder:
        newlabelcounter+=1
        temp_mapback_holder = []
        for hit in clust:
            temp_mapback_holder.append(mapback_idx[hit])
            labels[mapback_idx[hit]] = newlabelcounter 
        ret_showeridx_holder.append(temp_mapback_holder)

    return ret_showeridx_holder, labels
    




def rebase_showers_reco(f, dataset,showeridx_holder,track_ell,labels,mc_dl , jdir,int jcount , make_jsons=False):
    # ``````````````````````
    #        Params
    # ``````````````````````
    
    cdef int mincluster,b_mincluster,ts_fcl_minsize,min_kept_size
    cdef float bloat_q_Thresh,b_nn_dist,bloat_doca,lcmin,vari_0,ts_fcl_length,dist_thresh,min_obj_length,min_fkp,crit_angle,merge_dist

    #---bloat-----
    #mincluster = 10
    mincluster = 20
    bloat_q_Thresh = 100.
    #bloat_q_Thresh = 800

    #---crawler-----
    b_nn_dist = 4.
    b_mincluster = 10

    #---sweep-----
    bloat_doca = 10.

    #---lc length cut-----
    lcmin = 10.

    #---cluster_first_length-----
    vari_0 = 0.998
    ts_fcl_length = 10.
    ts_fcl_minsize = 10
    #ts_fcl_length = 5
    #ts_fcl_minsize = 5

    #---consensus cut-----
    dist_thresh  = 0.8
    min_obj_length = 15.
    min_fkp = 0.8
    min_kept_size =10

    #---Merging ---
    crit_angle = .15
    merge_dist = 40.
    # ``````````````````````
    # ``````````````````````
    # ``````````````````````

    bloat_list = Es.bloat_showers_ROI(dataset, showeridx_holder , labels)
    # If Bloat list ==0 we move on
    if len(bloat_list)==0:
        # Chitty hack
        return dataset, showeridx_holder,showeridx_holder, labels

    bloat_dataset, roi_id_list = Erc.bloat_showers(f,dataset,showeridx_holder, bloat_list ,mincluster, bloat_q_Thresh)
    # dataset isnt needed

    bloat_labels = pc.crawlernn(bloat_dataset,b_nn_dist,b_mincluster) # Runs clustering and returns labels list 
    bloatidx_holder = lh.label_to_idxholder(bloat_labels,b_mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  

    bloat_showeridx_holder, bloat_trackidx_holder, bloat_labels = mr.TrackExtend_sweep_holders(bloat_dataset,bloatidx_holder,bloat_labels,track_ell,bloat_doca)

    #bloat_showeridx_holder , bloat_trackidx_holder = tss.exiting_tracks_fid(bloat_dataset,bloatidx_holder,1,1,1,1,1,1)

    #if make_jsons:
    #    dh.MakeJson_Objects(bloat_dataset,bloat_showeridx_holder,bloat_labels,jdir,jcount,'roi_hres', mc_dl)

    # Need to remove straight tracks 
    bloat_showeridx_holder , tbloat_trackidx_holder = tss.cluster_lhull_cut(bloat_dataset,bloat_showeridx_holder,lcmin)
    bloat_trackidx_holder = bloat_trackidx_holder+tbloat_trackidx_holder

    bloat_showeridx_holder , tbloat_trackidx_holder = tss.cluster_first_length(bloat_dataset,bloat_showeridx_holder, vari_0, ts_fcl_length, ts_fcl_minsize)
    bloat_trackidx_holder = bloat_trackidx_holder+tbloat_trackidx_holder

    bloat_showeridx_holder, tbloat_trackidx_holder = tss.line_consensus(bloat_dataset,bloat_showeridx_holder,dist_thresh, min_obj_length ,min_fkp,min_kept_size)
    bloat_trackidx_holder = bloat_trackidx_holder+tbloat_trackidx_holder

    # take the shower and run merging
    plabels = mr.wpca_merge(bloat_dataset,bloat_labels,bloat_showeridx_holder,crit_angle,merge_dist)
    #if make_jsons:
    #    dh.MakeJson_Objects(bloat_dataset,bloat_showeridx_holder,plabels,jdir,jcount,'hires_merge', mc_dl)

    return bloat_dataset, bloat_trackidx_holder , bloat_showeridx_holder , plabels



#############################################################################################################
#############################################################################################################
######################    OLD DEPRICATED THINGS THAT WILL EVENTUALLY BE DELETED #############################
#############################################################################################################
#############################################################################################################
'''

#################################################################################
def Reco_trackshower( dataset, mc_dl , jdir, int jcount , make_jsons=False,timer=False):
    # Need some type of config 
    min_spts = 20
    nn_dist = 6
    # This will take in a dataset and file information
    # Returns a rebased dataset, clustered index holder for showers, labels :  with candidate shower events 
    ########################
    # cluster the event into something 
    ########################
    time_v = []  #  Walker, js, Stitch, js, cluster_sep, 2js, extend, 2js, stray, js
    start = datetime.now()


    start_RG_2 = datetime.now()
    #labels = pc. kdtree_radius(dataset,min_spts) # Runs clustering and returns labels list 
    labels = pc.walker(dataset,nn_dist,min_spts) # Runs clustering and returns labels list 
    end_RG_2 = datetime.now()
    delta_RG_2 = end_RG_2-start_RG_2
    print '####################################  walker time :' , str(delta_RG_2.seconds)

    datasetidx_holder = lh.label_to_idxholder(labels,min_spts) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  
    ########################
    # Make Jsons
    ########################
    if make_jsons:
        dh.MakeJson(dataset,labels,jdir,jcount,'Alg1_first_pass',mc_dl)
    #######################
    #  Stitch track like clusters
    #######################
    start_RG_3 = datetime.now()
    d, labels = st.Track_Stitcher_epts(dataset,datasetidx_holder,labels,100,20,2.0,0.16,10 )
    end_RG_3 = datetime.now()
    delta_RG_3 = end_RG_3-start_RG_3
    print '####################################  stitch time :' ,str(delta_RG_3.seconds)
    # STICH :  dataset,datasetidx_holder,labels,gap_dist,k_radius,min_pdelta, angle_error,min_clust_length
    datasetidx_holder = lh.label_to_idxholder(labels,min_spts) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  
    ########################
    # Make Jsons
    ########################
    if make_jsons:
        dh.MakeJson_Objects(dataset,datasetidx_holder,labels,jdir,jcount,'Alg2_stitch_obj', mc_dl)
    ###########################
    # track Shower Seperation 
    # based on length 
    ###########################
    #showeridx_holder, trackidx_holder  =tss.clusterlength_sep(dataset,datasetidx_holder,50)
    showeridx_holder, trackidx_holder  =tss.cluster_lhull_length_cut(dataset,datasetidx_holder,50)
    #showeridx_holder, trackidx_holder  =tss.clusterspread(dataset,datasetidx_holder,5000,50)

    ########################
    # Make Jsons
    ########################
    if make_jsons:
        dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'Shower_len_obj',mc_dl)
        dh.MakeJson_Objects(dataset,trackidx_holder,labels,jdir,jcount,'Track_len_obj',mc_dl)
    ########################
    # Sweep the shower objects using track volumes
    ########################
    start_RG_4 = datetime.now()
    ell = mr.make_extend_lines_list(dataset,trackidx_holder,labels)
    #ell = mr.make_extend_lines_list(dataset,trackidx_holder,labels, 10)

    showeridx_holder, Strackidx_holder, labels = mr.TrackExtend_sweep_holders(dataset,showeridx_holder,labels,ell,10)
    end_RG_4 = datetime.now()
    delta_RG_4 = end_RG_4-start_RG_4
    print '####################################  merging time :' ,str(delta_RG_4.seconds)
    
    #showeridx_holder, Strackidx_holder, labels = mr.TrackExtend_sweep_holders(dataset,showeridx_holder,labels,ell,5)
    #datasetidx_holder = lh.label_to_idxholder(labels,25) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  

    ########################
    # Make Jsons
    ########################
    if make_jsons:
        dh.MakeJson_Objects(dataset,Strackidx_holder,labels,jdir,jcount,'Alg3_T_sweep_obj', mc_dl)
        dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'Alg3_S_sweep_obj', mc_dl)
    # cut out showers based on PCA cuts 
    ########################

    out_shower_holder , in_tracks_holder = tss.clusterspreadR(dataset,showeridx_holder, vari_lo=0.99, vari_hi=1, moment = 0 )
    out2_shower_holder , in2_tracks_holder = tss.clusterspreadR(dataset,out_shower_holder, vari_lo=0.0, vari_hi=0.002, moment = 1 )
    
    ########################
    # Make Jsons
    ########################
    if make_jsons:
        dh.MakeJson_Objects(dataset,out2_shower_holder,labels,jdir,jcount,'PCA_shower_obj', mc_dl)
        dh.MakeJson_Objects(dataset,in2_tracks_holder+in_tracks_holder,labels,jdir,jcount,'PCA_track_obj', mc_dl)

    #if timer: 
    #    return trackidx_holder , out2_shower_holder , labels, time_v
    #return trackidx_holder , out2_shower_holder , labels



    # Carefull with keeping objects
    strayidx_holder, showeridx_holder, rlabels = tss.stray_charge_removal(dataset,showeridx_holder,labels,100 , 30)
    #strayidx_holder, remainidx_holder, rlabels = tss.stray_charge_removal(dataset,showeridx_holder,labels,100 , 30)
    ########################
    # Make Jsons
    ########################
    if make_jsons:
        dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'remain_shower_obj', mc_dl)
return trackidx_holder , showeridx_holder , labels 



def Reco_Showers_FirstStage(dataset , mc_dl , jdir, jcount , make_jsons=False):
    # ``````````````````````
    #        Params
    # ``````````````````````

    #---Walker-----
    mincluster = 20
    nn_dist = 8

    #---stitcher-----
    min_clust_length = 10
    gap_dist = 120
    k_radius = 10
    min_pdelta = 5
    AE = .08

    #---cluster_first_length-----
    vari_0 = 0.998
    ts_fcl_length = 20
    ts_fcl_minsize = 10

    #---stitcher-----
    doca_sweep = 5

    #---lc length cut-----
    lcmin = 25

    #---cluster_first_length-----
    vari_1 = 0.998
    ts_scl_length = 20
    ts_scl_minsize = 10

    #---cluster hlength cut-----
    cmin_length =90 

    # ``````````````````````
    # ``````````````````````

    #===Run the walker===
    labels = pc.walker(dataset,nn_dist,mincluster) # Runs clustering and returns labels list 
    datasetidx_holder = lh.label_to_idxholder(labels,mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  

    if make_jsons:
        dh.MakeJson_Objects(dataset,datasetidx_holder,labels,jdir,jcount,'Walker', mc_dl)

    #===Run the Stitcher===
    d, labels = st.Track_Stitcher_epts(dataset,datasetidx_holder,labels,gap_dist,k_radius,min_pdelta,AE,min_clust_length )
    datasetidx_holder = lh.label_to_idxholder(labels,mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  

    #===Run the Stitcher===
    # Now run T_S and see how things look... do we need a sweep... and if so what do we sweep on 
    showeridx_holder , trackidx_holder = tss.cluster_first_length(dataset,datasetidx_holder, vari_0,ts_fcl_length, ts_fcl_minsize)

    #===Run the sweep===
    ell = mr.make_extend_lines_list(dataset,trackidx_holder,labels)
    # Now do the volume sweep 
    showeridx_holder, Strackidx_holder, labels = mr.TrackExtend_sweep_holders(dataset,showeridx_holder,labels,ell,doca_sweep)
    trackidx_holder = trackidx_holder+Strackidx_holder

    #===Run the sweep===
    showeridx_holder , Strackidx_holder = tss.cluster_lhull_cut(dataset,showeridx_holder,lcmin)
    trackidx_holder = trackidx_holder+Strackidx_holder

    showeridx_holder , Strackidx_holder = tss.cluster_second_length(dataset,showeridx_holder, vari_1, ts_scl_length, ts_scl_minsize)
    trackidx_holder = trackidx_holder+Strackidx_holder

    #if make_jsons:
    #    dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'second_cut', mc_dl)

    showeridx_holder , Strackidx_holder = tss.clusterlength_sep(dataset,showeridx_holder,cmin_length)
    trackidx_holder = trackidx_holder+Strackidx_holder

    if make_jsons:
        dh.MakeJson_Objects(dataset,showeridx_holder,labels,jdir,jcount,'clusterlength_cut', mc_dl)

    return trackidx_holder , showeridx_holder , labels, ell

















def rebase_Full_reco(rdataset,mc_dl , jdir, jcount , make_jsons=True,timer=False):
    # Start of a robust clustering and reco	
    ########################
    # cluster using tight NN
    ########################
    labels = []
    trackidx_holder = []
    showeridx_holder = []
    if len(rdataset)>=15000 or len(rdataset)==0:
    #if len(rdataset)>=15000:
        #labels = pc.walker(dataset,6,20) # Runs clustering and returns labels list 
        return trackidx_holder , showeridx_holder , labels
    else:
        #print len((rdataset))
        labels = pc.crawlernn(rdataset, 6, 20 ) # Runs clustering and returns labels list 

    #labels = pc.crawlernn(dataset, 4, 20 ) # Runs clustering and returns labels list 
    datasetidx_holder = lh.label_to_idxholder(labels,20) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  

    ########################
    # Make Jsons
    ########################
    if make_jsons:
        dh.MakeJson(rdataset,labels,jdir,jcount,'rebase_Alg1',mc_dl)


    return trackidx_holder , showeridx_holder , labels



'''
