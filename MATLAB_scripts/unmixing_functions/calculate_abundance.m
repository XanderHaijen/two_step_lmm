function Abund = calculate_abundance(n, r)
% calculate_abundance - Generates all possible combinations of n elements divided into r groups, normalized by n
%
% Syntax: Abund = calculate_abundance(n, r)
%
% Inputs:
%    n - The total number of elements
%    r - The number of groups to divide the elements into
%
% Outputs:
%    Abund - The abundance matrix, where each row represents a unique combination
%            of elements divided into r groups, normalized by n
%
% Example:
%    Abund = calculate_abundance(3, 2)
%    % This will return a matrix with all possible combinations of 3 elements
%    % divided into 2 groups, normalized by 3
%
% See also: nchoosek
    function combs = generate_combinations(n, r)
        if r == 1
            combs = n;
        else
            combs = zeros(nchoosek(n + r - 1, r - 1), r);
            index = 1;
            for i = 0:n
                rest_combs = generate_combinations(n - i, r - 1);
                [rows, ~] = size(rest_combs);
                combs(index:(index + rows - 1), 1) = i;
                combs(index:(index + rows - 1), 2:end) = rest_combs;
                index = index + rows;
            end
        end
    end

    Abund = generate_combinations(n, r)'/n;
end