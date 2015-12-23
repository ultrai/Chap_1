# Retinal Layer delineation

## Computational Environment
64GB Ram Ubuntu 14.04

## Dependencies
1. [Piotr's Image & Video Matlab Toolbox](https://github.com/pdollar/toolbox) 
2. [Structured Edge Detection Toolbox ](https://github.com/pdollar/edges)
3. [Automated retinal layer delineation for benchmark](https://github.com/pangyuteng/caserel)


## Dataset
Prof. Sina Farsiu's team from Duke has generously made the data available [here!](http://people.duke.edu/~sf59/Chiu_BOE_2014_dataset.htm)

## Usage
Train models
```bash
>> run(main)
````
Evaluate models
```bash
>> run(Evaluation)
````
Test for an image
``` bash
>> I = imaread('test_image.jpg');
>> Out = zeros(size(I,1),size(I,2),8);
>> parfor layer = 1:8
>>        opts = edgesTrain();
>>        opts.modelDir='models/';          % model will be in models/forest
>>        opts.modelFnm=['modelBsds_layer',num2str(layer)];  
>>        model = edgesTrain(opts);
>>        E = edgesDetect(model,I);
>>        Out(:,:,layer) = shotest_path(mat2gray(E));
>>end
>> imshow(sum(Out,3))
```
