function [dirty,num_of_executing,executing] = delete_finished_applications (num_of_executing,executing,current_time)

    % check for any finished task and delete it from the executing list

%global chip_width chip_height
  
dirty = 0;
for i = num_of_executing : -1 : 1 
    if (executing(i,8) == current_time) && (current_time ~=0)
        dirty = 1;
%        num_of_executing = num_of_executing - 1;
%        executing (i,:) = [];  % delete finished task from executing array 
        if i == num_of_executing
            executing (i,:) = [];
        else
            for k = i : num_of_executing-1
                executing(k,:) = executing(k+1,:);
            end
            executing(num_of_executing,:) = [];
        end
        num_of_executing = num_of_executing - 1;

        % uncomment these lines if you need to see the updated space
        % after deleting an application.
        % also uncomment the "global" line above

%            [MHS,num_of_MHS] = create_MHS(executing,num_of_executing,chip_width,chip_height);
%            [MVS,num_of_MVS] = create_MVS(executing,num_of_executing,chip_width,chip_height);
%            [HV_strips,num_of_Strips] = merge_strips(executing,num_of_executing,MHS,MVS,num_of_MHS,num_of_MVS,1,1,chip_width,chip_height);
%            draw(MVS,num_of_MVS,MHS,num_of_MHS,executing,num_of_executing,0,chip_width,chip_height)
    end
end

        
        
    
    