function [frontier,y] = mark_frontier(width,height,t_row, t_col,frontier,y)

% function was called MARKFRONTIER in Mostafa code

%updates frontier node array and list Y after a task is mapped to (p, q)
p = t_row;
q = t_col;

%frontier(p, q) = 0;
%remove (p,q) from Y
for i = size(y,1): -1 : 1
    if (y(i,1) == p) && (y(i,2) == q)
        y(i,:) = [];
    end
end

if (p+1 <= height) && (frontier(p+1, q) == 0)	
    % add N, S, E, W neighbors to frontier if not mapped
	frontier(p+1, q) = 1;
	y(size(y,1)+1,:) = [p+1,q];
end
if (p>1)
    if (p-1 >= 0) && (frontier(p-1, q)  == 0) 
        % add N, S, E, W neighbors to frontier if not mapped
        frontier(p-1, q) = 1;
        y(size(y,1)+1,:) = [p-1,q];
    end
end
if (q+1 <= width) && (frontier(p, q+1) == 0)
    % add N, S, E, W neighbors to frontier if not mapped
	frontier(p, q+1) = 1;
	y(size(y,1)+1,:) = [p,q+1];
end
if (q>1)
    if (q-1 >= 0) && (frontier(p, q-1) == 0) 
        % add N, S, E, W neighbors to frontier if not mapped
        frontier(p, q-1) = 1;
        y(size(y,1)+1,:) = [p,q-1];
    end
end
if (p+1 <= height) && (q+1 <= width) && (frontier(p+1, q+1) == 0)
    % add NE, NW, SE, SW neighbors to frontier if not mapped
	frontier(p+1, q+1) = 1;
    y(size(y,1)+1,:) = [p+1,q+1];
end
if(q>1)
    if (p+1 <= height) && (q-1 >= 0) && (frontier(p+1, q-1) == 0) 
        % add NE, NW, SE, SW neighbors to frontier if not mapped
        frontier(p+1, q-1) = 1;
        y(size(y,1)+1,:) = [p+1,q-1];
    end
end
if (p>1)
    if (p-1 >= 0) && (q+1 <= width) && (frontier(p-1, q+1) == 0) 
        % add NE, NW, SE, SW neighbors to frontier if not mapped
        frontier(p-1, q+1) = 1;
        y(size(y,1)+1,:) = [p-1,q+1];
    end
end
if (p>1) && (q>1)
    if (p-1 >= 0) && (q-1 >= 0) && (frontier(p-1, q-1) == 0) && (p>0) && (q>0)
        % add NE, NW, SE, SW neighbors to frontier if not mapped
        frontier(p-1, q-1) = 1;
        y(size(y,1)+1,:) = [p-1,q-1];
    end
end


end

