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
    list = []
    Label = np.array(Label, dtype=uint8)
    Label2 = np.array(Label2, dtype=uint8)
    Label = np.array(Label, dtype=uint8)
    for scan in range(I.shape[2]):
        image = I[:,:,scan]
        s = image.shape()
        l = L[:,:,scan]
        if np.sum(~np.isnan(l.sum(0)))>50:
            list = list.append(scan)
            l = np.round(l)
            l[l<3]=3
            l[l>s[0]] = s[0]
            layers = np.zeros((l.shape(0)+1,s[2],2))
            layers[1::,:,0) = l
            layers(::-2,:,1) = l-1
            layers(-1,:,1) = s[0]-1;
            label = np.zeros((s(0),s(1)))
            label2 = np.zeros((s(0),s(1)))
            for col in range(s(1)):
                for lay in range(layers.shape[0])):
                    label[layers[lay,col,0]:layers[lay,col,1],col)=lay+1
                    label2[layers[lay,col,0],col]=lay
            Label = np.concatenate((Label,label),axis=2)
            Label2 = np.concatenate((Label2,label2),axis=2)
            Images = np.concatenate((Images, image),axis=2)
    return (Label,Label2,Images,list)    

os.chdir("/home/mict/Desktop/edges-master" )
files = glob.glob(os.getcwd()+"/Data/*.mat")
Labels = []
Contours = []
Images = []
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
    L_M1,C_M1,Im,temp = maps2labels(I,L1-1) # as python is 0 index
    L_M2,C_M2,temp,temp = maps2labels(I,L2-1) # as python is 0 index
    L,C,temp,temp = maps2labels(I,0.5*(L1+L2)-1) # as python is 0 index
    Labels = Labels.append(L)
    Contours = Contours.append(C)
    Images = Images.append(Im)
    
    
