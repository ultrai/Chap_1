function [Label,ML1,ML2] = bench_mark()
%comment 112 line of getHyperReflectiveLayers.m
Label=[];
ML1=[];
ML2 = [];
Label=uint8(Label);
addpath(genpath('pangyuteng-caserel-bb0865d/'))
%d='Automatic versus Manual Study/';
d='Data/';
files = dir([d,'/*.mat']);


for Count = 1:length(files)
    load([d,files(Count).name]);
    [~,~, ~,list] = maps2labels( images,manualLayers1 );
    images = images(:,:,list);
    manualLayers1 = manualLayers1(:,:,list);
    manualLayers2 = manualLayers2(:,:,list);
    manualLayers1 =interp_nan(manualLayers1);
    manualLayers2 =interp_nan(manualLayers2);
    for stack = 1:size(images,3)
        I = images(:,:,stack);
        I = mat2gray(I);
        scale=0.5;
        Img = imresize(I,scale); %because heuristics by pangyuteng is considred for this scale
        try
            retinalLayers = getRetinalLayers(Img); % tags Bruch as RPE
            for temp = 1:7
                y = retinalLayers(temp).pathX; % they are interchanged in getRetinalLayers
                x = retinalLayers(temp).pathY;
                y(x==1)=[];
                x(x==1)=[];
                y(x==(size(Img,2)+2))=[];
                retinalLayers(temp).pathY = y;
            end
            Ilm = retinalLayers(1).pathY;
            NFL = retinalLayers(5).pathY;
            IPL = retinalLayers(6).pathY;
            INL = retinalLayers(4).pathY;
            OPL = retinalLayers(7).pathY;
            ISOS = retinalLayers(2).pathY;
            Bruch = retinalLayers(3).pathY;
            img = Img;
            for temp =1:size(img,2)
                img(1:ISOS(temp)+4,temp) = Img(ISOS(temp)+4,temp);
                img(Bruch(temp)-2:end,temp) = Img(Bruch(temp)-2,temp);
            end
            [adjMatrixW, adjMatrixMW, adjMAsub, adjMBsub, adjMW, adjMmW, img] = getAdjacencyMatrix(img);
            adjMatrixW = sparse(adjMAsub,adjMBsub,adjMmW,numel(img(:)),numel(img(:)));    
            [ ~, path ] = graphshortestpath( adjMatrixW, 1, numel(img(:)) );
            [pathX, pathY] = ind2sub(size(img),path);
            pathX(pathY==1)=[];
            pathY(pathY==1)=[];
            pathX(pathY==(size(Img,2)+2))=[];
            RPE = pathX;
            layers =  [Ilm; NFL; IPL; INL;OPL; ISOS; RPE; Bruch];
            Layers = [];
            for temp = 1:size(layers,1)
                ll = layers(temp,:)/scale;
                ll =  interp1(1:length(ll),ll,scale:scale:length(ll));
                Layers = cat(1,Layers,ll);
            end
            Label = cat(3,Label,Layers);
        catch
            Label = cat(3,Label,ones(8,size(I,2)));
        end
      ML1 = cat(3,ML1,manualLayers1(:,:,stack));
      ML2 = cat(3,ML2,manualLayers2(:,:,stack));
    end
  end
end
