function [] = ND2TIF(FileName, varargin)

Montage='off';
ChannelMontage='off';
% ReSize=1080;

if isempty(varargin)
else
    for i = 1:(size(varargin, 2) / 2)
        if ischar(varargin{i * 2})
            eval([varargin{i * 2 - 1}, ' = ''', varargin{i * 2}, '''; ']);
        elseif size(varargin{2},2)==1
            eval([varargin{i * 2 - 1}, '=', num2str(varargin{i * 2}), ';']);
        else
            AssignVar(varargin{i * 2 - 1},varargin{i * 2})
        end
    end
end

disp('----------------------------------------------------------------------------------------------------')
disp('Getting nd2 infomation...')
% Reload the parameters input by user

[ImageInfo] = ND2Info(FileName);
[FilePointer, ImagePointer, ImageReadOut] = ND2Open(FileName);

[Path, Name, ~] = fileparts(FileName);

disp('----------------------------------------------------------------------------------------------------')
disp('Setting up .tif file name and image size...')

ChannelNum=ImageInfo.metadata.contents.channelCount;
LayerNum=size(ImageInfo.Experiment,1);

if exist('ChannelIndex','var')
else
    ChannelIndex=1:ChannelNum;
end

if exist('Layer0','var')
    Layer0Index=Layer0;
else
    Layer0Index=1:ImageInfo.Experiment(1).count;
end

if exist('Layer1','var')
    Layer1Index=Layer1;
    LayerIndex{1}=Layer1Index;
elseif LayerNum>=2
    Layer1Index=1:ImageInfo.Experiment(2).count;
    LayerIndex{1}=Layer1Index;
end

if exist('Layer2','var')
    Layer2Index=Layer2;
    LayerIndex{2}=Layer2Index;
elseif LayerNum>=3
    disp('Warning, too many layers, compress high level layers into one stack.')
    ExperimentCount3=1;
    for ii=3:LayerNum
        ExperimentCount3=ExperimentCount3*ImageInfo.Experiment(ii).count;
    end
    Layer2Index=1:ExperimentCount3;
    LayerIndex{2}=Layer2Index;
end



if strcmp(Montage, 'off')
    
    TifFileName=cell(0);
    
    if LayerNum==1
        ImageIndex=reshape(1:ImageInfo.numImages,[1,ImageInfo.Experiment(1).count]);
        for i=1:ChannelNum
            TifFileName{i}=[Path, '\', Name, ImageInfo.metadata.channels(i).channel.name, '.tif'];
        end
        
        for i=1:size(Layer0Index(:),1)
            [~, ~, ImageReadOut] = calllib('Nd2ReadSdk', 'Lim_FileGetImageData', FilePointer, uint32(ImageIndex(Layer0Index(i)) - 1), ImagePointer);
            Image = reshape(ImageReadOut.pImageData, [ImageReadOut.uiComponents, ImageReadOut.uiWidth * ImageReadOut.uiHeight]);
            for j = 1:size(ChannelIndex(:),1)
                Original_Image = reshape(Image(ChannelIndex(j), :), [ImageReadOut.uiWidth, ImageReadOut.uiHeight])';
                imwrite(Original_Image,TifFileName{ChannelIndex(j)}, 'WriteMode', 'append', 'Compression', 'none')
            end
        end
        
    elseif LayerNum==2
        ImageIndex=reshape(1:ImageInfo.numImages,[ImageInfo.Experiment(2).count,ImageInfo.Experiment(1).count]);
        for i=1:ChannelNum
            for j=1:ImageInfo.Experiment(2).count
                TifFileName{i}{j}=[Path, '\', Name, '_' ,ImageInfo.metadata.channels(i).channel.name, '_' ImageInfo.Experiment(2).type, '_', num2str(j), '.tif'];
            end
        end
        
        for i=1:size(Layer0Index(:),1)
            for j=1:size(Layer1Index(:),1)
                
                [~, ~, ImageReadOut] = calllib('Nd2ReadSdk', 'Lim_FileGetImageData', FilePointer, uint32(ImageIndex(Layer1Index(j),Layer0Index(i)) - 1), ImagePointer);
                Image = reshape(ImageReadOut.pImageData, [ImageReadOut.uiComponents, ImageReadOut.uiWidth * ImageReadOut.uiHeight]);
                
                for k = 1:size(ChannelIndex(:),1)
                    Original_Image = reshape(Image(ChannelIndex(k), :), [ImageReadOut.uiWidth, ImageReadOut.uiHeight])';
                    imwrite(Original_Image,TifFileName{ChannelIndex(k)}{Layer1Index(j)}, 'WriteMode', 'append', 'Compression', 'none')
                end
            end
        end
        
    elseif LayerNum>=3
        ImageIndex=reshape(1:ImageInfo.numImages,[ImageInfo.Experiment(3).count,ImageInfo.Experiment(2).count,ImageInfo.Experiment(1).count]);
        for i=1:ChannelNum
            for j=1:ImageInfo.Experiment(2).count
                for k=1:ExperimentCount3
                    TifFileName{i}{j}{k}=[Path, '\', Name, '_' ,ImageInfo.metadata.channels(i).channel.name, '_' ImageInfo.Experiment(2).type, '_', num2str(j), '_' ImageInfo.Experiment(3).type, '_', num2str(k) '.tif'];
                end
            end
        end
        
        for i=1:size(Layer0Index(:),1)
            for j=1:size(Layer1Index(:),1)
                for kkk=1:size(Layer2Index(:),1)
                    [~, ~, ImageReadOut] = calllib('Nd2ReadSdk', 'Lim_FileGetImageData', FilePointer, uint32(ImageIndex(Layer2Index(kkk),Layer1Index(j),Layer0Index(i)) - 1), ImagePointer);
                    Image = reshape(ImageReadOut.pImageData, [ImageReadOut.uiComponents, ImageReadOut.uiWidth * ImageReadOut.uiHeight]);
                    
                    for k = 1:size(ChannelIndex(:),1)
                        Original_Image = reshape(Image(ChannelIndex(k), :), [ImageReadOut.uiWidth, ImageReadOut.uiHeight])';
                        imwrite(Original_Image,TifFileName{ChannelIndex(k)}{Layer1Index(j)}{Layer2Index(kkk)}, 'WriteMode', 'append', 'Compression', 'none')
                    end
                    
                end
            end
        end
        
    end
    
elseif strcmp(Montage,'on')
    % do Motage
    ImageHeightNum=1; ImageWidthNum=1;
    
    if LayerNum>=2
        for i=1:LayerNum-1
            ImageHeightNum=ImageHeightNum*size(LayerIndex{i},1);
            ImageWidthNum=ImageWidthNum*size(LayerIndex{i},2);
        end
    else
    end
    if strcmp(ChannelMontage, 'on')
        ChannelHeightNum=size(ChannelIndex,1);
        ChannelWidthNum=size(ChannelIndex,2);
    else
    end
    
    if strcmp(ChannelMontage, 'on')
            MontageTifFileName=[Path, '\', Name, '_Montage', '.tif'];
    elseif strcmp(ChannelMontage, 'off')
        for i=1:ChannelNum
            MontageTifFileName{i}=[Path, '\', Name, '_Montage_' ,ImageInfo.metadata.channels(i).channel.name, '.tif'];
        end
    end
    
    
    if LayerNum==1
        if strcmp(ChannelMontage, 'off')
        disp('Only one loop, try ChannelMotage On please!')
        return
        elseif strcmp(ChannelMontage, 'on')
            for i=1:size(Layer0Index(:),1)
                
                [~, ~, ImageReadOut] = calllib('Nd2ReadSdk', 'Lim_FileGetImageData', FilePointer, uint32(ImageIndex(Layer1Index(j),Layer0Index(i)) - 1), ImagePointer);
                Image = reshape(ImageReadOut.pImageData, [ImageReadOut.uiComponents, ImageReadOut.uiWidth * ImageReadOut.uiHeight]);
                
                for k = 1:size(ChannelIndex(:),1)
                    Original_Image{k} = reshape(Image(ChannelIndex(k), :), [ImageReadOut.uiWidth, ImageReadOut.uiHeight])';
                end
                MotageImage=ImageMontage(Original_Image,ImageHeightNum,ImageWidthNum);
                imwrite(MotageImage,MontageTifFileName, 'WriteMode', 'append', 'Compression', 'none')
                
            end
        end
            
    elseif LayerNum==2
        ImageIndex=reshape(1:ImageInfo.numImages,[ImageInfo.Experiment(2).count,ImageInfo.Experiment(1).count]);

        for i=1:size(Layer0Index(:),1)
            Original_Image=cell(0);
            for j=1:size(Layer1Index(:),1)                
                [~, ~, ImageReadOut] = calllib('Nd2ReadSdk', 'Lim_FileGetImageData', FilePointer, uint32(ImageIndex(Layer1Index(j),Layer0Index(i)) - 1), ImagePointer);
                Image = reshape(ImageReadOut.pImageData, [ImageReadOut.uiComponents, ImageReadOut.uiWidth * ImageReadOut.uiHeight]);
                for k = 1:size(ChannelIndex(:),1)
                    Original_Image{k}{j} = reshape(Image(ChannelIndex(k), :), [ImageReadOut.uiWidth, ImageReadOut.uiHeight])';
                end
            end
            
            MotageLayer1Image=cell(size(Original_Image));
                for i=1:size(Original_Image, 2)
                    MotageLayer1Image{i}=cell2mat(reshape(Original_Image{i},[ImageHeightNum,ImageWidthNum]));
                end
            
            if strcmp(ChannelMontage, 'on')
               MotageImage=cell2mat(reshape(MotageLayer1Image,[ChannelHeightNum,ChannelWidthNum]));
               imwrite(MotageImage,MontageTifFileName, 'WriteMode', 'append', 'Compression', 'none')

            elseif strcmp(ChannelMontage, 'off')                
                for k = 1:size(ChannelIndex(:),1)
                    imwrite(MotageLayer1Image{k},MontageTifFileName{ChannelIndex(k)}, 'WriteMode', 'append', 'Compression', 'none')
                end
            end
            
        end
        
    elseif LayerNum>=3
        
        disp('Warning, too many layers, do not support montage mode.')        
        return
    end

end

end
