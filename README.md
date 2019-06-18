# Loading '.nd2' file into Matlab

![MIT - License](https://img.shields.io/bower/l/bootstrap.svg)

## 1. Overview

This is a small tool to load '.nd2' image stack into Matlab with 'ND2SDK' (Windows/Linux). The SDK is provided [here](https://www.nd2sdk.com/) by [Laboratory Imaging](https://www.laboratory-imaging.com/). 

The windows version is 'Master' branch and if you needed Linux version you can change to 'Linux' branch and download it.

For now, only uint16 mono-color ```.nd2``` file is supported. The reader can get the infomation of channel infomation and loops infomation of the file.

**Knowing issues:**

1. Now we cannot get metadata from some spesific ```.nd2``` file with the ```ND2SDK```. For these files we use the information in ```TextInfo``` to get the channel and loop information.  
2. For the files that show empty metadata in the script, we can neither get the frame metadata. Therefore, the ```SeqInfo``` funtion do not work for these files.  
3. By comparing the information in ```TextInfo``` and ```ExperimentInfo```, I found that there are some difference in loop information if you set multipoints in ```xp position loop``` but not check all the choice box during capturing. ```ExperimentInfo``` record all the points you set in ```nd2capture``` while ```TextInfo``` only record the points that you really captured during the expriment.

## 2. Usage

### 2.1 Load the library

Matlab provides function ```loadlibrary``` to load C / C++ libraries into Matlab. You need to configure for C language compilation in your Matlab.

```matlab
mex -setup
```

If you do not have any compiler, you can add 'MinGW64 Compiler' in 'HOME' > 'Add-Ons' follow the image below.

![MinGW64](/Resource/MinGW64.jpg "MinGW64")

Once you set up the C compiler, you should able to sucessfully loading the library by command,

```matlab
loadlibrary('Nd2ReadSdk', 'Nd2ReadSdk.h')
```
Noticed that you should add the 'SDK' (both 'include' and 'windows' folder) into Matlab 'Path'. 

For Linux version, you should add both 'include' and 'Linux' folder into Matlab 'Path' and you can load the library with,

```
loadlibrary('libNd2ReadSdk', 'Nd2ReadSdk.h')
```

### 2.2 Read the infomation in '.nd2' file

You can run the command below to get the information from the file. ```FileName``` should contain the full path and extension name, such as ```'D:\Data\Test.nd2'```

```matlab
[ImageInfo] = ND2Info(FileName)
```
The function will runture a structure ```ImageInfo``` contains the width, height, number of images and also channel numbers. Also the experiment details are recorded in ```ImageInfo.metadata``` and ```ImageInfo.Experiment```.

The infomation will be print on the command window such as,

```matlab
There are 3608 images in 2 channel(s).
The No. 1 channel is: Phase Contrast 100ms
The No. 2 channel is: GFP 100ms
Images are captured in 2 layer(s) of loops
The No. 0 layer is: 164 TimeLoop
The No. 1 layer is: 11 XYPosLoop
```

The total images number should be same as the product of loops number in each layer and also the channels number. These images are organised as the figure below.

![ND2 Oganization](/Resource/nd2-oganization.jpg "ND2 Oganization")


### 2.3 Read image.

If you want to read a specific image in a '.nd2' file. You can use the command below to read the image with the specific sequence index (not the image index) ```Num```.

```matlab
[Image] = ND2ReadSingle(FileName, Num)
```

If your '.nd' file has multiple channels, i.e. ```Components```, these channels would be stored in different cells in ```Image``` as ```Image{1}```, ```Image{2}```,.... 

If you want to read out multiple images at once, you can specify the image index as ```Num = [1,2,3...]```. The result ```Image``` will be in a 3D array in Matlab. Additionally, multiple channels images will be stored in different cells and each cell contains the 3D matrix of the image stack.

If you haven't spicified the image index ```Num```. ```[Image] = ND2ReadSingle(FileName)``` will read all the images in the file into ```Image```.

Here, ```Single``` means store all the data into a single variable.


### 2.4 TIF stack output

The ```ND2TIF``` function can save the ```.nd2``` stack into ```.tif``` stacks based on loops and channels. 

```matlab
ND2TIF(FileName)
```
Running the above command will seprated your image into ```.tif``` stacks of the highest level loops (layer 0, see 2.2 above).

![Save as TIF](/Resource/Save-as-tif.gif "Save as TIF")

You can also control the output ```.tif``` stack with ```Parameter``` as below. You can find the corresponding parameters in 3.2 below.

```matlab
ND2TIF(FileName, 'Parameter', value)
```

## 3. Advanced usage

### 3.1 Read images with a loop

If your '.nd2' file is very huge and not able to read all the data into the memory. You can also read the image with a ```for``` loop. But, do not use ```ND2ReadSingle``` in a loop as each calling will open and close the file pointer once.

You would better create a file pointer, read the images you need, and then close the pointer. Here is an example.

```matlab
[FilePointer, ImagePointer, ImageReadOut] = ND2Open(FileName);
Num = 2:2:100;
for i =1:size(Num, 2)
    Image = ND2Read(FilePointer, ImagePointer, ImageReadOut, Num(i));
end
ND2Close(FilePointer)
```

### 3.2 Select .tif output channel and merge montage stack.

You can control output ```.tif``` stack length by setting ```..., 'Layer0', Index``` such as,

```matlab
ND2TIF(FileName, 'Layer0', 2:2:100)
```

Each output ```.tif``` stacks will only contain the ```2:2:100``` of the ```layer0``` loop.

You can choose the specific stack or channel by setting ```..., 'Layer1', Index``` and ```..., 'Channel', Index```

```matlab
ND2TIF(FileName, 'Layer1', [2, 3, 4], 'ChannelIndex', 2)
```

This will only generate 3 ```.tif``` stacks, i.e., the ```2nd``` channel of No. ```2, 3, 4``` in layer 1 loops.

You can also generate a montage image by setting ```'Montage', 'on'```. You can make montage in layer 1 loop and also channels. You can arrange the output montage image with a matrix index.

```matlab
ND2TIF(FileName, 'Montage', 'on', 'Layer1', [2, 3; 4, 5])
```
This will generated a montage stack in the arrangement below. 

![Montage Stack](/Resource/montage-stack.jpg "Montage stack")

The images in different channels will be seprated into different montage stacks. If you want to montage images in differen channel, you can try,

```matlab
ND2TIF(FileName, 'Montage', 'on', 'Layer1', [2, 3; 4, 5], 'ChannelMontage', 'on')
```
You can also set the arrangment of each channel by set ```'Channel'``` with a matrix.


### 3.3 Image compress and resize

You can set ```'Compress', 'on'``` to compress the images into ```8 bits``` ```.tif``` stacks. The images will be compress to ```0-255``` with the ```min``` and ```max``` value of the first image in the stack.

```matlab
ND2TIF(FileName, 'Compress', 'on')
```
You can set ```'Resize', 1080``` to resize the height of output ```.tif``` stack to ```1080p```. 

```matlab
ND2TIF(FileName, 'Resize', 1080)
```

For montage stacks, the value contols the final output iamge size of the stack. You can set the value to other number as you with, such as, ```'Resize', 1024``` or ```'Resize', 720``` 

### 3.4 Controling parameters

|      Parameters      	| Value                                                                                                                                    	|
|:--------------------:	|------------------------------------------------------------------------------------------------------------------------------------------	|
|     ```Layer0```     	| The index of the layer0 loop, length of the ```.tif``` stack. For example, ```1:100```                                                   	|
|     ```Layer1```     	| The index of the layer1 loop. If ```Montage``` is ```'on'```, the images will be combined same as the matrix. For example, ```[1,2;3,4]``` 	|
|     ```Channel```    	| The index of the channels. If ```ChannelMontage``` is ```'on'```, the images will be combined same as the matrix. For example, ```[1,2]``` 	|
|     ```Montage```    	| Control if combined the images in layer1 loop into one stack. For example, ```'on'```, ```'off'```.                                          	|
| ```ChannelMontage``` 	| Control if combined the images in different channels into one stack. For example, ```'on'```, ```'off'```.                                   	|
|    ```Compress```    	| Control if compress the images into ```8 bits```. For example, ```'on'```, ```'off'```.                                                      	|
|     ```Resize```     	| Control if resize the images. For example, ```1080```, ```'off'```.                                                                        	|

For now, set ```'ChannelMontage', 'on'``` will automatically set ```'Montage', 'on'``` and ```'Compress', 'on'```； set ```'Resize', 1080``` （or other number） will automatically set ```'Compress', 'on'```; set ```'Resize', 'on'``` will automatically set ```'Resize', 1080```.


### 3.5 Sequence infomation.

You can get the time and position information of each frame in the sequence by

```matlab
[SeqTime,SeqPosition] = SeqInfo(FileName,Num)
```

If your ```.nd2``` file contains multiple channels. The infomation will be stored into cells as ```Seqtime{i}, SeqPosition{i}```.

