import numpy as np 
import math as math
import collections as col
import lib.utility.Geo_Utils.axisfit as axfi
from sklearn.decomposition import PCA
import lib.utility.Geo_Utils.wpca as wp
import lib.utility.Geo_Utils.detector as det
import lib.utility.Geo_Utils.geo_funcs as gf 
# Not sure what to do ^^^ with this? 
from scipy.spatial import ConvexHull


###########################################################################################
#############     a few functions to use for the geometry ################################
###########################################################################################
cdef float xDetL,yDetL,zDetL
xDetL = det.GetX_Length()
yDetL = det.GetY_Length()
zDetL =  det.GetZ_Length()
###########################################################################################
###########################################################################################


def sublist_group(l):
    #cdef int i , item, node , index
    taken=[False]*len(l)
    l=map(set,l)

    def dfs(node,index):
        taken[index]=True
        ret=node
        for i,item in enumerate(l):
            if not taken[i] and not ret.isdisjoint(item):
                ret.update(dfs(item,i))
        return ret

    ret=[]
    for i,node in enumerate(l):
        if not taken[i]:
            ret.append(list(dfs(node,i)))
    return ret



def make_extend_lines_list(dataset , idxlist_for_tracks,labels):
    # loop over all the 'track' points 
    # take the pca for direction 
    # extend the direction past the top and bottom in y 
    # make a circle of radius that is user defined. 
    # return the vector of points for each..there is no hull done here...  just getting the points to make hulls for 
    cdef int p
    cdef float mp_length
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
        # This needs to be corrected for outside of TPC
        mp_length = pow( pow(zDetL*100,2)+pow(xDetL*100,2) + pow(yDetL*100,2),0.5)
        #mp_length = pow( pow(zDetL,2)+pow(xDetL,2) + pow(yDetL,2),0.5)
        top_pt = sp + mp_length*tdir_forward
        bottom_pt = sp + mp_length*tdir_backward
        # Calcuate brute forced cyl polygon 
        pointslist = [label_val,top_pt, bottom_pt]
        lp_list.append(pointslist)
    return lp_list



def Shower_Forward_Sweep(dataset,idx_holder, labels):
    #This will be slowish for now.  

    # General idea : 
    # Sort the showers from largest Nspts to smalles
    # Calculate dist between avg of large and avg of small. 
    # Start with largest as the forward project towards the smallest 
    # Calculate the fraction of charge within a sphere of the forward projected point 
    #if qsel/qsmal>some frac then merge, break the loop update the shower holder and labels 
    
    # for now do all the math here... we will move this to updating dataproucts later 
    idx_q_av= [] 
    for idx in len(idx_holder): 
        # get the average point
        points = [] 
        tot_q = 0.
        for pt in idx_holder[idx]:
            points.append([dataset[pt][0],dataset[pt][1],dataset[pt][2]])
            tot_q+= dataset[pt][3]
        #Make vector 
        temp_list = [idx,tot_q,np.average(np.array(pt),axis=0)]
        idx_q_av.append(temp_list)
 
    idx_q_av = np.asarray(idx_q_av)
    #Find the index of the max q

    #Sort the list 
    idx_q_av_sorted = sorted(idx_q_av,key=lambda row:row[1])[::-1]#This reverse sorted from highest charge
    return True
    # Now we have the sorted list. 
#    for idx_ss in len(idx_q_av_sorted): 
        #
        #
#            vtx_A =  np.asarray([dataset[vp_idx_a][0],dataset[vp_idx_a][1],dataset[vp_idx_a][2]])
#            vtx_B =  np.asarray([dataset[vp_idx_b][0],dataset[vp_idx_b][1],dataset[vp_idx_b][2]])
#            Length_between_vtx = pow( pow((vtx_A[0] - vtx_B[0]),2) + pow((vtx_A[1] - vtx_B[1]),2)+ pow((vtx_A[2] - vtx_B[2]),2) ,0.5) # This is slow

        
    


###########################################################################################
def TrackExtend_sweep_holders(dataset,idx_holder, labels, extended_lines_list, float doca):
    cdef int cl,i,
    cdef float doca_sq,pt_to_line_dist_sq

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
                pt_to_line_dist_sq = gf.sqdist_ptline_to_point(t[1],t[2],[dataset[i][0],dataset[i][1],dataset[i][2]])
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
def TrackExtend_sweep_prohibit_holders(dataset,idx_holder, labels, extended_lines_list, float doca):
    cdef int cl,i,
    cdef float doca_sq,pt_to_line_dist_sq

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
                pt_to_line_dist_sq = gf.sqdist_ptline_to_point(t[1],t[2],[dataset[i][0],dataset[i][1],dataset[i][2]])
                if pt_to_line_dist_sq<doca_sq:
                    #check if this passes a prohibit.... 
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
 



'''
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
            pt_to_line_dist_sq = gf.sqdist_ptline_to_point(t[1],t[2],[dataset[i][0],dataset[i][1],dataset[i][2]])
            if pt_to_line_dist_sq<doca_sq:
		# Add this shit to the cluster
                labels[i]=t[0]
                break 
    return labels

'''
   
def wpca_merge(dataset,labels,datasetidx_holder,float crit_merge_angle, float wt_dist):
    cdef int matchlabel, a,b
    cdef float min_angle_merge , wt_dist_sq, cos , min_angle

    wpca_holder = []
    wpt_holder = []
    # This is hard code need to be writted better
    min_angle_merge = crit_merge_angle
    wt_dist_sq = wt_dist*wt_dist
    #print 'are there -1 in the datasetholder input ?'
    #print datasetidx_holder

    for d in datasetidx_holder:
        pp = []
        dd = []
        cc = []
        #print ' this is the label value  ' , str(labels[d[0]])
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
    #print ' this is wpca holder'
    #print wpca_holder

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

            #check to see if points from weight are close to agerage wpca
            delta = wtpointA[:] - wtpointB[:] 
            ptab_avg_vect = delta/np.linalg.norm(delta)
            dirA_norm = dirA/sma
            dirB_norm = dirB/smb
            angle_A_p = math.acos(np.dot(dirA_norm,ptab_avg_vect)) 
            angle_B_p = math.acos(np.dot(dirA_norm,ptab_avg_vect) )
            if angle_A_p>np.pi/2.:
                angle_A_p = np.pi-angle_A_p
            if angle_B_p>np.pi/2.:
                angle_B_p = np.pi-angle_B_p
            
            
            ############33
            delta_sq = delta*delta
            test_dist_sq = delta_sq.sum()
            #print 'angle', str(min_angle)
            #print 'pointa', str(wtpointA[:])
            #print 'ptb', str(wtpointB[:])
            #print 'delta', str(delta)
            #print 'sqdelta', str(delta_sq.sum())
            if min_angle< crit_merge_angle and test_dist_sq<wt_dist_sq and angle_B_p < crit_merge_angle and angle_B_p < crit_merge_angle :
            #^^^^^^^^^^^^^^^^^^^ Change this to diff variable for vrit merge with angle to point
            #if min_angle< crit_merge_angle and test_dist_sq<wt_dist_sq  :
                print 'going to merge'
            #if min_angle< crit_merge_angle:
                # merge them together
                pair = [a,b]
                mergedpairs.append(pair)

    #print 'what do the merged pairs look like '
    #print mergedpairs
    # that share nodes
    #lists = mergedpairs
    #resultlist = []
    #if len(lists) >= 1: # If your list is empty then you dont need to do anything.
    #    resultlist = [lists[0]] #Add the first item to your resultset
    #    if len(lists) > 1: #If there is only one list in your list then you dont need to do anything.
    #        for l in lists[1:]: #Loop through lists starting at list 1
    #            listset = set(l) #Turn you list into a set
    #            merged = False #Trigger
    #            for index in range(len(resultlist)): #Use indexes of the list for speed.
    #                rset = set(resultlist[index]) #Get list from you resultset as a set
    #                if len(listset & rset) != 0: #If listset and rset have a common value then the len will be greater than 1
    #                    resultlist[index] = list(listset | rset) #Update the resultlist with the updated union of listset and rset
    #                    merged = True #Turn trigger to True
    #                    break #Because you found a match there is no need to continue the for loop.
    #            if not merged: #If there was no match then add the list to the resultset, so it doesnt get left out.
    #                resultlist.append(l)
    ####
    resultlist =  sublist_group(mergedpairs)

    # Connect all of these into a holder
    return_holder = []
    for s in resultlist:
        #print 'These below will all be merged '
        matchlabel = labels[datasetidx_holder[s[0]][0]] # grabbing the cluster index from datasetholder using s[0] and looking at the first point in that cluster to get the label
        temp_holder =[]
        for z in xrange(len(s)):
        #for z in xrange(1,len(s)):
	# This is overkill in the loop... it's renaminge labels as two things
           # print s[z]
            for dlab in datasetidx_holder[z]:
                temp_holder.append(dlab)
                labels[dlab] = matchlabel
        return_holder.append(temp_holder)
    return  labels
