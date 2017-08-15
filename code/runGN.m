
% runGN3.m is the script that takes already created application sets then
%   schedules them using PCF then LCF then EM.
% runGN.m is the script for running experiments to schedule
%   sequences of applications.  It generated undirected and weighted
%   task graphs.
%   It specifies experiment parameters listed as global below.

% adapted from March 2013 version of run.m, July 2013 version of runAR.m,
%   and July 2013 version of runGD.m


global num_data_files num_of_runs chip_width chip_height sorted_option
global num_of_applications min_task_per_application max_task_per_application edge_ratio 
global prime_option_less prime_option_more non_prime_option_less non_prime_option_more width_max_fraction height_max_fraction
global mapping_heuristic TRY_ALL
global arrival_time_max max_execution_time
global same_commun_vol min_commun_vol max_commun_vol
global min_laxity max_laxity


num_data_files = 1;
num_of_runs = 2; %changed from 210./////
chip_width= 32;   % define the chip width
chip_height= 32;   % define the chip height

num_of_applications = 300;
min_task_per_application = 10;
max_task_per_application = 100;
edge_ratio = 0.5;
min_laxity = 1;
max_laxity = 50;
arrival_time_max = 1000;
max_execution_time = 100;
same_commun_vol = 1;    % 0: uniform random distribution of weights with
                        %      next two variables setting lower and upper
                        %      limits
                        % 1: all pairwise task communication volumes same;
min_commun_vol = 1;
max_commun_vol = 1;

prime_option_less = 2;     % 1: as is    2: next non prime with size limitation
prime_option_more = 2;     % 1: as is    2: next non prime with size limitation
non_prime_option_less = 2; % 1: as is    2: size limitation
non_prime_option_more = 2;  % 1: as is    2: size limitation
width_max_fraction = 0.5;
height_max_fraction = 0.5;

% mapping_heuristic variable will select the type of mapping heuristic to
% be used 
% 1: placed communication first (PCF, was LCFA)
% 2: largest communication first (LCF)
% 3: neighbor-aware frontier (NF)
% 4: Euclidean minimum (EM)
% 5: fixed center (FC)
mapping_heuristic = 1;

        % "sorted_option" variable allows sorting possible rectangle shapes
        % in which an application can be placed.
sorted_option = 2;       % 1: sort by aspect ratio from closest to 1
                         % 2: random order
                         % any other number:  leave as generated

% TRY_ALL option will determine whether the scheduler will search for
% a placement for an application using all possible rectangle shapes,
% then select the placement with minimum communication cost (TRY_ALL = 1)
% or will search for a placement using each possible rectangle
% shape only until finding a placement (TRY_ALL = 0).
% (When TRY_ALL = 1, "sorted_option" does not matter because the scheduler
% will check every shape.)
TRY_ALL = 0;



% Function applic_generator_GN uses variables (all global):
%    chip_width,chip_height, num_of_applications, min_task_per_application,
%    max_task_per_application, edge_ratio, prime_option_less,
%    prime_option_more, non_prime_option_less, non_prime_option_more,
%    width_max_fraction, height_max_fraction,
%    arrival_time_max, max_execution_time, same_commun_vol, min_commun_vol,
%    max_commun_vol, min_laxity, max_laxity

% Function order_arrays uses variables (both global):
%    sorted_option, num_of_applications

% Function experiment_GN uses variables (all global):
%    num_data_files, num_of_runs, chip_width, chip_height, 
%    num_of_applications, arrival_time_max


for count = 1: num_of_runs
    [incoming,adjacency,commun_vol,incoming_possible_shapes,incoming_num_of_possible_shapes] = applic_generator_GN();
    [incoming_possible_shapes] = order_arrays(incoming_possible_shapes,incoming_num_of_possible_shapes);
    %count
    file_name = strcat('dataGN/incoming_data',num2str(count));
%    file_name = strcat('dataGN',num2str(data_number),'/incoming_data',num2str(count));
    save (file_name,'incoming','adjacency','commun_vol','incoming_possible_shapes','incoming_num_of_possible_shapes');
    clear incoming adjacency commun_vol incoming_possible_shapes incoming_num_of_possible_shapes;
%    clc
end
% changed //////// san

if 0
   
mapping_heuristic = 1;
[exper_avg_execution_time,exper_avg_communication_cost,exper_avg_makespan,exper_avg_utilization] = experiment_GN();
file_name = strcat('resultsGN/experResults',num2str(mapping_heuristic));
save (file_name ,'exper_avg_execution_time','exper_avg_communication_cost','exper_avg_makespan','exper_avg_utilization');
mapping_heuristic,exper_avg_execution_time,exper_avg_communication_cost,exper_avg_makespan,exper_avg_utilization

mapping_heuristic = 2;
[exper_avg_execution_time,exper_avg_communication_cost,exper_avg_makespan,exper_avg_utilization] = experiment_GN();
file_name = strcat('resultsGN/experResults',num2str(mapping_heuristic));
save (file_name ,'exper_avg_execution_time','exper_avg_communication_cost','exper_avg_makespan','exper_avg_utilization');
mapping_heuristic,exper_avg_execution_time,exper_avg_communication_cost,exper_avg_makespan,exper_avg_utilization
end

% changed //////// san


mapping_heuristic = 4;
[exper_avg_execution_time,exper_avg_communication_cost,exper_avg_makespan,exper_avg_utilization] = experiment_GN();
file_name = strcat('resultsGN/experResults',num2str(mapping_heuristic));
save (file_name ,'exper_avg_execution_time','exper_avg_communication_cost','exper_avg_makespan','exper_avg_utilization');
mapping_heuristic,exper_avg_execution_time,exper_avg_communication_cost,exper_avg_makespan,exper_avg_utilization

