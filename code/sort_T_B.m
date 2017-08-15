
function [T_B] = sort_T_B (executing,num_of_executing,T_B)
% this funtion will sort the tops and bottoms in descending order.
% the function will follow the following rules:
% 1- if two tops has the same Y value they will be ordered from left to
% right
% 2- if a top and a bottom has the same Y value they will be ordered to
% have the bottom first.

   %  T_B =  ( Y_value, Left_x, Right_x, T_B flag)
T_B(1,:) = [executing(1,5) + executing(1,3) - 1,executing(1,4),(executing(1,4)+executing(1,2)-1),1];  % top of the task
T_B(2,:) = [executing(1,5),executing(1,4),(executing(1,4)+executing(1,2)-1),0];   % bottom of the task
last = 0;
for i = 2 : 1 : num_of_executing
    % handling the top of the task

    for j=1 : size(T_B,1)
       if T_B(j,4) == 1                  % handling top with top
           if (executing(i,5) + executing(i,3) - 1) == T_B(j,1)
               if executing(i,4) > T_B(j,2)
               if j== size(T_B,1)
                   last = 1;
               end
               continue;
               end
           elseif (executing(i,5) + executing(i,3) - 1) < T_B(j,1)
               if j== size(T_B,1)
                   last = 1;
               end
               continue;
           end
           temp= [executing(i,5) + executing(i,3) - 1,executing(i,4),(executing(i,4)+executing(i,2)-1),1];
           T_B = [ T_B(1:j-1,:) ; temp ; T_B(j:size(T_B,1),:)];
           break;
       else   %  handling top with a bottom
           if (executing(i,5) + executing(i,3) - 1) < T_B(j,1)
               if j== size(T_B,1)
                   last = 1;
               end
               continue;
           end
           temp= [executing(i,5) + executing(i,3) - 1,executing(i,4),(executing(i,4)+executing(i,2)-1),1];
           T_B = [ T_B(1:j-1,:) ; temp ; T_B(j:size(T_B,1),:)];
           break;
       end
    end
    if last == 1   
        % thisifstatment because the previous will not be able to insert
        % the last top or last bottom if it should be added to the end of
        % the array
        last= 0;
        temp= [executing(i,5) + executing(i,3) - 1,executing(i,4),(executing(i,4)+executing(i,2)-1),1];
        T_B = [ T_B ; temp];
    end      
    %handling the bottom of the task
   
    for j=1 : size(T_B,1)
       if T_B(j,4) == 0                  % handling bottom with bottom
           if executing(i,5) == T_B(j,1)
               if executing(i,4) > T_B(j,2)
                   if j== size(T_B,1)
                       last = 1;
                   end
                   continue;
               end
           elseif executing(i,5)< T_B(j,1)
               if j== size(T_B,1)
                   last = 1;
               end
               continue;
           end
           temp= [executing(i,5),executing(i,4),(executing(i,4)+executing(i,2)-1),0];
           T_B = [ T_B(1:j-1,:) ; temp ; T_B(j:size(T_B,1),:)];
           break;
       else   %  handling bottom with a top
           if executing (i,5) <= T_B(j,1)
               if j== size(T_B,1)
                   last = 1;
               end
               continue;
           end
           temp= [executing(i,5),executing(i,4),(executing(i,4)+executing(i,2)-1),0];
           T_B = [ T_B(1:j-1,:) ; temp ; T_B(j:size(T_B,1),:)];
           break;
       end
    end
    if last == 1
        % thisifstatment because the previous will not be able to insert
        % the last top or last bottom if it should be added to the end of
        % the array
        last = 0;
        temp= [executing(i,5),executing(i,4),(executing(i,4)+executing(i,2)-1),0];
        T_B = [ T_B ; temp];
    end 

end
                          
            
%    T_B(i,:) = [executing(i,5),executing(i,4),(executing(i,2)-1),1];
%    T_B{i+num_of_executing,:} = [(executing(i,5)+executing(i,3)-1),executing(i,4),(executing(i,2)-1),0];
%end

% sort the T_B array in a descending order.
%[T_B] = sortrow(T_B,2);
%for i = 1 : 2*num_of_executing
%    T_B(i,2) = - T_B(i,2);
%end
%[T_B] = sortrow(T_B,2);
%%for i = 1 : 2*num_of_executing
%    T_B(i,2) = - T_B(i,2);
%end

    