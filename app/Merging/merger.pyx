import numpy as np 
import collections as col
import lib.utility.Geo_Utils.axisfit as axfi
from sklearn.decomposition import PCA
import lib.utility.Geo_Utils.wpca as wp
# Not sure what to do ^^^ with this? 
from scipy.spatial import ConvexHull



xDetL = 256.
yDetL = 116.*2
zDetL = 1060. # This is not correct 


###########################################################################################
#############     a few functions to use for the geometry ################################
###########################################################################################

def sqdist_ptline_to_point(pt_a,pt_b,pt_t):
    n = [pt_b[0]- pt_a[0],pt_b[1]- pt_a[1],pt_b[2]- pt_a[2]]
   # pt_t = [np.random.rand(),np.random.rand(),np.random.rand()]
    pa = [pt_a[0]- pt_t[0],pt_a[1]- pt_t[1],pt_a[2]- pt_t[2]]
    #c = n  * pa.n /n.n
    pan = (pa[0]*n[0] + pa[1]*n[1]+pa[2]*n[2])/ (n[0]*n[0] + n[1]*n[1]+n[2]*n[2])
    #pan = (pt_a[0]*n[0] + pt_a[1]*n[1]+pt_a[2]*n[2])/ (n[0]*n[0] + n[1]*n[1]+n[2]*n[2])
    c = [n[0] * pan, n[1]*pan,n[2]*pan]
    d = [pa[0]-c[0], pa[1]-c[1],pa[2]-c[2]]
    return d[0]*d[0]+d[1]*d[1]+d[2]*d[2]

###########################################################################################
###########################################################################################
###########################################################################################

def make_extend_lines_list(dataset , idxlist_for_tracks,labels):
    # loop over all the 'track' points 
    # take the pca for direction 
    # extend the direction past the top and bottom in y 
    # make a circle of radius that is user defined. 
    # return the vector of points for each..there is no hull done here...  just getting the points to make hulls for 
    lp_list = [] # Append will be slow.... but this is ok for now
    for t in idxlist_for_tracks:
        #Get PCA Direction # note... this will be easier when more organized ... we have done this loop already once
        pointsc = []
        label_val = labels[t[0]]# This gets the label value to pass along
        for p in t:
            ptc = [ dataset[p][0],dataset[p][1],dataset[p][2],dataset[p][3] ]
            pointsc.append(ptc)
        # This PCA Should always converge since we have done it already 
	# There should be a Try in here
        pcacomp = axfi.WPCAParams_dir(pointsc,[x for x in range(len(t))],3)
        tdir_forward = pcacomp[0]
        tdir_backward = -1.0*pcacomp[0]
        # Get start point 
        sp = np.mean(np.asarray(pointsc),axis=0)[:-1] # clip off the charge
        # Instead of finding the box ... just extent past the farthest possible track ( corner to corner ) 
        mp_length = pow( pow(zDetL,2)+pow(xDetL,2) + pow(yDetL,2),0.5)
        top_pt = sp + mp_length*tdir_forward
        bottom_pt = sp + mp_length*tdir_backward
        # Calcuate brute forced cyl polygon 
        pointslist = [label_val,top_pt, bottom_pt]
        lp_list.append(pointslist)
    return lp_list

###########################################################################################
def TrackExtend_sweep_holders(dataset,idx_holder, labels, extended_lines_list, doca):
    doca_sq = doca*doca
 
    unswept_holder = []
    swept_holder = []

    # Loop over holders
    for cl in range(len(idx_holder)):
        unswept = True
	# loop over points in the holder
        for i in idx_holder[cl]:
            # Points are volumes lines
            for t in extended_lines_list:
                pt_to_line_dist_sq = sqdist_ptline_to_point(t[1],t[2],[dataset[i][0],dataset[i][1],dataset[i][2]])
                if pt_to_line_dist_sq<doca_sq:
		    # Add this cluster to it by changing label
                    for ii in idx_holder[cl]:
                        labels[ii]=t[0]
                    swept_holder.append(idx_holder[cl])
                    unswept = False
                    break 
            if not unswept:
                break
        if unswept:
            unswept_holder.append(idx_holder[cl])

    return unswept_holder , swept_holder, labels
 





###########################################################################################
def TrackExtend_sweep(dataset, labels, extended_lines_list, doca, labelcase=-1):

# unlabel = True ==> Use only points that are  only unlabled
# unlabel = True clust= False ==> Use all points that are clust clusteread
# unlabel = False ==> Use all points

#Case -1: Use only points that are  only unlabled
#Case 0: Use All points 
#Case 1: Use only clustered points 

    doca_sq = doca*doca
    for i in range(len(dataset)):
        if labelcase==-1:
            if labels[i]!= -1 :
                continue
        if labelcase== 1:
            if labels[i]== -1 :
                continue
    # Points are list
        for t in extended_lines_list:
            pt_to_line_dist_sq = sqdist_ptline_to_point(t[1],t[2],[dataset[i][0],dataset[i][1],dataset[i][2]])
            if pt_to_line_dist_sq<doca_sq:
		# Add this shit to the cluster
                labels[i]=t[0]
                break 
    return labels

   

####### Stupid PCA Merge

def wpca_merge(dataset, idx_holder,labels,minangle):
    mergeidx_holder = []

    return mergeidx_holder , labels

		
#def TrackExtend_sweep_ShowerLabels(dataset, labels, extended_lines_list, doca, labelcase=-1):
'''
#def TrackExtend_sweep(dataset, labels, extended_lines_list, doca, unlabel=True):
# unlabel = True ==> Use only points that are  only unlabled
# unlabel = True clust= False ==> Use all points that are clust clusteread
# unlabel = False ==> Use all points

#Case -1: Use only points that are  only unlabled
#Case 0: Use All points 
#Case 1: Use only clustered points 

#def TrackExtend_sweep(dataset, labels, extended_lines_list, doca):
    # 
    doca_sq = doca*doca
    for i in range(len(dataset)):
	if labelcase==-1:
	    if labels[i]!= -1 :
	        continue
	if labelcase== 1:
	    if labels[i]== -1 :
		continue

    # Points are list
        for t in extended_lines_list:
            pt_to_line_dist_sq = sqdist_ptline_to_point(t[1],t[2],[dataset[i][0],dataset[i][1],dataset[i][2]])
	    if pt_to_line_dist_sq<doca_sq:
		# Add this shit to the cluster
	        labels[i]=-1
		break 
    return labels
'''
