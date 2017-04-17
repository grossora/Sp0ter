import os, sys 
import pandas as pd
import numpy as np
import seaborn as sns
import pylab as plt
import math as math
from scipy.stats import norm
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
#import matplotlib as mpl
#mpl.rc('lines', linewidth=4, color='r', markersize= 6)


# Save items? 
_save = True
#_save = True
#Show items?
_show = True 
#_show = True
#Where to save things? 
fig_dir = os.getcwd()+'/Figs/photon_Eff'
if not os.path.isdir(fig_dir):
    print 'makeing this for you'
    os.makedirs(fig_dir) 

if(len(sys.argv)==1):
    df = pd.read_csv('../Out_text/photon_ana_obj.txt', sep=" ", header = None)
else:
    df = pd.read_csv('{}'.format(sys.argv[1]), sep=" ", header = None)

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
total_events = 0
max_bin_ob = ev_df.N_Objects.max()
n, bins, patches = plt.hist(ev_df.N_Objects,bins=max_bin_ob,range=(0,max_bin_ob),facecolor='red',alpha = 0.8)
print ' total showers'
print n.sum()
total_events = n.sum()
plt.show()

#####################e
#####################e
cev_df = df[0.5*df.q_tot_obj>1000000].groupby('jcount')
#####################e
# Number of showers
#####################e
#max_bin_ob = max(cev_df.count())
ccev_df = cev_df.count()
#print ccev_df.q_tot_obj

count_df = [ x for x in ccev_df.q_tot_obj]
zfill =  total_events - len(count_df)
[count_df.append(0) for x in xrange(int(zfill))]
#Appendlen(count_df) on the zeros to make things pretty
len(count_df)

max_bin_ob = max(count_df)
print len(count_df)


print ' made it out'

n, bins, patches = plt.hist(count_df,bins=max_bin_ob,range=(0,max_bin_ob),facecolor='red',alpha = 0.8)
print n
plt.show()
#####################e


#####################e



#####################e
# Number of showers
#####################e
gev_df = df.groupby('jcount')


#n, bins, patches = plt.hist(gev_df.q_tot_obj.min(),bins=100,facecolor='green',range=(0,5000000),alpha = 0.8)
#n, bins, patches = plt.hist(gev_df.mc_qdep.first() ,bins=100,facecolor='red',range=(0,5000000),alpha = 0.8)
#plt.xlabel('min_reco_charge ')
#plt.ylabel('lalal')
#plt.title('mincharges')
#plt.show()


n, bins, patches = plt.hist(0.5*ev_df.q_tot_obj,bins=50,facecolor='green',range=(0,5000000),alpha = 0.5)
n, bins, patches = plt.hist(ev_df.mc_qdep ,bins=50,facecolor='red',range=(0,5000000),alpha = 0.8)
#n, bins, patches = plt.hist(ev_df.q_tot_obj,bins=100,facecolor='green',range=(0,5000000),alpha = 0.8,normed=1)
#n, bins, patches = plt.hist(ev_df.mc_qdep ,bins=100,facecolor='red',range=(0,5000000),alpha = 0.8,normed=1)
plt.xlabel('min_reco_charge ')
plt.ylabel('lalal')
plt.title('mincharges')
plt.show()


n, bins, patches = plt.hist(0.5*ev_df.q_tot_obj,bins=100,facecolor='green',range=(0,50000000),alpha = 0.5)
n, bins, patches = plt.hist(ev_df.mc_qdep ,bins=100,facecolor='red',range=(0,50000000),alpha = 0.8)
#n, bins, patches = plt.hist(ev_df.q_tot_obj,bins=100,facecolor='green',range=(0,5000000),alpha = 0.8,normed=1)
#n, bins, patches = plt.hist(ev_df.mc_qdep ,bins=100,facecolor='red',range=(0,5000000),alpha = 0.8,normed=1)
plt.xlabel('min_reco_charge Full ')
plt.ylabel('lalal')
plt.title('mincharges')
plt.show()





plt.hist2d(ev_df.p_mc_mag,ev_df.N_Objects,bins=20, range=[[0,2],[0,max_bin_ob]],cmap='viridis')
plt.xlabel('Energy (GeV)')
plt.ylabel('NShower')
plt.title('Reco_Shower V Energy')
plt.show()



# Let's compare the totall charge deposited wrt all charge clustered
n, bins, patches = plt.hist((gev_df.mc_qdep.max()-0.5*gev_df.q_tot_obj.sum() )/gev_df.mc_qdep.first() ,bins=20,facecolor='green',alpha = 0.8)
#n, bins, patches = plt.hist((gev_df.mc_qdep.first()-0.5*gev_df.q_tot_obj.sum() )/gev_df.mc_qdep.first() ,bins=20,facecolor='green',alpha = 0.8)
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
plt.xlabel('zposition')
plt.ylabel('charge resolution')
plt.title('charge_resolution V Energy')
plt.show()





plt.hist2d(ev_df.vtx_mc_z, (gev_df.mc_qdep.first()-0.5*gev_df.q_tot_obj.sum() )/gev_df.mc_qdep.first() ,bins=20, range=[[0,1100],[-0.1,1.1]],cmap='viridis')
plt.show()

plt.hist2d(ev_df.Wvtx_gamma_z, (gev_df.mc_qdep.first()-0.5*gev_df.q_tot_obj.sum() )/gev_df.mc_qdep.first() ,bins=20, range=[[0,1100],[-0.1,1.1]],cmap='viridis')
plt.show()







print 'AT THE END '


