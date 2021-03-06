function [communication_cost] = communication_cost_calculator (commun_vol_one,map_by_task_ID)

%
% The only change needed from directed to undirected graphs is changing
%  the parameters for k and m.  Rather than considering all pairs,
%  consider just the upper right triangle of the adjacency_one matrix.
%                                    
  %  adjacency_one/commun_vol_one note:  instead of checking if adjacency_one (k,m+1) == 1,
  %     can check if commun_vol_one(k,m+1) is not equal to 0, so can substitute

% sort "commun_vol_one" array by task ID rather than communication volume
%   This way, row k of "commun_vol_unsorted_one" will match row k of
%   "map_by_task_ID"
commun_vol_unsorted_one = sortrows(commun_vol_one, 1);
communication_cost = 0;
no_of_tasks = size(commun_vol_unsorted_one,1);

for k = 1 : no_of_tasks-1
    for m = k+1 : no_of_tasks
        if commun_vol_unsorted_one(k,m+1) > 0
            communication_cost = communication_cost + (commun_vol_unsorted_one(k,m+1) * (abs(map_by_task_ID(k,1) - map_by_task_ID(m,1)) + abs(map_by_task_ID(k,2) - map_by_task_ID(m,2))));
        end
    end
end

end

