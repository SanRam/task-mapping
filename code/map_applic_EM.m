% map_applic_EM

function [map_by_place,map_by_task_ID] = map_applic_EM (commun_vol_one,width,height)

% EM mapping heuristic                                                                                                                                                                                      - takes one application as input, 
%   maps it using EM, returns map_by_place and map_by_task_ID
            %
            % adjacency_one/commun_vol_one note:  in this EM case, all uses of adjacency_one
            %   use first column, which is task ID, and commun_vol_one holds
            %   the same data, so can substitute

        map_by_task_ID = [];
        map_by_place = [];

        no_of_tasks = size(commun_vol_one,1);
        frontier(height,width) = 0; % initialize Frontier to all 0s array of frontier cores
        y(:,2)=0;          % list of frontier cores
        c_row = ceil(height/2);  % row of center of mesh
        c_col = ceil(width/2);  % column of center of mesh
        map_by_place(c_row, c_col) = commun_vol_one(1,1);	% places at the center of the mesh but could choose a different starting point
        map_by_task_ID(commun_vol_one(1,1),:) = [c_row c_col];
        no_of_mapped_tasks = 1;
        frontier(c_row, c_col) = 2; % Frontier of the center of mesh equals 2
        y(1,:) = [c_row, c_col]; %add (c_row, c_col) to Y
        [frontier,y] = mark_frontier(width,height,c_row, c_col,frontier,y);
        for i = 2 : no_of_tasks
            distance = inf;
            for j = 1 : size(y,1)
                temp_dist = ((y(j,1)-c_row)^2+(y(j,2)-c_col)^2)^2 ; 
                if temp_dist<distance 
        			distance = temp_dist;
    				t_row = y(j,1);
    				t_col = y(j,2);
                end
            end
            map_by_place(t_row, t_col) = commun_vol_one(i,1);
            map_by_task_ID(commun_vol_one(i,1),:) = [t_row t_col];
            no_of_mapped_tasks = no_of_mapped_tasks + 1;
            frontier(t_row, t_col) = 2;
            [frontier,y] = mark_frontier(width,height,t_row, t_col,frontier,y);
            %calculate the new center
            c_row = ceil(((no_of_mapped_tasks-1) * c_row + t_row) / (no_of_mapped_tasks)); % update row of center of mapped cores
            c_col = ceil(((no_of_mapped_tasks-1) * c_col + t_col) / (no_of_mapped_tasks)); % update column of center of mapped cores
        end
end


