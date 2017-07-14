import numpy as np 
import math as math
import lib.utility.Geo_Utils.axisfit as axfi
import lib.utility.Geo_Utils.detector as detector
import lib.SParams.selpizero as selpz


##################################
# ----- list of function ------- #

# --- CorrelatedObjects 
# --- bloat_showers_ROI 
# --- CorrelatedObjectsROI
# --- perform_first_cut_type_pair
# --- perform_second_cut_type_pair

##################################

def CorrelatedObjects( dataset,idx_holder,labels):
    keptpairs = []
    if len(idx_holder) ==0:
        return keptpairs
    if len(idx_holder)==1:
        keptpairs = idx_holder
        return keptpairs

    for a in range(len(idx_holder)):
        shrA = axfi.weightshowerfit(dataset,idx_holder[a])
        EA = selpz.corrected_energy(dataset,idx_holder[a])
        ChargeA = selpz.totcharge(dataset,idx_holder[a])
        N_sptA = len(idx_holder[a])
        #print ' new pair '
        for b in range(a+1, len(idx_holder)):
            shrB = axfi.weightshowerfit(dataset,idx_holder[b])
            EB = selpz.corrected_energy(dataset,idx_holder[b])
            ChargeB = selpz.totcharge(dataset,idx_holder[b])
            N_sptB = len(idx_holder[b])
            vertex = selpz.findvtx(shrA,shrB)
            IP = selpz.findIP(shrA,shrB)
        #    print 'VERTEX ', str(vertex)
         #   print 'IP ', str(IP)
            SP_a = selpz.findRoughShowerStart(dataset,idx_holder[a],vertex)
            #print 'SP A : ', str(SP_a)
            radL_a = selpz.findconversionlength(vertex,SP_a)
            SP_b = selpz.findRoughShowerStart(dataset,idx_holder[b],vertex)
            #print 'SP B : ', str(SP_b)
            radL_b = selpz.findconversionlength(vertex,SP_b)
         #   print 'radL A', str(radL_a)
         #   print 'radL B', str(radL_b)
            angle = selpz.openingangle(shrA,shrB,vertex)
	    # If we pass the cuts.... keep this pair

	    # crap cut for fun
            if IP>20: 
               continue
            if angle<0.2: 
                continue
            if angle>2.94: 
                continue
            if radL_a>50 and radL_b>50: 
                continue
            keptpairs.append(a)
            keptpairs.append(b)

    # Clean up kept pairs
    retpairs = list(set(keptpairs))
    # make the output holder
    ret_holder = [ idx_holder[x] for x in retpairs]
    return ret_holder


def bloat_showers_ROI(dataset, idx_holder ,labels):
    cdef int a,i
    cdef float max_distsq,distsq,max_dist
    bloatROI = []
    if len(idx_holder) ==0:
        return bloatROI 
    for a in range(len(idx_holder)):
        # Find the weighted charge 
        points_v = []
        q_v = []
        for i in idx_holder[a]:
            points_v.append([dataset[i][0],dataset[i][1],dataset[i][2]])
            q_v.append(dataset[i][3])
        Wavg_xyz = np.average(points_v,axis=0, weights = q_v)
        # Now find the point farthest away
        # Return ROI,Dist
        max_distsq = 0.
        for i in idx_holder[a]:
            distsq =  ((Wavg_xyz[0] - dataset[i][0])**2)  +((Wavg_xyz[1] - dataset[i][1])**2) +((Wavg_xyz[2] - dataset[i][2])**2) 
            #distsq =  pow((Wavg_xyz[0] - dataset[i][0]),2) +pow((Wavg_xyz[1] - dataset[i][1]),2) +pow((Wavg_xyz[2] - dataset[i][2]),2) 
            if distsq>max_distsq:
                max_distsq=distsq
        # Once we get out... return the distance
        max_dist = math.sqrt(max_distsq)
        #max_dist = pow(max_distsq,0.5)
        # I don't care about speed
        bloatROI.append([Wavg_xyz,max_dist])
    return bloatROI

def CorrelatedObjectsROI( dataset,idx_holder,labels):
    # Retun a list that holds the ROI info [  [ROI].... ]
    # Each ROI :  [ vertex[x,y,z], shrAholderidx , ShrBholderidx ]
    preROI_list = []
    if len(idx_holder) ==0:
        return preROI_list 
    # it could be a large shower.... so fill here eventually
    if len(idx_holder)==1:
        keptpairs = idx_holder
        return preROI_list

    for a in range(len(idx_holder)):
        shrA = axfi.weightshowerfit(dataset,idx_holder[a])
        ChargeA = selpz.totcharge(dataset,idx_holder[a])
        for b in range(a+1, len(idx_holder)):
            shrB = axfi.weightshowerfit(dataset,idx_holder[b])
            ChargeB = selpz.totcharge(dataset,idx_holder[b])
            vertex = selpz.findvtx(shrA,shrB)
            IP = selpz.findIP(shrA,shrB)
            SP_a = selpz.findRoughShowerStart(dataset,idx_holder[a],vertex)
            radL_a = selpz.findconversionlength(vertex,SP_a)
            SP_b = selpz.findRoughShowerStart(dataset,idx_holder[b],vertex)
            radL_b = selpz.findconversionlength(vertex,SP_b)
            angle = selpz.openingangle(shrA,shrB,vertex)
	    # If we pass the cuts.... keep this pair

            passed = perform_first_cut_type_pair(vertex,IP,radL_a, radL_b, ChargeA, ChargeB, angle)
            if passed:
		# make the ROI
                temp_roi = [ vertex , a, b ]
                preROI_list.append(temp_roi)

    return preROI_list 


################################## 
# ------------ Cuts ------------ #
################################## 

def perform_first_cut_type_pair(vertex,IP,RadL_A, RadL_B, chargeA, chargeB, angle):
    #Hardcode cuts
    cdef float IP_cut, angle_cut_lo, angle_cut_hi, rad_max, rad_sum_min , charge_min
    IP_cut = 35
    angle_cut_lo = 0.6
    angle_cut_hi = 2.5
    rad_max = 50
    rad_sum_max = 70
    charge_sum_min = 1000000
    charge_min = 200000
    
    # Cut on vertex
    #if vertex[2]< 400:
    if vertex[2]< detector.GetZ_Length()/2:
        return False
    if IP>IP_cut: 
        return False
    if angle<angle_cut_lo: 
        return False
    if angle>angle_cut_hi: 
        return False
    if RadL_A > rad_max: 
        return False
    if RadL_B > rad_max: 
        return False
    if RadL_A + RadL_B > rad_sum_max: 
        return False
    if chargeA + chargeB < charge_sum_min: 
        return False
    if chargeA < charge_min: 
        return False
    if chargeB < charge_min: 
        return False

    return True


def perform_second_cut_type_pair(IP,RadL_A, RadL_B, chargeA, chargeB, angle):
    #Hardcode cuts
    IP_cut_min = 2.6
    angle_cut_lo = 0.9
    angle_cut_hi = 2.0
    charge_asym = 0.6
    charge_sum_min = 1700000
    charge_min = 250000

    if IP<IP_cut_min: 
        return False
    if angle<angle_cut_lo: 
        return False
    if angle>angle_cut_hi: 
        return False
    if math.fabs(chargeA- chargeB)/(chargeA + chargeB)>charge_asym:
        return False

    return True


