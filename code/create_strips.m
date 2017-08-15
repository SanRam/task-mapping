function [strips,num_of_strips] = create_strips(executing,num_of_executing,width,height)

%we have to deal with the top and the bottoms seprate
% this function will generate horizontal strips.
% in case we want to create the MHS we will provide the subroutine with the
% chip width and chip height and executing list
% in case we want to create the vertical strips we need to reverse the chip
% and provide the height to  be the width of this algorithm and the chip
% width to be the height required here. also in the eecuting listwe will
% provide the left and right X valuse as the top and bottoms.

if num_of_executing == 0
    num_of_strips = 1;
    strips =[width height 1 1];
else
    %  T_B =  ( Y_value, Left_x, Right_x, T_B flag)
    T_B = [];
    [T_B] = sort_T_B (executing,num_of_executing,T_B);
    %MHS = width,height,left_x,bottom_Y
    num_of_strips = 0;
    strips = [];
    intervals(1,:) = [height 1 width];% top_Y, left_x , right_x

    for i = 1 : 1 : 2*num_of_executing
        current_T_B = T_B(i,:);
        if current_T_B(4) == 1
            [current_int,current_int_index] = int_search_top(current_T_B, intervals);
            [intervals] = create_two_intervals (current_int,intervals,current_T_B); 
            [intervals,strips,num_of_strips] = delete_int_create_strip (intervals,current_int,current_int_index,current_T_B,strips,num_of_strips);
        else
            [current_int1,current_int2,current_int1_index,current_int2_index] = int_search_bottom(current_T_B, intervals);
            [intervals] = create_one_interval (current_int1,current_int2,intervals,current_T_B); 
            [intervals,strips,num_of_strips] = delete_int_create_strip (intervals,current_int1,current_int1_index,current_T_B,strips,num_of_strips);
            % if index 1 is smaller than index 2 so after deleting interval
            % number one the index for int 2 will point to a wrong place as
            % there is a record been deleted from the array. and for this
            % the index of current int 2 need to be reduced by one.
            if (current_int1_index ~=0) && (current_int1_index < current_int2_index)
                current_int2_index = current_int2_index - 1;
            end
            [intervals,strips,num_of_strips] = delete_int_create_strip (intervals,current_int2,current_int2_index,current_T_B,strips,num_of_strips);            
        end
    end
    % we need to check on the intervals list:
    % there are two cases at this point
    % 1- if the last task in T_B array has a bottom of 1 it means no more work
    % to be done.
    % 2- if the last task in T_B has a bottom value greater than one. this
    % means there is a MHS that needs to be created from the task bottom
    % till the chip bottom.
    if intervals(1,1) ~= 0
        strip_height = intervals(1,1);
		strip_width = width; 
        bottom_Y = 1; 
        num_of_strips = num_of_strips + 1;
		strips(num_of_strips,:) = [ strip_width, strip_height, 1, bottom_Y ];
    end

end
    


