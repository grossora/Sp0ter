import numpy as np
import lib.utility.Utils.datahandle as dh
import lib.utility.Utils.labelhanle as lh

##################################
# ----- list of function ------- #

# --- pi0_cleanup 
# --- bloat_showers 
# --- rebase_spts 

##################################



def pi0_cleanup(f,dataset,showeridx_holder,labels):
    
    # Get all of the unclustered point
    
    # put them together 
    
    
    

    # Find the index points from the dataset that are not labeled yet
    unclustered_idx = [ x for x in range(len(labels)) if labels[x]==-1]
    print 'this is the length of the unclustered points to use ', str(len(unclustered_idx))

   

    return







def bloat_showers(f,dataset,showeridx_holder, ROI, float roi_buffer,float  Charge_Thresh):
    # Loop over the showeridx_ holder to find farthesst away point
    cdef int closest_ROI_ID, i,vrv
    cdef float max_dist_sq , closest_distsq_to_ROI, rebase_test_distsq
    max_dist_sq = 0.0
    # Now  Rebase the dataset to a lower charge thersh
    rebase = dh.ConvertWC_above_thresh('{}'.format(f),Charge_Thresh)

    roi_idx = []
    roi_id_list = []
    for i in range(len(rebase)):
        # Rebase point 
        # Check the point to be close to any give ROI with respective length thresh 
        closest_distsq_to_ROI = 10000000000000000000000000000.# This is hardcode for now # and using it as a pass... really shaddy....
        closest_ROI_ID = -1
	
        for vrv in range(len(ROI)):
        #for vrv in vert_Rad_V:
            rebase_test_distsq = pow(rebase[i][0]-ROI[vrv][0][0],2) +pow(rebase[i][1]-ROI[vrv][0][1],2) + pow(rebase[i][2]-ROI[vrv][0][2],2)
            if rebase_test_distsq<pow(ROI[vrv][1]+roi_buffer,2) and rebase_test_distsq<closest_distsq_to_ROI:
                # keep this 
                closest_distsq_to_ROI = rebase_test_distsq
                closest_ROI_ID = vrv

        if closest_ROI_ID!=-1:
            roi_idx.append(i)
            roi_id_list.append(ROI[closest_ROI_ID])
            #roi_id_list.append(vrv)
    re_dataset = [ rebase[x] for x in roi_idx]
    rebase_dataset = np.asanyarray(re_dataset)

    return rebase_dataset, roi_id_list



def rebase_spts(f,dataset,showeridx_holder, ROI,float roi_buffer, float Charge_Thresh):
    cdef float max_dist_sq 

    # Loop over the showeridx_ holder to find farthesst away point
    max_dist_sq = 0.0

    # loop over the ROI list and get the holders
    vertex_v = [ ROI[x][0] for x in range(len(ROI))]

    # Vertex and Radius 
    vert_Rad_V = [] 
    # ^^ This is [ [vertex , dist_sq]... ] 

    for roi in ROI:
        roi_vtx = roi[0]
        idx_A = roi[1]
        idx_B = roi[2]
        for h in showeridx_holder[idx_A]:
            tdist = pow(dataset[h][0]-roi_vtx[0],2) +pow(dataset[h][1]-roi_vtx[1],2) + pow(dataset[h][2]-roi_vtx[2],2)
            if tdist>max_dist_sq:
                max_dist_sq = tdist
        vert_Rad_V.append([roi_vtx,max_dist_sq])

    # Loop through the vert_roi_V and clean up repeats 
    # This will speed things up
    # Now  Rebase the dataset to a lower charge thersh
    rebase = dh.ConvertWC_above_thresh('{}'.format(f),Charge_Thresh)

    roi_idx = []
    for i in range(len(rebase)):
        # Rebase point 
        # Check the point to be close to any give ROI with respective length thresh 
        for vrv in vert_Rad_V:
            rebase_test_dist = pow(rebase[i][0]-vrv[0][0],2) +pow(rebase[i][1]-vrv[0][1],2) + pow(rebase[i][2]-vrv[0][2],2)
            if rebase_test_dist<pow(pow(vrv[1],0.5)+roi_buffer,2):
	        # keep this 
                roi_idx.append(i)
                break

    # make the return rebase_dataset
    re_dataset = [ rebase[x] for x in roi_idx]
    rebase_dataset = np.asanyarray(re_dataset)

    return rebase_dataset
