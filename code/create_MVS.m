function [MVS,num_of_MVS] = create_MVS(executing,num_of_executing,chip_width,chip_height)


reversed_executing(:,8) = 0;

for i = 1 : num_of_executing
    reversed_executing(i,:)= [executing(i,1) executing(i,3) executing(i,2) executing(i,5) executing(i,4) executing(i,6:8) ];
end

[MVS,num_of_MVS] = create_strips(reversed_executing,num_of_executing,chip_height,chip_width);

for i = 1 : num_of_MVS
    MVS(i,:) = [MVS(i,2) MVS(i,1) MVS(i,4) MVS(i,3)];
end

%MVS = [];
%num_of_MVS = 0;
%MVS = sortrows (MVS,[3 4]);