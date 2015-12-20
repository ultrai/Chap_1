import os, sys
import glob
import scipy.io as sio
import numpy as np


def maps2labels(I,L):
    Label = []
    Label2 = []
    Images = []
    list = []
    Label = np.array(Label, dtype=uint8)
    Label2 = np.array(Label2, dtype=uint8)
    Label = np.array(Label, dtype=uint8)
  
   return [ Label,Label2, Images, list]



os.chdir("/home/mict/Desktop/edges-master" )
files = glob.glob(os.getcwd()+"/Data/*.mat")
for x in range(files):
    x=0
    data = sio.loadmat(files[x])
    I = data['images']    #data.keys()
    L = data['manualLayers1']
    Label = []
    Label2 = []
    Images = []
    list = []
    
    
    Label = np.uint8([])
    Label2 = np.uint8([])
    Images = np.uint8([])

    for scan = 1:size(I,3)
        image = I(:,:,scan);
%         image = imresize(image,0.5);
        s = size(image);
        l = L(:,:,scan);
%         l = round(l/2);
%         l = imresize(l,[8,s(2)]);
        
        if sum(~isnan(sum(l)))>50
            list = [list;scan];
            for layer = 1:size(l,1)
                l_temp = l(layer,:);
                t = 1:numel(l_temp);
                l(layer,:) = interp1(t(~isnan(l_temp)),l_temp(~isnan(l_temp)),t,'linear','extrap');
            end
            l = round(l);
            l(l<3)=3;
            l(l>s(1)) = s(1);
            layers = ones(size(l,1)+1,s(2),2);
            layers(2:end,:,1) = l;
            layers(1:end-1,:,2) = l-1;
            layers(end,:,2) = s(1);
            label = zeros(s(1),s(2));
            label2 = zeros(s(1),s(2));
            for col = 1: s(2)
                for lay = 1: size(layers,1)
                    label(layers(lay,col,1):layers(lay,col,2),col)=lay;
                    label2(layers(lay,col,2),col)=lay;
%                     label(layers(lay,col,1):layers(lay,col,2),col)=lay;
%                     label2(layers(lay,col,1),col)=lay-1;
                end
            end
            Label = cat(3,Label,label);
            Label2 = cat(3,Label2,label2);
            Images = cat(3,Images, image);
        end
    end
end

