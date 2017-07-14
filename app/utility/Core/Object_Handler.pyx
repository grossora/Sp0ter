import numpy as np
import math as math

import lib.utility.Core.Objects as UO


# Here we have to take in a list of labels or handles and return a list of shower objects


#This will always return a new list of showers
def Labels_to_ShowerList(dataset,datasetidx_holder):

    # make the return list 
    shower_list =  [] 

    for dsidx in range(len(datasetidx_holder)):

        #Make a shower object and put the values in the list
        my_obj = UO.Any_Object(dataset,datasetidx_holder[dsidx])

        # Now make a shower object we do this so we don't have to calcualte every time we call 
	#somethign like PCA or hull

        # dsixd is filling in for the shower id
        S = UO.Shower(dataset,datasetidx_holder[dsidx],dsidx,my_obj.nspts,my_obj.total_charge,my_obj.length,my_obj.area, my_obj.volume,my_obj.wavg_point,my_obj.wpca)
        shower_list.append(S)

    return shower_list
    


