function [exper_avg_execution_time,exper_avg_communication_cost,exper_avg_makespan,exper_avg_utilization] = experiment_GN ()

% Modified version of experiment_GN to report results for multiple
%    scheduling experiments using different mapping heuristics

% Function experiment_GN manages the experiments for scheduling a sequence
%   of applications without deadlines to a many-core.
%   Will process applications in first-come, first-served order in the
%   order in which they are given in array "incoming."  (Note that
%   array "incoming" is sorted by arrival time in "applic_generator_GN"
%   rather than sorted by application ID.)  That is, it must place and
%   begin executing each application in "incoming" before moving on to the
%   next application in sequence.
% The primary metrics will be communication cost and makespan, where
%   makespan is the time from starting the first application until the last
%   application finishes.
%
% Inputs:  "adjacency", "commun_vol" -- generated by "applic_generator_GN"
% where the first column holds task ID and the remaining columns of
% "adjacency" hold the adjacency matrix and the remaining columns of
% "commun_vol" hold the weighted adjacency matrix (instead of 1 to denote
% an edge, it holds the communication volume on that edge).
% Assumption:  The task graph is undirected.
%
% For each of "num_data_files" times "num_of_runs" iterations will execute
% independent simulations in which each simulation schedules a sequence of
% "num_of_applications" number of applications.
%
% Calls "FF_scheduler_GN" to schedule one sequence of applications.
% Note:  "FF_scheduler_GN" will append two columns to "adjacency", "commun_vol"

% adapted from March 2013 version of MHVS_initialize.m, July 2013
% version of experiment_AR.m, and July 2013 version of experiment_GD.m


global num_of_runs num_data_files num_of_applications
%global chip_width chip_height

% clear
% clc
for data_number = 1: num_data_files
%    total_num_of_applications = 0;
         % "total_num_of_applications" counts the number of applications
         % across all runs (within one data file)
    exper_execution_time = zeros(num_of_runs,1);
    exper_communication_cost = zeros(num_of_runs,1);
    exper_makespan = zeros(num_of_runs,1);
    exper_utilization = zeros(num_of_runs,1);
    for count = 1 : num_of_runs

           % array "finished" has the following columns
           %  application ID  Arrival_time, Placement_time, time_to_finish communication_Cost


%%%%%%%%%%%%%
% load data for the current simulation run
%%%%%%%%%%%%%
%        file_name = strcat('dataGN',num2str(data_number),'\incoming_data',num2str(count));
%        file_name = strcat('dataGN',num2str(data_number),'/incoming_data',num2str(count));
        file_name = strcat('dataGN/incoming_data',num2str(count));
        load(file_name);
        % This file contains the following:
        %   'incoming','adjacency','commun_vol',
        %   'incoming_possible_shapes','incoming_num_of_possible_shapes'
        % array "incoming" has the following columns:
        % Application ID
        % number_of_tasks
        % Arrival time
        % Execution_Time
        % Deadline
        %   Array "incoming" is sorted by arrival time, not application ID.
        %   Will place applications in the order in which they appear in
        %   "incoming".  Will ignore arrival time, execution time, and
        %   deadline for this case of FCFS scheduling of tasks without 
        %   deadlines.
        
        % Array "incoming_possible_shapes" is already sorted or randomly
        % permuted or unchanged, based on the "sorted_option" parameter,
        % where this ordering was done by function "order_shapes"
        
        % ????? M's file numbering system included "data_number" as part of
        % a folder name, but that was not part of file creation in "run"
        % after application creation in "task_generator"
        
        
%%%%%%%%%%%%%
% schedule one sequence of applications
%%%%%%%%%%%%%
        tic;
        [makespan,utilization,finished] = FF_scheduler_GN(incoming,adjacency,commun_vol,incoming_possible_shapes,incoming_num_of_possible_shapes);
        exper_execution_time(count) = toc;

%%%%%%%%%%%%%
% collect data from one run of scheduling a sequence of applications
%%%%%%%%%%%%%
        temp_cost = sum(finished(:,5));
        exper_communication_cost(count) = temp_cost;
        exper_utilization(count) = sum(utilization,2) / size(utilization,2);
        exper_makespan(count) = makespan;
%        total_num_of_applications = total_num_of_applications + num_of_applications;
%        data_number, count
        count
        clear incoming adjacency commun_vol incoming_possible_shapes incoming_num_of_possible_shapes possible_shapes;
    end

%%%%%%%%%%%%%
% collect data across "num_of_runs" number of independent scheduling
% simulations
%%%%%%%%%%%%%

exper_total_execution_time = 0;
exper_total_communication_cost = 0;
exper_total_makespan = 0;
exper_total_utilization = 0;
for k = 1 : num_of_runs
    exper_total_execution_time = exper_total_execution_time + exper_execution_time(k);
    exper_total_communication_cost = exper_total_communication_cost + exper_communication_cost(k);
    exper_total_makespan = exper_total_makespan + exper_makespan(k);
    exper_total_utilization = exper_total_utilization + exper_utilization(k);
end
exper_avg_execution_time = exper_total_execution_time / num_of_runs;
exper_avg_communication_cost = exper_total_communication_cost / num_of_runs;
exper_avg_makespan = exper_total_makespan / num_of_runs;
exper_avg_utilization = exper_total_utilization / num_of_runs;

% % next line commented off because of problems creating folder
% %file_name = strcat('resultsGN/results',num2str(data_number),'/experResults');
% file_name = strcat('resultsGN/experResults',num2str(data_number));
% save (file_name ,'exper_avg_execution_time','exper_avg_communication_cost','exper_avg_makespan','exper_avg_utilization');
% exper_avg_execution_time,exper_avg_communication_cost,exper_avg_makespan,exper_avg_utilization
% end

end



