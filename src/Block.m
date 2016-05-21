clear 
load('Data.mat')
I = Images(:,:,8);
L = Label(:,:,8);
C = Contour(:,:,8);

imwrite(mat2gray(L),'segmentation.tif','tif')
imwrite(mat2gray(I),'input.tif','tif')
imwrite(mat2gray(C),'segmentation2.tif','tif')
% cmap = hsv(9);  
Out1 = zeros([size(I)]);
Out2 = zeros([size(I)]);
Out3 = zeros([size(I)]);
Out1_2 = zeros([size(I)]);
Out2_2 = zeros([size(I)]);
Out3_2 = zeros([size(I)]);
cmap = [[20,10,240];[2,123,10];[240,10,10];[18,170,170];[170,30,170];[180,180,0];[17,160,170];[10,10,220];[10,120,10]];
for i = 1:9    
  colo = cmap(i,:);
  Out1(C==i) = colo(1);
  Out2(C==i) = colo(2);
  Out3(C==i) = colo(3);
  Out1_2(L==i) = colo(1);
  Out2_2(L==i) = colo(2);
  Out3_2(L==i) = colo(3);
end
Out = cat(3,Out1,Out2,Out3);
Out_2 = cat(3,Out1_2,Out2_2,Out3_2);
imwrite(mat2gray(Out_2),'segmentation.png','png')
imwrite(mat2gray(I),'input.png','png')
imwrite(mat2gray(Out),'segmentation2.png','png')
figure,imshow(mat2gray(Out_2(115:115+236,135:135+236,:)))
