function [Compressed_Image] = ImageCompress(Original_Image, Min_Intensity, Max_Intensity, Resize)

    Compressed_Image = uint8(mat2gray(Original_Image, [Min_Intensity, Max_Intensity]) .* 255);

    if strcmp(Resize, 'off')

    else
        ImageHeight = size(Compressed_Image, 1);
        Ratio = Resize / ImageHeight;
        Compressed_Image = imresize(Compressed_Image, Ratio, 'nearest');
    end

end
