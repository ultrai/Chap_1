clear
d = [pwd,'/'];
%% Data processing
files = dir([d,'Data/*.mat']);

GT1=[];
GT2=[];
Images=[];
AN=[];
AD =[];

for sub = 1:numel(files)
    load([d, 'Data/',files(sub).name])
    [~,~, ~,list] = maps2labels( images,manualLayers1 );
    gt1 = manualLayers1(:,:,list);
    gt2 = manualLayers2(:,:,list);
    an = automaticLayersNormal(:,:,list);
    ad = automaticLayersDME(:,:,list);
    I = images(:,:,list);
    GT1 = cat(3,GT1,gt1);
    GT2 = cat(3,GT2,gt2);
    AN = cat(3,AN,an);
    AD = cat(3,AD,ad);
    Images = cat(3,Images,I);
end    
GT1 = interp_nan(GT1); % identifies nan values and perform 1D interp
GT2 = interp_nan(GT2);
AN = interp_nan(AN);
AD = interp_nan(AD);

%% Load models
Model = {};
for layer = 1:8
opts=edgesTrain();                % default options (good settings)
opts.nChnsColor=1;
opts.modelFnm=['modelBsds_layer',num2str(layer)];        % model name
Model{layer}=edgesTrain(opts); 
end

%% predicitons
Pred = zeros(size(GT1));
for Idx = 1:size(Images,3)
    Img = Images(:,:,Idx)/255;
    Img(Img==1) =0.01;
    %imwrite(Img,['input',num2str(Idx),'.jpg'],'jpg')
    Img = cat(3,Img,Img,Img);
    parfor layer = 1:8
        model = Model{layer};
            tic, E=edgesDetect(Img,model);
         %   imwrite(mat2gray(E),['edges',num2str(layer),'.jpg'],'jpg')
         %   imwrite(short_path(mat2gray(E),['edges',num2str(layer),'_DP.jpg'],'jpg')
            [~,hat] = max(short_path(mat2gray(E)));toc
            Pred(layer,:,Idx) = sgolayfilt(hat,11,101); % no particular reason just randomly chosen
    end
%     [L1,L2] = maps2labels3( Img,Pred(:,:,Idx));
%     Out = image_result(Img,L1,L2);
    %imwrite(mat2gray(Out),['out',num2str(layer),'.jpg'],'jpg')
end
save('temp.mat')
%% Corrections  
load('temp.mat')
col_start = 120; % columns in all labelmaps are alloted nans
col_end = 650;

GT1 = GT1(:,col_start:col_end,:);
GT2 = GT2(:,col_start:col_end,:);
AN = AN(:,col_start:col_end,:);
AD = AD(:,col_start:col_end,:);
Pred = Pred(:,col_start:col_end,:);  

test = 56; % as first 55 images are alloted for training
GT1 = GT1(:,:,test:end); 
GT2 = GT2(:,:,test:end);
AN = AN(:,:,test:end);
AD = AD(:,:,test:end);
Pred = Pred(:,:,test:end);
%Pred=Pred-1;
Error = []; %absolute difference between predicted and actual contour along each column
for layer= 1:8
    Error_AN_GT1 = mean2(abs(GT1(layer,:,:)-AN(layer,:,:)));
    Error_AN_GT2 = mean2(abs(GT2(layer,:,:)-AN(layer,:,:)));
    Error_AD_GT1 = mean2(abs(GT1(layer,:,:)-AD(layer,:,:)));
    Error_AD_GT2 = mean2(abs(GT2(layer,:,:)-AD(layer,:,:)));
    Error_Pred_GT1 = mean2(abs(GT1(layer,:,:)-Pred(layer,:,:)));
    Error_Pred_GT2 = mean2(abs(GT2(layer,:,:)-Pred(layer,:,:)));
    Error = cat(1,Error,[Error_AN_GT1,Error_AN_GT2,Error_AD_GT1,Error_AD_GT2,Error_Pred_GT1,Error_Pred_GT2]);
end
width_GT1 = GT1(2:8,:,:)-GT1(1:7,:,:);
width_GT2 = GT2(2:8,:,:)-GT2(1:7,:,:);
width_AN = AN(2:8,:,:)-AN(1:7,:,:);
width_AD = AD(2:8,:,:)-AD(1:7,:,:);
width_Pred = Pred(2:8,:,:)-Pred(1:7,:,:);

width_Error = [];  %absolute difference between predicted and actual layer width along each column
for layer= 1:7
    width_Error_AN_GT1 = mean2(abs(width_GT1(layer,:,:)-width_AN(layer,:,:)));
    width_Error_AN_GT2 = mean2(abs(width_GT2(layer,:,:)-width_AN(layer,:,:)));
    width_Error_AD_GT1 = mean2(abs(width_GT1(layer,:,:)-width_AD(layer,:,:)));
    width_Error_AD_GT2 = mean2(abs(width_GT2(layer,:,:)-width_AD(layer,:,:)));
    width_Error_Pred_GT1 = mean2(abs(width_GT1(layer,:,:)-width_Pred(layer,:,:)));
    width_Error_Pred_GT2 = mean2(abs(width_GT2(layer,:,:)-width_Pred(layer,:,:)));
    width_Error = cat(1,width_Error,[width_Error_AN_GT1,width_Error_AN_GT2,width_Error_AD_GT1,width_Error_AD_GT2,width_Error_Pred_GT1,width_Error_Pred_GT2]);
end
Error1 = width_Error;

Images = Images(:,col_start:col_end,:);
Labels_GT1 = zeros(size(Images)); %label manual1
Labels_GT2 = zeros(size(Images)); %label manual2
Labels_AN = zeros(size(Images)); %label manual1
Labels_DME = zeros(size(Images)); %label manual2
Labels_Pred = zeros(size(Images)); %label prediction
parfor Idx = 1:size(Images,3)
    Img = Images(:,:,Idx)/255;
    Labels_GT1(:,:,Idx) = maps2labels( images,GT1(:,:,Idx));
    Labels_GT2(:,:,Idx) = maps2labels( images,GT2(:,:,Idx));
    Labels_AN(:,:,Idx) = maps2labels( images,AN(:,:,Idx));
    Labels_DME(:,:,Idx) = maps2labels( images,DME(:,:,Idx));
    Labels_Pred(:,:,Idx) = maps2labels( images,Pred(:,:,Idx));
end
C_AN1 = confusionmatStats(Labels_GT1,Labels_AN);
C_AN2 = confusionmatStats(Labels_GT2,Labels_AN);
C_DME1 = confusionmatStats(Labels_GT1,Labels_DME);
C_DME2 = confusionmatStats(Labels_GT2,Labels_DME);
C_Pred1 = confusionmatStats(Labels_GT1,Labels_Pred);
C_Pred2 = confusionmatStats(Labels_GT2,Labels_Pred);

