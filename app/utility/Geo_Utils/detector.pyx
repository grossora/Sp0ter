import numpy as np 

# Some method for detector Geometry 
cdef float  x_lo, x_hi, y_lo,y_hi, z_lo,z_hi
x_lo = 0.0
x_hi = 256.35
y_lo = -116.5
y_hi = 116.5
z_lo = 0.0
#Check if this is correct... if so, remove the comment
z_hi = 1036.8



def GetX_Length():
    return x_hi-x_lo 
def GetY_Length():
    return y_hi-y_lo 
def GetZ_Length():
    return z_hi-z_lo 

def GetX_Bounds():
    return x_lo, x_hi

def GetY_Bounds():
    return y_lo, y_hi

def GetZ_Bounds():
    return z_lo, z_hi

def In_TPC(spt):
    if spt[0] <x_lo or spt[0]>x_hi:
        return False
    if spt[1] <y_lo or spt[1]>y_hi:
        return False
    if spt[2] <z_lo or spt[2]>z_hi:
        return False
    return True


def In_TPC_Fid(spt, float fid_xlo=0, float fid_xhi=0,float  fid_ylo=0, float fid_yhi=0, float fid_zlo=0, float fid_zhi=0):
    if spt[0] < x_lo+fid_xlo or spt[0]>x_hi-fid_xhi:
        return False
    if spt[1] <y_lo+fid_ylo or spt[1]>y_hi-fid_yhi:
        return False
    if spt[2] <z_lo+fid_zlo or spt[2]>z_hi-fid_zhi:
        return False
    return True


def In_Range_Fid(spt, float fid_xlo=0, float fid_xhi=0, float fid_ylo=0, float fid_yhi=0, float fid_zlo=0, float fid_zhi=0):
    if spt[0] < fid_xlo or spt[0]>fid_xhi:
        return False
    if spt[1] <fid_ylo or spt[1]>fid_yhi:
        return False
    if spt[2] <fid_zlo or spt[2]>fid_zhi:
        return False
    return True



