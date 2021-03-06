function [ Label,Label2, Images, list] = maps2labels3( I,L )
%converts indexes of layer contours to label images
    s = size(I);
    Label = [];
    Label2 = [];
    Images = [];
    list = [];
        image = I;
        l = L;
        if sum(~isnan(sum(l)))>50
            %scan
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
                    label(layers(lay,col,1):layers(lay,col,2),col)=lay-1;
                    label2(layers(lay,col,1),col)=lay-1;
                end
            end
            Label = cat(3,Label,label);
            Label2 = cat(3,Label2,label2);
            Images = cat(3,Images, image);
        end
end


