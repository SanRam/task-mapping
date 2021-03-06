function [map_commun_cost] = mapper_GN(commun_vol_one,required_width_units,required_height_units)

% Function mapper_GN takes as input one application and a fixed-size
% rectangle (that is, one region), then maps tasks of that application to 
% cores in that region.  Uses "mapping_heuristic" to specify which
% heuristic to use to map individual tasks to cores.  Calls
% "communication_cost_calculator" to determine cost of a mapping.

% In this version, mapper_GN calls the mapping heuristics itself
%   rather than pushing that down to communication_cost_calculator.
%   Also, it encapsulates the mapping heuristics as self-contained
%   functions, while communication_cost_calculator just
%   calculates communication costs.

% adapted from March 2013 version of FF_scheduler.m and July 2013 version
% of mapper_AR.m
% 


global mapping_heuristic


switch mapping_heuristic
    case 1
                                                                   % PCF mapping heuristic
        [map_by_place,map_by_task_ID] = map_applic_PCF(commun_vol_one,required_width_units,required_height_units);
    case 2
                                                                   % LCF mapping heuristic
        [map_by_place,map_by_task_ID] = map_applic_LCF(commun_vol_one,required_width_units,required_height_units);
    case 4
                                                                   % EM mapping heuristic
        [map_by_place,map_by_task_ID] = map_applic_EM(commun_vol_one,required_width_units,required_height_units);
end

[map_commun_cost] = communication_cost_calculator(commun_vol_one,map_by_task_ID);
end

