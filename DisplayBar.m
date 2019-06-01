function [Percentage, Barlength] = DisplayBar(Index, Length)

    Percentage = Index / Length * 100;
    Barlength = floor(Percentage);

    if Index == 1

        for i = 1:100
            fprintf('-')
        end

        fprintf('%6.2f%%', Percentage)
    else

        fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');
        
        if Barlength == 100
            for i = 1:100
                fprintf('#')
            end
            
        elseif Barlength>=1
            for i = 1:(Barlength - 1)
                fprintf('#')
            end
            fprintf('>')
        end
        
        for i = 1:(100 - Barlength)
            fprintf('-')
        end
        
        fprintf('%6.2f%%', Percentage)
        
        if Barlength == 100
            fprintf('\n')
        end
    
    end
        
    end
