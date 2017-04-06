import numpy as np
import math as math
import lib.utility.Geo_Utils.axisfit as axfi
import lib.SParams.selpizero as selpz


def cluster_pairs_data_textmaker(dataset, datasetidx_holder, ers_string, out_textfile):
    # Open the textfile 
    lookup = open('Out_text/{}.txt'.format(out_textfile),'a+')
    # This needs to change to a global call
    # will I need to move the counter to the bottom? Will it matter? 

    # outputstring_vector
    id_counter = 0
    for a in xrange(len(datasetidx_holder)):
        # Can we get the color
        #ca =  colors[labels_merge[datasetidx_holder_merge[a][0]]]
        print datasetidx_holder[a]
        shrA = axfi.weightshowerfit(dataset,datasetidx_holder[a])
        #EA = selpz.corrected_energy(dataset,datasetidx_holder_merge[a])
        ChargeA = selpz.totcharge(dataset,datasetidx_holder[a])
        id_A = id_counter
        b_set_counter = id_A+1
        for b in xrange(a+1,len(datasetidx_holder)):
            #cb =  colors[labels_merge[datasetidx_holder[b][0]]]
            shrB = axfi.weightshowerfit(dataset,datasetidx_holder[b])
            #EB = selpz.corrected_energy(dataset,datasetidx_holder[b])
            ChargeB = selpz.totcharge(dataset,datasetidx_holder[b])
            vertex = selpz.findvtx(shrA,shrB)
            IP = selpz.findIP(shrA,shrB)
            SP_a = selpz.findRoughShowerStart(dataset,datasetidx_holder[a],vertex)
            radL_a = selpz.findconversionlength(vertex,SP_a)
            SP_b = selpz.findRoughShowerStart(dataset,datasetidx_holder[b],vertex)
            radL_b = selpz.findconversionlength(vertex,SP_b)
            angle = selpz.openingangle(shrA,shrB,vertex)
            id_B = b_set_counter
	    # Now pring a text string to add to the ext vector

            # n_showers ,pair vertex_x, pair vertex_y , pair vertex_z, ShrA , ShrB, Elarge, Esmall, Angle, IP,radL_A , radL_B, vtx_x , vtx_y, vtx_z
            RecoString =str(len(datasetidx_holder))+' '+ str(vertex[0])+ ' '+ str(vertex[1])+ ' '+ str(vertex[2])+' '+ str(ChargeA)+ ' '+ str(SP_a[0])+ ' '+ str(SP_a[1])+ ' '+ str(SP_a[2])+' '+ str(ChargeB)+ ' '+ str(SP_b[0])+ ' '+str(SP_b[1])+ ' '+ str(SP_b[2])+ ' '+str(angle)+' '+str(1-math.cos(angle))+ ' '+ str(IP)+ ' '+ str(radL_a)+ ' '+ str(radL_b)
            #RecoString =str(len(datasetidx_holder))+' '+ str(vertex[0])+ ' '+ str(vertex[1])+ ' '+ str(vertex[2])+' '+ str(ChargeA)+ ' '+ str(SP_a[0])+ ' '+ str(SP_a[1])+ ' '+ str(SP_a[2])+' '+ str(ChargeB)+ ' '+ str(SP_b[0])+ ' '+str(SP_b[1])+ ' '+ str(SP_b[2])+ ' '+str(angle)+' '+str(1-math.cos(angle))+ ' '+ str(IP)+ ' '+ str(radL_a)+ ' '+ str(radL_b)
	    
            full_string = ers_string + ' '+ RecoString +'\n'
            lookup.writelines(full_string)

	    # Bump the id 
            id_B +=1        
    lookup.close()
    return
