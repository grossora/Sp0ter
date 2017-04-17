import numpy as np 

# Some method for detector Geometry 
x_lo = 0.0
x_hi = 256.0
y_lo = -116.0
y_hi = 116.0
z_lo = 0.0
#Check if this is correct... if so, remove the comment
z_hi = 1056.0



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


def In_TPC_Fid(spt, fid_xlo=0, fid_xhi=0, fid_ylo=0, fid_yhi=0, fid_zlo=0, fid_zhi=0):
    if spt[0] < x_lo+fid_xlo or spt[0]>x_hi-fid_xhi:
        return False
    if spt[1] <y_lo+fid_ylo or spt[1]>y_hi-fid_yhi:
        return False
    if spt[2] <z_lo+fid_zlo or spt[2]>z_hi-fid_zhi:
        return False
    return True



