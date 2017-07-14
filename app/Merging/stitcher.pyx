import numpy as np
import lib.utility.Geo_Utils.axisfit as axfi
import lib.utility.Geo_Utils.geo_funcs as gf
from scipy.spatial import ConvexHull


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



def Shower_Brute_nn(dataset, datasetidx_holder, labels,float nn_dist):
    min_sq_dist = nn_dist*nn_dist    

    clust_merge_plex=[]
    for a in range(len(datasetidx_holder)):

        for pta_idx in datasetidx_holder[a]:
            pta_x = dataset[pta_idx][0] 
            pta_y = dataset[pta_idx][1] 
            pta_z = dataset[pta_idx][2] 
            for b in xrange(a+1,len(datasetidx_holder)):

                for ptb_idx in datasetidx_holder[b]:
                    ptb_x = dataset[ptb_idx][0] 
                    ptb_y = dataset[ptb_idx][1] 
                    ptb_z = dataset[ptb_idx][2] 
                   
                    sq_dist= (pta_x-ptb_x)**2+  (pta_y-ptb_y)**2 + (pta_z-ptb_z)**2
                    if sq_dist<min_sq_dist: 
                        # We have a merge
                        clust_merge_plex.append([a,b])
                        break
           
    resultlist =  sublist_group(clust_merge_plex)
    ####### Reassign all labels for the results list
    for pa in resultlist:
        # First one keeps the label
        clusterlabel = pa[0]
        # These already should all have the same labels
        cluster_idx_positions =  datasetidx_holder[clusterlabel]
        # This gets the label value for the cluster
        labels_label = labels[cluster_idx_positions[0]]
        for p in range(1,len(pa)):
            # p is the clusterlabel
            cidx = datasetidx_holder[pa[p]]
            for i in cidx:
                labels[i] = labels_label


    return datasetidx_holder,labels



def Track_Stitcher_nn(dataset,datasetidx_holder,labels, float edge_dist):
    cdef float edge_dist_sq, min_z , max_z, test_sq_dist, jjx,jjy,jjz, kkx,kky,kkz
    cdef int a,i, j,k,jj,kk, clusterlabel,  p

    edge_dist_sq = edge_dist*edge_dist
    pvert_vec = []
    # ^^^^^^ Will be of the form [    [datasetidx_holder INDEX, datasetpoints that are vertex points of the hull] ]
    #print 'start of the stitcher'
    for a in range(len(datasetidx_holder)):
        min_z = 10000000000 
        max_z = 10000000000
        points_v = [dataset[i][2] for i in datasetidx_holder[a] if labels[i]!=-1 ]
        min_z = min(points_v)
        max_z = max(points_v)
 
        chq = [a,datasetidx_holder[a], [min_z , max_z]]
        pvert_vec.append(chq)

        
    #print 'made in the stitcher'
    #print 'size of vert ', str(len(pvert_vec))

    # Now we can run a quick NN over the vertex points to merge
    # We will need to update the hull lists and update the labels after each merge
    clust_merge_plex = []
    
    # Sort vert_vec by min_z
    sorted_index_vv = sorted(range(len(pvert_vec)), key=lambda k: pvert_vec[k][2][0])
    vert_vec = [ pvert_vec[x] for x in sorted_index_vv] 

    #print ' here is the vert vector '
    #print vert_vec[0:100]
    # This is taking forever
    for j in range(len(vert_vec)):
        #print 'at j we are at ', str(j)
        #if vert_vec[j][2][1]> 200:  # Shit hack
         #   break # Shit Hack
        for k in range(j+1,len(vert_vec)):
            if vert_vec[k][2][0] - vert_vec[j][2][1] > edge_dist:
            #if vert_vec[k][2][0] - vert_vec[j][2][1] > edge_dist+1:
                break
            # Now loop over points in each
            found_match = False
            for jj in vert_vec[j][1]:
                jjx = dataset[jj][0]
                jjy = dataset[jj][1]
                jjz = dataset[jj][2]
                if found_match:
                    break
                for kk in vert_vec[k][1]:
                    # Check to see if any of them touch
                    # If the do touch.... add them as a pair
                    kkx = dataset[kk][0]
                    kky = dataset[kk][1]
                    kkz = dataset[kk][2]
                    test_sq_dist = (jjx-kkx)**2  + (jjy-kky)**2 + (jjz-kkz)**2
                    if test_sq_dist<edge_dist_sq:
                        clust_merge_plex.append([vert_vec[j][0],vert_vec[k][0]])
                        found_match = True
                        #print'we matched!!', str(vert_vec[j][0]), 'and ', str( vert_vec[k][0])
                        #print'dist is', str(test_sq_dist)
                        break

    resultlist =  sublist_group(clust_merge_plex)

#    print ' this is the result list \n'
 #   print resultlist 
    ####### Reassign all labels for the results list
    for pa in resultlist:
        # First one keeps the label
        clusterlabel = pa[0]
        # These already should all have the same labels
        cluster_idx_positions =  datasetidx_holder[clusterlabel]
        # This gets the label value for the cluster
        labels_label = labels[cluster_idx_positions[0]]

#----------------------------------------------------------
        # loop over all of the PA;
        #for p in pa:
        for p in range(1,len(pa)):
            # p is the clusterlabel
            cidx = datasetidx_holder[pa[p]]
            for i in cidx:
                labels[i] = labels_label
#----------------------------------------------------------
    # Shit hack 
    #for i in range(len(dataset)):
    #    if dataset[i][2]>200:
    #        labels[i] = -1

    # Return here? 
    # Currently this is only working of the labels end of things... .the new dataset is not addresed yet
    # I just  need the labels at the moment .... and this is a mess.... 
    return datasetidx_holder,labels
       



def Track_Stitcher(dataset,datasetidx_holder,labels, float edge_dist):
    # Make hulls
    edge_dist_sq = edge_dist*edge_dist

    pvert_vec = []
    # ^^^^^^ Will be of the form [    [datasetidx_holder INDEX, datasetpoints that are vertex points of the hull] ]
    print 'start of the stitcher'
    for a in range(len(datasetidx_holder)):
        points_v = []
        for i in datasetidx_holder[a]:
            if labels[i]==-1:
                break
            pt = [ dataset[i][0],dataset[i][1],dataset[i][2]]
            points_v.append(pt)
        # Find the max/ min z position
	# This can be done over the vertices
        points_v = np.asarray(points_v)
        points_z = points_v[:,2]
        min_z = np.min(points_z)
        max_z = np.max(points_z)
        #Try to make a hull 
        goodhull = True
        try:
            hull = ConvexHull(points_v)
        except:
            print ' AHHHHHHHHHH couldnt make hull'
            goodhull=False
            #just use all of the points
	    #print ' length of the points cluster' , str(len(points_v))
            continue
        # Now we have the hull
        if goodhull:
            ds_hull_idx = [datasetidx_holder[a][i] for i in list(hull.vertices)] # Remeber use the true idx
            chq = [a,ds_hull_idx, [min_z , max_z]]
            pvert_vec.append(chq)
        else:
            ds_hull_idx = datasetidx_holder[a] # Remeber use the true idx
            chq = [a,ds_hull_idx, [min_z , max_z]]
            pvert_vec.append(chq)


    print 'hulls are made in the stitcher'
    print 'size of vert ', str(len(pvert_vec))
    clust_merge_plex = []
    # Now we can run a quick NN over the vertex points to merge
    # We will need to update the hull lists and update the labels after each merge
    
    # Sort vert_vec by min_z
    sorted_index_vv = sorted(range(len(pvert_vec)), key=lambda k: pvert_vec[k][2][0])
    vert_vec = [ pvert_vec[x] for x in sorted_index_vv] 

    #print ' here is the vert vector '
    #print vert_vec[0:100]
    # This is taking forever
    for j in range(len(vert_vec)):
        print 'at j we are at ', str(j)
        for k in range(j+1,len(vert_vec)):
            if vert_vec[k][2][0] - vert_vec[j][2][1] > edge_dist:
                continue
                #break
            # Now loop over points in each
            found_match = False
            for jj in vert_vec[j][1]:
                if found_match:
                    break
                for kk in vert_vec[k][1]:
                    # Check to see if any of them touch
                    # If the do touch.... add them as a pair
                    jjx = dataset[jj][0]
                    jjy = dataset[jj][1]
                    jjz = dataset[jj][2]
                    kkx = dataset[kk][0]
                    kky = dataset[kk][1]
                    kkz = dataset[kk][2]
                    test_sq_dist = (jjx-kkx)**2  + (jjy-kky)**2 + (jjz-kkz)**2
                    if test_sq_dist<edge_dist_sq:
                        clust_merge_plex.append([vert_vec[j][0],vert_vec[k][0]])
                        found_match = True
                        break

    # Push together the clusters that should be merged 
    print 'past the makeing of perplex stitcher'
    # Put together the clusters that should be merged
    print clust_merge_plex
    clust_merge_plex = sorted([sorted(x) for x in clust_merge_plex])
    #print clust_merge_plex
    resultlist = []
    if len(clust_merge_plex) >= 1: # If your list is empty then you dont need to do anything.
        resultlist = [clust_merge_plex[0]] #Add the first item to your resultset
        if len(clust_merge_plex) > 1: #If there is only one list in your list then you dont need to do anything.
            for l in clust_merge_plex[1:]: #Loop through lists starting at list 1
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

    ####### Reassign all labels for the results list
    for pa in resultlist:
        # First one keeps the label
        clusterlabel = pa[0]
        # These already should all have the same labels
        cluster_idx_positions =  datasetidx_holder[clusterlabel]
        # This gets the label value for the cluster
        labels_label = labels[cluster_idx_positions[0]]

#----------------------------------------------------------
        # loop over all of the PA;
        #for p in pa:
        for p in range(1,len(pa)):
            # p is the clusterlabel
            cidx = datasetidx_holder[pa[p]]
            for i in cidx:
                labels[i] = labels_label
#----------------------------------------------------------
    # Return here? 
    # Currently this is only working of the labels end of things... .the new dataset is not addresed yet
    # I just  need the labels at the moment .... and this is a mess.... 
    return datasetidx_holder,labels
       

def Track_Stitcher_epts(dataset,datasetidx_holder,labels, float gap_dist,float k_radius,float min_pdelta,float pangle_uncert,float min_clust_length):
    #k_radius = radius for points around the hulls minimal dist point 
    #pdelta = minimal distance allowed from the projection 
    cdef float gap_dist_sq  = gap_dist*gap_dist
    cdef float k_radius_sq  = k_radius*k_radius 
    cdef float min_clust_length_sq= min_clust_length*min_clust_length
    cdef float clust_length_sq  
    cdef float k_dist_sq
    cdef float x_min,  y_min,  z_min,  x_max,  y_max, z_max
    cdef int a, b , i , j  

    CHQ_vec = []
    # ^^^^^^ Will be of the form [    [datasetidx_holder INDEX, the vertices of the hull, total_charge] ]

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
            #print ' AHHHHHHHHHH couldnt make hull'
	    #print ' length of the points cluster' , str(len(points_v))
            continue

        # Check if it is past the min_length
        min_bd = hull.min_bound
        max_bd = hull.max_bound
        # distance using NP 
        x_min = float(min_bd[0])
        y_min = float(min_bd[1])
        z_min = float(min_bd[2])
        x_max = float(max_bd[0])
        y_max = float(max_bd[1])
        z_max = float(max_bd[2])

        #clust_length_sq = (x_max-x_min)*(x_max-x_min) + (y_max-y_min)*(y_max-y_min) + (z_max-z_min)*(z_max-z_min)
        clust_length_sq = gf.square_dist(x_min,y_min,z_min,x_max,y_max,z_max)
        if clust_length_sq<min_clust_length_sq:
            #print ' are we losing things on the min cluster cut?'
            continue
	
        # Now we have the hull
        ds_hull_idx = [datasetidx_holder[a][i] for i in list(hull.vertices)] # Remeber use the true idx
        chq = [a,ds_hull_idx]
        CHQ_vec.append(chq)

    clust_merge_plex = [] # Pairs of local clusters that need to be merged There are from the id from the datasetidx_holder labels

    for a in range(len(CHQ_vec)):
        # Get the first 
        first_CHQ = CHQ_vec[a]
        for b in xrange(a+1,len(CHQ_vec)):
            second_CHQ = CHQ_vec[b]
            # Find the closest points between the two hulls
            cur_smallest_dist_sq = 1000000000000. # This stays hardcoded as a maximum
            cur_pair = []
            #Find the two vertex points that are closest to each other from the different clusters
            for i in range(len(first_CHQ[1])):
                for j in range(len(second_CHQ[1])):
                    ## RG This is slow... USE Dist SQ to speed up...  do it yourself
                    test_dist_sq = ((dataset[first_CHQ[1][i]][0] - dataset[second_CHQ[1][j]][0]) *(dataset[first_CHQ[1][i]][0] - dataset[second_CHQ[1][j]][0])) +((dataset[first_CHQ[1][i]][1] - dataset[second_CHQ[1][j]][1]) *(dataset[first_CHQ[1][i]][1] - dataset[second_CHQ[1][j]][1])) + ( (dataset[first_CHQ[1][i]][2] - dataset[second_CHQ[1][j]][2]) *(dataset[first_CHQ[1][i]][2] - dataset[second_CHQ[1][j]][2]))
                    if  test_dist_sq<gap_dist_sq and test_dist_sq<cur_smallest_dist_sq:
                        cur_smallest_dist_sq = test_dist_sq
                        cur_pair = [i,j] # This is the idx value that should corespond to dataset for this pair of hull vertices

            if len(cur_pair)==0:
                #we didn't get anything to match
                continue
            # If we have a pair... look at the NN points in each hull seperatly
            #.... then get local PCA... and compare

            # First vertex  position in the CHQ_vec
            clst_label_a = first_CHQ[0] # This is the label coresponding to which posiition in the holder    
            clst_indexs_a = first_CHQ[1] # This is a list of index for this cluster... index of datasets
            vp_idx_a = first_CHQ[1][cur_pair[0]] # This is the ds index for the vertex in question

            # second vertex  position in the CHQ_vec
            clst_label_b = second_CHQ[0]        # This is the label coresponding to which posiition in the holder    
            clst_indexs_b =  second_CHQ[1] # This is a list of index for this cluster... index of datasets
            vp_idx_b = second_CHQ[1][cur_pair[1]] # This is the ds index for the vertex in question

            # Now do the comparison
            local_pts_idx_a = []
            for i in datasetidx_holder[clst_label_a]:
            #for i in clst_indexs_a:
                k_dist_sq = ((dataset[i][0] -dataset[vp_idx_a][0])*(dataset[i][0] -dataset[vp_idx_a][0])) +((dataset[i][1] -dataset[vp_idx_a][1])*(dataset[i][1] -dataset[vp_idx_a][1])) +((dataset[i][2] -dataset[vp_idx_a][2])*(dataset[i][2] -dataset[vp_idx_a][2])) 
                if k_dist_sq<k_radius_sq:
                    local_pts_idx_a.append(i)

            # Find the PCA
            local_PCA_a = [-999]
            local_PCA_dir_a = [-999]
            try:
		# Use the charge weighted PCA
                local_PCA_a = axfi.WPCAParams(dataset,local_pts_idx_a,3)
                local_PCA_dir_a = axfi.WPCAParams_dir(dataset,local_pts_idx_a,3)
            except:
                local_PCA_a = [-999]
                #print ' AHHHHHHHHHH AAAA Bad PCA'
                continue

            #Find second PCA 
            local_pts_idx_b = []
            for i in datasetidx_holder[clst_label_b]:
                k_dist_sq = ((dataset[i][0] -dataset[vp_idx_b][0])*(dataset[i][0] -dataset[vp_idx_b][0])) +((dataset[i][1] -dataset[vp_idx_b][1])*(dataset[i][1] -dataset[vp_idx_b][1]))   +((dataset[i][2] -dataset[vp_idx_b][2])*(dataset[i][2] -dataset[vp_idx_b][2])) 
                if k_dist_sq<k_radius_sq:
                    local_pts_idx_b.append(i)

            # Find the PCA
            local_PCA_b = [-999]
            local_PCA_dir_b = [-999]
            try:
		# Use the charge weighted PCA
                local_PCA_b = axfi.WPCAParams(dataset,local_pts_idx_b,3)
                local_PCA_dir_b = axfi.WPCAParams_dir(dataset,local_pts_idx_b,3)
            except:
                local_PCA_b = [-999]
                #print ' AHHHHHHHHHH BBBB Bad PCA'
                continue


	    ################# IF the PCA is a bad fit.... meaning not straight... then don't bother stitching these together... you could be stitching blobs to trakcs?
	    # This is not implemented ..
            # Get the points 
            vtx_A =  np.asarray([dataset[vp_idx_a][0],dataset[vp_idx_a][1],dataset[vp_idx_a][2]])
            vtx_B =  np.asarray([dataset[vp_idx_b][0],dataset[vp_idx_b][1],dataset[vp_idx_b][2]])
            Length_between_vtx = pow( pow((vtx_A[0] - vtx_B[0]),2) + pow((vtx_A[1] - vtx_B[1]),2)+ pow((vtx_A[2] - vtx_B[2]),2) ,0.5) # This is slow
	    # ^^^ This is the gap

	    # Project things forward from the point along the PCA direction in both directions
            projA_plus = vtx_A + np.asarray([1,1,1])*Length_between_vtx * np.asarray(local_PCA_dir_a[0])
            projA_minus = vtx_A - np.asarray([1,1,1])*Length_between_vtx * np.asarray(local_PCA_dir_a[0])
            projB_plus = vtx_B + np.asarray([1,1,1])*Length_between_vtx * np.asarray(local_PCA_dir_b[0])
            projB_minus = vtx_B - np.asarray([1,1,1])*Length_between_vtx * np.asarray(local_PCA_dir_b[0])

            # Deltas
            deltaAB_plus_sq = (projA_plus[0] - vtx_B[0])*(projA_plus[0] - vtx_B[0]) + (projA_plus[1] - vtx_B[1])*(projA_plus[1] - vtx_B[1])+(projA_plus[2] - vtx_B[2])*(projA_plus[2] - vtx_B[2])
            deltaAB_minus_sq = (projA_minus[0] - vtx_B[0])*(projA_minus[0] - vtx_B[0]) + (projA_minus[1] - vtx_B[1])*(projA_minus[1] - vtx_B[1])+(projA_minus[2] - vtx_B[2])*(projA_minus[2] - vtx_B[2])
            deltaBA_plus_sq = (projB_plus[0] - vtx_A[0])*(projB_plus[0] - vtx_A[0]) + (projB_plus[1] - vtx_A[1])*(projB_plus[1] - vtx_A[1])+(projB_plus[2] - vtx_A[2])*(projB_plus[2] - vtx_A[2])
            deltaBA_minus_sq = (projB_minus[0] - vtx_A[0])*(projB_minus[0] - vtx_A[0]) + (projB_minus[1] - vtx_A[1])*(projB_minus[1] - vtx_A[1])+(projB_minus[2] - vtx_A[2])*(projB_minus[2] - vtx_A[2])

            # Assume this should work for small angles make pdelta depended on the gap and a fixed angle uncertanty
	    # I would try 5 degree... 0.087 rads 
            pdelta = min_pdelta+pangle_uncert*Length_between_vtx 
            pdelta_sq  = pdelta*pdelta 

	    # Do the comparison
            AB = False
            BA = False
            if deltaAB_plus_sq < pdelta_sq or deltaAB_minus_sq <pdelta_sq:
                AB = True

            if deltaBA_plus_sq < pdelta_sq or deltaBA_minus_sq <pdelta_sq:
                BA = True

	    # or  they are just really really freakin close... 
            if pow( (vtx_A[0]- vtx_B[0]) *(vtx_A[0]- vtx_B[0]) +(vtx_A[1]- vtx_B[1]) *(vtx_A[1]- vtx_B[1]) +(vtx_A[2]- vtx_B[2]) *(vtx_A[2]- vtx_B[2])   , 0.5) < 5:
                #print ' mereging based on just the vertex'
                AB = True
                BA = True

            if not AB :
                continue

            if not BA :
                continue

            # Now we have found that these two need to get merged together. 
            clust_merge_plex.append([clst_label_a,clst_label_b])

    # Put together the clusters that should be merged
    clust_merge_plex = sorted([sorted(x) for x in clust_merge_plex])
    resultlist = []
    if len(clust_merge_plex) >= 1: # If your list is empty then you dont need to do anything.
        resultlist = [clust_merge_plex[0]] #Add the first item to your resultset
        if len(clust_merge_plex) > 1: #If there is only one list in your list then you dont need to do anything.
            for l in clust_merge_plex[1:]: #Loop through lists starting at list 1
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

    ####### Reassign all labels for the results list
    for pa in resultlist:
        # First one keeps the label
        clusterlabel = pa[0]
        # These already should all have the same labels
        cluster_idx_positions =  datasetidx_holder[clusterlabel]
        # This gets the label value for the cluster
        labels_label = labels[cluster_idx_positions[0]]

#----------------------------------------------------------
        # loop over all of the PA;
        #for p in pa:
        for p in range(1,len(pa)):
            # p is the clusterlabel
            cidx = datasetidx_holder[pa[p]]
            for i in cidx:
                labels[i] = labels_label
#----------------------------------------------------------
    # Return here? 
    # Currently this is only working of the labels end of things... .the new dataset is not addresed yet
    # I just  need the labels at the moment .... and this is a fucking mess.... 
    return datasetidx_holder,labels





