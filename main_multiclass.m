clear
d = [pwd,'/'];
if exist('models_multiclass/','dir')
        rmdir('models_multiclass/','s')
end
if exist('Data/images/train/','dir')
    rmdir('Data/images/train/','s')
    
end
if exist('Data/groundTruth/train/','dir')
    rmdir('Data/groundTruth/train/','s')
     
end
 mkdir([d,'Data/images/train/'])
 mkdir([d,'Data/groundTruth/train/'])

%% Data processing
% files = dir([d,'Data/*.mat']);
% Label = [];
% Contour = [];
% Images  = [];
% for sub = 1:numel(files)
%     load([d, 'Data/',files(sub).name])
%     %I = images;
%     %L = manualLayers1;
%     [ L,L2, I,list] = maps2labels( images,round(0.5*(manualLayers1+manualLayers2) ));
% %     ,v~
%     Label = cat(3,Label,L);
%     Contour = cat(3,Contour,L2);
%      Images = cat(3,Images,I);
% end
% start=120;
% sto = 650;
% Label = Label(:,start:sto,:);
% Contour = Contour(:,start:sto,:);
% Images = Images(:,start:sto,:);
% 
% save([d,'Data.mat'],'Label','Contour','Images','-v7.3')
%% Training forest
clear
d = [pwd,'/'];
load([d,'Data.mat'])
Label = single(Label);
Contour = single(Contour); 
Images = single(Images);
s = size(Images);
for Idx = 1:55%size(Images,3)
    Img = reshape(Images(:,:,Idx),[s(1),s(2)])/255;
    Img(Img==1)=0.01;
    %Img = filter_image(Img);
%     h= fspecial('average',[5 5]);
%     m1 = conv2(Img,h,'same');
%         m2 = conv2(Img.^2,h,'same');
%         m3 = conv2(Img.^3,h,'same');
%         m4 = conv2(Img.^4,h,'same');
%         feat2 = sqrt(m2-m1.^2);
%         feat3 = (m3-3*m2.*m1+2*m1.^3)./feat2.^3;
%         feat4 = (m4-4*m3.*m1+6*m2.*(m1.^2)-3*m1.^3+m1.^4)./feat2.^4;
%         Img = cat(3,Img,m1,feat2,feat3,feat4);
        Img = cat(3,Img,Img,Img);
    %imwrite(Img,[d,'BSR/BSDS500/data/images/train/', num2str(Idx), '.jpg'],'JPG')
    save([d,'Data/images/train/', num2str(Idx), '.mat'],'Img')
    groundTruth = {struct('Segmentation',reshape(Label(:,:,Idx),[s(1),s(2)]),'Boundaries',reshape(Contour(:,:,Idx),[s(1),s(2)]))};
    save([d,'Data/groundTruth/train/', num2str(Idx), '.mat'],'groundTruth')
end


%% set opts for training (see edgesTrain.m)
opts=edgesTrain2();                % default options (good settings)
opts.modelDir='models_multiclass/';          % model will be in models/forest
opts.modelFnm=['modelBsds_layer'];        % model name
opts.nPos=1.5e6; opts.nNeg=1.5e6;     % decrease to speedup training
% opts.useParfor=0;                 % parallelize if sufficient memory
opts.nChnsColor=1;

%% train edge detector (~20m/8Gb per tree, proportional to nPos/nNeg)
tic, model=edgesTrain2(opts); toc; % will load model if already trained
save('temp2.mat','-v7.3')
clear 
close all
load('temp2.mat')
Img = reshape(Images(:,:,62),[s(1),s(2)])/255;
Img(Img==1)=0.01;
Img = cat(3,Img,Img,Img);

model2 = model;
E_temp=edgesDetect(Img,model);%zeros(size(Img,1),size(Img,2));
for layer=8:-1:1
model = model2;
segs = model.segs;
        s = size(segs);
        %[sum(segs(:)==1) sum(segs(:)==2) sum(segs(:)==3)  sum(segs(:)==4)  sum(segs(:)==5)  sum(segs(:)==6) sum(segs(:)==7)] 
        segs_t = reshape(segs,s(1)*s(2),[]);
        segs_t=((segs_t>=layer)+1);
        segs_t = uint8(reshape(segs_t,s));
        
%         for rr = 1:s(3)
%             for cc = 1:s(4)
%             segs(:,:,rr,cc) = (segs(:,:,rr,cc)==layer)+1;
%             end
%         end
        %[sum(segs(:)==1) sum(segs(:)==2) sum(segs(:)==3)  sum(segs(:)==4)  sum(segs(:)==5)  sum(segs(:)==6) sum(segs(:)==7)] 
        model.segs=segs_t;
        tic, E=edgesDetect(Img,model);
        E = mat2gray(E);%-mat2gray(E_temp);
%         E_temp = E_temp+E;
if layer == 7
            figure,imshow(E,[])
end
end
%%
clear
% Evaluation_multiclass
% d = [pwd,'/'];
% load([d,'Data.mat'])
% s = size(Images);
% 
% Error = [];
% for layer = 1:8
% %% set opts for training (see edgesTrain.m)
% opts=edgesTrain();                % default options (good settings)
% opts.modelDir='models/';          % model will be in models/forest
% opts.modelFnm=['modelBsds_layer',num2str(layer)];        % model name
% opts.nPos=5e5; opts.nNeg=5e5;     % decrease to speedup training
% opts.useParfor=0;                 % parallelize if sufficient memory
% opts.nChnsColor=1;
% %% set detection parameters (can set after training)
% model.opts.multiscale=1;          % for top accuracy set multiscale=1
% model.opts.sharpen=1;             % for top speed set sharpen=0
% model.opts.nTreesEval=0;          % for top speed set nTreesEval=1
% model.opts.nThreads=8;            % max number threads for evaluation
% model.opts.nms=0;                 % set to true to enable nms
% model=edgesTrain(opts); % will load model if already trained
% err = [];
% formatspec = 'error is %1.4f \n';
% for Idx = 56 :size(Images,3)
%     Img = reshape(Images(:,:,Idx),[s(1),s(2)])/255;
%     Img(Img==1)=0.01;
%     %Img = filter_image(Img);
% %     h= fspecial('average',[5 5]);
% %     m1 = conv2(Img,h,'same');
% %         m2 = conv2(Img.^2,h,'same');
% %         m3 = conv2(Img.^3,h,'same');
% %         m4 = conv2(Img.^4,h,'same');
% %         feat2 = sqrt(m2-m1.^2);
% %         feat3 = (m3-3*m2.*m1+2*m1.^3)./feat2.^3;
% %         feat4 = (m4-4*m3.*m1+6*m2.*(m1.^2)-3*m1.^3+m1.^4)./feat2.^4;
% %         Img = cat(3,Img,m1,feat2,feat3,feat4);
%         I = cat(3,Img,Img,Img);
%     
%     tic, E=edgesDetect(I,model); 
%     Est = short_path(mat2gray(E));
%     C = Contour(:,:,Idx)==layer;
%     Est = Est(:,sum(C)>0);
%     C = C(:,sum(C)>0);
%     
%     [~,hat] = max(Est);
%     %hat = sgolayfilt(hat,11,101);
%     [~,GT] = max(C);
%     %fprintf(formatspec,sum(abs(GT-hat+1))/length(GT))
%     err = [err;sum(abs(GT-hat+1))/length(GT)];
% end
% Error = [Error err];
% end
% mean(Error)
% % 0.8144  1.0373  0.9737  0.9166  1.2073  0.6835  0.8368  0.7054
% % train 0.8330  1.0493  0.9801  0.9218 1.3699  0.6679  0.8947 0.7112
% 
% % test 0.8303  2.0972  1.7573  2.8220  3.1096  0.9042  1.8040  0.9583
% 
% %1.96 with sharp = 2 and cell =5