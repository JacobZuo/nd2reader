# Loading '.nd2' file into Matlab

![MIT - License](https://img.shields.io/bower/l/bootstrap.svg)

## 1. Overview

This is a small tool to load '.nd2' image stack into Matlab with 'ND2SDK' (Windows). The SDK is provided [here](https://www.nd2sdk.com/) by [Laboratory Imageing](https://www.laboratory-imaging.com/). 

## 2. Usage

### 2.1 Load the library

Matlab provides function ```loadlibrary``` to load C / C++ libraries into Matlab. You need to configure for C language compilation in your Matlab.

```matlab
mex -setup
```

If you do not have any compiler, you can add 'MinGW64 Compiler' in 'HOME' > 'Add-Ons' follow the image below.

![MinGW64](/Resource/MinGW64.jpg "MinGW64")

Once you set up the C compiler, you and add the 'SDK' into Matlab 'Path' and run

```matlab
loadlibrary('Nd2ReadSdk', 'Nd2ReadSdk.h')
```

### 2.2 Read the infomation in '.nd2' file

You can run the command below to get the information from the file. ```FileName``` should contain the full path and extension name, such as ```'D:\Data\Test.nd2'```

```matlab
[ImageInfo] = ND2Info(FileName)
```
The function will runture a structure ```ImageInfo``` contains the width, height, number of images and also channel numbers. Also the metadata is recorded in ```ImageInfo.metadata```.

### 2.3 Read image.

If you want to read a specific image in a '.nd2' file. You can use the command below to read the image with the specific index ```Num```.

```matlab
[Image] = ND2ReadSingle(FileName, Num)
```

If your '.nd' file has multiple channels, i.e. ```Components```, these channels would be stored in different cells in ```Image``` as ```Image{1}```, ```Image{2}```,.... 

If you want to read out multiple images at once, you can specify the image index as ```Num=[1,2,3...]```. The result ```Image``` will be in a 3D array in Matlab. Additionally, multiple channels images will be stored in different cells and each cell contains the 3D array of the image stack.

Here, ```Single``` means store all the data in a single variable.

### 2.4 Advanced usage

If your '.nd2' file is very huge and not able to read all the data into the memory. You can also read the image with a ```for``` loop. Do not use ```ND2ReadSingle``` in a loop at each calling will open and close the file pointer once.

You should create a file pointer, read the images you need, and then close the pointer. Here is an example.

```matlab
[FilePointer, ImagePointer, ImageReadOut] = ND2Open(FileName);
Num = 2:2:100;
for i =1:size(Num, 2)
    Image = ND2Read(FilePointer, ImagePointer, ImageReadOut, Num(i));
end
ND2Close(FilePointer)
```
