function [current_int1,current_int2,current_int1_index,current_int2_index] = int_search_bottom(current_T_B, intervals)

% Interval list (Y, left x, right x)
% T_B 	(Y, Left_x, Right_x, T_B flag)
% MHS	(width, height, left x, bottom_Y)	
		
current_int1 = [];
current_int2 = [];
current_int1_index = 0;
current_int2_index = 0;

for i = 1 : size(intervals,1)
    current_int = intervals(i,:);
    if current_int(3) + 1 == current_T_B(2)
        current_int1 = current_int;
        current_int1_index = i;
    end
    if current_int(2) == current_T_B(3) + 1
        current_int2 = current_int;
        current_int2_index = i;        
    end
end
