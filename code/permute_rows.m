function [incoming_possible_shapes,incoming_num_of_possible_shapes] = permute_rows(incoming_possible_shapes,incoming_num_of_possible_shapes,num_of_applications);    



for i =1 : num_of_applications 
    shapes_count = size(incoming_possible_shapes{i},1);
    for j = 1 : shapes_count
        random_row_index = randi ([j,shapes_count]);
        temp = incoming_possible_shapes{i}(random_row_index,:);
        incoming_possible_shapes{i}(random_row_index,:) =incoming_possible_shapes{i}(j,:);
        incoming_possible_shapes{i}(j,:) = temp;
    end
end

end

