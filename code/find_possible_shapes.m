function [ shapes,num_of_possible_shapes ] = find_possible_shapes(num_of_tasks)
% note 1 : for the scheduler to place an application with a certain number
% of tasks, we need to know the space width and length required to fit the
% number of tasks of the application. as the input to the scheduler has
% only the number of tasks per application, find_possible_shapes will
% construct all
% possible combinations for space to place the application. 
% Separately from find_possible_shapes, the scheduler can manipulate
% the order of shapes, such as sorting by aspect ratio or
% randomizing the order.

% As an example of sorting by aspect ratio,
% if the applications has 18 tasks, the order of shapes would be
% 3*6 then 6*3 then 2*9 then 9*2 then 1*18 then 18*1.
% As another example, for a num_of_tasks =15, the order is
% 3*5 then 5*3 then 1*15 then 15*1.

% This version of the code only constructs shapes with exactly the
% number of required tasks

num_of_possible_shapes = 0;
shapes=[];
    for i = num_of_tasks : -1 : 1
        if rem(num_of_tasks,i) ==0 
            num_of_possible_shapes = num_of_possible_shapes + 1;
            shapes(num_of_possible_shapes,:)=[(num_of_tasks/i),i,0];
        end
    end

 end
    
% If num_of_tasks is not a perfect square, then
% array shapes will have an even number of possible shapes.
% The order of these shapes is as follows.
% For example, if num_of_tasks is 18 the resulting shapes array will be:
%shapes =
%
%     1    18
%     2     9
%     3     6
%     6     3
%     9     2
%    18     1
%
% Observe that the two shapes with aspect ratio closest to 1
% (that is, 3 x 6 and 6 x 3)
% are in the middle.  The order of shapes proceeds from aspect ratio
% furthest from 1 to closest to 1 then back to furthest from 1.

% If num_of_tasks is a perfect square, then
% array shapes will have an even number of possible shapes.
% The order of these shapes is as follows.
% For example, if num_of_tasks is 64 the resulting shapes array will be:
%shapes =
    %     1     64
    %     2     32
    %     4     16
    %     8     8
    %     16    4
    %     32    2
    %     64    1
%
% Observe that the shape with aspect ratio = 1 (that is, 8 x 8)
% is in the middle.  The order of shapes proceeds from aspect ratio
% furthest from 1 to closest to 1 then back to furthest from 1.
