% map_applic_LCF

function [map_by_place,map_by_task_ID] = map_applic_LCF (commun_vol_one,width,height)

% LCF mapping heuristic                                                                                                                                                                                      - takes one application as input, 
%   maps it using LCF, returns map_by_place and map_by_task_ID


     % Can replace "adjacency_one" by "commun_vol_one" throughout
     %   because using column 1 which holds task ID
     %   or column n+2 which holds count of communicating tasks
     
        map_by_task_ID = [];
        map_by_place = [];

        no_of_tasks = size(commun_vol_one,1);


        % Calculate c2,c3,c4 based on the height and width
        % C2 = set of cores in hxw mesh with 2 links 
        % C3 = set of cores in hxw mesh with 3 links
        % C4 = set of cores in hxw mesh with 4 links
        if height == 1 && width == 1
            c2 = [1 1];
            c3 = [];
            c4 = [];
        elseif height == 1 && width > 1
            if width == 2
                c2 = [1 1; 1 2];
            else
                c2(:,2) = 1:width;
                c2(:,1) = 1;
            end
            c3 = [];
            c4 = [];
        elseif height > 1  && width == 1
            if height == 2
                c2 = [1 1;2 1];
            else
                c2(:,1) = 1:height;
                c2(:,2) = 1;
            end
            c3 = [];
            c4 = [];
        elseif height > 1 && width > 1
            c2 = [1,1 ; 1,width ; height,1 ; height,width];
            if height==2 && width==2
                c3 = [];
                c4 = [];
            elseif height == 2 && width >2
                for i = 1 : height
                    for j = 1:width-2
                        c3(j+((i-1)*(width-2)),:) = [i,j+1];
                    end
                end 
                c4 =[];
            elseif height > 2 && width == 2
                for i = 1 : width
                    for j = 1:height-2
                        c3(j+((i-1)*(height-2)),:) = [j+1,i];
                    end
                end 
                c4 =[];
            else
                % Calculate c3
                for i= 1 : width-2
                    c3(i,:)=[1,i+1];
                end
                for i= 1 : width-2
                    c3(i+width-2,:)=[height,i+1];
                end                
                for i= 1 : height-2
                    c3(i+2*(width-2),:)=[i+1,1];
                end
                for i= 1 : height-2
                    c3(i+2*(width-2)+height-2,:)=[i+1,width];
                end
                
                % claculate c4
                for i = 1 : height-2
                    for j = 1 : width-2
                        c4(j+((i-1)*(width-2)),:) = [i+1,j+1];
                    end
                end
            end
        end
        availablec2 = size(c2,1);
        availablec3 = size(c3,1);
        availablec4 = size(c4,1);
        
        w2 = [];    % list of tasks with >2 links waiting for assignment
        w3 = [];    % list of tasks with 3 links waiting for assignment
        w4 = [];    % list of tasks with 4+ links waiting for assignment
        a2 = [];    % list of tasks assigned to cores in C2
        a3 = [];    % list of tasks assigned to cores in C3
        a4 = [];    % list of tasks assigned to cores in C4

        R = [];			% array of row numbers in sorted commun_vol_one
					%  corresponding to already mapped tasks
        for i = 1 : no_of_tasks
            if commun_vol_one(i,no_of_tasks+2) <= 2
                if availablec2 > 0
                    a2(size(a2,1)+1,:) = i;   %row # in sorted commun_vol_one;
                    availablec2 = availablec2 - 1;
                else
                    w2(size(w2,1)+1,:) = i;   %row # in sorted commun_vol_one;
                end
            elseif commun_vol_one(i,no_of_tasks+2) == 3
                if availablec3 > 0
                    a3(size(a3,1)+1,:) = i;   %row # in sorted commun_vol_one;
                    availablec3 = availablec3 - 1;
                else
                    w3(size(w3,1)+1,:) = i;   %row # in sorted commun_vol_one;
                end
            elseif commun_vol_one(i,no_of_tasks+2) >= 4
                if availablec4 > 0
                    a4(size(a4,1)+1,:) = i;   %row # in sorted commun_vol_one;
                    availablec4 = availablec4 - 1;
                else
                    w4(size(w4,1)+1,:) = i;   %row # in sorted commun_vol_one;
                end
            end
        end


        for i = size (a4,1) : -1 : 1
            task = a4(i); %row # in sorted commun_vol_one;
            a4(i) = [];
            [t_row,t_col, c4, R] = assign_task_LCF(map_by_task_ID,map_by_place,commun_vol_one,task,height,width,c4, R);
            map_by_place(t_row, t_col) = commun_vol_one(task,1);
            map_by_task_ID(commun_vol_one(task,1),:) = [t_row t_col];
        end
        for i = size (a3,1) : -1 : 1
            task = a3(i); %row # in sorted commun_vol_one;
            a3(i) = [];
            [t_row,t_col, c3, R] = assign_task_LCF(map_by_task_ID,map_by_place,commun_vol_one,task,height,width,c3, R);
            map_by_place(t_row, t_col) = commun_vol_one(task,1);
            map_by_task_ID(commun_vol_one(task,1),:) = [t_row t_col];            
        end
        for i = size (a2,1) : -1 : 1
            task = a2(i); %row # in sorted commun_vol_one;
            a2(i) = [];
            [t_row,t_col, c2, R] = assign_task_LCF(map_by_task_ID,map_by_place,commun_vol_one,task,height,width,c2, R);
            map_by_place(t_row, t_col) = commun_vol_one(task,1);
            map_by_task_ID(commun_vol_one(task,1),:) = [t_row t_col];            
        end

        for i = size (w4,1) : -1 : 1
            task = w4(i); %row # in sorted commun_vol_one;
            w4(i) = [];
            if size(c4,1) > 0
               [t_row,t_col, c4, R] = assign_task_LCF(map_by_task_ID,map_by_place,commun_vol_one,task,height,width,c4, R);
               map_by_place(t_row, t_col) = commun_vol_one(task,1);
               map_by_task_ID(commun_vol_one(task,1),:) = [t_row t_col];               
            elseif size(c3,1) >0
               [t_row,t_col, c3, R] = assign_task_LCF(map_by_task_ID,map_by_place,commun_vol_one,task,height,width,c3, R);
               map_by_place(t_row, t_col) = commun_vol_one(task,1);
               map_by_task_ID(commun_vol_one(task,1),:) = [t_row t_col];            
            elseif size(c2,1) >0
               [t_row,t_col, c2, R] = assign_task_LCF(map_by_task_ID,map_by_place,commun_vol_one,task,height,width,c2, R);
               map_by_place(t_row, t_col) = commun_vol_one(task,1);
               map_by_task_ID(commun_vol_one(task,1),:) = [t_row t_col];            
            end
        end
        for i = size (w3,1) : -1 : 1
            task = w3(i); %row # in sorted commun_vol_one;
            w3(i) = [];
            if size(c3,1) > 0
               [t_row,t_col, c3, R] = assign_task_LCF(map_by_task_ID,map_by_place,commun_vol_one,task,height,width,c3, R);
               map_by_place(t_row, t_col) = commun_vol_one(task,1);
               map_by_task_ID(commun_vol_one(task,1),:) = [t_row t_col];            
            elseif size(c4,1) >0
               [t_row,t_col, c4, R] = assign_task_LCF(map_by_task_ID,map_by_place,commun_vol_one,task,height,width,c4, R);
               map_by_place(t_row, t_col) = commun_vol_one(task,1);
               map_by_task_ID(commun_vol_one(task,1),:) = [t_row t_col];            
            elseif size(c2,1) >0
               [t_row,t_col, c2, R] = assign_task_LCF(map_by_task_ID,map_by_place,commun_vol_one,task,height,width,c2, R);
               map_by_place(t_row, t_col) = commun_vol_one(task,1);
               map_by_task_ID(commun_vol_one(task,1),:) = [t_row t_col];            
            end
        end
        for i = size (w2,1) : -1 : 1
            task = w2(i); %row # in sorted commun_vol_one;
            w2(i) = [];
            if size(c2,1) > 0
               [t_row,t_col, c2, R] = assign_task_LCF(map_by_task_ID,map_by_place,commun_vol_one,task,height,width,c2, R);
               map_by_place(t_row, t_col) = commun_vol_one(task,1);
               map_by_task_ID(commun_vol_one(task,1),:) = [t_row t_col];            
            elseif size(c3,1) >0
               [t_row,t_col, c3, R] = assign_task_LCF(map_by_task_ID,map_by_place,commun_vol_one,task,height,width,c3, R);
               map_by_place(t_row, t_col) = commun_vol_one(task,1);
               map_by_task_ID(commun_vol_one(task,1),:) = [t_row t_col];            
            elseif size(c4,1) >0
               [t_row,t_col, c4, R] = assign_task_LCF(map_by_task_ID,map_by_place,commun_vol_one,task,height,width,c4, R);
               map_by_place(t_row, t_col) = commun_vol_one(task,1);
               map_by_task_ID(commun_vol_one(task,1),:) = [t_row t_col];            
            end
        end



