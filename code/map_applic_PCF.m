% function map_applic_PCF

function [map_by_place,map_by_task_ID] = map_applic_PCF (commun_vol_one,width,height)

% PCF mapping heuristic - takes one application as input, 
%   maps it using PCF, returns map_by_place and map_by_task_ID

% Includes modified pseudocode to run faster (implemented by Mostafa,
%    November 2013) plus changes by Jerry to let "communplaced" be indexed
%    by task ID, while "commun_vol_one" remains sorted by communication
%    volume and not by task ID.
% "communplaced" is an array that holds the communication volume for each
%    unplaced task to the already placed tasks.  If a task j is already
%    placed, then communplaced(j) = -1.  Indexed by task ID.
% 1-22-14 further changes for new2:  make R get full row, not just ID, so that can
%    access communication volume via R and avoid a doubly nested loop
% 1-23-14 further changes for new3:  when incrementally updating
%    communplaced at the end, step through U rather than commun_vol_one
% 1-23-14 further change for new4:  in main loop, before searching for
%    large, initialize large to U(1,1) so that, in case no task in U
%    communicates with any task in R, then we have a valid selection.

global max_task_per_application;


%&&&&&&&
%& initialization
%&&&&&&&    
    map_by_task_ID = [];
    map_by_place = [];

    no_of_unmapped_tasks = size(commun_vol_one,1);
    no_of_mapped_tasks = 0;
    frontier = zeros(height, width);  % initialize frontier to all 0s
    y(:,2) = 0;  % list of frontier cores
    U = commun_vol_one;   % set of unmapped tasks
       % commun_vol_one is already sorted by total communication volume
       % columns of commun_vol_one, hence, U:
       %  1 - task ID
       %  2 through n+1 - weighted adjacency matrix
       %  n+2 - count of communicating tasks
       %  n+3 - volume of communication to/from task
%%%% JT change start
%    R(1,1) = 0;  % set of mapped task IDs
    total_no_of_tasks = no_of_unmapped_tasks;
    R_width = total_no_of_tasks +3;
    R = zeros(total_no_of_tasks, R_width);
    communplaced = zeros(max_task_per_application);
%%%% JT change end
    
%&&&&&&&
%& map first task
%&&&&&&&    
    c_row = ceil(height/2);  % row of center of mesh
    c_col = ceil(width/2);  % column of center of mesh
    large = U(1,1);  % ID of task in U with largest communication;
                     %   recall that U is sorted by communication volume
%%%% JT change start
%    R(1,1) = large;
    R(1,:) = U(1,:);
%%%% JT change end
    U(1,:) = [];
    map_by_place(c_row, c_col) = large;	% places at the center of the mesh 
                        % but could choose a different starting point
    map_by_task_ID(large,:) = [c_row c_col];
    frontier(c_row, c_col) = 2;
    y(1,:) = [c_row, c_col]; %add (c_row, c_col) to Y so that 
                            %   "mark_frontier" can remove it
    [frontier,y] = mark_frontier(width,height,c_row,c_col,frontier,y);

 %%%% added for the new modification   
%%%% JT change start
    for i = 1 : total_no_of_tasks
            % load "communplaced" with volume of communication between each
            %   task and the first placed task, with ID "large"
        temp_ID = commun_vol_one(i,1);
        communplaced(temp_ID) = commun_vol_one(i,large+1);
    end
%%%% JT change end
    communplaced(large) = -1;  % mark task "large" as placed
%%%%%%  
    
    no_of_unmapped_tasks = no_of_unmapped_tasks - 1;
    no_of_mapped_tasks = no_of_mapped_tasks + 1;
    
    
     
    
%&&&&&&&
%& map tasks after first
%&&&&&&&       
    while no_of_unmapped_tasks > 0
%%%%% deleted for the modification of PCF
%        [large] = mostcomm_vol(U(:,1),R,commun_vol_one);  % task to map next
%        
%        if large == 0
%            large = U(1,1); % if no unmapped task (in U) communicates with 
%                            %   task in R, then take first task remaining
%                            %   in U (largest total communication volume)
%        end
%        
%        [mostcomm_ID] = mostcomm_vol(R,large,commun_vol_one);
%                    % mostcomm_ID is task in R the largest communication with
%                    %   "large"
%                    % "mostcomm_vol" returns 0 if no communicating tasks
%                    %   between the two input sets
%       
%        distance = inf;
%%%%%%%%%%%%
%%%%% added for the modification of PCF
%%%%  test changes for new4 - start
%        mostcomm_vol = -1;
        mostcomm_vol = 0;  % test:  like the original, compare to 0
        large = U(1,1);  % test:  like the original, initializ large in 
                            % case in case the following loop does not find
                            % any commun from U to R
%%%% test changes for new4 - end
        for j = 1 : total_no_of_tasks
            if communplaced(j) > mostcomm_vol
                mostcomm_vol = communplaced (j);
                large =j;
            end
        end
        mostcomm_ID = 0;
        mostcomm_vol =0;
%%%% JT change start
%         for i = 1 : total_no_of_tasks
%             for j = 1 : size(R,1)
%                 if (commun_vol_one(i,1) == R(j,1))
%                     if commun_vol_one(i,large+1) > mostcomm_vol
%                         mostcomm_vol = commun_vol_one(i,large+1);
%                         mostcomm_ID = commun_vol_one(i, 1);
%                     end
%                 end
%             end
%         end
        for j = 1 : size(R,1)
            if R(j,large+1) > mostcomm_vol
                mostcomm_vol = R(j,large+1);
                mostcomm_ID = R(j, 1);
            end
        end
%%%% JT change end
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
        

        
        if mostcomm_ID == 0  % that is, no task in R communicates with "large"
            distance = inf;
            for j = 1 : size(y,1)
                temp_dist = (abs(y(j,1)-c_row)+abs(y(j,2)-c_col)); 
                if temp_dist < distance 
        			distance = temp_dist;
    				t_row = y(j,1);
    				t_col = y(j,2);
                end
            end
        else
%            [mC_row mC_col] = map_by_task_ID(mostcomm_ID,:);
            distance =inf;
            mC_row = map_by_task_ID(mostcomm_ID,1);
            mC_col = map_by_task_ID(mostcomm_ID,2);
            for j = 1 : size(y,1)
                temp_dist = (abs(y(j,1)-mC_row)+abs(y(j,2)-mC_col)); 
                if temp_dist < distance 
        			distance = temp_dist;
    				t_row = y(j,1);
    				t_col = y(j,2);
                end
            end
        end
%%%% JT change start
%        R(no_of_mapped_tasks + 1,1) = large;
%%%% JT change end
        large_index = 0;
        for j = 1 : size(U,1)
            if U(j,1) == large
                large_index = j;
            end
        end
%%%% JT change start
        R(no_of_mapped_tasks + 1,:) = U(large_index,:);
%%%% JT change end
        U(large_index,:) = [];
        map_by_place(t_row, t_col) = large;
        map_by_task_ID(large,:) = [t_row t_col];
        frontier(t_row, t_col) = 2;
        [frontier,y] = mark_frontier(width,height,t_row,t_col,frontier,y);
%%%%% added for the modification of PCF
        communplaced(large) = -1;
%%%% JT change start
        no_of_unmapped_tasks = no_of_unmapped_tasks - 1;
        no_of_mapped_tasks = no_of_mapped_tasks + 1;
        
% %         for i = 1 : size(U,1)
% %             temp_ID = U(i,1);  % task ID of i-th element of U
% %             communplaced (temp_ID) = communplaced(temp_ID) + commun_vol_one(temp_ID,large+1);
% %         end
        for i = 1 : no_of_unmapped_tasks
            temp_ID = U(i,1);  % temp_ID is the ID of the task
                                            %   in row i of commun_vol_one
            if communplaced (temp_ID) > -1
                communplaced (temp_ID) = communplaced(temp_ID) + U(i,large+1);
            end
        end
%%%% JT change end
        
    end  % endwhile
    
end

