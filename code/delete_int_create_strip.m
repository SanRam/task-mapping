function [intervals,strips,num_of_strips] = delete_int_create_strip (intervals,current_int,current_int_index,current_T_B,strips,num_of_strips)

% Interval list (Y, left x, right x)
% T_B 	(Y, Left_x, Right_x, T_B flag)
% strips	(width, height, left x, Bottom_y)	

% not that the intervals are represented by their top left corner
% but because the scheduler and the palcer deals with tasks and the
% palcement as bottom left corner we will represent the strips by their bottom
% left corner.



if current_T_B(4) == 1 
    if current_int (1) ~= current_T_B (1) 
        height = current_int(1) - current_T_B(1);
		width = current_int(3) - current_int(2) + 1; 
        bottom_Y = current_int(1) - height + 1; 
        num_of_strips = num_of_strips + 1;
		strips(num_of_strips,:) = [ width, height, current_int(2), bottom_Y ];
    end
    intervals(current_int_index,:) = [];
else
    if current_int_index ~= 0
        if current_int(1) + 1 ~= current_T_B(1)   % this case when you have an interval under the bottom of the task in which it will generate a height 0
            height = current_int(1) - current_T_B(1) +1;
            width = current_int(3) - current_int(2) + 1;
            bottom_Y = current_int(1) - height + 1; 
            num_of_strips = num_of_strips + 1;
            strips(num_of_strips,:) = [ width, height, current_int(2), bottom_Y ];
        end
        intervals(current_int_index,:) = [];
    end
end
