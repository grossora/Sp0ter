import numpy as np
import lib.utility.Utils.datahandle as dh


def rebase_spts(f,dataset,showeridx_holder, ROI,roi_buffer, Charge_Thresh):

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
    rebase = dh.ConvertWC_InTPC_thresh('{}'.format(f),Charge_Thresh)
    #print ' are we getting the rebase length' 
    #print len( rebase)

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

    #print ' ROI idx length' 
    #print len( roi_idx)
    # make the return rebase_dataset
    re_dataset = [ rebase[x] for x in roi_idx]
    rebase_dataset = np.asanyarray(re_dataset)

    return rebase_dataset

'''
def rebase_spts(f,dataset,showeridx_holder, ROI,roi_buffer, Charge_Thresh):
    # Loop over the showeridx_ holder to find farthesst away point
    max_dist_sq = 0.0
    # we just look at the first one... .this hsould be a loop eventually
    roi_vtx = ROI[0][0]
    for h in range(len(showeridx_holder)):
	if h not in ROI[0][1:]:
	    continue
	for idx in showeridx_holder[h]:
	    tdist = pow(dataset[idx][0]-roi_vtx[0],2) +pow(dataset[idx][1]-roi_vtx[1],2) + pow(dataset[idx][2]-roi_vtx[2],2)
	    if tdist>max_dist_sq:
		#print 'this is the tdist'
		#print tdist
		max_dist_sq = tdist
    #Use the max value at the radius for the ROI
    #now loop over the rebase points
    
    
    #print ' what is max_dist'
    #print max_dist_sq
    rebase = dh.ConvertWC_InTPC_thresh('{}'.format(f),Charge_Thresh)
    #print ' are we getting the rebase length' 
    len( rebase)

    roi_idx = []
    for i in range(len(rebase)):
	rebase_test_dist = pow(rebase[i][0]-roi_vtx[0],2) +pow(rebase[i][1]-roi_vtx[1],2) + pow(rebase[i][2]-roi_vtx[2],2)
	if rebase_test_dist<max_dist_sq+roi_buffer:
	    # keep this 
	    roi_idx.append(i)

    #print ' ROI idx length' 
    len( roi_idx)
    # make the return rebase_dataset
    rebase_dataset = [ rebase[x] for x in roi_idx]

    return rebase_dataset
'''
