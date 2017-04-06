import math as math
from lib.utility.Geo_Utils import detector as geo
import ROOT

# Define these locally for ease
xlo = geo.GetX_Bounds()[0]
xhi = geo.GetX_Bounds()[1]
ylo = geo.GetY_Bounds()[0]
yhi = geo.GetY_Bounds()[1]
zlo = geo.GetZ_Bounds()[0]
zhi = geo.GetZ_Bounds()[1]



############################## 
## Def for no pi0 back evt  ## 
############################## 
def mc_Backgroung_no_piz(f):
    tf = ROOT.TFile("{}".format(f))
    tree = tf.Get("TMCP")
    _x_particle = []
    _y_particle = []
    _z_particle = []
    _Ex_particle = []
    _Ey_particle = []
    _Ez_particle = []
    _pp_particle = []
    pi0_4mom = []
    daughter_4mom = []

    for i in tree:

        id_list = [x for x in i.mcparticle_id]
        mother_list = [ x for x in i.mcparticle_mother]
        pdg_list = [ x for x in i.mcparticle_pdg]
        Sxyzt_list = [[x] for x in i.mcparticle_startXYZT]
        Exyzt_list = [[x] for x in i.mcparticle_endXYZT]
        Sxyzp_list = [[x] for x in i.mcparticle_startMomentum]
        process_list = [ x for x in i.mcparticle_process]
        # Sort out the xyztlist

        # Sort out the xyztlist
        for itr in range(len(Sxyzt_list)):
            modu = itr%4
            if modu ==0:
                _x_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ex_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==1:
                _y_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ey_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==2:
                _z_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ez_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==3:
                _pp_particle.append(str(Sxyzp_list[itr]).split('[')[1].split(']')[0])

        pi0_mothers=[]
        pi0_partid=[]
        for pdg in range(len(pdg_list)):
            if pdg_list[pdg]==111:
                #is the pi0 is not inside the TPC
                if float(_x_particle[pdg])<xlo or float(_x_particle[pdg])>xhi or float(_y_particle[pdg])<ylo or float(_y_particle[pdg])>yhi or float(_z_particle[pdg])<zlo or float(_z_particle[pdg])>zhi:
                    continue
                pi0_id = id_list[pdg]
                #pi0_4mom.append(float(_x_particle[pdg]))
                #pi0_4mom.append(float(_y_particle[pdg]))
                #pi0_4mom.append(float(_z_particle[pdg]))
                #pi0_4mom.append(float(_pp_particle[pdg]))
                #try:
                 #   motherindex = id_list.index(mother_list[pdg])
                # if this is a value error that mean s we are dealing with single particle files
               # except ValueError:
                #    for pdg in range(len(pdg_list)):
                 #       if pdg_list[pdg]==22 or pdg_list[pdg]==-11 or pdg_list[pdg]==11:
                  #          try:
                  #              mom = pdg_list[id_list.index(mother_list[pdg])]
                  #              if mom!=111:
                  #                  continue
                  #          except :
                  #              continue
                  #          tdaughter_4mom = []
                  #          tdaughter_4mom.append(float(_Ex_particle[pdg]))
                  #          tdaughter_4mom.append(float(_Ey_particle[pdg]))
                  #          tdaughter_4mom.append(float(_Ez_particle[pdg]))
                  #          tdaughter_4mom.append(float(_pp_particle[pdg]))
                  #          daughter_4mom.append(tdaughter_4mom)
                   # return True, pi0_4mom, daughter_4mom

                pi0_mothers.append(pdg_list[id_list.index(mother_list[pdg])])
                pi0_partid.append(pi0_id)

        # If there is not only one pi0 in the TPC continue
        if len(pi0_mothers)==0:
            # make up a fake
            [pi0_4mom.append(-99999) for x in range(4)]
            td = [-99999 for x in range(4)]
            tdaughter_4mom = []
            tdaughter_4mom.append(td)
            tdaughter_4mom.append(td)
            return True , pi0_4mom , tdaughter_4mom
    return False




def mc_neutron_induced_contained(f):
    tf = ROOT.TFile("{}".format(f))
    tree = tf.Get("TMCP")
    _x_particle = []
    _y_particle = []
    _z_particle = []
    _Ex_particle = []
    _Ey_particle = []
    _Ez_particle = []
    _pp_particle = []
    pi0_4mom = []
    daughter_4mom = []

    for i in tree:
        id_list = [x for x in i.mcparticle_id]
        mother_list = [ x for x in i.mcparticle_mother]
        pdg_list = [ x for x in i.mcparticle_pdg]
        Sxyzt_list = [[x] for x in i.mcparticle_startXYZT]
        Exyzt_list = [[x] for x in i.mcparticle_endXYZT]
        Sxyzp_list = [[x] for x in i.mcparticle_startMomentum]
        process_list = [ x for x in i.mcparticle_process]

        # Sort out the xyztlist
        for itr in range(len(Sxyzt_list)):
            modu = itr%4
            if modu ==0:
                _x_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ex_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==1:
                _y_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ey_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==2:
                _z_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ez_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==3:
                _pp_particle.append(str(Sxyzp_list[itr]).split('[')[1].split(']')[0])

        # Handle the mothers
        pi0_mothers=[]
        pi0_partid=[]
        for pdg in range(len(pdg_list)):
	    # Look for pi0's
            if pdg_list[pdg]==111:
                #is the pi0 is not inside the TPC
                if float(_x_particle[pdg])<xlo or float(_x_particle[pdg])>xhi or float(_y_particle[pdg])<ylo or float(_y_particle[pdg])>yhi or float(_z_particle[pdg])<zlo or float(_z_particle[pdg])>zhi:
                    print' pi0 is outside '
                    continue
		# if the pi0 is inside detector then fill things out
                pi0_id = id_list[pdg]
                pi0_4mom.append(float(_x_particle[pdg]))
                pi0_4mom.append(float(_y_particle[pdg]))
                pi0_4mom.append(float(_z_particle[pdg]))
                pi0_4mom.append(float(_pp_particle[pdg]))
                motherindex = id_list.index(mother_list[pdg])
                pi0_mothers.append(pdg_list[id_list.index(mother_list[pdg])])
                pi0_partid.append(pi0_id)

        # If there is not only one pi0 in the TPC continue
        if len(pi0_mothers)!=1 or len(pi0_mothers)==0:  # Why do we have the len==0? RG
            return False 

        # If the pi0 mom is not a neutron
        if pi0_mothers[0]!=2112:# is this a neutron? 
            return False

	# Find the daughters for the pi0
        for pdg in range(len(pdg_list)):
            if pdg_list[pdg]==22 or pdg_list[pdg]==-11 or pdg_list[pdg]==11:
                if mother_list[pdg]==0:
                    continue
                try:
                    mom = pdg_list[id_list.index(mother_list[pdg])]
                    if mom==111:
                        if pi0_partid[0] != mother_list[pdg]:
                            continue
                        if float(_Ex_particle[pdg])<xlo or float(_Ex_particle[pdg])>xhi or float(_Ey_particle[pdg])<ylo or float(_Ey_particle[pdg])>yhi or float(_Ez_particle[pdg])<zlo or float(_Ez_particle[pdg])>zhi:
                            return False 
                except:
                    continue

    return True


def mc_neutron_induced_OBJ( f ):
    tf = ROOT.TFile("{}".format(f))
    tree = tf.Get("TMCP")

    _x_particle = []
    _y_particle = []
    _z_particle = []
    _Ex_particle = []
    _Ey_particle = []
    _Ez_particle = []
    _pp_particle = []
    pi0_4mom = []
    daughter_4mom = []

    for i in tree:

        id_list = [x for x in i.mcparticle_id]
        mother_list = [ x for x in i.mcparticle_mother]
        pdg_list = [ x for x in i.mcparticle_pdg]
        Sxyzt_list = [[x] for x in i.mcparticle_startXYZT]
        Exyzt_list = [[x] for x in i.mcparticle_endXYZT]
        Sxyzp_list = [[x] for x in i.mcparticle_startMomentum]
        process_list = [ x for x in i.mcparticle_process]
        # Sort out the xyztlist

        # Sort out the xyztlist
        for itr in range(len(Sxyzt_list)):
            modu = itr%4
            if modu ==0:
                _x_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ex_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==1:
                _y_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ey_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==2:
                _z_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ez_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==3:
                _pp_particle.append(str(Sxyzp_list[itr]).split('[')[1].split(']')[0])

        pi0_mothers=[]
        pi0_partid=[]
        for pdg in range(len(pdg_list)):
            if pdg_list[pdg]==111:
                #is the pi0 is not inside the TPC
                if float(_x_particle[pdg])<xlo or float(_x_particle[pdg])>xhi or float(_y_particle[pdg])<ylo or float(_y_particle[pdg])>yhi or float(_z_particle[pdg])<zlo or float(_z_particle[pdg])>zhi:
                    continue
                pi0_id = id_list[pdg]
                pi0_4mom.append(float(_x_particle[pdg]))
                pi0_4mom.append(float(_y_particle[pdg]))
                pi0_4mom.append(float(_z_particle[pdg]))
                pi0_4mom.append(float(_pp_particle[pdg]))
                try:
                    motherindex = id_list.index(mother_list[pdg])
		# if this is a value error that mean s we are dealing with single particle files
                except ValueError:
                    for pdg in range(len(pdg_list)):
                        if pdg_list[pdg]==22 or pdg_list[pdg]==-11 or pdg_list[pdg]==11:
                            try:
                                mom = pdg_list[id_list.index(mother_list[pdg])]
                                if mom!=111:
                                    continue
                            except :
                                continue
                            tdaughter_4mom = []
                            tdaughter_4mom.append(float(_Ex_particle[pdg]))
                            tdaughter_4mom.append(float(_Ey_particle[pdg]))
                            tdaughter_4mom.append(float(_Ez_particle[pdg]))
                            tdaughter_4mom.append(float(_pp_particle[pdg]))
                            daughter_4mom.append(tdaughter_4mom)
                return True, pi0_4mom, daughter_4mom
		
                pi0_mothers.append(pdg_list[id_list.index(mother_list[pdg])])
                pi0_partid.append(pi0_id)

        # If there is not only one pi0 in the TPC continue
        if len(pi0_mothers)!=1:
	    # make up a fake
            [pi0_4mom.append(-99999) for x in range(4)]
            td = [-99999 for x in range(4)]
            tdaughter_4mom = []
            tdaughter_4mom.append(td)
            tdaughter_4mom.append(td)
            return False , pi0_4mom , tdaughter_4mom

        # If the pi0 mom is not a neutron
        if pi0_mothers[0]!=2112:# is this a neutron? 
	    # make up a fake
            [pi0_4mom.append(-99999) for x in range(4)]
            td = [-99999 for x in range(4)]
            tdaughter_4mom = []
            tdaughter_4mom.append(td)
            tdaughter_4mom.append(td)
            return False , pi0_4mom , tdaughter_4mom


        for pdg in range(len(pdg_list)):
            if pdg_list[pdg]==22 or pdg_list[pdg]==-11 or pdg_list[pdg]==11:
                if mother_list[pdg]==0:
                    continue
                try:
                    mom = pdg_list[id_list.index(mother_list[pdg])]
                    if mom==111:
                        if pi0_partid[0] != mother_list[pdg]:
                            continue
                        #print ' this is the mother index list' , pi0_partid[0]
                        #print ' this is the id current list ' , str(mother_list[pdg])
                        if float(_Ex_particle[pdg])<xlo or float(_Ex_particle[pdg])>xhi or float(_Ey_particle[pdg])<ylo or float(_Ey_particle[pdg])>yhi or float(_Ez_particle[pdg])<zlo or float(_Ez_particle[pdg])>zhi:
                            continue
                        tdaughter_4mom = []
                        tdaughter_4mom.append(float(_Ex_particle[pdg]))
                        tdaughter_4mom.append(float(_Ey_particle[pdg]))
                        tdaughter_4mom.append(float(_Ez_particle[pdg]))
                        tdaughter_4mom.append(float(_pp_particle[pdg]))
                        daughter_4mom.append(tdaughter_4mom)
                except:
                    continue

    #print 'From the MC Filter We are returning True'
    return True ,pi0_4mom, daughter_4mom


def mc_Obj_points(pobj_list):
    #print obj_list
    obj_list = pobj_list[1:]
    pi0_xyz = obj_list[0]
    gamma_xyz = obj_list[1]

    # The first entry in the list is a 4 position of the pi0
    space = 20*20*20 +  20* 3*len(gamma_xyz)
    dataset = [None for x in range(space)]
    #dataset = []
    mclab = 0 # This is hard code magic for coloring in the bee viewer
    box_size = 1
    density = 5
    # lower number is higher density
    # Fix this later on# lower number is higher density


    counter=0
    for i in range(0,box_size*100,density):
        for j in range(0,box_size*100,density):
            for k in range(0,box_size*100,density):
                dataset[counter] = [pi0_xyz[0]-box_size +2.*box_size*k/100.,pi0_xyz[1]-box_size+2.*box_size*j/100.,pi0_xyz[2]-box_size+2.*box_size*i/100.]
                counter+=1
		#dataset.append([pi0_xyz[0]-box_size +2.*box_size*k/100.,pi0_xyz[1]-box_size+2.*box_size*j/100.,pi0_xyz[2]-box_size+2.*box_size*i/100.])

    # Draw a cross for the photons
    for a in range(len(gamma_xyz)):
        for i in range(0,box_size*100,density):
            dataset[counter] = [gamma_xyz[a][0]-box_size +2.*box_size*i/100.,gamma_xyz[a][1],gamma_xyz[a][2]]# wali the X
            counter+=1
            dataset[counter] = [gamma_xyz[a][0],gamma_xyz[a][1]-box_size +2.*box_size*i/100.,gamma_xyz[a][2]]# wali the X
            counter+=1
            dataset[counter] = [gamma_xyz[a][0],gamma_xyz[a][1],gamma_xyz[a][2]-box_size +2.*box_size*i/100.]# wali the X
            counter+=1

    # Draw a line between the pi0vtx and daughters

    # We are going to fill out a box around the region
    labels = [0 for a in range(len(dataset))]
    return dataset , labels
 


def piz_mc_info(infile):
    #Returns a large string of of MC truth info which is specific and useful for pi0s
    f = ROOT.TFile("{}".format(infile))
    #t = f.Get("TMC")
    t = f.Get("TMCP")

    #Find the pi0 
    for i in t:

        id_list = [x for x in i.mcparticle_id]
        mother_list = [ x for x in i.mcparticle_mother]
        pdg_list = [ x for x in i.mcparticle_pdg]
        Sxyzt_list = [[x] for x in i.mcparticle_startXYZT]
        Exyzt_list = [[x] for x in i.mcparticle_endXYZT]
        Sxyzp_list = [[x] for x in i.mcparticle_startMomentum]
        process_list = [ x for x in i.mcparticle_process]
        _x_particle = []
        _y_particle = []
        _z_particle = []
        _Ex_particle = []
        _Ey_particle = []
        _Ez_particle = []
        _px_particle = []
        _py_particle = []
        _pz_particle = []
        _pp_particle = []

        # Sort out the xyztlist
        for itr in range(len(Sxyzt_list)):
            modu = itr%4
            if modu ==0:
                _x_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ex_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
                _px_particle.append(str(Sxyzp_list[itr]).split('[')[1].split(']')[0])
            if modu ==1:
                _y_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ey_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
                _py_particle.append(str(Sxyzp_list[itr]).split('[')[1].split(']')[0])
            if modu ==2:
                _z_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ez_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
                _pz_particle.append(str(Sxyzp_list[itr]).split('[')[1].split(']')[0])
            if modu ==3:
                _pp_particle.append(str(Sxyzp_list[itr]).split('[')[1].split(']')[0])

        pi0_mothers=[]
        pi0_partid=[]
        daughter_4posmom = []
        p_gamma_x = -1.
        p_gamma_y = -1.
        p_gamma_z = -1
        p_gamma_2_x = -1
        p_gamma_2_y = -1
        p_gamma_2_z = -1
        p_gamma_mag = -1
        p_gamma_2_mag = -1

        for pdg in range(len(pdg_list)):
            if pdg_list[pdg]==111:
                #is the pi0 is not inside the TPC
                if float(_x_particle[pdg])<xlo or float(_x_particle[pdg])>xhi or float(_y_particle[pdg])<ylo or float(_y_particle[pdg])>yhi or float(_z_particle[pdg])<zlo or float(_z_particle[pdg])>zhi:
                    continue
                pi0_id = id_list[pdg]
                vtx_pi_x = float(_x_particle[pdg])
                vtx_pi_y = float(_y_particle[pdg])
                vtx_pi_z = float(_z_particle[pdg])
	        #normalized momentum

                p_pi_x = float(_px_particle[pdg])/float(_pp_particle[pdg])
                p_pi_y = float(_py_particle[pdg])/float(_pp_particle[pdg])
                p_pi_z = float(_pz_particle[pdg])/float(_pp_particle[pdg])
                p_pi_mag = float(_pp_particle[pdg])

	        #The showerconversion point is supposed to be the end of the gamma
                try:
                    motherindex = id_list.index(mother_list[pdg])
		    #print ' this is the mother index ' , str(motherindex)
                except ValueError:
                    for dpdg in range(len(pdg_list)):
                        if pdg_list[dpdg]==22 or pdg_list[dpdg]==-11 or pdg_list[dpdg]==11:
			    #print ' in the list  pdg' , str(pdg_list[dpdg])
                            try:
                                mom = pdg_list[id_list.index(mother_list[dpdg])]
                                if mom!=111:
                                    continue
				#print 'We have the pi0 ' , str(mom)	
                            except :
                                continue
                            tdaughter_4mom = []
                            tdaughter_4mom.append(float(_Ex_particle[dpdg]))
                            tdaughter_4mom.append(float(_Ey_particle[dpdg]))
                            tdaughter_4mom.append(float(_Ez_particle[dpdg]))
                            tdaughter_4mom.append(float(_px_particle[dpdg]))
                            tdaughter_4mom.append(float(_py_particle[dpdg]))
                            tdaughter_4mom.append(float(_pz_particle[dpdg]))
                            tdaughter_4mom.append(float(_pp_particle[dpdg]))
                            daughter_4posmom.append(tdaughter_4mom)


		    # Now we have to fill this ... because this is the single particle
		    # This is the first gamma
                    vtx_gamma_x = daughter_4posmom[0][0]
                    vtx_gamma_y = daughter_4posmom[0][1]
                    vtx_gamma_z = daughter_4posmom[0][2]
                    p_gamma_x = daughter_4posmom[0][3]/daughter_4posmom[0][6]
                    p_gamma_y = daughter_4posmom[0][4]/daughter_4posmom[0][6]
                    p_gamma_z = daughter_4posmom[0][5]/daughter_4posmom[0][6]
                    p_gamma_mag = daughter_4posmom[0][6]

	            # Now do the second gamma
                    vtx_gamma_2_x = daughter_4posmom[1][0]
                    vtx_gamma_2_y = daughter_4posmom[1][1]
                    vtx_gamma_2_z = daughter_4posmom[1][2]
                    p_gamma_2_x = daughter_4posmom[1][3]/daughter_4posmom[1][6]
                    p_gamma_2_y = daughter_4posmom[1][4]/daughter_4posmom[1][6]
                    p_gamma_2_z = daughter_4posmom[1][5]/daughter_4posmom[1][6]
                    p_gamma_2_mag = daughter_4posmom[1][6]

                    gamma_angle = math.acos((p_gamma_x*p_gamma_2_x+p_gamma_y*p_gamma_2_y+p_gamma_z*p_gamma_2_z))

 	            #Is this a non-dalitz
                    if len(daughter_4posmom)!=2:
	                # Write out a bail list to return
                        fill = str('-1 ')*24
                        bails = fill.rsplit(' ',1)[0]
                        return bails

                    # Form the return string
                    dalitz = 0
                    ret = str(dalitz)+' '+str(vtx_pi_x)+' '+str(vtx_pi_y)+' '+str(vtx_pi_z)+' '+str(p_pi_x)+' '+str(p_pi_y)+' '+str(p_pi_z)+' '+str(p_pi_mag)+' '+str(vtx_gamma_x)+' '+str(vtx_gamma_y)+' '+str(vtx_gamma_z)+' '+str(p_gamma_x)+' '+str(p_gamma_y)+' '+str(p_gamma_z)+' '+str(p_gamma_mag)+' '+str(vtx_gamma_2_x)+' '+str(vtx_gamma_2_y)+' '+str(vtx_gamma_2_z)+' '+str(p_gamma_2_x)+' '+str(p_gamma_2_y)+' '+str(p_gamma_2_z)+' '+str(p_gamma_2_mag)+' '+str(gamma_angle) + ' '+ str(1-math.cos(gamma_angle))
                    return ret







		#here RG FIXXXX
                for dpdg in range(len(pdg_list)):
                    if pdg_list[dpdg]==22 or pdg_list[dpdg]==-11 or pdg_list[dpdg]==11:
                        try:
                            mom = pdg_list[id_list.index(mother_list[dpdg])]
                            if mom!=111:
                                continue
                        except :
                            continue
                        tdaughter_4mom = []
                        tdaughter_4mom.append(float(_Ex_particle[dpdg]))
                        tdaughter_4mom.append(float(_Ey_particle[dpdg]))
                        tdaughter_4mom.append(float(_Ez_particle[dpdg]))
                        tdaughter_4mom.append(float(_px_particle[dpdg]))
                        tdaughter_4mom.append(float(_py_particle[dpdg]))
                        tdaughter_4mom.append(float(_pz_particle[dpdg]))
                        tdaughter_4mom.append(float(_pp_particle[dpdg]))
                        daughter_4posmom.append(tdaughter_4mom)
		# This is the first gamma
                vtx_gamma_x = daughter_4posmom[0][0] 
                vtx_gamma_y = daughter_4posmom[0][1] 
                vtx_gamma_z = daughter_4posmom[0][2]
                p_gamma_x = daughter_4posmom[0][3]/daughter_4posmom[0][6]
                p_gamma_y = daughter_4posmom[0][4]/daughter_4posmom[0][6]
                p_gamma_z = daughter_4posmom[0][5]/daughter_4posmom[0][6]
                p_gamma_mag = daughter_4posmom[0][6]

	        # Now do the second gamma
                vtx_gamma_2_x = daughter_4posmom[1][0]
                vtx_gamma_2_y = daughter_4posmom[1][1]
                vtx_gamma_2_z = daughter_4posmom[1][2]
                p_gamma_2_x = daughter_4posmom[1][3]/daughter_4posmom[1][6]
                p_gamma_2_y = daughter_4posmom[1][4]/daughter_4posmom[1][6]
                p_gamma_2_z = daughter_4posmom[1][5]/daughter_4posmom[1][6]
                p_gamma_2_mag = daughter_4posmom[1][6]

	#Is this a non-dalitz
        if len(daughter_4posmom)!=2:
	    # Write out a bail list to return
            fill = str('-1 ')*24
            bails = fill.rsplit(' ',1)[0]
	    #bail = [-1 for x in xrange(0,24)]
            return bails

	# now do relationship of showers. 
	#print p_gamma_x
	#print p_gamma_y
	#print p_gamma_z
	#print p_gamma_2_x
	#print p_gamma_2_y
	#print p_gamma_2_z
	#print p_gamma_mag
	#print p_gamma_2_mag
	#print p_gamma_mag* p_gamma_2_mag
	#print (p_gamma_x*p_gamma_2_x+p_gamma_y*p_gamma_2_y+p_gamma_z*p_gamma_2_z)  
	#print (p_gamma_x*p_gamma_2_x+p_gamma_y*p_gamma_2_y+p_gamma_z*p_gamma_2_z) / (p_gamma_mag*p_gamma_2_mag)
        gamma_angle = math.acos((p_gamma_x*p_gamma_2_x+p_gamma_y*p_gamma_2_y+p_gamma_z*p_gamma_2_z))

	# Form the return string
        dalitz = 0
        ret = str(dalitz)+' '+str(vtx_pi_x)+' '+str(vtx_pi_y)+' '+str(vtx_pi_z)+' '+str(p_pi_x)+' '+str(p_pi_y)+' '+str(p_pi_z)+' '+str(p_pi_mag)+' '+str(vtx_gamma_x)+' '+str(vtx_gamma_y)+' '+str(vtx_gamma_z)+' '+str(p_gamma_x)+' '+str(p_gamma_y)+' '+str(p_gamma_z)+' '+str(p_gamma_mag)+' '+str(vtx_gamma_2_x)+' '+str(vtx_gamma_2_y)+' '+str(vtx_gamma_2_z)+' '+str(p_gamma_2_x)+' '+str(p_gamma_2_y)+' '+str(p_gamma_2_z)+' '+str(p_gamma_2_mag)+' '+str(gamma_angle) + ' '+ str(1-math.cos(gamma_angle))

        return ret 








def gamma_mc_info(infile):
    #Returns a large string of of MC truth info which is specific and useful for pi0s
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("TMCP")
    # the photon should be the first
    for en in t:
        vtx_gamma_x = en.mcparticle_endXYZT[0]
        vtx_gamma_y = en.mcparticle_endXYZT[1]
        vtx_gamma_z = en.mcparticle_endXYZT[2]
        p_gamma_x = en.mcparticle_startMomentum[0]/en.mcparticle_startMomentum[3]
        p_gamma_y = en.mcparticle_startMomentum[1]/en.mcparticle_startMomentum[3]
        p_gamma_z = en.mcparticle_startMomentum[2]/en.mcparticle_startMomentum[3]
        p_gamma_mag = en.mcparticle_startMomentum[3]
        ret = str(vtx_gamma_x)+' '+str(vtx_gamma_y)+' '+str(vtx_gamma_z)+' '+str(p_gamma_x)+' '+str(p_gamma_y)+' '+str(p_gamma_z)+' '+str(p_gamma_mag)
        return ret



def gamma_mc_dep(infile):
    #Returns a large string of of MC truth info which is specific and useful for pi0s
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("T_true")
    # the photon should be the first
    qdep = 0.0
    for en in t:
        qdep +=en.q
    ret = str(qdep)
    return ret






##########################################################################################
####     OLD WC Version.... not Brooke
##########################################################################################


'''
def mc_neutron_induced_contained(f):
    tf = ROOT.TFile("{}".format(f))
    tree = tf.Get("TMC")

    # Files to be run since we only want to do certain  
    Signal_event = []
#    id_counter = 0

    _x_particle = []
    _y_particle = []
    _z_particle = []
    _Ex_particle = []
    _Ey_particle = []
    _Ez_particle = []
    _pp_particle = []
    pi0_4mom = []
    daughter_4mom = []

    for i in tree:

        id_list = [x for x in i.mc_id]
        mother_list = [ x for x in i.mc_mother]
        pdg_list = [ x for x in i.mc_pdg]
        Sxyzt_list = [[x] for x in i.mc_startXYZT]
        Exyzt_list = [[x] for x in i.mc_endXYZT]
        Sxyzp_list = [[x] for x in i.mc_startMomentum]
        process_list = [ x for x in i.mc_process]
        # Sort out the xyztlist

        for itr in range(len(Sxyzt_list)):
            modu = itr%4
            if modu ==0:
                _x_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ex_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==1:
                _y_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ey_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==2:
                _z_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ez_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==3:
                _pp_particle.append(str(Sxyzp_list[itr]).split('[')[1].split(']')[0])

        pi0_mothers=[]
        pi0_partid=[]
        for pdg in range(len(pdg_list)):
            if pdg_list[pdg]==111:
                #is the pi0 is not inside the TPC
                if float(_x_particle[pdg])<xlo or float(_x_particle[pdg])>xhi or float(_y_particle[pdg])<ylo or float(_y_particle[pdg])>yhi or float(_z_particle[pdg])<zlo or float(_z_particle[pdg])>zhi:
                    print' pi0 is outside '
                    continue
                pi0_id = id_list[pdg]
                pi0_4mom.append(float(_x_particle[pdg]))
                pi0_4mom.append(float(_y_particle[pdg]))
                pi0_4mom.append(float(_z_particle[pdg]))
                pi0_4mom.append(float(_pp_particle[pdg]))
                motherindex = id_list.index(mother_list[pdg])
                pi0_mothers.append(pdg_list[id_list.index(mother_list[pdg])])
                pi0_partid.append(pi0_id)

        # If there is not only one pi0 in the TPC continue
        if len(pi0_mothers)!=1 or len(pi0_mothers)==0:
            return False 

        # If the pi0 mom is not a neutron
        if pi0_mothers[0]!=2112:# is this a neutron? 
            return False


        for pdg in range(len(pdg_list)):
            if pdg_list[pdg]==22 or pdg_list[pdg]==-11 or pdg_list[pdg]==11:
                if mother_list[pdg]==0:
                    continue
                try:
                    mom = pdg_list[id_list.index(mother_list[pdg])]
                    if mom==111:
                        if pi0_partid[0] != mother_list[pdg]:
                            continue
                        if float(_Ex_particle[pdg])<xlo or float(_Ex_particle[pdg])>xhi or float(_Ey_particle[pdg])<ylo or float(_Ey_particle[pdg])>yhi or float(_Ez_particle[pdg])<zlo or float(_Ez_particle[pdg])>zhi:
                            print ' this is a bad daughter'
			    return False 
                except:
                    continue

    return True







def mc_neutron_induced_OBJ( f ):
    tf = ROOT.TFile("{}".format(f))
    tree = tf.Get("TMC")

    # Files to be run since we only want to do certain  
    Signal_event = []

    _x_particle = []
    _y_particle = []
    _z_particle = []
    _Ex_particle = []
    _Ey_particle = []
    _Ez_particle = []
    _pp_particle = []
    pi0_4mom = []
    daughter_4mom = []

    for i in tree:

        id_list = [x for x in i.mc_id]
        mother_list = [ x for x in i.mc_mother]
        pdg_list = [ x for x in i.mc_pdg]
        Sxyzt_list = [[x] for x in i.mc_startXYZT]
        Exyzt_list = [[x] for x in i.mc_endXYZT]
        Sxyzp_list = [[x] for x in i.mc_startMomentum]
        process_list = [ x for x in i.mc_process]
        # Sort out the xyztlist

        for itr in range(len(Sxyzt_list)):
            modu = itr%4
            if modu ==0:
                _x_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ex_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==1:
                _y_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ey_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==2:
                _z_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ez_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==3:
                _pp_particle.append(str(Sxyzp_list[itr]).split('[')[1].split(']')[0])

        pi0_mothers=[]
        pi0_partid=[]
        for pdg in range(len(pdg_list)):
            if pdg_list[pdg]==111:
                #is the pi0 is not inside the TPC
                if float(_x_particle[pdg])<xlo or float(_x_particle[pdg])>xhi or float(_y_particle[pdg])<ylo or float(_y_particle[pdg])>yhi or float(_z_particle[pdg])<zlo or float(_z_particle[pdg])>zhi:
                    #print' pi0 is outside '
		    #print _x_particle[pdg]
		    #print _y_particle[pdg]
		    #print _z_particle[pdg]	
                    continue
                pi0_id = id_list[pdg]
                pi0_4mom.append(float(_x_particle[pdg]))
                pi0_4mom.append(float(_y_particle[pdg]))
                pi0_4mom.append(float(_z_particle[pdg]))
                pi0_4mom.append(float(_pp_particle[pdg]))
		try:
                    motherindex = id_list.index(mother_list[pdg])
		except ValueError:
                    for pdg in range(len(pdg_list)):
            	        if pdg_list[pdg]==22 or pdg_list[pdg]==-11 or pdg_list[pdg]==11:
                            try:
                    	        mom = pdg_list[id_list.index(mother_list[pdg])]
                                if mom!=111:
				    continue
			    except :
				continue
		            tdaughter_4mom = []
                            tdaughter_4mom.append(float(_Ex_particle[pdg]))
                            tdaughter_4mom.append(float(_Ey_particle[pdg]))
                            tdaughter_4mom.append(float(_Ez_particle[pdg]))
                            tdaughter_4mom.append(float(_pp_particle[pdg]))
                            daughter_4mom.append(tdaughter_4mom)
		    return pi0_4mom, daughter_4mom
		
                pi0_mothers.append(pdg_list[id_list.index(mother_list[pdg])])
                pi0_partid.append(pi0_id)

        # If there is not only one pi0 in the TPC continue
        if len(pi0_mothers)!=1:
            return False 

        # If the pi0 mom is not a neutron
        if pi0_mothers[0]!=2112:# is this a neutron? 
            return False


        for pdg in range(len(pdg_list)):
            if pdg_list[pdg]==22 or pdg_list[pdg]==-11 or pdg_list[pdg]==11:
                if mother_list[pdg]==0:
                    continue
                try:
                    mom = pdg_list[id_list.index(mother_list[pdg])]
                    if mom==111:
                        if pi0_partid[0] != mother_list[pdg]:
                            continue
                        #print ' this is the mother index list' , pi0_partid[0]
                        #print ' this is the id current list ' , str(mother_list[pdg])
                        if float(_Ex_particle[pdg])<xlo or float(_Ex_particle[pdg])>xhi or float(_Ey_particle[pdg])<ylo or float(_Ey_particle[pdg])>yhi or float(_Ez_particle[pdg])<zlo or float(_Ez_particle[pdg])>zhi:
			    continue
                        tdaughter_4mom = []
                        tdaughter_4mom.append(float(_Ex_particle[pdg]))
                        tdaughter_4mom.append(float(_Ey_particle[pdg]))
                        tdaughter_4mom.append(float(_Ez_particle[pdg]))
                        tdaughter_4mom.append(float(_pp_particle[pdg]))
                        daughter_4mom.append(tdaughter_4mom)
                except:
                    continue

    #print 'From the MC Filter We are returning True'
    return pi0_4mom, daughter_4mom

















def oldmc_neutron_induced_OBJ( f ):
    tf = ROOT.TFile("{}".format(f))
    mctree = tf.Get("TMC")
    _x_particle = []
    _y_particle = []
    _z_particle = []
    _Ex_particle = []
    _Ey_particle = []
    _Ez_particle = []
    _pp_particle = []
    pi0_4mom = []
    daughter_4mom = []

    for i in mctree:
        id_list = [x for x in i.mc_id]
        mother_list = [ x for x in i.mc_mother]
        pdg_list = [ x for x in i.mc_pdg]
        Sxyzt_list = [[x] for x in i.mc_startXYZT]
        Exyzt_list = [[x] for x in i.mc_endXYZT]
        Sxyzp_list = [[x] for x in i.mc_startMomentum]

        # Sort out the xyztlist
        for itr in range(len(Sxyzt_list)):
            modu = itr%4
            if modu ==0:
                _x_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ex_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==1:
                _y_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ey_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==2:
                _z_particle.append(str(Sxyzt_list[itr]).split('[')[1].split(']')[0])
                _Ez_particle.append(str(Exyzt_list[itr]).split('[')[1].split(']')[0])
            if modu ==3:
                _pp_particle.append(str(Sxyzp_list[itr]).split('[')[1].split(']')[0])

        pi0_id = -1
        # ^^ This is a little hacked
        # This should be unique for neutron photon
        for pdg in range(len(pdg_list)):
            if pdg_list[pdg]==111:
                pi0_id = id_list[pdg]
                pi0_4mom.append(float(_x_particle[pdg]))
                pi0_4mom.append(float(_y_particle[pdg]))
                pi0_4mom.append(float(_z_particle[pdg]))
                pi0_4mom.append(float(_pp_particle[pdg]))

        for pdg in range(len(pdg_list)):
            if pdg_list[pdg]==22 or pdg_list[pdg]==-11 or pdg_list[pdg]==11:
                if mother_list[pdg]==0:
                    continue
                try:
                    mom = pdg_list[id_list.index(mother_list[pdg])]
                    if mom==111:
                        tdaughter_4mom = []
                        tdaughter_4mom.append(float(_Ex_particle[pdg]))
                        tdaughter_4mom.append(float(_Ey_particle[pdg]))
                        tdaughter_4mom.append(float(_Ez_particle[pdg]))
                        tdaughter_4mom.append(float(_pp_particle[pdg]))
                        daughter_4mom.append(tdaughter_4mom)
                except:
                    continue

    return pi0_4mom, daughter_4mom



   
    

def mc_roi( f):
    tf = ROOT.TFile("{}".format(f))
    mctree = tf.Get("TMC")
    _x_particle = []
    _y_particle = []
    _z_particle = []
    _t_particle = []
    _px_particle = []
    _py_particle = []
    _pz_particle = []
    _pp_particle = []
    # Make the lists for things to look though
    for i in mctree:
	id_list = [x for x in i.mc_id]
	mother_list = [ x for x in i.mc_mother]
	pdg_list = [ x for x in i.mc_pdg]
	process_list = [ x for x in i.mc_process]
	xyzt_list = [[x] for x in i.mc_startXYZT]
	xyzp_list = [[x] for x in i.mc_startMomentum]
        # Sort out the xyztlist
        for itr in range(len(xyzt_list)):
            modu = itr%4
            if modu ==0:
                _x_particle.append(str(xyzt_list[itr]).split('[')[1].split(']')[0])
                _px_particle.append(str(xyzp_list[itr]).split('[')[1].split(']')[0])
            if modu ==1:
                _y_particle.append(str(xyzt_list[itr]).split('[')[1].split(']')[0])   
                _py_particle.append(str(xyzp_list[itr]).split('[')[1].split(']')[0])   
            if modu ==2:
                _z_particle.append(str(xyzt_list[itr]).split('[')[1].split(']')[0])
                _pz_particle.append(str(xyzp_list[itr]).split('[')[1].split(']')[0])   
            if modu ==3:
                _t_particle.append(str(xyzt_list[itr]).split('[')[1].split(']')[0])
                _pp_particle.append(str(xyzp_list[itr]).split('[')[1].split(']')[0])   
 
    # Get the pi0 list
    pi0_itr = []    
    pi0_mother_itr = []    
 
    for itr in range(len(pdg_list)):
        if pdg_list[itr]==111:
            pi0_itr.append(itr)
            pi0_mother_itr =  mother_list[itr]

    # Make the string It will be a vector of strings 
    ret_string_vec = [] 
    for a in range(len(pi0_itr)):
        N_pi0 = str(len(pi0_itr))
	ID_pi0 = str(a)
	xyzt_string = str(_x_particle[pi0_itr[a]])+' ' +str(_y_particle[pi0_itr[a]])+' '+str(_z_particle[pi0_itr[a]])+' '+str(_t_particle[pi0_itr[a]])
	xyzp_string = str(_px_particle[pi0_itr[a]])+' ' +str(_py_particle[pi0_itr[a]])+' '+str(_pz_particle[pi0_itr[a]])+' '+str(_pp_particle[pi0_itr[a]])
 	fstr = N_pi0+' ' + ID_pi0+' '+xyzt_string +' '+xyzp_string
	ret_string_vec.append(fstr)
    return ret_string_vec
	


def gamma_mc_info(infile):
    #Returns a large string of of MC truth info which is specific and useful for pi0s
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("TMC")
    # the photon should be the first
    for en in t:
        vtx_gamma_x = en.mc_endXYZT[0]
        vtx_gamma_y = en.mc_endXYZT[1]
        vtx_gamma_z = en.mc_endXYZT[2]
        p_gamma_x = en.mc_startMomentum[0]/en.mc_startMomentum[3]
        p_gamma_y = en.mc_startMomentum[1]/en.mc_startMomentum[3]
        p_gamma_z = en.mc_startMomentum[2]/en.mc_startMomentum[3]
        p_gamma_mag = en.mc_startMomentum[3]
        ret = str(vtx_gamma_x)+' '+str(vtx_gamma_y)+' '+str(vtx_gamma_z)+' '+str(p_gamma_x)+' '+str(p_gamma_y)+' '+str(p_gamma_z)+' '+str(p_gamma_mag)
        return ret

def gamma_mc_dep(infile):
    #Returns a large string of of MC truth info which is specific and useful for pi0s
    f = ROOT.TFile("{}".format(infile))
    t = f.Get("T_true")
    # the photon should be the first
    qdep = 0.0
    for en in t:
        qdep +=en.q
    ret = str(qdep)
    return ret
'''
