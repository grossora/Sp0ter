import numpy as np
import collections as col


def label_to_idxholder(labels,min_cluster):
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


