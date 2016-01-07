function [Out Out1 Out2] = image_result( Img,L1,L2 )
Img(Img==1)=0.01;
I = Img(:,:,1);

ll = [[20,10,240];[2,123,10];[240,10,10];[18,170,170];[170,30,170];[180,180,0];[17,160,170];[10,10,220];[10,120,10]];
%ll = [[240,150,150];[150,220,150];[140,170,220];[220,240,180];[210, 140,220];[230,210,150];[220,170,180];[170,220,160];[160,170,220]];
Mask1_1 = ones(size(I,1),size(I,2))*255;
Mask2_1 = ones(size(I,1),size(I,2))*255;
Mask1_2 = ones(size(I,1),size(I,2))*255;
Mask2_2 = ones(size(I,1),size(I,2))*255;
Mask1_3 = ones(size(I,1),size(I,2))*255;
Mask2_3 = ones(size(I,1),size(I,2))*255;
L2 = imdilate(L2,strel('disk',1));

for layer = 1:8
    Mask1_1(L1==layer) = ll(layer,1);
    Mask1_2(L1==layer) = ll(layer,2);
    Mask1_3(L1==layer) = ll(layer,3);
    Mask2_1(L2==layer) = ll(layer,1);
    Mask2_2(L2==layer) = ll(layer,2);
    Mask2_3(L2==layer) = ll(layer,3);
end

Mask1 = cat(3,Mask1_1,Mask1_2,Mask1_3);
Mask2 = cat(3,Mask2_1,Mask2_2,Mask2_3);
n=round(size(Mask1,2)/2);
Mask = cat(2,Mask1(:,1:n,:),Mask2(:,n+1:end,:))/255;
I = Img;
Out = I .*Mask;
Out1 = Mask1;
Out2 = Mask2;

%figure,imshow(Out)
end
