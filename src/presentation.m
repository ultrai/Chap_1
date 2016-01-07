clear
d = [pwd,'/'];
files = dir([d,'Data/*.mat']);
Label = [];
Contour = [];
Images  = [];
sub = 1
load([d, 'Data/',files(sub).name])
[ L,L2, I,list] = maps2labels( images,round(0.5*(manualLayers1+manualLayers2) ));

start=120;
sto = 650;
I=I/255;
II=I;
n=8;
[out out1 out2] = image_result( cat(3,II(:,start:sto,7),II(:,start:sto,7),II(:,start:sto,n)),(L(:,start:sto,n)),(L2 (:,start:sto,n)));

imwrite(I(:,start:sto,n),'input.bmp','bmp')
imwrite(out,'train_result.bmp','bmp')
imwrite(mat2gray(out1),'train_segmentation.bmp','bmp')
imwrite(mat2gray(out2),'train_segmentation2.bmp','bmp')
%%
clear 
load('Data.mat')
n=8;
I = Images(:,:,n);
I=I/255;
II=I;
II(II==1)=0.01;
II=rgbConvert(II,'gray');
[M,O] = gradientMag( II, 0, 4, .01 );
H = gradientHist( M, O, 1,4, 0 );
imwrite(II,'feat.bmp','bmp')
imwrite(mat2gray(convTri(M,2)),'feat1.bmp','bmp')
imwrite(mat2gray(convTri(H(:,:,1),2)),'feat1.bmp','bmp')
imwrite(mat2gray(convTri(H(:,:,2),2)),'feat2.bmp','bmp')
imwrite(mat2gray(convTri(H(:,:,3),2)),'feat3.bmp','bmp')
imwrite(mat2gray(convTri(H(:,:,4),2)),'feat4.bmp','bmp')

      
%%

clear 
load('Data.mat')
n=63;
I = Images(:,:,n);
L = Label(:,:,n);
C = Contour(:,:,n);
Out = zeros(size(I,1),size(I,2),8);
I=I/255;
II=I;
II(II==1)=0.01;
parfor layer = 1:8
        opts = edgesTrain();
        opts.modelDir='models/';          % model will be in models/forest
        opts.modelFnm=['modelBsds_layer',num2str(layer)];  
        model = edgesTrain(opts);
              E = edgesDetect(II,model);
        Out(:,:,layer) = short_path(mat2gray(E));
end
ML = [];
for layer = 1:8
    [~,idx] = max(Out(:,:,layer));
    ML=cat(1,ML,idx);
end
[ L,L2] = maps2labels( I,ML);

[out out1 out2] = image_result( cat(3,II,II,II),L,L2);

imwrite(I,'testinput.bmp','bmp')
imwrite(out,'test_result.bmp','bmp')
imwrite(mat2gray(out1),'test_segmentation.bmp','bmp')
imwrite(mat2gray(out2),'test_segmentation2.bmp','bmp')
