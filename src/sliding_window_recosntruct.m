% Extracts overlapping patches amd recosntructs from overlapping patches
A = im2double(imread('cell.tif')); 
n = 3;
B = im2col(A,[3 3]);
out = zeros([size(A),n*n]);
k=0;
for row = 1:n
    for col = 1:n
        k=k+1;
        out(row:row+size(A,1)-n,col:col+size(A,2)-n,k) = reshape(B(k,:),[size(A)-n+1]);
    end
end
wei = double(out>0);
Out = sum(out,3)./sum(wei,3);
%% OR to avoid blurring but include patches around corners%%
Out = zeros([size(A)]);
Out_temp = zeros([size(A)]);
Out(1:size(A,1)-n+1,1:size(A,2)-n+1) = reshape(B(1,:),[size(A)-n+1]);
Out_temp(n:size(A,1),n:size(A,2)) = reshape(B(n*n,:),[size(A)-n+1]);
Out(:,end-n:end) = Out_temp(:,end-n:end);
Out(end-n:end,:) = Out_temp(end-n:end,:);

