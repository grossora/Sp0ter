import numpy as np
import math as math
import lib.utility.Geo_Utils.axisfit as axfi
import lib.SParams.selpizero as selpz


def shower_pairs_ana_data(dataset, holder,labels, jcount, tpath , filename='dummy_data_ana.txt'):
    # This will be a function to write the text file that will be used to look at pairs of showers
    # note there are no cuts in here. Just filling out all the pairs
    
    # File will go in the out directory 
    lookup = open('Out_text/{}.txt'.format(filename),'a+')

    # number of shower objects 
    N_Showers = len(holder) 
    
    if N_Showers<2: 
        # Fill out the list and returno
        fill = str('-9 ')*11 # This is the size to fill the frame
        fillline = str(jcount)+ ' '+ str(N_Showers) + ' '+ fill.rsplit(' ',1)[0] + '\n'
        lookup.writelines(fillline)
        lookup.close()
        return

    # Now run over the pairs and fill  out the files 
    for a in range(len(holder)):
        shrA = axfi.weightshowerfit(dataset,holder[a],labels)
        EA = selpz.corrected_energy(dataset,holder[a]) # This function is nont active at the moment
        ChargeA = selpz.totcharge(dataset,holder[a])
        N_sptA = len(holder[a])

        for b in range(a+1,len(holder)):
            shrB = axfi.weightshowerfit(dataset,holder[b],labels)
            EB = selpz.corrected_energy(dataset,holder[b])
            ChargeB = selpz.totcharge(dataset,holder[b])
            N_sptB = len(holder[b])
            vertex = selpz.findvtx(shrA,shrB)
            IP = selpz.findIP(shrA,shrB)

            SP_a = selpz.findRoughShowerStart(dataset,holder[a],vertex)
            radL_a = selpz.findconversionlength(vertex,SP_a)
            SP_b = selpz.findRoughShowerStart(dataset,holder[b],vertex)
            radL_b = selpz.findconversionlength(vertex,SP_b)
            angle = selpz.openingangle(shrA,shrB,vertex)

            selection_line = str(N_sptA) + ' ' + str(ChargeA) + ' '+ str(N_sptB) + ' '+ str(ChargeB) + ' '+ str(vertex[0]) + ' '+ str(vertex[1]) + ' '+ str(vertex[2]) + ' '+ str(IP) + ' '+ str(radL_a) + ' '+ str(radL_b) + ' '+ str(angle)

            fullrecoline = str(jcount)+ ' '+ str(N_Showers) +' '+ selection_line + '\n'
            lookup.writelines(fullrecoline)
    lookup.close()
    return







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
