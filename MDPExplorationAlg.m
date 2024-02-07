
function [distance2source] = MDPExplorationAlg(netCostMatrix, s)
%==============================================================
% shortestPath: the list of nodes in the shortestPath from source to destination;
% totalCost: the total cost of the  shortestPath;
% farthestNode: the farthest node to reach for each node after performing the routing;
% n: the number of nodes in the network;
% s: source node index;
% d: destination node index;
%==============================================================
%  Code by:
% ++by Xiaodong Wang
% ++23 Jul 2004 (Updated 29 Jul 2004)
% ++http://www.mathworks.com/matlabcentral/fileexchange/5550-dijkstra-shortest-path-routing
% Modifications (simplifications) by Meral Shirazipour 9 Dec 2009
%==============================================================
% Modifications(Increased amount of data collected for MDPALg) by Diego Lopez, 2020.
%==============================================================
n = size(netCostMatrix,1);
% all the nodes are un-visited;
visited(1:n) = false;
distance(1:n) = inf;    % it stores the shortest distance between each node and the source node;
distance2source= Inf(size(netCostMatrix)); %Matrix to store the distance towards source node
parent(1:n) = 0;
distance(s) = 0;
for i = 1:(n)
    temp = [];
     for h = 1:n
          if ~visited(h)  % in the tree;
              temp=[temp distance(h)];
          else
              temp=[temp inf];
          end
     end
     [t, u] = min(temp);      % it starts from node with the shortest distance to the source;
     visited(u) = true;         % mark it as visited;
     for v = 1:n               % for each neighbors of node u;
       if(v~=s) %La fuente no puede analizar costes, se parte de ella 
         if(parent(u) ~= v) %El primer mensaje no reenvia hacia detras
           if ( ( netCostMatrix(u, v) + distance(u)) < distance(v) )          
                 distance(v) = distance(u) + netCostMatrix(u, v);   % update the shortest distance when a shorter shortestPath is found;
                 parent(v) = u;     % update its parent;
            end
             distance2source(u,v)= distance(u) + netCostMatrix(u, v);
             %parent
         else
           %Penalize cost from father and restore the value from previous
           %father
           x=find(distance2source(:,v)>=500 & ~isinf(distance2source(:,v)));
           distance2source(x,v)=distance(x) + netCostMatrix(x, v);
           %distance2source(u,v)= distance(u) + netCostMatrix(u, v)+ 500;
         end
       end
     end
end
end