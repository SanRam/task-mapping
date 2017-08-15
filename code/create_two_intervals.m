function [intervals] = create_two_intervals (current_int,intervals,current_T_B)

% Interval list (Y, left x, right x)
% T_B 	(Y, left_x, right_x, T_B flag)
		
if current_int(2) ~= current_T_B(2)
    intervals(size(intervals,1) + 1,:) = [ current_T_B(1), current_int(2), current_T_B(2)- 1 ];
end
if current_int(3) ~= current_T_B(3)
    intervals(size(intervals,1) + 1,:) = [ current_T_B(1), current_T_B(3) + 1, current_int(3) ] ;
end
		
