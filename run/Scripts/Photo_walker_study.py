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

#colors = 10*['r','g','b','c','y','m']
mycolors = 10*['r','g','b','c','y','m', 'pink','maroon']
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


df= []
if(len(sys.argv)==1):
    df0 = pd.read_csv('../Out_text/walker_gamma_small/photon_ana_obj_nn_6_mspt_20.txt', sep=" ", header = None)
    df1 = pd.read_csv('../Out_text/walker_gamma_small/photon_ana_obj_nn_6_mspt_60.txt', sep=" ", header = None)
    df2 = pd.read_csv('../Out_text/walker_gamma_small/photon_ana_obj_nn_6_mspt_100.txt', sep=" ", header = None)
    df3 = pd.read_csv('../Out_text/walker_gamma_small/photon_ana_obj_nn_8_mspt_20.txt', sep=" ", header = None)
    df4 = pd.read_csv('../Out_text/walker_gamma_small/photon_ana_obj_nn_8_mspt_60.txt', sep=" ", header = None)
    df5 = pd.read_csv('../Out_text/walker_gamma_small/photon_ana_obj_nn_8_mspt_100.txt', sep=" ", header = None)
    df6 = pd.read_csv('../Out_text/walker_gamma_small/photon_ana_obj_nn_10_mspt_20.txt', sep=" ", header = None)
    df7 = pd.read_csv('../Out_text/walker_gamma_small/photon_ana_obj_nn_10_mspt_60.txt', sep=" ", header = None)
    df8 = pd.read_csv('../Out_text/walker_gamma_small/photon_ana_obj_nn_10_mspt_100.txt', sep=" ", header = None)
    df.append(df0)
    df.append(df1)
    df.append(df2)
    df.append(df3)
    df.append(df4)
    df.append(df5)
    df.append(df6)
    df.append(df7)
    df.append(df8)
else:
    # This will be for looking at one 
    df0 = pd.read_csv('{}'.format(sys.argv[1]), sep=" ", header = None)
    df.append(df0)
    

for i in range(len(df)):
    df[i].columns = ['jcount', 'vtx_mc_x','vtx_mc_y','vtx_mc_z','p_mc_x','p_mc_y','p_mc_z','p_mc_mag','mc_qdep','N_Objects' ,'N_totSpts','N_spts','q_tot_obj','vtx_gamma_x','vtx_gamma_y','vtx_gamma_z', 'Wvtx_gamma_x', 'Wvtx_gamma_y','Wvtx_gamma_z', 'hull_length', 'hull_area', 'hull_volume', 'wpca_0' , 'wpca_1' , 'wpca_2',  'wpca_0r' , 'wpca_1r' , 'wpca_2r']


# Make a list of names..
fnames = ['nn_6_mspt20','nn_6_mspt60','nn_6_mspt_100','nn_8_mspt20','nn_8_mspt60','nn_8_mspt_100','nn_10_mspt20','nn_10_mspt60','nn_10_mspt_100']

######### First plot come general histograms about parameters


# Plot histograms for hull length
#for i in range(len(df)):
n, bins, patches = plt.hist([df[i].hull_length for i in range(len(df))],bins=15,range=(0,150),alpha = 0.8,label=fnames)
plt.legend()
plt.show()

for i in range(len(df)):
    n, bins, patches = plt.hist(df[i].hull_length ,bins=15,range=(0,150),alpha = 0.5,label=fnames[i])
plt.legend()
plt.title("hull Length")
plt.show()

for i in range(len(df)):
    n, bins, patches = plt.hist(df[i].N_Objects ,bins=15,range=(0,15),alpha = 0.6,label=fnames[i])
plt.legend()
plt.title("N_Objects")
plt.show()


for i in range(len(df)):
    n, bins, patches = plt.hist(df[i].N_spts ,bins=30,range=(0,5000),alpha = 0.5,label=fnames[i])
plt.legend()
plt.title("N_spts")
plt.show()



for i in range(len(df)):
    n, bins, patches = plt.hist(df[i].wpca_0r ,bins=50,range=(0.95,1),alpha = 0.6,label=fnames[i])
plt.legend()
plt.title("wpca0r")
plt.show()

for i in range(len(df)):
    plt.scatter(df[i].hull_length,df[i].wpca_0r ,facecolor = mycolors[i],label=fnames[i])
plt.legend()
plt.ylim(0.9,1)
plt.xlim(0.,200)
plt.title("length : wpca0r")
plt.show()



for i in range(len(df)):
    n, bins, patches = plt.hist(df[i].wpca_1r ,bins=30,range=(0,1),alpha = 0.5,label=fnames[i])
plt.legend()
plt.title("wpca1r")
plt.show()


for i in range(len(df)):
    n, bins, patches = plt.hist(df[i].wpca_2r ,bins=30,range=(0,1),alpha = 0.5,label=fnames[i])
plt.legend()
plt.title("wpca2r")
plt.show()

for i in range(len(df)):
    plt.scatter(df[i].hull_length, pow(df[i].hull_area,2./3),facecolor=mycolors[i],label=fnames[i])
    #plt.scatter(df[i].hull_length, df[i].hull_area,facecolor=mycolors[i],label=fnames[i])
plt.legend()
plt.ylim(0,600)
plt.xlim(0,300)
plt.title("hull scatter")
plt.show()


for i in range(len(df)):
    plt.scatter(df[i].hull_length, df[i].hull_area/df[i].hull_length,facecolor=mycolors[i],label=fnames[i])
    #plt.scatter(df[i].hull_length, df[i].hull_area,facecolor=mycolors[i],label=fnames[i])
plt.legend()
plt.ylim(0,100)
plt.xlim(0,300)
plt.title("hull SA / L scatter")
plt.show()




gdf = [df[i].groupby('jcount') for i in range(len(df))]

zerobin = []
for i in range(len(df)):
    n, bins, patches = plt.hist(gdf[i].N_Objects.first() ,bins=10,range=(0,10),alpha = 0.5,label=fnames[i])
    zerobin.append(float(n[0]))
plt.legend()
plt.xlim(0,10)
plt.title("nobjects")
plt.show()

print zerobin


for i in range(len(df)):
    n, bins, patches = plt.hist(df[i][df[i].N_Objects==0].p_mc_mag,bins=10,range=(0,2),alpha = 0.5,label=fnames[i])

plt.title("Energy of zero bin ")
plt.show()


for i in range(len(df)):
    n, bins, patches = plt.hist((gdf[i].mc_qdep.first()-0.5*gdf[i].q_tot_obj.max())/gdf[i].mc_qdep.first() ,bins=30,range=(0,1),alpha = 0.5,label=fnames[i])
plt.legend()
plt.xlim(0,1)
plt.title("charge resolution")
plt.show()


print 'AT THE END '


