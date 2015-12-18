function [ Label,Label2, Images,list] = maps2labels( I,L )
%converts indexes of layer contours to label images
    Label = [];
    Label2 = [];
    Images = [];
    list = [];
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

