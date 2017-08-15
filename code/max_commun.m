% function max_commun

function [mC_ID] = max_commun (A, B, commun_vol_one)

% Finds task in A with maximum communication volume with tasks in B and
%   returns the ID of that task
% If no task in A communicates with a task in B, then function returns 0.
% Assumes A, B are 1D arrays of task IDs.

% called from "map_applic_PCF"

% commun_vol_one is sorted by total communication volume
% columns of commun_vol_one:
%  1 - task ID
%  2 through n+1 - weighted adjacency matrix
%  n+2 - count of communicating tasks
%  n+3 - volume of communication to/from task

TaskCommun = zeros(size(A,1),1);
    % array "taskCommun" will hold the total communication volume for each
    %   task in A, with volume for task A(i) in TaskCommun(i)
    
% sort "commun_vol_one" array by task ID rather than communication volume
%   This way, row k of "commun_vol_unsorted_one" will match the task with
%   ID k
commun_vol_unsorted_one = sortrows(commun_vol_one, 1);

for i = 1 : size(A,1)
    ID_i = A(i,1);
%     TaskCommun(ID_i) = 0;
    TaskCommun(i) = 0;  % rather than index by ID a_i as in pseudocode, 
                        %   will index by i
%     for j = 2 : (size(commun_vol_unsorted_one,2)-2)
%             % Recall that the weighted adjacency matrix starts in column 2,
%             %   so column j describes edges for task j-1
%         if commun_vol_unsorted_one(ID_i,j) > 0
%                 % that is, if an edge exists from task ID_i to task j-1,
%                 %   then check if task j-1 is in B
%             found_in_B = 0;  % flag
%             index_B = 1;  % pointer
%             while found_in_B == 0
%                 if j-1 == B(index_B) % column j holds info for task j-1
%                     found_in_B = 1;
%                 end
%                 index_B = index_B + 1;
%                 if index_B > size(B,1) % that is, 
%                     found_in_B = 2;
%                 end
%             end
%             if found_in_B == 1
%                 TaskCommun(i) = TaskCommun(i) + commun_vol_unsorted_one(ID_i,j);
%             end
%         end
%     end

% The above commented-off code matches my pseudocode and checks for each 
%   edge from task ID_i whether it is in B.
%   Instead, invert to test for each task in B whether it has an edge from
%   task ID_i.
    for k = 1 : size(B,1)
        if commun_vol_unsorted_one(ID_i,B(k)+1) > 0
                % That is, if an edge exists from task ID_i to task B(k).
                % Recall that the weighted adjacency matrix starts in
                %   column 2, so an edge to task j would be in column j+1
            TaskCommun(i) = TaskCommun(i) + commun_vol_unsorted_one(ID_i,B(k)+1);
        end
    end
end
max_comm_vol = 0;
mC_ID = 0;  % if no task in A has communication with any task in B, then
            %   function will return mC_ID = 0
for i = 1 : size(A,1)
    if TaskCommun(i) > max_comm_vol
        max_comm_vol = TaskCommun(i);
        mC_ID = A(i,1);
    end
end
end

