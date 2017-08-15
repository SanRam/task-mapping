function [incoming_possible_shapes] = order_arrays (incoming_possible_shapes,incoming_num_of_possible_shapes)

% "order_arrays" takes as input one array of shapes and either sorts the
%   shapes by aspect ratio or randomly permutes the order of shapes, as
%   directed by "sorted_option"
% Also appends a third column that is later overwritten by "mapper" with
%   the communication cost of the shape in each row.

global sorted_option num_of_applications

%%%%%%%%%%%%%
% sorted_option == 1 sorts shapes by aspect ratio so that the ones with
%   aspect ratio closest to 1 are first
% sorted_option == 2 randomly permutes the array of possible shapes
% any other value for sorted_option leaves the array of possible shapes
%   unchanged
%
% Array "incoming_possible_shapes" holds for each application its possible
% rectangle shapes.
%%%%%%%%%%%%%

    if sorted_option == 1
        for i = 1 : num_of_applications
            % we will subtract the first column from the second column and
            % then sort the array based on the absoulute value of the
            % difference
            incoming_possible_shapes{i}(:,3) = abs(incoming_possible_shapes{i}(:,2) - incoming_possible_shapes{i}(:,1));
            incoming_possible_shapes{i} = sortrows(incoming_possible_shapes{i},3);
            % This third column is later overwritten by "mapper" with
            % the communication cost of the shape in each row.
%                incoming_possible_shapes{i} = incoming_possible_shapes{i}(:,[1 2]);
        end
    end
    if sorted_option == 2
        [incoming_possible_shapes,incoming_num_of_possible_shapes] = permute_rows(incoming_possible_shapes,incoming_num_of_possible_shapes,num_of_applications);    
    end
    for i = 1 : num_of_applications
        incoming_possible_shapes{i}(:,3) = 0;
            % This third column is later overwritten by "mapper" with
            % the communication cost of the shape in each row.
    end

end