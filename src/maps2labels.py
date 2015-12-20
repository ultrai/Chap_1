import os, sys
import glob
import scipy.io as sio

import numpy as np
nan = np.nan
isnan = np.isnan

def interp_nan(layers):
    s=layers.shape
    L = np.zeros([s[0],s[1],s[2]])
#    L = zeros(size(layers));
    for temp in range(s[2]):
        #for temp = 1:size(layers,3)
        l = layers[:,:,temp]
        #l = layers(:,:,temp);
        for layer in range(s[0]):
        #for layer = 1:size(l,1)
            A = l[layer,:]
            ok = ~np.isnan(A)
            xp = ok.ravel().nonzero()[0]
            fp = A[~np.isnan(A)]
            x  = np.isnan(A).ravel().nonzero()[0]
            A[np.isnan(A)] = np.interp(x, xp, fp)
            l[layer,:] = A
        L[:,:,temp] = l
    return L

def maps2labels(I,L):
    Label = []
    Label2 = []
    Images = []
    list = []
    Label = np.array(Label, dtype=uint8)
    Label2 = np.array(Label2, dtype=uint8)
    Label = np.array(Label, dtype=uint8)

os.chdir("/home/mict/Desktop/edges-master" )
files = glob.glob(os.getcwd()+"/Data/*.mat")
for x in range(files):
    x=0
    data = sio.loadmat(files[x])
    I = data['images']    #data.keys()
    L1 = data['manualLayers1']
    L2 = data['manualLayers1']
    nan_check = np.sum(np.sum(~isnan(L1),axis=0),axis=0)
    I = I[:,:,nan_check>0]
    Label1 = L1[:,:,nan_check>0]
    Label2 = L2[:,:,nan_check>0]
    L1 = interp_nan(Label1)
    L2 = interp_nan(Label2)
    Label = np.uint8([])
    Label2 = np.uint8([])
    Images = np.uint8([])
   
