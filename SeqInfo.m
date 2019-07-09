function [SeqTime,SeqPosition] = SeqInfo(FileName,Num)

if not(libisloaded('Nd2ReadSdk'))
    [~, ~] = loadlibrary('Nd2ReadSdk', 'Nd2ReadSdk.h');
end

FileID = libpointer('voidPtr', [int8(FileName) 0]);
[FilePointer] = calllib('Nd2ReadSdk', 'Lim_FileOpenForReadUtf8', FileID);

FrameMetadata = calllib('Nd2ReadSdk', 'Lim_FileGetFrameMetadata', FilePointer,0);
TestLength=3000;
setdatatype(FrameMetadata, 'uint8Ptr', TestLength)
FrameMetadataValue = FrameMetadata.Value';
while isempty(find(FrameMetadataValue == 0, 1))
    TestLength=TestLength*2;
    setdatatype(FrameMetadata, 'uint8Ptr', TestLength)
    FrameMetadataValue = FrameMetadata.Value';
end
FrameMetadataLength = find(FrameMetadataValue == 0, 1);
FrameMetadataJson = char(FrameMetadataValue(1:FrameMetadataLength - 1));
FrameMetadataStru=jsondecode(FrameMetadataJson);

setdatatype(FrameMetadata, 'voidPtr', TestLength)
calllib('Nd2ReadSdk', 'Lim_FileFreeString', FrameMetadata);

if FrameMetadataStru.contents.channelCount==1
    SeqTime=zeros(size(Num,2),1);
    SeqPosition=zeros(size(Num,2),3);
elseif FrameMetadataStru.contents.channelCount>1
    SeqTime=cell(0);
    SeqPosition=cell(0);
    for j=1:FrameMetadataStru.contents.channelCount
        SeqTime{j}=zeros(size(Num,2),1);
        SeqPosition{j}=zeros(size(Num,2),3);
    end
else
end

for i=1:size(Num,2)
    
    FrameMetadata = calllib('Nd2ReadSdk', 'Lim_FileGetFrameMetadata', FilePointer,Num(i)-1);
    setdatatype(FrameMetadata, 'uint8Ptr', TestLength)
    FrameMetadataValue = FrameMetadata.Value';
    FrameMetadataLength = find(FrameMetadataValue == 0, 1);
    FrameMetadataJson = char(FrameMetadataValue(1:FrameMetadataLength - 1));
    FrameMetadataStru=jsondecode(FrameMetadataJson);
    setdatatype(FrameMetadata, 'voidPtr', TestLength)
    calllib('Nd2ReadSdk', 'Lim_FileFreeString', FrameMetadata);
 
    if FrameMetadataStru.contents.channelCount==1
        SeqTime(i)=FrameMetadataStru.channels.time.relativeTimeMs;
        SeqPosition(i,:)=FrameMetadataStru.channels.position.stagePositionUm';
    elseif FrameMetadataStru.contents.channelCount>1
        for j=1:FrameMetadataStru.contents.channelCount
            SeqTime{j}(i)=FrameMetadataStru.channels(j).time.relativeTimeMs;
            SeqPosition{j}(i,:)=FrameMetadataStru.channels(j).position.stagePositionUm';
        end
    else
    end
    
    [~, Barlength] = DisplayBar(i, size(Num,2));
    
end

ND2Close(FilePointer)

end

