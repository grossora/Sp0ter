import numpy as np
import ROOT
import mchandle as mh

#Need to define detector volumes


###########################################################
#---------- Get some basic file info ---------------------#
###########################################################
def F_Info(f):
#    event = f.rsplit('/',1)[1].split('.')[0].split('_')[1]
#    run = f.rsplit('/',1)[1].split('.')[0].split('_')[2]
#    subrun = f.rsplit('/',1)[1].split('.')[0].split('_')[3]
    GoodBad = True
#    ers = str(event)+'_'+str(run)+'_'+str(subrun)
    # The file
    fi = ROOT.TFile("{}".format(f))
    #### Check if file is zomobie
    if fi.IsZombie():
        print 'We have a Zombie!'
        fline =[ -1 for x in range(15)] ### Fix to what ever the number is
        #rfline = ers+' '+ str(fline).split('[')[1].rsplit(']')[0].replace(',','')+ '\n'
        rfline = str(fline).split('[')[1].rsplit(']')[0].replace(',','')+ '\n'
        #rfline = event+' '+run+' '+subrun+' '+ str(fline).split('[')[1].rsplit(']')[0].replace(',','')+ '\n'
        GoodBad = False
        return GoodBad
    rt= fi.Get("T_rec_charge_blob")
    #rt= fi.Get("T_rec_charge")
    if rt.GetEntries()==0:
        print 'AHHHH Got nothing...'
        fline =[ -2 for x in range(15)] ### Fix to what ever the number is
        rfline = str(fline).split('[')[1].rsplit(']')[0].replace(',','')+ '\n'
        #rfline = event+' '+run+' '+subrun+' '+ str(fline).split('[')[1].rsplit(']')[0].replace(',','')+ '\n'
        GoodBad = False
        return GoodBad 
    return GoodBad

def F_Info_Cosmic_2(f):
    print f
    dirnum = f.rsplit('/')[-2]
    event = f.rsplit('/')[-1].split('.')[0].rsplit('_')[-1] 
    GoodBad = True
    de = str(dirnum)+'_'+str(event)
    # The file
    fi = ROOT.TFile("{}".format(f))
    #### Check if file is zomobie
    if fi.IsZombie():
        print 'We have a Zombie!'
        fline =[ -1 for x in range(18)] ### Fix to what ever the number is
        rfline = de+' '+ str(fline).split('[')[1].rsplit(']')[0].replace(',','')+ '\n'
        GoodBad = False
        return GoodBad, de 
    rt= fi.Get("T_rec_charge_blob")
    #rt= fi.Get("T_rec_charge")
    # This will need a try/catch
    if rt.GetEntries()==0:
        print 'AHHHH Got nothing...'
        fline =[ -2 for x in range(18)] ### Fix to what ever the number is
        rfline = de+' '+ str(fline).split('[')[1].rsplit(']')[0].replace(',','')+ '\n'
        GoodBad = False
        return GoodBad, de 
    return GoodBad , de

def F_Info_Cosmic(f):
    print f
    dirnum = f.rsplit('/')[-2]
    event = f.rsplit('/')[-1].split('.')[0].rsplit('_')[-1] 
    GoodBad = True
    de = str(dirnum)+'_'+str(event)
    # The file
    fi = ROOT.TFile("{}".format(f))
    #### Check if file is zomobie
    if fi.IsZombie():
        print 'We have a Zombie!'
        fline =[ -1 for x in range(18)] ### Fix to what ever the number is
        rfline = de+' '+ str(fline).split('[')[1].rsplit(']')[0].replace(',','')+ '\n'
        GoodBad = False
        return GoodBad, de 
    rt= fi.Get("T_rec_charge_blob")
    #rt= fi.Get("T_rec_charge")
    # This will need a try/catch
    if rt.GetEntries()==0:
        print 'AHHHH Got nothing...'
        fline =[ -2 for x in range(18)] ### Fix to what ever the number is
        rfline = de+' '+ str(fline).split('[')[1].rsplit(']')[0].replace(',','')+ '\n'
        GoodBad = False
        return GoodBad, de 
    return GoodBad , de

######################################################################



   
########################################
#----- Handshakes for the data
########################################

def Unique(infile): 
    #returns all unique
    b = np.ascontiguousarray(infile).view(np.dtype((np.void, infile.dtype.itemsize * infile.shape[1])))
    _, idx = np.unique(b, return_index=True)
    return infile[idx]

def DuplicateIDX(lst,value):
    #returns a list of duplicated 
    return [i for i, x in enumerate(lst) if x == value]

def ConvertWC_InRange(infile,xlo,xhi,ylo,yhi,zlo,zhi, float qt=0.0 ):
    #Bring in the file 
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("T_rec_charge_blob")
    # Parse into an array 
    sptarray = []
    for entry in t:
        if entry.q>qt and entry.x>xlo and entry.x<xhi and entry.y>ylo and entry.y<yhi and entry.z>zlo and entry.z<zhi and entry.type==1: 
            sptarray.append([entry.x,entry.y,entry.z,entry.q])
    #make this an ndarray    
    spta = np.asanyarray(sptarray)
    cleanspta = Unique(spta)
    return cleanspta

def ConvertWCMC(infile):
    #Bring in the file 
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("T_true")
    # Parse into an array 
    sptarray = []
    for entry in t:
        sptarray.append([entry.x,entry.y,entry.z,entry.q])
    #make this an ndarray    
    spta = np.asanyarray(sptarray)
    return spta

def ConvertWC(infile):
    #Bring in the file 
    f = ROOT.TFile("{}".format(infile))
    #t = f.Get("T_rec_charge")
    t = f.Get("T_rec_charge_blob")
    # Parse into an array 
    sptarray = []
    for entry in t:
        if entry.q!=0.0 and entry.type==1: 
            sptarray.append([entry.x,entry.y,entry.z,entry.q])
    #make this an ndarray    
    spta = np.asanyarray(sptarray)
    #Make sure all points are unique
    cleanspta = Unique(spta)
    return cleanspta

 
def ConvertWC_above_thresh(infile,float qt):
    #Bring in the file 
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("T_rec_charge_blob")
    # Parse into an array 
    sptarray = []
    for entry in t:
        if entry.q>qt and entry.type==1: 
            sptarray.append([entry.x,entry.y,entry.z,entry.q])
    #make this an ndarray    
    spta = np.asanyarray(sptarray)
    cleanspta = Unique(spta)
    return cleanspta
 
def ConvertWC_FauxTrue_above_thresh(infile,float qt):
    #Bring in the file 
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("T_true")
    # Parse into an array 
    sptarray = []
    for entry in t:
        if entry.q>qt : 
            sptarray.append([entry.x,entry.y,entry.z,entry.q])
    #make this an ndarray    
    spta = np.asanyarray(sptarray)
    cleanspta = Unique(spta)
    return cleanspta


def Convert_olddata_WC_above_thresh(infile,float qt):
    #Bring in the file 
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("T_rec_charge_blob")
    # Parse into an array 
    sptarray = []
    for entry in t:
        if entry.q>qt: 
            sptarray.append([entry.x,entry.y,entry.z,entry.q])
    #make this an ndarray    
    spta = np.asanyarray(sptarray)
    cleanspta = Unique(spta)
    return cleanspta
########################################

def Get_Total_MC_Charge(infile):
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("T_true")
    # Parse into an array  
    tot_q = 0.0
    for entry in t:
        tot_q +=entry.q
    return tot_q
   
def Get_Total_Thresh_Charge(infile,Thresh):
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("T_rec_charge_blob")
    # Parse into an array  
    tot_q = 0.0
    for entry in t:
        if entry.q>Thresh and entry.type==1:
            tot_q +=entry.q
    return tot_q

def Get_Total_Object_Charge(dataset,datasetidx_holder):
    tot_q = 0.0
    for c in datasetidx_holder:
        for i in c:
            tot_q +=dataset[i][3]
    return tot_q









###########################################################
#---------- Fill out the Json        ---------------------#
###########################################################


def MakeJsonMC(f,str jpath, int jcount,reco_label,mc_dl):
    # Bring in the MC set of Space points
    dataset = ConvertWCMC(f)
    #MC Labels special for Pi0
    mlabels = mc_dl[1]
    #Make data list of list to fit the length of the dataset and the mc objects
    data = [[dataset[i][0],dataset[i][1],dataset[i][2],dataset[i][3],1] for i in range(len(dataset))]
    [data.append([mc_dl[0][i][0],mc_dl[0][i][1],mc_dl[0][i][2],0.0, 1]) for i in range(len(mlabels))]
    #prep things to fill out 
    output_x = ["%.1f" % data[k][0] for k in range(len(data))]
    new_output_x = '[%s]' % ','.join(map(str,output_x))
    output_y = ["%.1f" % data[k][1] for k in range(len(data))]
    new_output_y = '[%s]' % ','.join(map(str,output_y))
    output_z = ["%.1f" % data[k][2] for k in range(len(data))]
    new_output_z = '[%s]' % ','.join(map(str,output_z))
    output_q = ["%.1f" % data[k][3] for k in range(len(data))]
    new_output_q = '[%s]' % ','.join(map(str,output_q))
    output_nq = ["%.1f" % data[k][4] for k in range(len(data))]
    new_output_nq = '[%s]' % ','.join(map(str,output_nq))

    # Write out the line for the BeeStructure
    l = "{ \"x\":%s, \"y\":%s, \"z\":%s, \"q\":%s, \"nq\":%s, \"type\":\"truth\", \"runNo\":\"1\", \"subRunNo\":\"1\", \"eventNo\":\"1\", \"geom\":\"uboone\" }" % (new_output_x,new_output_y,new_output_z,new_output_q,new_output_nq)

    # open a text file     
    lookup = open('{}/{}-{}.json'.format(jpath,str(jcount),reco_label),'a+')
    lookup.writelines(l)
    lookup.close()
    return
#################################################################################################################
def MakeJsonReco_2(f, str jpath,int jcount, str reco_label,mc_dl):
    dataset = ConvertWC(f)
    # ^^ This add a few seconds
    mlabels = []
    if  len(mc_dl)!=0:
        mlabels = mc_dl[1]
    
    data = [[dataset[i][0],dataset[i][1],dataset[i][2],dataset[i][3],1] for i in range(len(dataset))]
    [data.append([mc_dl[0][i][0],mc_dl[0][i][1],mc_dl[0][i][2],0.0, 1]) for i in range(len(mlabels))]

    output_x = ["%.1f" % data[k][0] for k in range(len(data))]
    new_output_x = '[%s]' % ','.join(map(str,output_x))
    output_y = ["%.1f" % data[k][1] for k in range(len(data))]
    new_output_y = '[%s]' % ','.join(map(str,output_y))
    output_z = ["%.1f" % data[k][2] for k in range(len(data))]
    new_output_z = '[%s]' % ','.join(map(str,output_z))
    output_q = ["%.1f" % data[k][3] for k in range(len(data))]
    new_output_q = '[%s]' % ','.join(map(str,output_q))
    output_nq = ["%.1f" % data[k][4] for k in range(len(data))]
    new_output_nq = '[%s]' % ','.join(map(str,output_nq))
    l = "{ \"x\":%s, \"y\":%s, \"z\":%s, \"q\":%s, \"nq\":%s, \"type\":\"truth\", \"runNo\":\"1\", \"subRunNo\":\"1\", \"eventNo\":\"1\", \"geom\":\"uboone\" }" % (new_output_x,new_output_y,new_output_z,new_output_q,new_output_nq)
    # open a text file     
    lookup = open('{}/{}-{}.json'.format(jpath,str(jcount),reco_label),'a+')
    lookup.writelines(l)
    lookup.close()
    return
	
def MakeJson(dataset,labels,str jpath, int jcount,str reco_label,mc_dl):
    mlabels = []
    if len(mc_dl)!=0:
        mlabels = mc_dl[1]
    data = [[dataset[i][0],dataset[i][1],dataset[i][2],(10*(labels[i] %20)/22.+2) *3600.,1] for i in range(len(dataset)) if labels[i]!=-1]
    [data.append([dataset[i][0],dataset[i][1],dataset[i][2],0.,1]) for i in range(len(dataset)) if labels[i]==-1]
    [data.append([mc_dl[0][i][0],mc_dl[0][i][1],mc_dl[0][i][2],float(1) *5000., 1]) for i in range(len(mlabels))]

    output_x = ["%.1f" % data[k][0] for k in range(len(data))]
    new_output_x = '[%s]' % ','.join(map(str,output_x))
    output_y = ["%.1f" % data[k][1] for k in range(len(data))]
    new_output_y = '[%s]' % ','.join(map(str,output_y))
    output_z = ["%.1f" % data[k][2] for k in range(len(data))]
    new_output_z = '[%s]' % ','.join(map(str,output_z))
    output_q = ["%.1f" % data[k][3] for k in range(len(data))]
    new_output_q = '[%s]' % ','.join(map(str,output_q))
    output_nq = ["%.1f" % data[k][4] for k in range(len(data))]
    new_output_nq = '[%s]' % ','.join(map(str,output_nq))

    # Write out the line for the BeeStructure
    l = "{ \"x\":%s, \"y\":%s, \"z\":%s, \"q\":%s, \"nq\":%s, \"type\":\"truth\", \"runNo\":\"1\", \"subRunNo\":\"1\", \"eventNo\":\"1\", \"geom\":\"uboone\" }" % (new_output_x,new_output_y,new_output_z,new_output_q,new_output_nq)
    
    # open a text file     
    lookup = open('{}/{}-{}.json'.format(jpath,str(jcount),reco_label),'a+')
    # Write the Jsonline 
    lookup.writelines(l)
    lookup.close()
    return

def MakeJson_Objects(dataset,datasetidx_holder,labels,jpath,jcount,reco_label,mc_dl):
    mlabels = []
    if len(mc_dl)!=0:
        mlabels = mc_dl[1]
    holder_idx_lab = [item for sublist in datasetidx_holder for item in sublist]
    data = [[dataset[i][0],dataset[i][1],dataset[i][2],(10*(labels[i] %20)/22.+2) *3600.,1] for i in holder_idx_lab if labels[i]!=-1]
    [data.append([mc_dl[0][i][0],mc_dl[0][i][1],mc_dl[0][i][2],float(1) *5000., 1]) for i in xrange(len(mlabels))]

    output_x = ["%.1f" % data[k][0] for k in range(len(data))]
    new_output_x = '[%s]' % ','.join(map(str,output_x))
    output_y = ["%.1f" % data[k][1] for k in range(len(data))]
    new_output_y = '[%s]' % ','.join(map(str,output_y))
    output_z = ["%.1f" % data[k][2] for k in range(len(data))]
    new_output_z = '[%s]' % ','.join(map(str,output_z))
    output_q = ["%.1f" % data[k][3] for k in range(len(data))]
    new_output_q = '[%s]' % ','.join(map(str,output_q))
    output_nq = ["%.1f" % data[k][4] for k in range(len(data))]
    new_output_nq = '[%s]' % ','.join(map(str,output_nq))
    l = "{ \"x\":%s, \"y\":%s, \"z\":%s, \"q\":%s, \"nq\":%s, \"type\":\"truth\", \"runNo\":\"1\", \"subRunNo\":\"1\", \"eventNo\":\"1\", \"geom\":\"uboone\" }" % (new_output_x,new_output_y,new_output_z,new_output_q,new_output_nq)
    # open a text file     
    #lookup = open('{}/{}-reco.json'.format(jpath,str(jcount)),'w')
    lookup = open('{}/{}-{}.json'.format(jpath,str(jcount),reco_label),'a+')
    lookup.writelines(l)
    lookup.close()
    return



# Make lines for PCA
import wpca as wp


def MakeJsonShower_Params(dataset,datasetidx_holder,labels,jpath,jcount,reco_label,mc_dl):
    mlabels = []
    if len(mc_dl)!=0:
        mlabels = mc_dl[1]


    ####### Make lines for each holder 
    pt_line = [] # [ [pointx,y,z q]  , , , , , ]
    # loop over the showers
    for h in datasetidx_holder: 
        points=[]
        q_wts=[]
        for p in h: 
            if labels[p]==-1:
                break
            pt = [dataset[p][0],dataset[p][1],dataset[p][2]]
            q_wt = [dataset[p][3],dataset[p][3],dataset[p][3]]
            points.append(pt)
            q_wts.append(q_wt)
            
        pca = wp.WPCA(n_components=3)
        pca.fit(points,weights=q_wts)
        dxdydz= pca.components_
        xyz = np.average(points, axis=0, weights=q_wts)

        # Add a few of these lines to 
        [pt_line.append(np.insert(xyz+a*dxdydz,3,5000.).tolist()  ) for a in range(100)]
        
    holder_idx_lab = [item for sublist in datasetidx_holder for item in sublist]
    data = [[dataset[i][0],dataset[i][1],dataset[i][2],(10*(labels[i] %20)/22.+2) *3600.,1] for i in holder_idx_lab if labels[i]!=-1]
    [data.append([mc_dl[0][i][0],mc_dl[0][i][1],mc_dl[0][i][2],float(1) *5000., 1]) for i in xrange(len(mlabels))]
    
    [data.append(pl) for pl in pt_line]

    output_x = ["%.1f" % data[k][0] for k in range(len(data))]
    new_output_x = '[%s]' % ','.join(map(str,output_x))
    output_y = ["%.1f" % data[k][1] for k in range(len(data))]
    new_output_y = '[%s]' % ','.join(map(str,output_y))
    output_z = ["%.1f" % data[k][2] for k in range(len(data))]
    new_output_z = '[%s]' % ','.join(map(str,output_z))
    output_q = ["%.1f" % data[k][3] for k in range(len(data))]
    new_output_q = '[%s]' % ','.join(map(str,output_q))
    output_nq = ["%.1f" % data[k][4] for k in range(len(data))]
    new_output_nq = '[%s]' % ','.join(map(str,output_nq))
    l = "{ \"x\":%s, \"y\":%s, \"z\":%s, \"q\":%s, \"nq\":%s, \"type\":\"truth\", \"runNo\":\"1\", \"subRunNo\":\"1\", \"eventNo\":\"1\", \"geom\":\"uboone\" }" % (new_output_x,new_output_y,new_output_z,new_output_q,new_output_nq)
    # open a text file     
    #lookup = open('{}/{}-reco.json'.format(jpath,str(jcount)),'w')
    lookup = open('{}/{}-{}.json'.format(jpath,str(jcount),reco_label),'a+')
    lookup.writelines(l)
    lookup.close()
    return


def MakeJsonData(f, str jpath,int jcount, str reco_label,mc_dl):
    dataset = Convert_olddata_WC_above_thresh(f,0.0) # Hard coded for now
    # ^^ This add a few seconds
    mlabels = []
    if  len(mc_dl)!=0:
        mlabels = mc_dl[1]
    
    data = [[dataset[i][0],dataset[i][1],dataset[i][2],dataset[i][3],1] for i in range(len(dataset))]
    [data.append([mc_dl[0][i][0],mc_dl[0][i][1],mc_dl[0][i][2],0.0, 1]) for i in range(len(mlabels))]

    output_x = ["%.1f" % data[k][0] for k in range(len(data))]
    new_output_x = '[%s]' % ','.join(map(str,output_x))
    output_y = ["%.1f" % data[k][1] for k in range(len(data))]
    new_output_y = '[%s]' % ','.join(map(str,output_y))
    output_z = ["%.1f" % data[k][2] for k in range(len(data))]
    new_output_z = '[%s]' % ','.join(map(str,output_z))
    output_q = ["%.1f" % data[k][3] for k in range(len(data))]
    new_output_q = '[%s]' % ','.join(map(str,output_q))
    output_nq = ["%.1f" % data[k][4] for k in range(len(data))]
    new_output_nq = '[%s]' % ','.join(map(str,output_nq))
    l = "{ \"x\":%s, \"y\":%s, \"z\":%s, \"q\":%s, \"nq\":%s, \"type\":\"truth\", \"runNo\":\"1\", \"subRunNo\":\"1\", \"eventNo\":\"1\", \"geom\":\"uboone\" }" % (new_output_x,new_output_y,new_output_z,new_output_q,new_output_nq)
    # open a text file     
    lookup = open('{}/{}-{}.json'.format(jpath,str(jcount),reco_label),'a+')
    lookup.writelines(l)
    lookup.close()
    return
	







 
######################################################################
###############    Deprocated things to be removed ###################
######################################################################
'''

def ConvertWC(infile):
    #Bring in the file 
    f = ROOT.TFile("{}".format(infile))
    #t = f.Get("T_rec_charge")
    t = f.Get("T_rec_charge_blob")
    # Parse into an array 
    sptarray = []
    for entry in t:
        if entry.q!=0.0 and entry.type==1: 
            sptarray.append([entry.x,entry.y,entry.z,entry.q])
    #make this an ndarray    
    spta = np.asanyarray(sptarray)
    #Make sure all points are unique
    cleanspta = Unique(spta)
    return cleanspta

def ConvertWC_InTPC(infile):
    #Bring in the file 
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("T_rec_charge_blob")
    # Parse into an array 
    sptarray = []
    for entry in t:
        if entry.q!=0.0 and entry.x>0 and entry.x<256 and entry.type==1: 
        #if entry.q!=0.0 and entry.x>0 and entry.x<256: 
            sptarray.append([entry.x,entry.y,entry.z,entry.q])
    #make this an ndarray    
    spta = np.asanyarray(sptarray)
    cleanspta = Unique(spta)
    return cleanspta

def ConvertWC_InTPC_thresh(infile,qt):
    #Bring in the file 
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("T_rec_charge_blob")
    #t = f.Get("T_rec_charge")
    # Parse into an array 
    sptarray = []
    for entry in t:
        if entry.q>qt and entry.x>0 and entry.x<256 and entry.type==1: 
            sptarray.append([entry.x,entry.y,entry.z,entry.q])
    #make this an ndarray    
    #cleanspta = np.asanyarray(sptarray)
    spta = np.asanyarray(sptarray)
    cleanspta = spta
    #cleanspta = Unique(spta)
    return cleanspta


def Get_Total_Reco_Charge(infile):
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("T_rec_charge_blob")
    # Parse into an array  
    tot_q = 0.0
    for entry in t:
        if entry.type==1:
            tot_q +=entry.q
    return tot_q


def ConvertWC_InRange_thresh(infile,qt,xlo,xhi,ylo,yhi,zlo,zhi):
    #Bring in the file 
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("T_rec_charge_blob")
    # Parse into an array 
    sptarray = []
    for entry in t:
        if entry.q>qt and entry.x>xlo and entry.x<xhi and entry.y>ylo and entry.y<yhi and entry.z>zlo and entry.z<zhi and entry.type==1: 
            sptarray.append([entry.x,entry.y,entry.z,entry.q])
    #make this an ndarray    
    spta = np.asanyarray(sptarray)
    cleanspta = Unique(spta)
    return cleanspta

def ConvertWCMC(infile):
    #Bring in the file 
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("T_true")
    # Parse into an array 
    sptarray = []
    for entry in t:
        sptarray.append([entry.x,entry.y,entry.z,entry.q])
    #make this an ndarray    
    spta = np.asanyarray(sptarray)
    return spta

def ConvertWC_points(infile):
    #Bring in the file 
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("T_rec_charge_blob")
    # Parse into an array 
    sptarray = []
    for entry in t:
        if entry.q!=0.0 and  entry.type==1: 
            sptarray.append([entry.x,entry.y,entry.z])
    #make this an ndarray    
    spta = np.asanyarray(sptarray)
    return spta










def Rebase_Dataset_Keep_Clustered(dataset, holder):
    # This will keep only the ojects that are  already clustered and rebase the dataset to just points that are in whatever holder_set comes in 
    datasetidx_holder_rebase=[]
    dataset_rebase = [ ]
    itr_r = 0
    labels_rebase = []
    labels_itr = 0
    for a in holder:
        temp_holder = []
        for i in a:
            dataset_rebase.append([dataset[i][0],dataset[i][1],dataset[i][2],dataset[i][3]])
            temp_holder.append(itr_r)
            itr_r+=1
            labels_rebase.append(labels_itr)
        datasetidx_holder_rebase.append(temp_holder)
        labels_itr+=1

    return dataset_rebase, datasetidx_holder_rebase , labels_rebase



'''
