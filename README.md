# Retinal Layer delineation

## Computational Environment
112GB Ram Ubuntu 14.04 

## Dependencies
1. [Piotr's Image & Video Matlab Toolbox](https://github.com/pdollar/toolbox) 
2. [Structured Edge Detection Toolbox ](https://github.com/pdollar/edges)
3. [Automated retinal layer delineation for benchmark](https://github.com/pangyuteng/caserel)


## Dataset
Prof. Sina Farsiu's team from Duke has generously made the data available [here!](http://people.duke.edu/~sf59/Chiu_BOE_2014_dataset.htm)

## Results
![Alt text](https://github.com/ultrai/Chap_1/blob/master/Results/out2.png)

## Usage
Train models
```bash
>> run(main_multiclass) % for faster trainng but slightly inferior results (~error = 0.01)
or
>> run(main_classic)  
````
Evaluate models (6 trees)
```bash
>> run(Evaluation_multicalss) % if trained with main_multiclass
or
>> run(Evaluation)  % if trained with main_classic
````
Needs only 8GB of ram (for 1sec prediction OpenMP is needed)
![Alt text](https://github.com/ultrai/Chap_1/blob/master/prediction.png)

moving on to single processor machine
![Alt text](https://github.com/ultrai/Chap_1/blob/master/space-time-1-procesor.png)

worst time complexity i.e., No dedicated memory, no OpenMP, single thread  results in 0.5-1sec per tree
![Alt text](https://github.com/ultrai/Chap_1/blob/master/space-time-3.png)


Test for an image
``` bash
% Img is the test image and models are trained with main_classic
Img(Img==1) =0.01;
Img = cat(3,Img,Img,Img);
parfor layer = 1:8
        model = Model{layer};
        tic, E=edgesDetect(Img,model);
        [~,hat] = max(short_path(mat2gray(E)));toc
        Pred = sgolayfilt(hat,11,101);%hat%sgolayfilt(hat,11,101);
end
[L1,L2] = maps2labels3( Img,Pred);
Out = image_result(Img,L1,L2);
Out = Out(:,120:650,:);
imwrite(mat2gray(Out),['out.png'],'png')

```
