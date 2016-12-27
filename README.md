# Retinal Layer delineation
(Update: Pretrained models_multiclass & models (only trees as github forbids >25MB file) are released for evaluation and note that training a new model deletes the corresponding folder )
## Other baselines codes
1. [Probabilistic Intra-Retinal Layer Segmentation in 3-D OCT Images Using Global Shape Regularization](https://github.com/FabianRathke/octSegmentation)

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
Needs only 8GB of ram for evaluating 6 tree
But 4 trees (0.25-0.3sec per tree) during evaluation are suffcient for crossing benchmark
![Alt text](https://github.com/ultrai/Chap_1/blob/master/prediction.png)

moving on to single processor machine
![Alt text](https://github.com/ultrai/Chap_1/blob/master/space-time-1-procesor.png)

worst time complexity i.e., No dedicated memory, no OpenMP, single thread  results in 1sec per tree
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
The MIT License (MIT)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
