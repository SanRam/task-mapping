function [current_int,current_int_index] = int_search_top(current_T_B, intervals)

% Interval list (Y, left x, right x)
% T_B 	(Y, Left_x, Right_x, T_B flag)
% MHS	(width, height, left x, bottom_Y)	
		
for i = 1 : size(intervals,1) 
    current_int = intervals(i,:);
    current_int_index = i;
    if (current_int(2) <= current_T_B(2)) && (current_int(3) >= current_T_B(3))
        return;
    end
end
