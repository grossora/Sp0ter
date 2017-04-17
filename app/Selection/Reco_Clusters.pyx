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

from datetime import datetime
   
#################################################################################
#################################################################################
#################################################################################


def Reco_trackshower( dataset, mc_dl , jdir, jcount , make_jsons=True,timer=False):
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


#############################################################################################################
########################    Reclustering and merging the shower objects  
#############################################################################################################


def Reco_showerReCluster(dataset,showeridx_holder,labels,mc_dl,jdir,jcount,make_jsons):

    min_spts = 20
    nn_dist = 10

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
    


    




#############################################################################################################

#############################################################################################################

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

#############################################################################################################
