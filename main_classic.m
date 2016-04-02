clear
d = [pwd,'/'];
if exist('models/','dir')
%         rmdir('models','s')
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
files = dir([d,'Data/*.mat']);
Label = [];
Contour = [];
Images  = [];
for sub = 1:numel(files)
    load([d, 'Data/',files(sub).name])
    %I = images;
    %L = manualLayers1;
    [ L,L2, I,list] = maps2labels( images,round(0.5*(manualLayers1+manualLayers2) ));
%     ,v~
    Label = cat(3,Label,L);
    Contour = cat(3,Contour,L2);
     Images = cat(3,Images,I);
end
start=120;
sto = 650;
Label = Label(:,start:sto,:);
Contour = Contour(:,start:sto,:);
Images = Images(:,start:sto,:);

save([d,'Data.mat'],'Label','Contour','Images','-v7.3')
%% Training forest
clear
d = [pwd,'/'];
load([d,'Data.mat'])
Label = single(Label);
Contour = single(Contour); 
Images = single(Images);
s = size(Images);
for layer = 1:8
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
    groundTruth = {struct('Segmentation',reshape((Label(:,:,Idx)>(layer))+1,[s(1),s(2)]),'Boundaries',reshape((Contour(:,:,Idx)==layer),[s(1),s(2)]))};
    save([d,'Data/groundTruth/train/', num2str(Idx), '.mat'])
end


%% set opts for training (see edgesTrain.m)
opts=edgesTrain();                % default options (good settings)
opts.modelDir='models/';          % model will be in models/forest
opts.modelFnm=['modelBsds_layer',num2str(layer)];        % model name
% opts.nPos=5e5; opts.nNeg=5e5;     % decrease to speedup training
% opts.useParfor=0;                 % parallelize if sufficient memory
opts.nChnsColor=1;

%% train edge detector (~20m/8Gb per tree, proportional to nPos/nNeg)
tic, model=edgesTrain(opts); toc; % will load model if already trained
end
%%
clear
Evaluation
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