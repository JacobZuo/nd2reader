function [Percentage, Barlength] = DisplayBar(Index, Length)

    Percentage = Index / Length * 100;
    Barlength = floor(Index / Length * 60);

    if Index == 1
        BarStart='Processing [';
    elseif Index == Length
        BarStart = repmat('\b',1,80);
    else
        BarStart = repmat('\b',1,68);
    end

    if Barlength == 60
        BarText=['Finished!  [', repmat('#',1,60)];
    elseif Barlength >= 1
        BarText=[repmat('#',1,(Barlength - 1)),'>'];
    else
        BarText='';
    end

    BarText=[BarStart, BarText,repmat('-',1,(60 - Barlength)),sprintf(']%6.1f', Percentage),'%%'];

    fprintf(BarText)

    if Barlength == 60
        fprintf('\n')
    end

end
