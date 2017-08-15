function [HV_strips,num_of_Strips] = merge_strips(executing_temp,num_of_executing_temp,MHS,MVS,num_of_MHS,num_of_MVS,required_width_units,required_height_units)

global chip_width chip_height

%*********************MHVS_MHSfirst*****************************************************
HV_strips = [MHS ; MVS];
num_of_Strips = num_of_MHS + num_of_MVS;
%**************************************************************************

%**************************MHVS_MVSfirst************************************************
%HV_strips = [MVS ; MHS];
%num_of_Strips = num_of_MHS + num_of_MVS;
%**************************************************************************

%*****************************MHSonly*********************************************
%HV_strips = [MHS];
%num_of_Strips = num_of_MHS;
%**************************************************************************

%**********************************MVSonly****************************************
%HV_strips = [MVS];
%num_of_Strips = num_of_MVS;
%**************************************************************************

%*************************************MHVS_smallsizefirst*************************************
%for i = 1 : num_of_Strips
%    HV_strips(i,5) = HV_strips(i,1) * HV_strips(i,2);
%end
%HV_strips = sortrows (HV_strips,5);
%HV_strips = HV_strips(:,1:4);

%HV_strips = sortrows (HV_strips,[4 3]);
%**************************************************************************

%*************************************MHVS_bestfit*************************************
%for i = 1 : num_of_Strips
%    if (required_width_units == HV_strips(i,1)) && (required_height_units == HV_strips(i,2))
%        HV_strips(i,5) = 4;
%    elseif (required_width_units == HV_strips(i,1)) && (required_height_units < HV_strips(i,2))
%        HV_strips(i,5) = 3;
%    elseif (required_width_units < HV_strips(i,1)) && (required_height_units == HV_strips(i,2))
%        HV_strips(i,5) = 3;
%    elseif (required_width_units < HV_strips(i,1)) && (required_height_units < HV_strips(i,2))
%        HV_strips(i,5) = 2;
%    elseif (required_width_units > HV_strips(i,1)) || (required_height_units > HV_strips(i,2))
%        HV_strips(i,5) = 0;
%    end
%end
%HV_strips = sortrows (HV_strips,-5);
%HV_strips = HV_strips(:,1:4);
%**************************************************************************

%***********************************MHVS_sortedy***************************************
%HV_strips = sortrows (HV_strips,[4 3]);
%**************************************************************************

%************************************MHVS_sortedx**************************************
%HV_strips = sortrows (HV_strips,[3 4]);
%**************************************************************************

%********************** MHVS sorted based on the number of MHVS resulting from placing the task within each of them*************

%for i = 1 : num_of_Strips
%     if (required_width_units <= HV_strips(i,1)) && (required_height_units <= HV_strips(i,2))
%         %assume we placed the task within this strip and see how this will
%         %effect the number of strips
%         % in the following code we will simulate as if we placed the task
%         % but this is a temp array that will not affect the actual array
%         num_of_executing_temp = num_of_executing_temp + 1; 
%         executing_temp(num_of_executing_temp,1) = 0; % assume any ID as this will not afect the actual executing list
%         executing_temp(num_of_executing_temp,2) = required_width_units;%task width
%         executing_temp(num_of_executing_temp,3) = required_height_units;%task height
%         executing_temp(num_of_executing_temp,4) = HV_strips(i,3);% x of the placement Top left corner
%         executing_temp(num_of_executing_temp,5) = HV_strips(i,4);% y of the placement Top left corner
%         executing_temp(num_of_executing_temp,6) = 0;%execution time
%         executing_temp(num_of_executing_temp,7) = 0;%deadline
%         executing_temp(num_of_executing_temp,8) = 0; % time to finish
%         [MHS,num_of_MHS] = create_MHS(executing_temp,num_of_executing_temp,chip_width,chip_height);
%         [MVS,num_of_MVS] = create_MVS(executing_temp,num_of_executing_temp,chip_width,chip_height);
%         HV_strips(i,5) = num_of_MHS + num_of_MVS;
%         executing_temp(num_of_executing_temp,:) = []; %return the array to what it was
%         num_of_executing_temp = num_of_executing_temp - 1; 
%     else
%         HV_strips(i,5) = inf;
%     end
% end
% HV_strips = sortrows (HV_strips,[5 3 4]);
% HV_strips = HV_strips(:,1:4);

%**************************************************************************

%********************** MHVS sorted based on the number of strips that will be cut during the task placement****
%{
for i = 1 : num_of_MHS
    if (required_width_units <= MHS(i,1)) && (required_height_units <= MHS(i,2))
        %assume we placed the task within this strip and see how this will
        %effect the number of strips
        % in the following code we will simulate as if we placed the task
        % but this is a temp array that will not affect the actual array
        task(1,1) = 0; % assume any ID as this will not afect the actual executing list
        task(1,2) = required_width_units;%task width
        task(1,3) = required_height_units;%task height
        task(1,4) = MHS(i,3);% x of the placement Top left corner
        task(1,5) = MHS(i,4);% y of the placement Top left corner
        task(1,6) = 0;%execution time
        task(1,7) = 0;%deadline
        task(1,8) = 0; % time to finish
        number_of_overlap =0;         
        for j = num_of_MVS : -1 : 1%

            xl = MVS(j,3);
            yb = MVS(j,4);
            xr = MVS(j,3) + MVS(j,1) - 1;
            yt = MVS(j,4) + MVS(j,2) - 1;
            rec_h = MVS(j,2);
            rec_w = MVS(j,1);%

            task_xl = task(1,4);
            task_xr = task(1,4) + task(1,2) - 1;
            task_yb = task(1,5);
            task_yt = task(1,5) + task(1,3) - 1;
            task_width = task(1,2);
            task_height = task(1,3);

            % the overlap function will check if there overlap between any two
            % rectangle shapes. these two rectangles canbe two empty rectangles or a
            % can be a task and an empty rectangle. the output of the function will be
            % either 0 or 1 or 2 or 3. if the output is 0 it means no overlap exist. if the
            % output is 1 it means the two rectangles overlaps. if the output of the
            % function is 2 it means rec 1 is contained inside rec 2. if the output is
            % 3 it means rec 2 is contained insode rec 1.%

            [overlap_result] = check_overlap(task_xl,task_xr,task_yb,task_yt,xl,xr,yb,yt);

            if overlap_result == 0
                % task is not fully or partially contained in the rectangle. should
                % go to the next itteration without doing anything to this
                % rectangle.
                continue;
            end
            number_of_overlap = number_of_overlap + 1;
        end
        HV_strips(i,5) = number_of_overlap;
    else
        HV_strips(i,5) = inf;
    end
end
for i = 1 : num_of_MVS
    if (required_width_units <= MVS(i,1)) && (required_height_units <= MVS(i,2))
        %assume we placed the task within this strip and see how this will
        %effect the number of strips
        % in the following code we will simulate as if we placed the task
        % but this is a temp array that will not affect the actual array
        task(1,1) = 0; % assume any ID as this will not afect the actual executing list
        task(1,2) = required_width_units;%task width
        task(1,3) = required_height_units;%task height
        task(1,4) = MVS(i,3);% x of the placement Top left corner
        task(1,5) = MVS(i,4);% y of the placement Top left corner
        task(1,6) = 0;%execution time
        task(1,7) = 0;%deadline
        task(1,8) = 0; % time to finish
        number_of_overlap =0;         
        for j = num_of_MHS : -1 : 1%

            xl = MHS(j,3);
            yb = MHS(j,4);
            xr = MHS(j,3) + MHS(j,1) - 1;
            yt = MHS(j,4) + MHS(j,2) - 1;
            rec_h = MHS(j,2);
            rec_w = MHS(j,1);%
            task_xl = task(1,4);
            task_xr = task(1,4) + task(1,2) - 1;
            task_yb = task(1,5);
            task_yt = task(1,5) + task(1,3) - 1;
            task_width = task(1,2);
            task_height = task(1,3);

            % the overlap function will check if there overlap between any two
            % rectangle shapes. these two rectangles canbe two empty rectangles or a
            % can be a task and an empty rectangle. the output of the function will be
            % either 0 or 1 or 2 or 3. if the output is 0 it means no overlap exist. if the
            % output is 1 it means the two rectangles overlaps. if the output of the
            % function is 2 it means rec 1 is contained inside rec 2. if the output is
            % 3 it means rec 2 is contained insode rec 1.

            [overlap_result] = check_overlap(task_xl,task_xr,task_yb,task_yt,xl,xr,yb,yt);

            if overlap_result == 0
                % task is not fully or partially contained in the rectangle. should
                % go to the next itteration without doing anything to this
                % rectangle.
                continue;
            end
            number_of_overlap = number_of_overlap + 1;
        end
        HV_strips(num_of_MHS+i,5) = number_of_overlap;
    else
        HV_strips(num_of_MHS+i,5) = inf;
    end
end
HV_strips = sortrows (HV_strips,5);
HV_strips = HV_strips(:,1:4);
%}
 
    
    
    
    
    
    
    