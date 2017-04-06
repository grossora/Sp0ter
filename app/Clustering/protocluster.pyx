import numpy as np
from operator import itemgetter # This should be removed... but it's not too heavy.

####
# Clusters only return a labels list
####

cdef inline float square_dist(float ax,float ay,float az ,float bx,float by,float bz ):
    return (ax-bx)*(ax-bx)+(ay-by)*(ay-by)+(az-bz)*(az-bz)


############################################
######### Walker Cluster ###################
############################################
def walker(inup, float dist, int mincluster):
    #Initialize an idx list to the label for -1
    idxlist = [-1 for x in range(len(inup))]
#    punused = [x for x in range(len(inup))]
    cdef int idxcounter 
    cdef float tdist, max_z,un_x, un_y, un_z,tm_x, tm_y, tm_z, sqdist_test

    tdist = dist*dist
    idxcounter = 0

    # Sort the unused list 
    punused_z =  inup[:,2]
    #punused_z = [inup[i][2] for i in punused]
    #sort_idx = sorted(range(len(punused_z)), key=lambda k: punused_z[k])
    #unused = [punused[idx] for idx in sort_idx]
    unused = sorted(range(len(punused_z)), key=lambda k: punused_z[k])

    for i in unused:
        # i is the first point
        if idxlist[i] != -1:
            continue
        tmpclust = []# make none
	#append_tmpclust = tmpclust.append
        #append_tmpclust(i)
        tmpclust.append(i)
	
        max_z = inup[i][2]
        for j in unused:
            if idxlist[j] !=-1:
                continue
            else:
                if inup[j][2] - max_z >dist:
                    break

            un_x =  inup[j][0]
            un_y =  inup[j][1]
            un_z =  inup[j][2]
            for te in tmpclust:
                tm_x = inup[te][0]
                tm_y = inup[te][1]
                tm_z = inup[te][2]
                #sqdist_test = (un_x-tm_x)*(un_x-tm_x)+(un_y-tm_y)*(un_y-tm_y)+(un_z-tm_z)*(un_z-tm_z)
                sqdist_test = square_dist(un_x,un_y,un_z,tm_x,tm_y,tm_z)
                #sqdist_test = (inup[j][0]-inup[te][0])*(inup[j][0]-inup[te][0])+(inup[j][1]-inup[te][1])*(inup[j][1]-inup[te][1])+(inup[j][2]-inup[te][2])*(inup[j][2]-inup[te][2])
                if sqdist_test<tdist:
                    # add j to tmpclust
                    tmpclust.append(j)
        	    #append_tmpclust(j)
                    if max_z<un_z:
                        max_z = un_z
                    break
    # log the idxlist
        if len(tmpclust)>mincluster:
            for lab in tmpclust:
                idxlist[lab] = idxcounter
            idxcounter +=1
    return idxlist
#====================================================================================================================================

############################################
######### crawler Clustering ###############
############################################
def crawler(inup, dist, mincluster ):
    indexlist = [-1 for x in range(len(inup))]
    unusedlist = [x for x in range(len(inup))]
    clusterlabel = 0
    mindist = dist*dist 
    for pt in range(len(inup)):
        #see if this point is already used
        if not pt in unusedlist:
            continue
        # Make a temp list for potential merged points 
        tmpmerge = []
        tmpmerge.append(pt)
        #Push back on a temp list... next version#### RG

        mergedpts = False# This is here now.. we can remove this later

        # remove pt from unused list 
        ptindex = unusedlist.index(pt)
        unusedlist.pop(ptindex)

        # Now crawthough all the rest of the points
        boo = True    ### Is this needed? 
        while boo: # This is going to take long... but it's like a clean up
            tmp_copy = len(tmpmerge)
            for testpt in unusedlist:
                # Check distances  
                # here we are going to check all the list of points in the tmp until we either end of find a close point
                for other in tmpmerge:
                    distsqrd = pow(inup[other][0]-inup[testpt][0],2) + pow(inup[other][1]-inup[testpt][1],2) + pow(inup[other][2]-inup[testpt][2],2)
                    if distsqrd<mindist:
                        #Merge them into the current cluster 
                        #The index in index list becomes whatever the cluster counter is
                        tmpmerge.append(testpt)
                        #now get out and move to next point to consider
                        break
            if len(tmpmerge)>mincluster:# this is not the best way to do this but for now its ok 
            # if we make it to pass the if that means we are going to make cluster
            # so it does not matter if we clean up the unusedlist here 
                for s in tmpmerge:
                    if s ==0:# this is the pt and it is not in unused
                        continue
                    # Check if it is in the list
                    if s in unusedlist:
                        # clear it out of the unused list since it is not used
                        iv = unusedlist.index(s)
                        unusedlist.pop(iv)

            # if we are at a steady state then get out of this
            if tmp_copy==len(tmpmerge):
                boo = False # is this needed? Wont break just take us out? 
                break

        if len(tmpmerge)>=mincluster:
            #label the points 
            for s in tmpmerge:
                indexlist[s] = clusterlabel
            clusterlabel+=1
            #remove from unused list 
        # we need a catch to put back the tmpperge points into unused if we do not pass the min cluster
#########   
    return indexlist

#====================================================================================================================================
#====================================================================================================================================
#====================================================================================================================================

############################################
######### crawler nn     ###############
############################################
def crawlernn(inup, float dist,int min_cls ):
    #print 'STARTING NN???? CRRAWLER NN ?'
    #return 5 
    #######
    #### some stuff at the start that won't change
    #######
    cdef int clusterlabel = 0
    indexlist = [-1 for x in range(len(inup))]

    cdef float distsq_max = dist*dist
    def nn(pta,ptb):
        distsq = pow(pta[1]-ptb[1],2) + pow(pta[2]-ptb[2],2) + pow(pta[3]-ptb[3],2)
        if distsq < distsq_max:
            return True
    #######
    #### some stuff at the start that won't change
    #######

    # Happens once
    '''
    unusedlist = [(x,inup[x][0],inup[x][1],inup[x][2]) for x in range(len(inup))]
    ## First sort the list based on z position since is it has the most spread
    unusedlist.sort(key=itemgetter(3))
    '''
    #print inup 

    punused = [x for x in range(len(inup))]
    #punused_z = [inup[i][2] for i in punused]
    punused_z =  inup[:,2]# Change  fast
    sort_idx = sorted(range(len(punused_z)), key=lambda k: punused_z[k])
    iunused = [punused[idx] for idx in sort_idx]
    unusedlist = [(x,inup[x][0],inup[x][1],inup[x][2]) for x in iunused]

    #unusedlist = sorted(range(len(punused_z)), key=lambda k: punused_z[k])# Change  fast
    

 
    cdef float minbatch_z, maxbatch_z
    
    #print ' just before the while loop.... ' , str(len(unusedlist))
    #while len(unusedlist)>10000000000:
    while len(unusedlist)>min_cls:
	#Find the minium and max  batch for z
        minbatch_z = unusedlist[0][3]
        #minbatch_z = unusedlist[0][2] #Changefast
        #print ' This is min z ' , str(minbatch_z)
	#This makes the batch list for unused to work with. 
        #unused_batchlist = [x for x in unusedlist if x[2]<minbatch_z+dist] # Change fast
        unused_batchlist = [x for x in unusedlist if x[3]<minbatch_z+dist]
	# Since it's sorted we can Use the last point as the farthest away point. 
        maxbatch_z = unused_batchlist[-1][3]
        #print ' This is max z ' , str(maxbatch_z)

	### Now make the added points list
        unused = unused_batchlist
	#Start a cluster
        temp_cluster = [unused[0]]
	#Start wit this added  point
        added_points =  [temp_cluster[0]]
	# remove it from the unused list since we will be uing it in the cluster
        unused.pop(0)

        temp_maxbatch_z = maxbatch_z
        while len(added_points)!=0:
            tmp_added = []
            for a in added_points:
	        #### Get some stuff for NN
                tmp_unused = []
                # Changed  RG
                append_tmp_unused = tmp_unused.append
                append_tmp_added = tmp_added.append
                append_temp_cluster = temp_cluster.append
                for u in unused:
                    if nn(a,u):
                        append_tmp_added(u)
		        #tmp_added.append(u)
                        append_temp_cluster(u)
		        #temp_cluster.append(u)
                    if not nn(a,u):
		        # Changed  RG
                        append_tmp_unused(u)
		        #tmp_unused.append(u)
                unused = tmp_unused
	        # Readjust the unused by adding extra points 
	        # Add points that are distance max z of temp cluster +dist
	        # this is going to be a time succk... but we need it for hookes with tracks on boundaries 

            #tunused = [x for x in unusedlist if  x[2] < max(temp_cluster,key=itemgetter(2))[2]+dist]#change Fast
            tunused = [x for x in unusedlist if  x[3] < max(temp_cluster,key=itemgetter(3))[3]+dist]
	    # Now remove the entries from front bactch that are already in the temp cluster
            unused = [x for x in tunused if x not in temp_cluster]
            added_points = tmp_added

        # When getting out of the While we should have we have to clean up
        if len(temp_cluster) >= min_cls:
            for idx in temp_cluster:
	        # Looping over the temp cluster and filling out the cluster label for the at the index in the index list
                indexlist[idx[0]] = clusterlabel
	    # KEep it and remove these points from the unused lis
            clusterlabel+=1
            unusedlist = [x for x in unusedlist if x not in temp_cluster]
	
        if len(temp_cluster) < min_cls:
            unusedlist = [x for x in unusedlist if x not in temp_cluster]
	# Still remove points from the unused
	# because this means we tried them
    ### The unused list should still remain sorted... so we can just pick up with the next batch step	
    return indexlist
