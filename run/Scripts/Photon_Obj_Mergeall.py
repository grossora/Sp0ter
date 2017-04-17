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
from scipy import stats
from scipy.stats import norm



# Crap hack since path is messed up
sys.path.insert(0, "../../")
from lib.utility.Geo_Utils import detector as detector

colors = 10*['r','g','b','c','y','m']
import matplotlib as mpl
mpl.rc('lines', linewidth=4, color='r', markersize= 6)
mycmap = 'afmhot'
#mycmap = 'hot'
#mycmap = 'jet'


# Save items? 
_save = True
#_save = True
#Show items?
_show = True 
#_show = True
#Where to save things? 
#fig_dir = os.getcwd()+'/Figs/test'
fig_dir = os.getcwd()+'/Figs/MergeAll'
if not os.path.isdir(fig_dir):
    print 'makeing this for you'
    os.makedirs(fig_dir) 

if(len(sys.argv)==1):
    df = pd.read_csv('../Out_text/photon_ana_obj.txt', sep=" ", header = None)
else:
    df = pd.read_csv('{}'.format(sys.argv[1]), sep=" ", header = None)


df.columns = ['jcount', 'vtx_mc_x','vtx_mc_y','vtx_mc_z','p_mc_x','p_mc_y','p_mc_z','p_mc_mag','mc_qdep','N_Objects' ,'N_totSpts','N_spts','q_tot_obj','vtx_gamma_x','vtx_gamma_y','vtx_gamma_z', 'Wvtx_gamma_x', 'Wvtx_gamma_y','Wvtx_gamma_z', 'hull_length', 'hull_area', 'hull_volume', 'wpca_0' , 'wpca_1' , 'wpca_2',  'wpca_0r' , 'wpca_1r' , 'wpca_2r']

def Charge_Correction(charge):
    Wion = 23.6 * pow(10,-6)
    recomb = 1./(1.-0.38)

    return charge*Wion*recomb 

print ' df make it to df? ' 
###############################e
# Set up some useful Dataframes
###############################e

# Spectrum of N showers per event
ev_df = df.groupby('jcount').first()


#####################e
# Some MC Plot to see what Energy We have 
#####################e
#max_nrg_mc = ev_df.p_mc_mag.max()
#n, bins, patches = plt.hist(ev_df.p_mc_mag,bins=15,facecolor='blue',alpha = 0.8)
#plt.title('Shower Energy')
#n, bins, patches = plt.hist(ev_df.p_mc_mag,bins=max_nrg_mc,range=(0,max_nrg_mc),facecolor='red',alpha = 0.8)
#plt.show()


# Let's compare the totall charge deposited wrt all charge clustered
# Pre - factor fit 
t = np.arange(0., 100000000, 1000)
plt.hist2d(ev_df.mc_qdep,ev_df.q_tot_obj , bins=100, range=[[0,100000000],[0,100000000]],cmap='gnuplot2', norm=LogNorm())
plt.plot(t,t,'k',label='y=x')
plt.plot(t,2*t,'r-',label='y=2x')
plt.legend(loc='upper left')
plt.title("Reco_Charge vs MC_charge")
plt.xlabel("mc_q (e)")
plt.ylabel("reco_q(e)")
if _save:
    plt.savefig('{}/recovmccharge.png'.format(fig_dir))
plt.show()
plt.close()


n, bins, patches = plt.hist((ev_df.mc_qdep-ev_df.q_tot_obj )/ev_df.mc_qdep ,bins=60,range=[-0.2,1],facecolor='green',alpha = 0.8)
plt.xlabel("q_Resolution")
plt.title("MergeAll WC Charge Resolution")
if _save:
    plt.savefig('{}/chargeres.png'.format(fig_dir))
plt.show()
plt.close()



plt.hist2d(ev_df.vtx_mc_z, (ev_df.mc_qdep-ev_df.q_tot_obj )/ev_df.mc_qdep ,bins=70, range=[[0,1100],[-0.2,1]],cmap=mycmap ,norm=LogNorm())
plt.xlabel('zposition (cm)')
plt.ylabel('charge resolution')
plt.title('Charge_Res vs. z position ')
if _save:
    plt.savefig('{}/chargeresvz.png'.format(fig_dir))
plt.show()
plt.close()


plt.hist2d(ev_df.Wvtx_gamma_z, (ev_df.mc_qdep-ev_df.q_tot_obj )/ev_df.mc_qdep ,bins=70, range=[[0,1100],[-0.2,1]],cmap=mycmap,norm=LogNorm() )
plt.xlabel('Wcharge zposition (cm)')
plt.ylabel('charge resolution')
plt.title('Charge_Res vs. wcharge z positon ')
if _save:
    plt.savefig('{}/chargeresvWz.png'.format(fig_dir))
plt.show()
plt.close()





#Lets look at the resolution in the fiducial region

fid_zlo = 300
fidev_df = ev_df[ev_df.Wvtx_gamma_z>fid_zlo]

n, bins, patches = plt.hist((fidev_df.mc_qdep-fidev_df.q_tot_obj )/fidev_df.mc_qdep ,bins=60,range=[-0.2,1],facecolor='green',alpha = 0.8)
plt.xlabel("Resolution")
plt.title("Charge Resolution With z>300 Fid cut")
if _save:
    plt.savefig('{}/chargeresz300.png'.format(fig_dir))
plt.show()
plt.close()

plt.hist2d(fidev_df.mc_qdep,(fidev_df.mc_qdep-fidev_df.q_tot_obj )/fidev_df.mc_qdep ,bins=60,range=[[0,50000000],[-1,1]],cmap=mycmap,norm=LogNorm())
plt.xlabel("true_q dep")
plt.title("charge Resolution With z>300 Fid cut vs True Dep Charge")
if _save:
    plt.savefig('{}/chargeresvtruez300.png'.format(fig_dir))
plt.show()
plt.close()

plt.hist2d(fidev_df.q_tot_obj,(fidev_df.mc_qdep-fidev_df.q_tot_obj )/fidev_df.mc_qdep ,bins=60,range=[[0,50000000],[-1,1]],cmap=mycmap,norm=LogNorm())
plt.xlabel("recoq")
plt.title("charge Resolution With z>300 Fid cut vs Reco Charge")
if _save:
    plt.savefig('{}/chargeresvrecoz300.png'.format(fig_dir))
plt.show()
plt.close()



###############################################
# Convert this to energy and see what happens
###############################################


n, bins, patches = plt.hist((fidev_df.p_mc_mag-Charge_Correction(fidev_df.q_tot_obj/1000.) )/fidev_df.p_mc_mag ,bins=60,range=[-1,1],facecolor='red',alpha = 0.8)
plt.xlabel("Resolution")
plt.title("Energy Resolution With z>300 Fid cut")
if _save:
    plt.savefig('{}/ERes300.png'.format(fig_dir))
plt.show()
plt.close()


n, bins, patches = plt.hist((0.-fidev_df.p_mc_mag+Charge_Correction(fidev_df.q_tot_obj/1000.) )/fidev_df.p_mc_mag ,bins=60,range=[-1,1],facecolor='red',alpha = 0.8)
plt.xlabel("Resolution")
plt.title("Energy Resolution With Fid cut FOR 2D Compare")

plt.scatter(fidev_df.Wvtx_gamma_x,fidev_df.Wvtx_gamma_y,c=((fidev_df.p_mc_mag-Charge_Correction(fidev_df.q_tot_obj/1000.) )/fidev_df.p_mc_mag),cmap=plt.cm.jet)
plt.colorbar()
plt.title('XY-position for Wcharge position : resolution in color')
plt.ylabel('y-position')
plt.xlabel('x-position')
if _save:
    plt.savefig('{}/XYRes300.png'.format(fig_dir))
plt.show()
plt.close()

plt.scatter(fidev_df.Wvtx_gamma_z,fidev_df.Wvtx_gamma_x,c=((fidev_df.p_mc_mag-Charge_Correction(fidev_df.q_tot_obj/1000.) )/fidev_df.p_mc_mag),cmap=plt.cm.jet)
plt.colorbar()
plt.title('XZ-position for Wcharge position : resolution in color')
plt.xlabel('z-position')
plt.ylabel('x-position')
plt.show()



xfid = 18
yfid = 18
fid_xlo = detector.GetX_Bounds()[0] +xfid
fid_xhi = detector.GetX_Bounds()[1] -xfid
fid_ylo = detector.GetY_Bounds()[0] +yfid
fid_yhi = detector.GetY_Bounds()[1] -yfid

fid_zlo = 300
fid_zhi = 1100
Tfidev_df = ev_df[(ev_df.Wvtx_gamma_x>fid_xlo) & (ev_df.Wvtx_gamma_x<fid_xhi)&(ev_df.Wvtx_gamma_y>fid_ylo)& (ev_df.Wvtx_gamma_y<fid_yhi)& (ev_df.Wvtx_gamma_z>fid_zlo)  ]


n, bins, patches = plt.hist((Tfidev_df.p_mc_mag-Charge_Correction(Tfidev_df.q_tot_obj/1000.) )/Tfidev_df.p_mc_mag ,bins=60,range=[-1,1],facecolor='red',alpha = 0.8)
plt.xlabel("Resolution")
plt.title("Energy Resolution With TFid cut")
if _save:
    plt.savefig('{}/EnergyResTfid.png'.format(fig_dir))
plt.show()
plt.close()

plt.scatter(Tfidev_df.Wvtx_gamma_x,Tfidev_df.Wvtx_gamma_y,c=((Tfidev_df.p_mc_mag-Charge_Correction(Tfidev_df.q_tot_obj/1000.) )/Tfidev_df.p_mc_mag),cmap=plt.cm.jet)
plt.colorbar()
plt.show()

plt.hist2d(Tfidev_df.p_mc_mag,(Tfidev_df.p_mc_mag-Charge_Correction(Tfidev_df.q_tot_obj/1000.) )/Tfidev_df.p_mc_mag ,bins=50,range=[[0,2],[-1,1]],cmap=mycmap,norm=LogNorm())
plt.xlabel("MCEnergy GeV")
plt.title("Energy Resolution vs. Reco Energy  ")
if _save:
    plt.savefig('{}/EnergyResvtrueTfid.png'.format(fig_dir))
plt.show()
plt.close()

plt.hist2d(Charge_Correction(Tfidev_df.q_tot_obj/1000.),(Tfidev_df.p_mc_mag-Charge_Correction(Tfidev_df.q_tot_obj/1000.) )/Tfidev_df.p_mc_mag ,bins=50,range=[[0.05,2],[-1,1]],cmap=mycmap,norm=LogNorm())
plt.xlabel("RecoEnergy GeV")
plt.title("Energy Resolution vs. Reco Energy  ")
if _save:
    plt.savefig('{}/EnergyResvrecoTfid.png'.format(fig_dir))
plt.show()
plt.close()



n, bins, patches = plt.hist(ev_df.p_mc_mag,bins=15,facecolor='blue',alpha = 0.8)
plt.show()
n, bins, patches = plt.hist(Charge_Correction(Tfidev_df.q_tot_obj) ,bins=20,facecolor='red',alpha = 0.8)
plt.title("Reconstructed Energy Spectrum")
plt.xlabel("Energy (MeV)")
if _save:
    plt.savefig('{}/EnergyRecoSpect.png'.format(fig_dir))
plt.show()
plt.close()


