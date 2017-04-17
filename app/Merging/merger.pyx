import numpy as np 
import math as math
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

   
def wpca_merge(dataset,labels,datasetidx_holder,crit_merge_angle,wt_dist):
    wpca_holder = []
    wpt_holder = []
    # This is hard code need to be writted better
    min_angle_merge = crit_merge_angle
    wt_dist_sq = wt_dist*wt_dist

    for d in datasetidx_holder:
        pp = []
        dd = []
        cc = []
        for s in d:
            t = [dataset[s][0],dataset[s][1],dataset[s][2]]
            c = [dataset[s][3],dataset[s][3],dataset[s][3]]
            dd.append(t)
            cc.append(t)
        wpt = np.average(dd,axis=0, weights = cc)
        #wpt = np.average(np.asarray(dd),axis=0, weights = np.asarray(cc))
        wpt_holder.append(wpt)
        pca = wp.WPCA(n_components=1)
        pca.fit(dd,cc)
        wpca_holder.append(pca.components_[0])# I don't know why we have [0]
        #wpca_holder.append(pca.components_)
    # now do the grouping
    mergedpairs = []

    for a in xrange(0,len(wpca_holder)):
        dirA = np.asarray(wpca_holder[a])
        wtpointA = np.asarray(wpt_holder[a]) # we don't need this ... for more speed we can make this with C type
        for b in xrange(a+1,len(wpca_holder)):
            dirB = np.asarray(wpca_holder[b])
            wtpointB = np.asarray(wpt_holder[b]) # we don't need this... we can make this with C type
	    # take the dotproduct
            sma = np.sqrt(dirA[0]*dirA[0] + dirA[1]*dirA[1]+dirA[2]*dirA[2])
            smb = np.sqrt(dirB[0]*dirB[0] + dirB[1]*dirB[1]+dirB[2]*dirB[2])
            cos = np.dot(dirA,dirB) /( sma*smb  )
            min_angle = math.acos(cos)
            if min_angle>np.pi/2.:
                min_angle = np.pi-min_angle
	    # IF the min angle is less than the critical angle then group together 
	    # We need to be careful with this and put some type of distance cut 
            # This way we avoid merging far away things
            delta = wtpointA[:] - wtpointB[:] 
            delta_sq = delta*delta
            test_dist_sq = delta_sq.sum()
            if min_angle< crit_merge_angle and test_dist_sq<wt_dist_sq  :
            #if min_angle< crit_merge_angle:
                # merge them together
                pair = [a,b]
                mergedpairs.append(pair)

    # that share nodes
    lists = mergedpairs
    resultlist = []
    if len(lists) >= 1: # If your list is empty then you dont need to do anything.
        resultlist = [lists[0]] #Add the first item to your resultset
        if len(lists) > 1: #If there is only one list in your list then you dont need to do anything.
            for l in lists[1:]: #Loop through lists starting at list 1
                listset = set(l) #Turn you list into a set
                merged = False #Trigger
                for index in range(len(resultlist)): #Use indexes of the list for speed.
                    rset = set(resultlist[index]) #Get list from you resultset as a set
                    if len(listset & rset) != 0: #If listset and rset have a common value then the len will be greater than 1
                        resultlist[index] = list(listset | rset) #Update the resultlist with the updated union of listset and rset
                        merged = True #Turn trigger to True
                        break #Because you found a match there is no need to continue the for loop.
                if not merged: #If there was no match then add the list to the resultset, so it doesnt get left out.
                    resultlist.append(l)


    # Connect all of these into a holder
    return_holder = []
    for s in resultlist:
        #print 'These below will all be merged '
        matchlabel = labels[datasetidx_holder[s[0]][0]] # grabbing the cluster index from datasetholder using s[0] and looking at the first point in that cluster to get the label
        temp_holder =[]
        for z in xrange(1,len(s)):
	# This is overkill in the loop... it's renaminge labels as two things
           # print s[z]
            for dlab in datasetidx_holder[z]:
                temp_holder.append(dlab)
                labels[dlab] = matchlabel
        return_holder.append(temp_holder)
    #return return_holder, labels
    return labels

