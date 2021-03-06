function [t_row,t_col, H, R] = assign_task_LCF(map_by_task_ID,map_by_place,commun_vol_one,task,height,width,H, R)

% function was called ASSIGNTASKLCF in code from Mostafa

% _R_ is an array of row numbers in                                                                                                                  sorted array _commun_vol_one_
%    corresponding to already mapped tasks
% _task_ is a row number in                                                                                                                  sorted array _commun_vol_one_ of the next task to map
%    and same row number of same next task in sorted array _commun_vol_one_


numCommun = 0;		% count of already placed tasks with which task communicates

     % in the for loop below, the "if adjacency_one(task,adjacency_one*) == 1"
     %   could be replaced by "if commun_vol_one(task,commun_vol_one*) > 0"
     %   because column 1 holds task ID, not adjacency_one bits
     %   Later uses such as "map_by_task_ID(adjacency_one(..." are using 
     %   "adjacency_one" just to find task ID, so can replace with "commun_vol_one"
     %
for i= 1 : size(R,1)
%	if adjacency_one(task,adjacency_one(R(i),1)+1) == 1
	if commun_vol_one(task,commun_vol_one(R(i),1)+1) > 0
        numCommun = numCommun + 1;
		communtask = R(i);      % identity of one placed task that communicates with t
    end
end
if numCommun == 0
    % map to core in H closest to center of mesh
    c_row = ceil(height/2);  % row of center of mesh
    c_col = ceil(width/2);  % column of center of mesh
 	distance = inf;
	for i = 1 : size(H,1)
        temp_dist = ((H(i,1)-c_row)^2+(H(i,2)-c_col)^2)^2 ; 
        if temp_dist < distance 
            distance = temp_dist;
    		t_row = H(i,1);
    		t_col = H(i,2);
        end
    end
elseif numCommun == 1
    % map to core in H closest to the one communicating task;
	% task communTask is that task
	distance = inf;
	for i = 1 : size(H,1)
        temp_dist = ((H(i,1) - map_by_task_ID(commun_vol_one(communtask,1),1))^2 + (H(i,2) - map_by_task_ID(commun_vol_one(communtask,1),2))^2)^2;
    	if temp_dist < distance
            distance = temp_dist;
			t_row = H(i,1);
			t_col = H(i,2);
        end
    end
elseif numCommun >= 2
    % evaluate all free cores, and assign to the location 
	% with lowest communication cost
	% here, lowest communication cost translates to
	% lowest sum of Manhattan distances to already placed
	% tasks
	sumDistance = inf;
    for i = 1 : size(H,1)
        temp_dist = 0;
		for j = 1 : size(R,1)
%            if adjacency_one(task,adjacency_one(R(j),1)+1) == 1
            if commun_vol_one(task,commun_vol_one(R(j),1)+1) > 0
                temp_dist = temp_dist + ((H(i,1) - map_by_task_ID(commun_vol_one(R(j),1),1))^2 + (H(i,2) - map_by_task_ID(commun_vol_one(R(j),1),2))^2)^2;
            end
        end
		if temp_dist < sumDistance
            sumDistance = temp_dist;
            t_row = H(i,1);
			t_col = H(i,2);
        end
    end
end

R(size(R,1) + 1,:) = task;

for i= 1 : size(H,1)
    if (H(i,1) == t_row) && (H(i,2) == t_col)
        H(i,:) = [];
        break;
    end
end


end


