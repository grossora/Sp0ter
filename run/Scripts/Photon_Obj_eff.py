import os 
import sys
import pandas as pd
import numpy as np
import seaborn as sns
import pylab as plt
import math as math
import matplotlib.mlab as mlab
from scipy.stats import norm
import collections as col
from itertools import combinations
#sns.set()
import seaborn as sns
#sns.set(style="white", color_codes=True ,{'' : True})
sns.set_style("white", {"axes.grid": True})
#from matplotlib import colors
from matplotlib.colors import LogNorm

# Crap hack since path is messed up
sys.path.insert(0, "../../")
from lib.utility.Geo_Utils import detector as detector

colors = 10*['r','g','b','c','y','m']
import matplotlib as mpl
mpl.rc('lines', linewidth=4, color='r', markersize= 6)


# Save items? 
_save = True
#_save = True
#Show items?
_show = True 
#_show = True
#Where to save things? 
#fig_dir = os.getcwd()+'/Figs/test'
fig_dir = os.getcwd()+'/Figs/Nshower_pi0'
if not os.path.isdir(fig_dir):
    print 'makeing this for you'
    os.makedirs(fig_dir) 

if(len(sys.argv)==1):
    df = pd.read_csv('../Out_text/photon_ana_obj.txt', sep=" ", header = None)
else:
    df = pd.read_csv('{}'.format(sys.argv[1]), sep=" ", header = None)

    #df = pd.read_csv('{}'.format(sys.argv[1]), sep=" ", header = None)

#df.columns = ['jcount', 'vtx_mc_x','vtx_mc_y','vtx_mc_z','p_mc_x','p_mc_y','p_mc_z','p_mc_mag','mc_qdep','N_Objects' ,'N_spts','q_tot_obj','vtx_gamma_x','vtx_gamma_y','vtx_gamma_z', 'Wvtx_gamma_x', 'Wvtx_gamma_y','Wvtx_gamma_z', 'hull_length', 'hull_area', 'hull_volume', 'wpca_0' , 'wpca_1' , 'wpca_2',  'wpca_0r' , 'wpca_1r' , 'wpca_2r']

df.columns = ['jcount', 'vtx_mc_x','vtx_mc_y','vtx_mc_z','p_mc_x','p_mc_y','p_mc_z','p_mc_mag','mc_qdep','N_Objects' ,'N_totSpts','N_spts','q_tot_obj','vtx_gamma_x','vtx_gamma_y','vtx_gamma_z', 'Wvtx_gamma_x', 'Wvtx_gamma_y','Wvtx_gamma_z', 'hull_length', 'hull_area', 'hull_volume', 'wpca_0' , 'wpca_1' , 'wpca_2',  'wpca_0r' , 'wpca_1r' , 'wpca_2r']

print ' df make it to df? ' 
###############################e
# Set up some useful Dataframes
###############################e

# Spectrum of N showers per event
ev_df = df.groupby('jcount').first()


#####################e
# Some MC Plot to see what Energy We have 
#####################e
max_nrg_mc = ev_df.p_mc_mag.max()
n, bins, patches = plt.hist(ev_df.p_mc_mag,bins=15,facecolor='blue',alpha = 0.8)
plt.title('Shower Energy')
#n, bins, patches = plt.hist(ev_df.p_mc_mag,bins=max_nrg_mc,range=(0,max_nrg_mc),facecolor='red',alpha = 0.8)
plt.show()

#####################e
# Number of showers
#####################e
max_bin_ob = ev_df.N_Objects.max()
n, bins, patches = plt.hist(ev_df.N_Objects,bins=max_bin_ob,range=(0,max_bin_ob),facecolor='red',alpha = 0.8)
plt.show()




#####################e
#####################e
#####################e
#####################e
gev_df = df.groupby('jcount')



plt.hist2d(ev_df.p_mc_mag,ev_df.N_Objects,bins=20, range=[[0,2],[0,max_bin_ob]],cmap='viridis')
plt.xlabel('Energy (GeV)')
plt.ylabel('NShower')
plt.title('Reco_Shower V Energy')
plt.show()



# Let's compare the totall charge deposited wrt all charge clustered
n, bins, patches = plt.hist((gev_df.mc_qdep.first()-0.5*gev_df.q_tot_obj.sum() )/gev_df.mc_qdep.first() ,bins=20,facecolor='green',alpha = 0.8)
plt.xlabel("Resolution")
plt.title("charge Resolution")
plt.show()


plt.hist2d(ev_df.p_mc_mag, (gev_df.mc_qdep.first()-0.5*gev_df.q_tot_obj.sum() )/gev_df.mc_qdep.first() ,bins=20, range=[[0,2],[0,1]],cmap='viridis')
plt.xlabel('Energy (GeV)')
plt.ylabel('charge resolution')
plt.title('charge_resolution V Energy')
plt.show()



plt.scatter(ev_df.vtx_mc_z, (gev_df.mc_qdep.first()-0.5*gev_df.q_tot_obj.sum() )/gev_df.mc_qdep.first())
#plt.scatter(ev_df.vtx_mc_z, (gev_df.mc_qdep.first()-0.5*gev_df.q_tot_obj.sum() )/gev_df.mc_qdep.first() range=[[0,2],[0,1]])
#plt.scatter(ev_df.vtx_mc_z, (gev_df.mc_qdep.first()-0.5*gev_df.q_tot_obj.sum() )/gev_df.mc_qdep.first() ,bins=20, range=[[0,2],[0,1]],cmap='viridis')
plt.xlabel('zposition')
plt.ylabel('charge resolution')
plt.title('charge_resolution V Energy')
plt.show()












print 'AT THE END '








ev_df = []
n_vec = []



for i in range(len(df)):
    df[i] = df[i][(df[i].dalitz==0) ]
    ev_dft = df[i].groupby('jcount').first()
    ev_df.append(ev_dft)
    max_bin_ob = ev_dft.N_objects.max()
    n, bins, patches = plt.hist(ev_dft.N_objects,bins=max_bin_ob,range=(0,max_bin_ob),facecolor='red',alpha = 0.8)
    n_vec.append(n)
    plt.show()


print n_vec[:][0]

zero_bin = []
one_bin = []
two_bin = []
three_bin = []
#four_bin = []
gfour_bin = []
Bestpossible_bin = []
for i in n_vec:
    # Normalize this to 
    zero_bin.append(i[0]/np.sum(i[:]))
    one_bin.append(i[1]/np.sum(i[:]))
    two_bin.append(i[2]/np.sum(i[:]))
    three_bin.append(i[3]/np.sum(i[:]))
    #four_bin.append(i[4]/np.sum(i[:]))
    gfour_bin.append(np.sum(i[4:])/np.sum(i[:]))
    Bestpossible_bin.append(np.sum(i[2:])/np.sum(i[:]))


#Hard code in test xvvalues
xcharge = [2,2.5,3,3.5,4]

plt.plot(xcharge,zero_bin,'o-',label ='0 showers')
plt.plot(xcharge,one_bin,'o-',label ='1 showers')
plt.plot(xcharge,two_bin,'o-',label ='2 showers')
plt.plot(xcharge,three_bin,'o-',label ='3 showers')
#plt.plot(xcharge,four_bin,'o-',label ='4 showers')
plt.plot(xcharge,gfour_bin,'o-',label ='>3 showers')
plt.plot(xcharge,Bestpossible_bin,'sk--',label ='BestPossible')
#plt.legend(loc='upper center')
plt.legend(loc='upper right', shadow=True)
plt.xlabel('e ChargeThreshold(1^3)')
plt.ylabel('Fraction of N Shower Bins')
plt.show()









plt.title('Number of Showers')
if _save:
    plt.savefig('{}/N_showers.png'.format(fig_dir))
if _show:
    plt.show()
plt.close()



