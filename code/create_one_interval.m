function [intervals] = create_one_interval (current_int1,current_int2,intervals,current_T_B)

% Interval list (Y, left x, right x)
% T_B 	(Y, Left_x, Right_x, T_B flag)
		
		
if size(current_int1,1) ~= 0 && size(current_int2,1) ~= 0
    intervals(size(intervals,1) + 1,:) = [ current_T_B(1) - 1, current_int1(2), current_int2(3) ];
elseif size(current_int1,1) == 0 && size(current_int2,1) ~= 0
    intervals(size(intervals,1) + 1,:) = [ current_T_B(1) - 1, current_T_B(2), current_int2(3) ];
elseif size(current_int1,1) ~= 0 && size(current_int2,1) == 0
    intervals(size(intervals,1) + 1,:) = [ current_T_B(1) - 1, current_int1(2), current_T_B(3) ];
elseif size(current_int1,1) == 0 && size(current_int2,1) == 0
    intervals(size(intervals,1) + 1,:) = [ current_T_B(1) - 1, current_T_B(2), current_T_B(3) ];
end
