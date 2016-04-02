clear
d = [pwd,'/'];
warning('off','all')
%% Data processing
files = dir([d,'Data/*.mat']);

GT1=[];
GT2=[];
Images=[];
AN=[];
AD =[];

for sub = 1:10
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
opts=edgesTrain2();                % default options (good settings)
opts.nChnsColor=1;
opts.modelDir='models_multiclass/';  
opts.modelFnm=['modelBsds_layer'];        % model name
model2=edgesTrain2(opts);% will load model if already trained
% model2.opts.multiscale=1;          % for top accuracy set multiscale=1
% model2.opts.sharpen=1;             % for top speed set sharpen=0
% model2.opts.nTreesEval=0;          % for top speed set nTreesEval=1
% model2.opts.nThreads=8;            % max number threads for evaluation
Model = {};
for layer = 1:8
    model = model2;
%     model.opts.multiscale=1;          % for top accuracy set multiscale=1
% model.opts.sharpen=1;             % for top speed set sharpen=0
% model.opts.nTreesEval=0;          % for top speed set nTreesEval=1
% model.opts.nThreads=8;            % max number threads for evaluation
% model.opts.nms=0;                 % set to true to enable nms
    segs = model.segs;
        s = size(segs);
        segs_t = reshape(segs,s(1)*s(2),[]);
        segs_t=((segs_t>=layer)+1);
        segs_t = uint8(reshape(segs_t,s));
        model.segs=segs_t;
        Model{layer}=model;
end
        
% model.opts.multiscale=1;          % for top accuracy set multiscale=1
% model.opts.sharpen=1;             % for top speed set sharpen=0
% model.opts.nTreesEval=0;          % for top speed set nTreesEval=1
% model.opts.nThreads=8;            % max number threads for evaluation
% model.opts.nms=0;                 % set to true to enable nms

%% predicitons
Pred = zeros(size(GT1));
for Idx = 1:size(Images,3)
    if ~isnan(sum(Pred(:)))
%     Idx
    Img = Images(:,:,Idx)/255;
    Img(Img==1) =0.01;
    %imwrite(Img,['input',num2str(Idx),'.jpg'],'jpg')
    Img = cat(3,Img,Img,Img);
    parfor layer = 1:8
        model = Model{layer};
            tic, E=edgesDetect(Img,model);
         %   imwrite(mat2gray(E),['edges',num2str(layer),'.jpg'],'jpg')
            [~,hat] = max(short_path(mat2gray(E)));toc
%              figure,imshow(E)
            Pred(layer,:,Idx) = sgolayfilt(hat,11,101);%hat%sgolayfilt(hat,11,101);
    end
%     [L1,L2] = maps2labels3( Img,Pred(:,:,Idx));
%     Out = image_result(Img,L1,L2);
    %imwrite(mat2gray(Out),['out',num2str(layer),'.jpg'],'jpg')
    else
        break
    end
end
save('temp.mat')
%% Corrections  
load('temp.mat')
col_start = 120;
col_end = 650;

GT1 = GT1(:,col_start:col_end,:);
GT2 = GT2(:,col_start:col_end,:);
AN = AN(:,col_start:col_end,:);
AD = AD(:,col_start:col_end,:);
Pred = Pred(:,col_start:col_end,:);  
n = 56;
GT1 = GT1(:,:,n:end);
GT2 = GT2(:,:,n:end);
AN = AN(:,:,n:end);
AD = AD(:,:,n:end);
Pred = Pred(:,:,n:end);
%Pred=Pred-1;
Error = [];
for layer= 1:8
    Error_GT2 = mean2(abs(GT1(layer,:,:)-GT2(layer,:,:)));
    Error_AN_GT1 = mean2(abs(GT1(layer,:,:)-AN(layer,:,:)));
    Error_AN_GT2 = mean2(abs(GT2(layer,:,:)-AN(layer,:,:)));
    Error_AD_GT1 = mean2(abs(GT1(layer,:,:)-AD(layer,:,:)));
    Error_AD_GT2 = mean2(abs(GT2(layer,:,:)-AD(layer,:,:)));
    Error_Pred_GT1 = mean2(abs(GT1(layer,:,:)-Pred(layer,:,:)));
    Error_Pred_GT2 = mean2(abs(GT2(layer,:,:)-Pred(layer,:,:)));
    Error = cat(1,Error,[Error_GT2,Error_AN_GT1,Error_AD_GT1,Error_Pred_GT1,Error_AN_GT2,Error_AD_GT2,Error_Pred_GT2]);
end
width_GT1 = GT1(2:8,:,:)-GT1(1:7,:,:);
width_GT2 = GT2(2:8,:,:)-GT2(1:7,:,:);
width_AN = AN(2:8,:,:)-AN(1:7,:,:);
width_AD = AD(2:8,:,:)-AD(1:7,:,:);
width_Pred = Pred(2:8,:,:)-Pred(1:7,:,:);

width_Error = [];
for layer= 1:7
    width_Error_GT2 = mean2(abs(width_GT1(layer,:,:)-width_GT2(layer,:,:)));
    width_Error_AN_GT1 = mean2(abs(width_GT1(layer,:,:)-width_AN(layer,:,:)));
    width_Error_AN_GT2 = mean2(abs(width_GT2(layer,:,:)-width_AN(layer,:,:)));
    width_Error_AD_GT1 = mean2(abs(width_GT1(layer,:,:)-width_AD(layer,:,:)));
    width_Error_AD_GT2 = mean2(abs(width_GT2(layer,:,:)-width_AD(layer,:,:)));
    width_Error_Pred_GT1 = mean2(abs(width_GT1(layer,:,:)-width_Pred(layer,:,:)));
    width_Error_Pred_GT2 = mean2(abs(width_GT2(layer,:,:)-width_Pred(layer,:,:)));
    width_Error = cat(1,width_Error,[width_Error_GT2,width_Error_AN_GT1,width_Error_AD_GT1,width_Error_Pred_GT1,width_Error_AN_GT2,width_Error_AD_GT2,width_Error_Pred_GT2]);
end

Error1 = width_Error;

Images = Images(:,col_start:col_end,n:end);
Labels_GT1 = maps2labels( Images,GT1); %label manual1
Labels_GT2 = maps2labels( Images,GT2);%label manual2
Labels_AN = maps2labels( Images,AN); %label manual1
Labels_DME = maps2labels( Images,AD); %label manual2
Labels_Pred = maps2labels( Images,Pred); %label prediction

C_GT = confusionmatStats(Labels_GT1(:),Labels_GT2(:));
C_AN1 = confusionmatStats(Labels_GT1(:),Labels_AN(:));
C_AN2 = confusionmatStats(Labels_GT2(:),Labels_AN(:));
C_DME1 = confusionmatStats(Labels_GT1(:),Labels_DME(:));
C_DME2 = confusionmatStats(Labels_GT2(:),Labels_DME(:));
C_Pred1 = confusionmatStats(Labels_GT1(:),Labels_Pred(:));
C_Pred2 = confusionmatStats(Labels_GT2(:),Labels_Pred(:));
Error2 = [C_GT.Fscore C_AN1.Fscore C_DME1.Fscore C_Pred1.Fscore C_AN2.Fscore C_DME2.Fscore  C_Pred2.Fscore];
Error = (round(1000*Error))/1000;
Error1 = (round(1000*Error1))/1000;
Error2 = (round(1000*Error2))/1000;
save('Benchmark_multiclass','Error','Error1','Error2')