function [Percentage, Barlength] = DisplayBar(Index, Length)

    Percentage = Index / Length * 100;
    Barlength = floor(Percentage);

    if Index == 1

        for i = 1:100
            fprintf('-')
        end

        fprintf('%6.2f%%', 0)
    else
    end

    fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b');

    for i = 1:Barlength
        fprintf('>')
    end

    for i = 1:(100 - Barlength)
        fprintf('-')
    end

    fprintf('%6.2f%%', Percentage)

    if Barlength == 100
        fprintf('\n')
    else

    end
