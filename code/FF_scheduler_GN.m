function [makespan,utilization,finished] = FF_scheduler_GN(incoming,adjacency,commun_vol,incoming_possible_shapes,incoming_num_of_possible_shapes)
  
% Function FF_scheduler_GN schedules one sequence of applications using
%   first-fit scheduling of applications without deadlines, taking
%   applications in first-core, first-served order from "incoming"
%
% adapted from March 2013 version of FF_scheduler.m, July 2013 version
% of mapper_AR.m, and July 2013 version of FF_scheduler_GD.m
%
% inputs:
% * "incoming" array of applications, with the following columns:
    % Application ID
    % number_of_tasks
    % Arrival time
    % Execution_Time
    % Deadline
% * "adjacency" - array of sub-arrays, with one sub-array for each application,
% where in each sub-array, the first column holds task ID and the remaining
% columns hold the adjacency matrix
% * "commun_vol" - array of sub-arrays, with one sub-array for each application,
% where in each sub-array, the first column holds task ID and the remaining
% columns hold the weighted adjacency matrix
% * "incoming_possible_shapes" - array holding the possible rectangle 
% shapes for each task
% incoming_possible_shapes{1,i} is an array of of three cols -- the first two
% are the width and height and the third col will be used later in the
% scheduler to store the communication cost for each possible shape.
% * "incoming_num_of_possible_shapes" - count of number of possible
% rectangle shapes for each task
%
% outputs:
% * "makespan" - simulated time from start of scheduling first application
%     until last application finishes
% * "utilization" - array indexed by time of fraction of cores being used
% * "finished" - array structure by column
%     1-application ID; 2-arrival time; 
%     3-start time for execution; 4-finish time; 5-cost


% The scheduler function operates in the YNM mode. the function
% will start by deleting the finished tasks. if any of the executing tasks
% finished the scheduler will try to place some of the tasks in the pending
% queue.
% also upon the arrival of any new task the scheduler will try to place it
% (this step will be performed after deleting the finished tasks
%
% this code will try all possible shapes for the application, possible shapes
% are supplied to the scheduler from the task generator code. The TRY_ALL
% variable determines whether it will check all possible shapes for lowest
% cost or stop at the first shape for which free space is available (that
% is, first fit)


%figure(1);

global chip_width chip_height num_of_applications
global TRY_ALL


%%%%%%%%%%%%%%%%%%%
% initialization
%%%%%%%%%%%%%%%%%%%
current_time = 0;
executing(:,9) = 0;
   % Array "executing" has the following columns:
   % 1-application_ID  2-region width  3-region height
   % 4-top_left_placement_x  5-top_left_placement_y  6-execution_time
   % 7-deadline  8-time_to_finish  9-communication_cost
num_of_executing = 0;
temp_placement = 0;
temp = 0;
required_width_temp = 0;
required_height_temp = 0;
%finished(:,5) = 0;
finished = zeros(num_of_applications,5);

%%%%%%%%%%%%%%%%%%%
% sort tasks in each application by total communication volume 
%  to/from each task
%%%%%%%%%%%%%%%%%%%

% % retain unsorted version of commun_vol for use in
% % "communication_cost_calculator"
% commun_vol_unsorted = commun_vol;
%   Instead, now the unsorting is done explicitly in
%   "communication_cost_calculator"

for i = 1 : num_of_applications
    no_of_tasks = size(adjacency{1,i},1);

% adjacency{1,i}(:,1) and commun_vol{1,i}(:,1) include task ID
% adjacency{1,i}(:,no_of_tasks+2) and commun_vol{1,i}(:,no_of_tasks+2) 
%  include the count of communicating tasks for each task.
% adjacency{1,i}(:,no_of_tasks+3) and commun_vol{1,i}(:,no_of_tasks+3)
%  include the total communication volume 
%  to/from each task
    adjacency{1,i}(:,no_of_tasks+2) = zeros;
    adjacency{1,i}(:,no_of_tasks+3) = zeros;
    commun_vol{1,i}(:,no_of_tasks+2) = zeros;
    commun_vol{1,i}(:,no_of_tasks+3) = zeros;
    adjacency{1,i}(:,no_of_tasks+2) = sum(adjacency{1,i},2)-adjacency{1,i}(:,1); 
    commun_vol{1,i}(:,no_of_tasks+2) = adjacency{1,i}(:,no_of_tasks+2);
    commun_vol{1,i}(:,no_of_tasks+3) = sum(commun_vol{1,i},2)-commun_vol{1,i}(:,1)-commun_vol{1,i}(:,no_of_tasks+2);
    adjacency{1,i}(:,no_of_tasks+3) = commun_vol{1,i}(:,no_of_tasks+3);

% sort both the adjacency{1,i} and commun_vol{1,i} arrays based on the 
%  total communication volume to/from each task
    adjacency{1,i}(no_of_tasks:-1:1,:) = sortrows (adjacency{1,i}, no_of_tasks+3);    
    commun_vol{1,i}(no_of_tasks:-1:1,:) = sortrows (commun_vol{1,i}, no_of_tasks+3);
end

next = 1; % pointer to row in "incoming" of next application to place

while ~((next > num_of_applications) && (num_of_executing == 0))
    % Each iteration of while loop corresponds to one time step of
    % simulated many-core
    current_time = current_time + 1;

%%%%%%%%%%%%%%%%%%%
% delete finished applications
%%%%%%%%%%%%%%%%%%%
    [dirty,num_of_executing,executing] = delete_finished_applications (num_of_executing,executing,current_time);
    % "dirty" is a flag indicating that at least one application was
    % deleted


%%%%%%%%%%%%%%%%%%%
% place applications in order listed in "incoming"
%%%%%%%%%%%%%%%%%%%
    placed = 1;
    while ((placed == 1) && (next <= num_of_applications))
        % Each iteration of this while loop attempts to place the next
        % application from the "incoming" array.  If successful, then
        % "placed" is set to 1 and the loop repeats.  If unsuccessful, then
        % exit loop and move on the next simulated time step.
        placed = 0;
        [MHS,num_of_MHS] = create_MHS(executing,num_of_executing,chip_width,chip_height);
        [MVS,num_of_MVS] = create_MVS(executing,num_of_executing,chip_width,chip_height);
        % this function merges the MHS and MVS in one array called
        % HV_strips based on several techniques. all techniques are
        % written in the code of the function and commented so you
        % need to uncomment the way you want to use. in this
        % version of the code I'm using simple merge with MHS first
        % then MVS
        dummy = 1;  % placeholder for unused variable in "merge-strips"
        [HV_strips,num_of_Strips] = merge_strips(executing,num_of_executing,MHS,MVS,num_of_MHS,num_of_MVS,dummy,dummy);

        if TRY_ALL == 1
            cost = inf;% variable to hold communication cost, initialized to a large number for the code to run correctly.
            for k = 1 : incoming_num_of_possible_shapes(next)
                temp = 0;
                required_width_units = incoming_possible_shapes{1,next}(k,1);
                required_height_units = incoming_possible_shapes{1,next}(k,2);            
                for m = 1 : num_of_Strips
                    if (HV_strips(m,1) >= required_width_units) && (HV_strips(m,2) >= required_height_units)
                       [temp] = mapper_GN(commun_vol{1,next},required_width_units,required_height_units);
                       if cost > temp
                           cost = temp;
                           temp_placement = m;    %hold the strip number corresponding to low communication cost
                           required_width_temp = required_width_units;
                           required_height_temp = required_height_units;
                           placed = 1;
                       end
                       % The following break is new.  With
                       % the break, then for any given shape, once a
                       % strip is found that can hold that shape, then
                       % calculate the cost of mapping to that shape and
                       % update as needed, then exit the "for m" loop to
                       % move on to the next shape.    Added to avoid
                       % redundantly checking the rest of strips for
                       % placing the same shape which will have the same
                       % communication cost as the one already found.
                       break;
                    end
                end
            end
            if placed == 1
                num_of_executing = num_of_executing + 1; 
                executing(num_of_executing,1) = incoming(next,1);%application ID
                executing(num_of_executing,2) = required_width_temp;%application width
                executing(num_of_executing,3) = required_height_temp;%application height
                executing(num_of_executing,4) = HV_strips(temp_placement,3);% x of the placement Top left corner
                executing(num_of_executing,5) = HV_strips(temp_placement,4);% y of the placement Top left corner
                executing(num_of_executing,6) = incoming(next,4);%execution time
%                executing(num_of_executing,7) = incoming(next,5);%deadline
                executing(num_of_executing,7) = 0;% no deadline, so placeholder
                executing(num_of_executing,8) = incoming(next,4) + current_time; % time to finish
                executing(num_of_executing,9) = cost;
                finished(incoming(next,1),:) = [incoming(next,1) incoming(next,3) current_time executing(num_of_executing,8) executing(num_of_executing,9)];
                next = next + 1;
    %           [MHS,num_of_MHS] = create_MHS(executing,num_of_executing,chip_width,chip_height);
    %           [MVS,num_of_MVS] = create_MVS(executing,num_of_executing,chip_width,chip_height);
    %           [HV_strips,num_of_Strips] = merge_strips(executing,num_of_executing,MHS,MVS,num_of_MHS,num_of_MVS,required_width_units,required_height_units,chip_width,chip_height);
    %           draw(MVS,num_of_MVS,MHS,num_of_MHS,executing,num_of_executing,num_of_rejected,chip_width,chip_height)
            end

        else     % TRY_ALL == 0
            for k = 1 : incoming_num_of_possible_shapes(next)
                required_width_units = incoming_possible_shapes{1,next}(k,1);
                required_height_units= incoming_possible_shapes{1,next}(k,2);            
                for m = 1 : num_of_Strips
                    if (HV_strips(m,1) >= required_width_units) && (HV_strips(m,2) >= required_height_units)
                       [cost] = mapper_GN(commun_vol{1,next},required_width_units,required_height_units);
                       num_of_executing = num_of_executing + 1; 
                       executing(num_of_executing,1) = incoming(next,1);%application ID
                       executing(num_of_executing,2) = required_width_units;%application width
                       executing(num_of_executing,3) = required_height_units;%application height
                       executing(num_of_executing,4) = HV_strips(m,3);% x of the placement Top left corner
                       executing(num_of_executing,5) = HV_strips(m,4);% y of the placement Top left corner
                       executing(num_of_executing,6) = incoming(next,4);%execution time
%                       executing(num_of_executing,7) = incoming(next,5);%deadline
                       executing(num_of_executing,7) = 0;% no deadline, so placeholder
                       executing(num_of_executing,8) = incoming(next,4) + current_time; % time to finish
                       executing(num_of_executing,9) = cost;
                       finished(incoming(next,1),:) = [incoming(next,1) incoming(next,3) current_time executing(num_of_executing,8) executing(num_of_executing,9)];
%                       [MHS,num_of_MHS] = create_MHS(executing,num_of_executing,chip_width,chip_height);
%                       [MVS,num_of_MVS] = create_MVS(executing,num_of_executing,chip_width,chip_height);
%                       [HV_strips,num_of_Strips] = merge_strips(executing,num_of_executing,MHS,MVS,num_of_MHS,num_of_MVS,required_width_units,required_height_units,chip_width,chip_height);
%                       draw(MVS,num_of_MVS,MHS,num_of_MHS,executing,num_of_executing,num_of_rejected,chip_width,chip_height)
                       placed = 1;
                       next = next + 1;
                       break;
                    end
                end
               if placed == 1
                   break;
               end
            end
        end
    end

    
    % utilization of the chip at current time
    uti_sum = 0;
    for zz = 1 : num_of_executing
        uti_sum = uti_sum + executing(zz,2)* executing(zz,3);
    end
%    current_time = current_time + 1 ;
    utilization(current_time) = uti_sum / (chip_width * chip_height);
 
end
makespan = current_time;
end

