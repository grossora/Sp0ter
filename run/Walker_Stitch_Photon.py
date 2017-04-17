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
import lib.utility.Utils.labelhanle as lh
import lib.Selection.Ana_Clusters as Ea
import lib.Merging.stitcher as st

#####################
####################



end_Rtime = datetime.now()
delta_Rt = end_Rtime-start_Rtime
print 'RTIME' ,str(delta_Rt.seconds)+' loadtime'
start_Rtime = datetime.now()

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
make_jsons = False
#make_jsons = True
make_ana = True 
#make_ana = False 
Charge_thresh = 3000 
method_name = 'walker_gamma_fixed'
drun_dir = method_name
jcount = -1

jdir = os.getcwd() + '/Out_text/'+method_name+'/'   # This still is global and can be used later
if os.path.isdir(jdir):
    shutil.rmtree(jdir)

if not os.path.isdir(jdir):
    print 'NO DIR.... making one for you'
    os.makedirs(jdir)





############################################
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
############################################


#######################################
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#######################################

jcount=0
for f in sys.argv[1:]:
    jcount +=1

    ########################
    # Check if the File is good
    ########################
    #file_info = dh.F_Info_Cosmic(f)
    file_info = dh.F_Info(f)
    ########################
    # if the file is bad then continue and fill 
    ########################
    if not file_info:
	continue
    ########################
    # Bring in the MC info 
    ########################
    mcinfo = mh.gamma_mc_info(f)
    mcqdep = mh.gamma_mc_dep(f)
    #print mcinfo 
    #print mcqdep 


    ########################
    #Bring in  Dataset 
    ########################
    dataset = dh.ConvertWC_InTPC_thresh('{}'.format(f),Charge_thresh)
    #print 'size of dataset : ' , str(len(dataset))
    if len(dataset)==0:
	continue

    ########################
    # Build the reco testing here 
    ########################
    labels = []
    #trackidx_holder = []
    #showeridx_holder = []

    labels = pc.walker(dataset,nn_dist,mincluster) # Runs clustering and returns labels list 
    datasetidx_holder = lh.label_to_idxholder(labels,mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  

    d, labels = st.Track_Stitcher_epts(dataset,datasetidx_holder,labels,gap_dist,k_radius,min_pdelta,AE,min_clust_length )
    datasetidx_holder = lh.label_to_idxholder(labels,mincluster) # Converts the labels list into a list of indexvalues for datasets  [ [ list of index], [list of indexes].. [] ]  

    Ea.Ana_Object_photons(dataset, datasetidx_holder, jcount,mcinfo,mcqdep, filename = '{}/photon_ana_obj_nn_{}_mspt_{}'.format(method_name,str(nn_dist),str(mincluster)))



