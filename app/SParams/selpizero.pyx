import numpy as np
import math as math
import lib.utility.Geo_Utils.axisfit as af
from operator import itemgetter

def findvtx(shrA,shrB):
    # Get the first Shower 
    shrA_dir = shrA[1]
    shrB_dir = shrB[1]

    a = np.dot(shrA[1],shrA[1])
    b = np.dot(shrA[1],shrB[1])
    c = np.dot(shrB[1],shrB[1])
    d = np.dot(shrA[1],(shrA[0]-shrB[0]))
    e = np.dot(shrB[1],(shrA[0]-shrB[0]))
    # Check if non paralle
    den = a*c-b*b
    if den<0.0000001:
        print 'lines are too close'
    sc = (b*e-c*d)/(den)
    tc = (a*e-b*d)/(den)
    midway = (shrA[0]+sc*shrA[1] - (shrB[0]+tc*shrB[1]))/2
    vtx = shrA[0]+sc*shrA[1] - midway
    return vtx

def findRoughShowerStart(inup,shr_inup,vtx):
    #shr_inup is the shower points 
    #vtx is the vertex you want to reference too 
    
    #Find the set of n_ru clostest points to the vertex
    dset = [] 
    for ru in shr_inup:
        dist = pow(vtx[0]-inup[ru][0],2) +pow(vtx[1]-inup[ru][1],2) +pow(vtx[2]-inup[ru][2],2)
        s = (ru,dist, inup[ru][0], inup[ru][1], inup[ru][2])
        dset.append(s)
    dsort = sorted(dset,key = itemgetter(1))
    # now dsort is a sorted list of sets... sorted by sitance 
    ### How big does this need to be? hmmm maybe something like 50 points? 
	# For now just average...
	# Later we can be a little more fancy with outliers 
        # i.e. Then loop over n_ru with a simple point cluster to remove outliers 
    # Hard coded number for shower start point
    max_test = 50
    if len(dsort)<max_test:
        max_test = len(dsort)
    npav = np.asarray(dsort[0:max_test])
    xpos = npav.mean(0)[2]
    ypos = npav.mean(0)[3]
    zpos = npav.mean(0)[4]
    shsp = [xpos,ypos,zpos]
    return shsp

def findconversionlength(vtx,startpt):
    v = np.asarray(vtx)
    s = np.asarray(startpt)
    d = v-s
    dist = np.sqrt(d[0]*d[0]+d[1]*d[1]+d[2]*d[2])
    return dist

def findIP(shrA,shrB):
    # Get the first Shower 
    cdef float dist
    shrA_dir = shrA[1]
    shrB_dir = shrB[1]

    a = np.dot(shrA[1],shrA[1])
    b = np.dot(shrA[1],shrB[1])
    c = np.dot(shrB[1],shrB[1])
    d = np.dot(shrA[1],(shrA[0]-shrB[0]))
    e = np.dot(shrB[1],(shrA[0]-shrB[0]))
    # Check if non paralle
    den = a*c-b*b
    if den<0.0000001:
        print 'lines are too close'
    sc = (b*e-c*d)/(den)
    tc = (a*e-b*d)/(den)
    ptd  = (shrA[0]+sc*shrA[1] - (shrB[0]+tc*shrB[1]))
    dist = np.sqrt(ptd[0]*ptd[0]+ptd[1]*ptd[1]+ptd[2]*ptd[2])
    return dist


def openingangle(shrA, shrB, vtx):
    cdef float cos,angle
    shrA_dir = shrA[1]
    shrB_dir = shrB[1]
    pv = shrA[0]-vtx
    qv = shrB[0]-vtx
    pvu = pv/(np.sqrt(pv[0]*pv[0]+pv[1]*pv[1]+pv[2]*pv[2]))
    qvu = qv/(np.sqrt(qv[0]*qv[0]+qv[1]*qv[1]+qv[2]*qv[2]))
    dirA = np.dot(pvu,shrA_dir)
    dirB = np.dot(qvu,shrB_dir)
    #print ' This is the dir dits '
    #print dirA
    #print dirB
    if dirA<0: 
        shrA_dir = -1.*shrA_dir
    if dirB<0: 
        shrB_dir = -1.*shrB_dir
    #print ' This is the post dir dits '
    #print np.dot(pvu,shrA_dir)
    #print np.dot(pvu,shrB_dir)
    # Get the angle between 
    sma = np.sqrt(shrA_dir[0]*shrA_dir[0] + shrA_dir[1]*shrA_dir[1]+shrA_dir[2]*shrA_dir[2])
    smb = np.sqrt(shrB_dir[0]*shrB_dir[0] + shrB_dir[1]*shrB_dir[1]+shrB_dir[2]*shrB_dir[2])
    cos = np.dot(shrA_dir,shrB_dir) /( sma*smb  )
    #print 'this is cos ', str(cos)
    angle = math.acos(cos)
    #print 'this is angle ', str(angle)
    return angle
    
def totcharge(inup, indexset):
    cdef int s 
    cdef float totq
    totq =0.0
    for s in indexset:
        totq+= inup[s][3]
    # Shitty fit for energy 
    ############# NEEDS TO BE FIxED
    #fenergy = 2.5847*pow(10,-8) *totq +0.017209
    #return fenergy
    return totq

def comp_lifetime(charge,xpos):
    time =  xpos*2.32/256. # This is hard coded guess
    z = time/8.0
    lifetime = pow(math.e,z)
    return charge*lifetime

def corrected_energy(inup, indexset):
    tot =0.0
    for s in indexset:
	# Find the X position and then correct for energy with lifetime
        tot+= comp_lifetime(inup[s][3],inup[s][0])
    # Shitty fit for energy 
    ############# NEEDS TO BE FIxED
    #fenergy = 2.5847*pow(10,-8) *totq +0.017209
    #return fenergy
    return tot
       

def mass(ea,eb,angle):
    # make sure things are ok 
    if ea<=0 or eb <=0 :
        print ' energy is zero!!!'
        zm = 0
        return zm
    mass = np.sqrt(2.* ea*eb*(1-math.cos(angle)))
    return mass
    
    
    
    

    
