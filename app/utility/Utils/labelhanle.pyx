import numpy as np
import collections as col


def label_to_idxholder(labels,int min_cluster):
    # This must be slow.... we can spead this up
    shi = col.Counter(labels)
    # Shi is a set, and dic lookup 
    cval = [x[0] for x in shi.items() if x[1]>=min_cluster and x[0]!=-1]
    #cval = [x[0] for x in shi.items() if x[1]>min_cluster]
    datasetidx_holder = []
    datasetidx_v = []
    for s in cval:
        datasetidx_v=[]
        [datasetidx_v.append(i) for i,j in enumerate(labels) if j==s]
        datasetidx_holder.append(datasetidx_v)
    return datasetidx_holder

def largestlabel_to_idxholder(labels):
    shi = col.Counter(labels)
    largest = shi.most_common(1)[0][0]
    # Shi is a set, and dic lookup 
    cval = [x[0] for x in shi.items() if x[0]==largest]
    datasetidx_holder = []
    datasetidx_v = []
    for s in cval:
        datasetidx_v=[]
        [datasetidx_v.append(i) for i,j in enumerate(labels) if j==s]
        datasetidx_holder.append(datasetidx_v)
    return datasetidx_holder


def unlabel_from_labels(labels,int min_cluster):
    # This must be slow.... we can spead this up
    shi = col.Counter(labels)
    # Shi is a set, and dic lookup 
    #cval = [x[0] for x in shi.items() if x[1]>=min_cluster and x[0]!=-1]
    cval = [x[0] for x in shi.items() if x[1]<min_cluster]
    datasetidx_v = []
    for s in cval:
        [datasetidx_v.append(i) for i,j in enumerate(labels) if j==s]
        #datasetidx_holder.append(datasetidx_v)
    return datasetidx_v

def unlabel_holder_from_labels(labels,int min_cluster):
    # This must be slow.... we can spead this up
    shi = col.Counter(labels)
    # Shi is a set, and dic lookup 
    #cval = [x[0] for x in shi.items() if x[1]>=min_cluster and x[0]!=-1]
    cval = [x[0] for x in shi.items() if x[1]<min_cluster]
    datasetidx_holder = []
    datasetidx_v = []
    for s in cval:
        datasetidx_v=[]
        [datasetidx_v.append(i) for i,j in enumerate(labels) if j==s]
        datasetidx_holder.append(datasetidx_v)
    return datasetidx_holder

def unique_relabel(labels, idx_holder): 
    # Takes in the labels an returns a new label list  that rebases the indexs based on the holder
    # we can copy the labels length 
    relabel = [ -1 for x in range(len(labels))]

    # Counter for the new label     
    counter = 0 
    for holder in idx_holder: 
        for idx in holder: 
            relabel[idx] = counter
        counter+=1
    # now return the relabel
    return relabel
         



 
