function [ImageWithBar, BarLength] = AddScaleBar(Image,Scale,varargin)

load('ScalebarText.mat')

ImageSize=size(Image);
ImageHeight=ImageSize(1);
ImageWidth=ImageSize(2);
BarLengthTest=[1,2.5,5,10,25,50,100,200,500,1000,2000,5000,10000];

    if nargin==2
        BarLength=min(BarLengthTest(BarLengthTest>ImageWidth.*Scale/4));
    else
        BarLength=min(BarLengthTest(abs(BarLengthTest-varargin{1})==min(abs(BarLengthTest-varargin{1}))));
    end

    BarNumber=find(BarLength==BarLengthTest);

    if BarNumber<=9
        BarLengthText=ScalebarText{BarNumber};
        BarUnitText=ScalebarText{10};
    else
        BarLengthText=ScalebarText{BarNumber-9};
        BarUnitText=ScalebarText{11};
    end
        
    BarTextImage=zeros(180,size(BarLengthText,2)+size(BarUnitText,2)+60);

    BarTextImage(1:size(BarLengthText,1),1:size(BarLengthText,2))=BarLengthText;
    BarTextImage(30:size(BarUnitText,1)+29,(end-size(BarUnitText,2)+1):end)=BarUnitText;
    
    BarTextImageHeight=floor(ImageHeight/25);

    BarTextImage = imresize(BarTextImage,BarTextImageHeight./size(BarTextImage,1));

    BarLengthPixel=floor(BarLength/Scale);
    BarHeightPixel=floor(ImageHeight/125);
    
    BarPositionX=floor(ImageWidth.*0.95)-BarLengthPixel;
    BarPositionY=floor(ImageHeight.*0.946);
    
    BarTextPositionX=floor(BarPositionX+BarLengthPixel/2-size(BarTextImage,2)/2);
    BarTextPositionY=BarPositionY-BarTextImageHeight-5;
    
    
    if size(Image,3)==1
        ImageWithBar=mat2gray(Image);
        ImageWithBar(BarTextPositionY+1:BarTextPositionY+size(BarTextImage,1),BarTextPositionX+1:BarTextPositionX+size(BarTextImage,2))=ImageWithBar(BarTextPositionY+1:BarTextPositionY+size(BarTextImage,1),BarTextPositionX+1:BarTextPositionX+size(BarTextImage,2))+BarTextImage;
        ImageWithBar(BarPositionY+1:BarPositionY+BarHeightPixel,BarPositionX:BarPositionX+1+BarLengthPixel)=1;
    elseif size(Image,3)==3
        ImageWithBar=Image;
        ImageWithBar(BarTextPositionY+1:BarTextPositionY+size(BarTextImage,1),BarTextPositionX+1:BarTextPositionX+size(BarTextImage,2),:)=ImageWithBar(BarTextPositionY+1:BarTextPositionY+size(BarTextImage,1),BarTextPositionX+1:BarTextPositionX+size(BarTextImage,2),:)+uint8(BarTextImage.*255);
        ImageWithBar(BarPositionY+1:BarPositionY+BarHeightPixel,BarPositionX:BarPositionX+1+BarLengthPixel,:)=255;
    end
    
end

