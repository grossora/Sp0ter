import numpy as np
import math as math

import wpca as wp
from scipy.spatial import ConvexHull



class Any_Object:
    def __init__(self,dataset,dataset_idx):
        self.dataset = dataset
        self.dataset_idx = dataset_idx

        # now try to fill all you can 
        #values to -999 if we cant
        try: 
            self.nspts = len(dataset_idx)
        except:
            self.nspts = -999
        # Make the points vector
        points = []
        q_wts = []
        tot_q = 0.0
        for i in dataset_idx:
            pt = [dataset[i][0],dataset[i][1],dataset[i][2]]
            this_q = dataset[i][3]  
            tot_q+=this_q
            qt = [this_q]
            points.append(pt)
            q_wts.append(qt)
        self.total_charge = tot_q
        #First try a convex hull
        try:
            hull = ConvexHull(points)
            min_bd = hull.min_bound
            max_bd = hull.max_bound
            # distance using NP 
            x_min = min_bd[0]
            y_min = min_bd[1]
            z_min = min_bd[2]
            x_max = max_bd[0]
            y_max = max_bd[1]
            z_max = max_bd[2]
            length_sq = (x_max-x_min)*(x_max-x_min) + (y_max-y_min)*(y_max-y_min) + (z_max-z_min)*(z_max-z_min)

            self.lenght = pow(length_sq,0.5) 
            self.area = hull.area 
            self.volume = hull.volume 
        except:
            self.lenght = -999
            self.area = -999
            self.volume = -999
        # Do the WPCA
        try:
            mpca = wp.WPCA(n_components=3)
            mpca.fit(points,weights=q_wts)
            self.wpca = [mpca.componets_[0],mpca.componets_[1],mpca.componets_[2]]
        except:
            self.wpca = [-999,-999,-999]
        try: 
            wavg = np.average(points, axis=0,weights=q_wts)
            self.wavg_point = [wavg[0],wavg[1],wavg[2]]
        except:
            self.wavg_point = [-999,-999,-999]


# This will just have light weight numbers not call any methods
class Shower:
    def __init__(self,dataset,dataset_idx,shower_id,nspts,total_charge,length,area,volume,wavg_point,wpca):
        self.dataset = dataset
        self.dataset_idx = dataset_idx
        self.shower_id = shower_id 
        self.nspts = nspts 
        self.total_charge = total_charge 
        self.length = length 
        self.area = area
        self.volume = volume
        self.wavg_point = wavg_point
        self.wpca = wpca


class Track:
    def __init__(self,dataset,dataset_idx,track_id,nspts,total_charge,length,area,volume):
        self.dataset = dataset
        self.dataset_idx = dataset_idx
        self.shower_id = track_id 
        self.nspts = nspts 
        self.total_charge = total_charge 
        self.length = length 
        self.area = area
        self.volume = volume
