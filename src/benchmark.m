function [Error, width_Error, Label,ML1,ML2] = bench_mark()%[Label,ML1,ML2] = bench_mark()
addpath(genpath('caserel-master'))
Label=[];
ML1=[];
ML2 = [];
%Label=uint8(Label);
col_start = 120; % columns in all labelmaps are alloted nans
col_end = 650;

%addpath(genpath('pangyuteng-caserel-bb0865d/'))
%d='Automatic versus Manual Study/';
d='Data/';
files = dir([d,'/*.mat']);


for Count = 1:length(files)
     load([d,files(Count).name]);
      [~,~, ~,list] = maps2labels( images,manualLayers1 );
      images = images(:,col_start:col_end,list);
      manualLayers1 = manualLayers1(:,col_start:col_end,list);
      manualLayers2 = manualLayers2(:,col_start:col_end,list);
      manualLayers1 =interp_nan(manualLayers1);
      manualLayers2 =interp_nan(manualLayers2);
      for stack = 1:size(images,3)
%           Count
%           stack
           Img = images(:,:,stack);
           Img =Img/255;
           Img(Img==1)=0.01;
           Img = mat2gray(Img);
           retinalLayers = getRetinalLayers(Img); % tags Bruch as RPE
           for temp = 1:7
               y = retinalLayers(temp).pathX; % they are interchanged in getRetinalLayers
               x = retinalLayers(temp).pathY;
               y(x==1)=[];
               x(x==1)=[];
               y(x==max(x))=[];
               x(x==max(x))=[];
               retinalLayers(temp).pathY = y;
               retinalLayers(temp).pathX = x;
%                ll = round(interp1(1:length(y*2),y*2,1:0.5:length(y*2)));
%                ll(1)=ll(2);
%                ll(ll<1)=1;ll(ll>size(Img,1))=size(Img,1);
%                retinalLayers(temp).pathY = ll;
%                retinalLayers(temp).pathX = (x-1)*2;
           end
           Ilm = retinalLayers(1).pathY;
           NFL = retinalLayers(5).pathY;
           IPL = retinalLayers(6).pathY;
           INL = retinalLayers(4).pathY;
           OPL = retinalLayers(7).pathY;
           ISOS = retinalLayers(2).pathY;
           Bruch = retinalLayers(3).pathY;
           img = imresize(Img,0.5); % Chiu 2010 does that and caserel follows 
            for temp =1:size(img,2)
                img(1:ISOS(temp)+2,temp) = Img(ISOS(temp)+2,temp);
                img(Bruch(temp)-1:end,temp) = Img(Bruch(temp)-1,temp);
            end
           [~, ~, adjMAsub, adjMBsub, ~, adjMmW, img] = getAdjacencyMatrix(img);
           adjMatrixW = sparse(adjMAsub,adjMBsub,adjMmW,numel(img(:)),numel(img(:)));    
           [ ~, path ] = graphshortestpath( adjMatrixW, 1, numel(img(:)) );
           [pathX, pathY] = ind2sub(size(img),path);
           pathX(pathY==1)=[];
           pathY(pathY==1)=[];
           pathX(pathY==max(pathY))=[];
           RPE = pathX;
           layers =  [Ilm; NFL; IPL; INL;OPL; ISOS; RPE; Bruch];
           Layers = [];
           scale =0.5;
            for temp = 1:size(layers,1)
                ll = layers(temp,:)/scale;
                ll =  interp1(1:length(ll),ll,1:scale:length(ll));
                Layers = cat(1,Layers,ll);
            end
            Layers(:,1,:) = Layers(:,2,:);
           
           Label = cat(3,Label,Layers);
    ML1 = cat(3,ML1,manualLayers1(:,:,stack));
    ML2 = cat(3,ML2,manualLayers2(:,:,stack));
           
     end
           
end

GT1 = ML1;
GT2 = ML2;
% col_start = 120; % columns in all labelmaps are alloted nans
% col_end = 650;
% GT1 = GT1(:,col_start:col_end,:);
% GT2 = GT2(:,col_start:col_end,:);
% Label = Label(:,col_start:col_end,:);  

test = 56; % as first 55 images are alloted for training
GT1 = GT1(:,:,test:end); 
GT2 = GT2(:,:,test:end);
Label = double(Label(:,:,test:end));

Error = []; %absolute difference between predicted and actual contour along each column
for layer= 1:8
    Error_Label_GT1 = mean2(abs(GT1(layer,:,:)-Label(layer,:,:)));
    Error_Label_GT2 = mean2(abs(GT2(layer,:,:)-Label(layer,:,:)));
    Error = cat(1,Error,[Error_Label_GT1,Error_Label_GT2]);
end
width_GT1 = GT1(2:8,:,:)-GT1(1:7,:,:);
width_GT2 = GT2(2:8,:,:)-GT2(1:7,:,:);
width_Label = Label(2:8,:,:)-Label(1:7,:,:);

width_Error = [];  %absolute difference between predicted and actual layer width along each column
for layer= 1:7
    width_Error_Label_GT1 = mean2(abs(width_GT1(layer,:,:)-width_Label(layer,:,:)));
    width_Error_Label_GT2 = mean2(abs(width_GT2(layer,:,:)-width_Label(layer,:,:)));
    width_Error = cat(1,width_Error,[width_Error_Label_GT1,width_Error_Label_GT2]);
end
end
