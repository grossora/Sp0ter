import numpy as np
import lib.utility.Geo_Utils.axisfit as axfi
from scipy.spatial import ConvexHull
import lib.utility.Geo_Utils.detector as det
import lib.utility.Geo_Utils.geo_funcs as gf

##################################
# ----- list of function ------- #
#------------------------------- #
# --- exiting_tracks_fid 
# --- line_consensus 
# --- clusterspread_first 
# --- clusterspreadR_first 
# --- clusterspreadR
# --- cluster_lhull_cut 
# --- cluster_lhull_length_cut
# --- cluster_first_length 
# --- cluster_second_length
# --- cluster_third_length
# --- clusterlength_sep
# --- stray_charge_removal 
##################################


cdef float xDetL,yDetL,zDetL
xDetL = det.GetX_Length()
yDetL = det.GetY_Length()
zDetL =  det.GetZ_Length()

#################################
# Just local for now
#################################
def make_extend_lines(pt_a , pt_b):
    #make a normalized direction vector 
    dirv = np.array([pt_b[0]-pt_a[0],pt_b[1]-pt_a[1],pt_b[2]-pt_a[2]])
    dirv_norm = dirv/np.linalg.norm(dirv)
    bdirv = -1.*dirv_norm
    mp_length = pow( pow(zDetL*100,2)+pow(xDetL*100,2) + pow(yDetL*100,2),0.5)
    #mp_length = pow( pow(zDetL,2)+pow(xDetL,2) + pow(yDetL,2),0.5)
    sp = np.array(pt_a)
    # anchor to point A and extend
    top_pt = sp + mp_length*dirv_norm
    bottom_pt = sp + mp_length*bdirv
    return [top_pt,bottom_pt]
####^^^^^^^^ Move this into geom

def exiting_tracks_fid(dataset, holder ,float fxlo=0, float fxhi=0, float fylo=0,float fyhi=0,float fzlo=0,float fzhi=0 ):
    cdef int h , idx
    
    shower_holder = []
    track_holder = []

    for h in range(len(holder)):
        passed = True
        points_v=[]

        for idx in holder[h]:

            pt = [dataset[idx][0],dataset[idx][1],dataset[idx][2]]
            # Make sure all points are inside of fid... 
            if not det.In_TPC_Fid(pt,fxlo,fxhi,fylo,fyhi,fzlo,fzhi):
       	        # IF a point isn't then flag the holder as track
                track_holder.append(holder[h])
                passed=False
                break

        if passed:
            shower_holder.append(holder[h])
            
    return shower_holder,track_holder



def line_consensus(dataset, datasetidx_holder, float dist_thresh,float min_obj_length,float min_fkp, int min_kept_size ):
    cdef int i, j, t, p 
    cdef float testpt_distsq , x_min, x_max, y_min,y_max,z_min,z_max, clust_length_sq, distsq_thresh

    distsq_thresh = dist_thresh*dist_thresh
    trackidx_holder = []
    showeridx_holder = []

    # This loops over each objet
    for h in datasetidx_holder:
        ##########################
        #Make hull and check length
        ##########################
        points_v = []
        for p in h:
            pt = [ dataset[p][0],dataset[p][1],dataset[p][2]]
            points_v.append(pt)
        try:
            hull = ConvexHull(points_v)
        except:
            # Put the cluster in the shower
            showeridx_holder.append(h)
            continue

        # Check if it is past the min_length
        min_bd = hull.min_bound
        max_bd = hull.max_bound
        # distance using NP 
        x_min = min_bd[0]
        y_min = min_bd[1]
        z_min = min_bd[2]
        x_max = max_bd[0]
        y_max = max_bd[1]
        z_max = max_bd[2]
        clust_length_sq = (x_max-x_min)*(x_max-x_min) + (y_max-y_min)*(y_max-y_min) + (z_max-z_min)*(z_max-z_min)
        if clust_length_sq<min_obj_length*min_obj_length:
            showeridx_holder.append(h)
            continue

        ##########################
        kept_points = []
        for i in range(len(h)):
            pt_i = dataset[h[i],0:-1]
            for j in xrange(i+1,len(h)):
                #Fit a 3Dline with points
                pt_j = dataset[h[j],0:-1]
                temp_kept_points = [i,j]
                pt_ex = make_extend_lines(pt_i,pt_j)
                for t in range(len(h)):
                    if t==i or t==j:
                        continue
                    pt_t = dataset[h[t],0:-1]
                    #Calculate sqdist
                    testpt_distsq = gf.sqdist_ptline_to_point(pt_ex[0],pt_ex[1] ,pt_t)
                    # if the dist is smaller than thresh_dist keep the point
                    if testpt_distsq<distsq_thresh:
                        #KEEP 
                        temp_kept_points.append(t)
                #Keep the largest keep_points
                if len(temp_kept_points)>len(kept_points):
                    kept_points = temp_kept_points
        # If the kept points pass some cuts... 
        # Sort out into track and shower holders... just append h
        
        # Fraction of kept points
        FKP = 1.0*len(kept_points)/len(h)
        #print ' FKP            :  ', str(FKP)
        #print ' Length of kept :  ', str(len(kept_points))
        # minimum size of kept points 
        if len(kept_points)<min_kept_size or FKP<min_fkp:
            showeridx_holder.append(h)
        else:
            trackidx_holder.append(h)

    return showeridx_holder , trackidx_holder
                


def clusterspread_first(dataset,datasetidx_holder, vari, clustersize):
    track_holder = []
    shower_holder = []

    for a in datasetidx_holder:
        points = []
        for p in a:
            pt = [ dataset[p][0],dataset[p][1],dataset[p][2] , dataset[p][3]]
            points.append(pt)

        if len(points)<clustersize:
            # Push this to the showers holder
            shower_holder.append(a)
            continue

        par = -999
        try:
            par = axfi.WPCAParams(points,[x for x in range(len(points))],3)
        except:
            #print ' could not make a PCA'
            shower_holder.append(a)
            continue

        if par[0] > vari:
            track_holder.append(a)
            continue
        else:
            shower_holder.append(a)

    return shower_holder, track_holder

def clusterspreadR_first(dataset,datasetidx_holder, vari, clustersize):
    track_holder = []
    shower_holder = []

    for a in datasetidx_holder:
        points = []
        for p in a:
            pt = [ dataset[p][0],dataset[p][1],dataset[p][2] , dataset[p][3]]
            points.append(pt)

        if len(points)<clustersize:
            # Push this to the showers holder
            shower_holder.append(a)
            continue

        par = -999
        try:
            par = axfi.WPCAParamsR(points,[x for x in range(len(points))],3)
        except:
            #print ' could not make a PCA'
            shower_holder.append(a)
            continue

        if par[0] > vari:
            track_holder.append(a)
            continue
        else:
            shower_holder.append(a)

    return shower_holder, track_holder

#============================================================================
def clusterspreadR(dataset,datasetidx_holder, vari_lo=0, vari_hi=1, moment = 0 ):
    in_holder = []
    out_holder = []

    for a in datasetidx_holder:
        points = []
        for p in a:
            pt = [ dataset[p][0],dataset[p][1],dataset[p][2] , dataset[p][3]]
            points.append(pt)

        par = -999
        try:
            par = axfi.WPCAParamsR(points,[x for x in range(len(points))],3)
        except:
            #print ' could not make a PCA'
            out_holder.append(a)
            continue

        if par[moment] > vari_lo and par[moment]<vari_hi:
            in_holder.append(a)
            continue
        else:
            out_holder.append(a)

    return out_holder, in_holder

#============================================================================
def cluster_lhull_cut(dataset,datasetidx_holder,float lcmin_length):

    cdef int i
    cdef float  x_min, x_max, y_min,y_max,z_min,z_max, clust_length_sq,Test_cut_param
    track_holder = []
    shower_holder = []

    # Function we will  use for the cut is something like pow(SA,3/2)
    for a in datasetidx_holder:
        points_v = []
        for i in a:
            pt = [ dataset[i][0],dataset[i][1],dataset[i][2]]
            points_v.append(pt)
        try:
            hull = ConvexHull(points_v)
        except:
            #print ' AHHHHHHHHHH couldnt make hull'
	    # Put the cluster in the shower
            shower_holder.append(a)
            continue

        # Check if it is past the min_length
        min_bd = hull.min_bound
        max_bd = hull.max_bound
        # distance using NP 
        x_min = min_bd[0]
        y_min = min_bd[1]
        z_min = min_bd[2]
        x_max = max_bd[0]
        y_max = max_bd[1]
        z_max = max_bd[2]
	
        clust_length_sq = (x_max-x_min)*(x_max-x_min) + (y_max-y_min)*(y_max-y_min) + (z_max-z_min)*(z_max-z_min)
        if clust_length_sq<lcmin_length*lcmin_length:
            shower_holder.append(a)
            continue

	# This is the function we will cut on .... it's derived from single pi0 and SA
        #Test_cut_param = pow(clust_length,1.5)-3
        Test_cut_param = pow(0.5*pow(clust_length_sq,0.5)-5,2)
        #Test_cut_param = 0.25*pow(clust_length,2)+3*clust_length +9

        if hull.area>= Test_cut_param:
            shower_holder.append(a)
        else :
            #print ' ###############################'
            #print ' Look we made a track object from length'
            #print ' ###############################'
            track_holder.append(a)
	
    return shower_holder, track_holder

#============================================================================
def cluster_lhull_length_cut(dataset,datasetidx_holder, float min_length):

    cdef float  x_min, x_max, y_min,y_max,z_min,z_max, clust_length_sq,Test_cut_param
    track_holder = []
    shower_holder = []

    # Function we will  use for the cut is something like pow(SA,3/2)
    for a in datasetidx_holder:
        points_v = []
        for i in a:
            pt = [ dataset[i][0],dataset[i][1],dataset[i][2]]
            points_v.append(pt)
        try:
            hull = ConvexHull(points_v)
        except:
            #print ' AHHHHHHHHHH couldnt make hull'
	    # Put the cluster in the shower
            shower_holder.append(a)
            continue

        # Check if it is past the min_length
        min_bd = hull.min_bound
        max_bd = hull.max_bound
        # distance using NP 
        x_min = min_bd[0]
        y_min = min_bd[1]
        z_min = min_bd[2]
        x_max = max_bd[0]
        y_max = max_bd[1]
        z_max = max_bd[2]
	
        clust_length_sq = (x_max-x_min)*(x_max-x_min) + (y_max-y_min)*(y_max-y_min) + (z_max-z_min)*(z_max-z_min)

        if clust_length_sq>= min_length*min_length:
            track_holder.append(a)
	# This is the function we will cut on .... it's derived from single pi0 and SA
        Test_cut_param = pow(pow(clust_length_sq,0.5),1.5)-15

        if hull.area>= Test_cut_param:
            shower_holder.append(a)
        else :
            #print ' ###############################'
            #print ' Look we made a track object from length'
            #print ' ###############################'
            track_holder.append(a)
	
    return shower_holder, track_holder

def cluster_first_length(dataset,datasetidx_holder,float vari, float clength, int clustersize):
    cdef float  x_min, x_max, y_min,y_max,z_min,z_max, clust_length_sq,Test_cut_param
    track_holder = []
    shower_holder = []

    for a in datasetidx_holder:
        points = []
        for p in a:
            pt = [ dataset[p][0],dataset[p][1],dataset[p][2] , dataset[p][3]]
            points.append(pt)

        try:
            hull = ConvexHull(points)
        except:
            #print ' AHHHHHHHHHH couldnt make hull'
            # Put the cluster in the shower
            shower_holder.append(a)
            continue

        # Check if it is past the min_length
        min_bd = hull.min_bound
        max_bd = hull.max_bound
        # distance using NP 
        x_min = min_bd[0]
        y_min = min_bd[1]
        z_min = min_bd[2]
        x_max = max_bd[0]
        y_max = max_bd[1]
        z_max = max_bd[2]

        clust_length_sq = (x_max-x_min)*(x_max-x_min) + (y_max-y_min)*(y_max-y_min) + (z_max-z_min)*(z_max-z_min)

        if len(points)<clustersize:
            # Push this to the showers holder
            shower_holder.append(a)
            continue

        par = -999
        try:
            par = axfi.WPCAParamsR(points,[x for x in range(len(points))],3)
            # Check this.... ^^^ is this correct
        except:
            #print ' could not make a PCA'
            shower_holder.append(a)
            continue

        if par[0] > vari and clust_length_sq >clength*clength :
            track_holder.append(a)
            continue
        else:
            shower_holder.append(a)

    return shower_holder, track_holder

def cluster_second_length(dataset,datasetidx_holder, vari, clength, clustersize):
    track_holder = []
    shower_holder = []

    for a in datasetidx_holder:
        points = []
        for p in a:
            pt = [ dataset[p][0],dataset[p][1],dataset[p][2] , dataset[p][3]]
            points.append(pt)

        try:
            hull = ConvexHull(points)
        except:
            #print ' AHHHHHHHHHH couldnt make hull'
            # Put the cluster in the shower
            shower_holder.append(a)
            continue

        # Check if it is past the min_length
        min_bd = hull.min_bound
        max_bd = hull.max_bound
        # distance using NP 
        x_min = min_bd[0]
        y_min = min_bd[1]
        z_min = min_bd[2]
        x_max = max_bd[0]
        y_max = max_bd[1]
        z_max = max_bd[2]

        clust_length = pow((x_max-x_min)*(x_max-x_min) + (y_max-y_min)*(y_max-y_min) + (z_max-z_min)*(z_max-z_min),0.5)

        if len(points)<clustersize:
            # Push this to the showers holder
            shower_holder.append(a)
            continue

        par = -999
        try:
            par = axfi.WPCAParamsR(points,[x for x in range(len(points))],3)
            # Check this.... ^^^ is this correct
        except:
            #print ' could not make a PCA'
            shower_holder.append(a)
            continue

        if par[1]>0.0 and par[1] < vari and clust_length >clength :
        #if par[1] < vari and clust_length >clength :
            track_holder.append(a)
            continue
        else:
            shower_holder.append(a)

    return shower_holder, track_holder



def cluster_third_length(dataset,datasetidx_holder, vari, clength, clustersize):
    track_holder = []
    shower_holder = []

    for a in datasetidx_holder:
        points = []
        for p in a:
            pt = [ dataset[p][0],dataset[p][1],dataset[p][2] , dataset[p][3]]
            points.append(pt)

        try:
            hull = ConvexHull(points)
        except:
            #print ' AHHHHHHHHHH couldnt make hull'
            # Put the cluster in the shower
            shower_holder.append(a)
            continue

        # Check if it is past the min_length
        min_bd = hull.min_bound
        max_bd = hull.max_bound
        # distance using NP 
        x_min = min_bd[0]
        y_min = min_bd[1]
        z_min = min_bd[2]
        x_max = max_bd[0]
        y_max = max_bd[1]
        z_max = max_bd[2]

        clust_length = pow((x_max-x_min)*(x_max-x_min) + (y_max-y_min)*(y_max-y_min) + (z_max-z_min)*(z_max-z_min),0.5)

        if len(points)<clustersize:
            # Push this to the showers holder
            shower_holder.append(a)
            continue

        par = -999
        try:
            par = axfi.WPCAParamsR(points,[x for x in range(len(points))],3)
            # Check this.... ^^^ is this correct
        except:
            #print ' could not make a PCA'
            shower_holder.append(a)
            continue

        if par[2]>0.0 and par[2] < vari and clust_length >clength :
            track_holder.append(a)
            continue
        else:
            shower_holder.append(a)

    return shower_holder, track_holder



#============================================================================

def clusterlength_sep(dataset,datasetidx_holder, min_length):

    track_holder = []
    shower_holder = []
    min_length_sq = min_length*min_length

    #for a in range(len(datasetidx_holder)):
    for a in datasetidx_holder:
        points_v = []
        for i in a:
            pt = [ dataset[i][0],dataset[i][1],dataset[i][2]]
            points_v.append(pt)

        try:
            hull = ConvexHull(points_v)
        except:
            #print ' AHHHHHHHHHH couldnt make hull'
	    # Put the cluster in the shower
            shower_holder.append(a)
            continue

        # Check if it is past the min_length
        min_bd = hull.min_bound
        max_bd = hull.max_bound
        # distance using NP 
        x_min = min_bd[0]
        y_min = min_bd[1]
        z_min = min_bd[2]
        x_max = max_bd[0]
        y_max = max_bd[1]
        z_max = max_bd[2]
	
        clust_length_sq = (x_max-x_min)*(x_max-x_min) + (y_max-y_min)*(y_max-y_min) + (z_max-z_min)*(z_max-z_min)
        if clust_length_sq<= min_length_sq:
            shower_holder.append(a)
        else :
            track_holder.append(a)
	
    return shower_holder, track_holder


######################################################################

### Needs to be updated
def stray_charge_removal(dataset,datasetidx_holder,labels, max_csize, m_dist):
    CHQ_vec = []
    stray_holder = []
    remain_holder = []
    # ^^^^^^ Will be of the form [    [datasetidx_holder INDEX, the vertices of the hull, total_charge] ]
    notStrays = []  # This is the idx holderr for the datasetidx_holder....
    min_dist_not_be_a_LONER_sq = m_dist*m_dist
 
    for a in range(len(datasetidx_holder)):
        points_v = []
        for i in datasetidx_holder[a]:
            if labels[i]==-1:
                break
            pt = [ dataset[i][0],dataset[i][1],dataset[i][2]]
            points_v.append(pt)
        #Try to make a hull 
        try:
            hull = ConvexHull(points_v)
        except:
	    # Use all the points in the cluster as the vertex points
            chq = [a,datasetidx_holder[a]]
            CHQ_vec.append(chq)
            continue
        # Now we have the hull
        ds_hull_idx = [datasetidx_holder[a][i] for i in list(hull.vertices)] # Remeber use the true idx
        chq = [a,ds_hull_idx]
        CHQ_vec.append(chq)
    Strays = []  # This is the idx holderr for the datasetidx_holder....
    for a in range(len(CHQ_vec)):
        first_CHQ = CHQ_vec[a]
        if len(datasetidx_holder[first_CHQ[0]])>max_csize:
            notStrays.append(first_CHQ[0]) # This is the idx holderr for the datasetidx_holder.... 
            continue
        passed_close_bool = False
        for b in range(len(CHQ_vec)):
        #for b in range(a+1,len(CHQ_vec)):
            if passed_close_bool:
                break
            if b==a:
                continue

            second_CHQ = CHQ_vec[b]
            min_dist_not_be_a_LONER_sq = m_dist*m_dist

	    # all I care about is if it passes to a so use a break... this will be a double count
            cur_pair = []
            for i in range(len(first_CHQ[1])):
                if passed_close_bool:
                    break
                for j in range(len(second_CHQ[1])):
                    test_dist_sq = ((dataset[first_CHQ[1][i]][0] - dataset[second_CHQ[1][j]][0]) *(dataset[first_CHQ[1][i]][0] - dataset[second_CHQ[1][j]][0])) +((dataset[first_CHQ[1][i]][1] - dataset[second_CHQ[1][j]][1]) *(dataset[first_CHQ[1][i]][1] - dataset[second_CHQ[1][j]][1])) + ( (dataset[first_CHQ[1][i]][2] - dataset[second_CHQ[1][j]][2]) *(dataset[first_CHQ[1][i]][2] - dataset[second_CHQ[1][j]][2]))
                    if test_dist_sq<min_dist_not_be_a_LONER_sq:
                        passed_close_bool = True
                        #print 'we have a close cluster'
                        break
			
            if passed_close_bool:
                #we didn't get anything to match
                notStrays.append(first_CHQ[0]) # This is the idx holderr for the datasetidx_holder.... 
                continue
    #print ' look at the straysStrays'
    #print notStrays

    # Take the idxs from the starys and label these are -1 objects
    for a in range(len(datasetidx_holder)):
        if a in notStrays:
            remain_holder.append(datasetidx_holder[a])
        else:
            stray_holder.append(datasetidx_holder[a])
            for lab in datasetidx_holder[a]:
                labels[lab] = -1

    return stray_holder, remain_holder, labels
######################################################################
