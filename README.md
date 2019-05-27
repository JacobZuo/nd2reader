# Loading '.nd2' file into Matlab

![MIT - License](https://img.shields.io/bower/l/bootstrap.svg)

## 1. Overview

This is a small tool to load '.nd2' image stack into Matlab with 'ND2SDK' (Windows). The SDK is provided [here](https://www.nd2sdk.com/) by [Laboratory Imaging](https://www.laboratory-imaging.com/). 

For now, only uint16 mono-color ```.nd2``` file is supported. The reader can get the infomation of channel infomation and loops infomation of the file.

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

If you want to read out multiple images at once, you can specify the image index as ```Num = [1,2,3...]```. The result ```Image``` will be in a 3D array in Matlab. Additionally, multiple channels images will be stored in different cells and each cell contains the 3D array of the image stack.

Here, ```Single``` means store all the data into a single variable.


### 2.4 TIF stack output

The ```ND2TIF``` function can save the ```.nd2``` stack into ```.tif``` stacks based on loops and channels. 

```matlab
ND2TIF(FileName)
```
Running the above command will seprated your image into ```.tif``` stacks of the highest level loops (layer 0, see 2.2 above).

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
