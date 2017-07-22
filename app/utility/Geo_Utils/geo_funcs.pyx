import sys, os
import numpy as np
import lib.utility.Geo_Utils.detector as det




###########################################################################################
###################    functions to use for sq_distance    ################################
###########################################################################################
cdef inline float isquare_dist(float ax,float ay,float az ,float bx,float by,float bz ):
    return (ax-bx)*(ax-bx)+(ay-by)*(ay-by)+(az-bz)*(az-bz)

cdef float xDetL,yDetL,zDetL
xDetL = det.GetX_Length()
yDetL = det.GetY_Length()
zDetL =  det.GetZ_Length()


def square_dist(float ax,float ay,float az ,float bx,float by,float bz ):
    rets = isquare_dist( ax,ay, az ,bx, by, bz )
    return  rets
    #return (ax-bx)*(ax-bx)+(ay-by)*(ay-by)+(az-bz)*(az-bz)

###########################################################################################
#############     a few functions to use for the geometry ################################
###########################################################################################
def sqdist_ptline_to_point(pt_a,pt_b,pt_t):
    n = [pt_b[0]- pt_a[0],pt_b[1]- pt_a[1],pt_b[2]- pt_a[2]]
   # pt_t = [np.random.rand(),np.random.rand(),np.random.rand()]
    pa = [pt_a[0]- pt_t[0],pt_a[1]- pt_t[1],pt_a[2]- pt_t[2]]
    #c = n  * pa.n /n.n
    pan = (pa[0]*n[0] + pa[1]*n[1]+pa[2]*n[2])/ (n[0]*n[0] + n[1]*n[1]+n[2]*n[2])
    c = [n[0] * pan, n[1]*pan,n[2]*pan]
    d = [pa[0]-c[0], pa[1]-c[1],pa[2]-c[2]]
    return d[0]*d[0]+d[1]*d[1]+d[2]*d[2]


###########################################################################################
#############     a few functions to use to exptend lines   ###############################
###########################################################################################
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


###########################################################################################
##################    function to find 3d point from doca   ###############################
###########################################################################################
def find_midpt(pa,pa_dir,pb,pb_dir):
    #make all nparray 
    pa = np.asarray(pa)
    pb = np.asarray(pb)
    pa_dir = np.asarray(pa_dir)
    pb_dir = np.asarray(pb_dir)
    
    w0 = pa-pb
    a = np.dot(pa_dir,pa_dir)
    b = np.dot(pa_dir,pb_dir)
    c = np.dot(pb_dir,pb_dir)
    d = np.dot(pa_dir,w0)
    e = np.dot(pb_dir,w0)
    
    # Get critical point
    sc = (b*e-c*d)/(a*c - b*b)
    tc = (a*e - b*d)/(a*c - b*b)
    pasc = pa + sc*pa_dir
    pbsc = pb + tc*pb_dir

    # Return midpoint and distacne 
    midpt = (pasc+pbsc)/2.
    dist = np.sqrt(np.sum((pasc-pbsc)**2))

    return midpt , dist


def dist_point_line(p,l):
    #line comes in as [ point , dir ]
    p= np.asarray(p)
    q= np.asarray(l[0])
    v= np.asarray(l[1])
    
    w = p-q
    c1 = np.dot(w,v)
    c2 = np.dot(v,v)

    b = c1/c2
 
    pb = q +b*v
    # dist between points 
    dist = np.linalg.norm(pb-p)
    return dist




