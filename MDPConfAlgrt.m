function [path_list, netCostMatrix]=MDPConfAlgrt(netCostMatrix, s, mode,destinations,second_round)
% Author, Diego Lopez, 2020.
%Mode: link and node
%Check op_mode
%Return path list and a modified netcostmatrix that has the paths found
%with a zeo cost value
if(strcmp(mode,'link'))
  op_mode=1;
elseif (strcmp(mode,'node'))
  op_mode=2;
else
  error('Operation mode possiblities are link or node, review input paramenters');
end
%Order matrix cost by index
[sorted,index]=sort(netCostMatrix,1,'ascend');
index(sorted==inf)=nan;%Quit index not valid
path_list=cell(1,length(destinations));
hop_back=false;
matrx_cell=cell(1,size(netCostMatrix,2));
for(i=1:size(netCostMatrix,2))
  matrx_cell{1,i}=index(:,i);
end
matrix_cell_orig=matrx_cell;
for i=1:length(destinations)%size(netCostMatrix,1)
  index_copy=index;
  switch(op_mode)
    case 1
      while (~isnan(index_copy(1,destinations(i))))
        path=[destinations(i)];
        next_hop=index_copy(1,destinations(i));
        path=[path index_copy(1,destinations(i))];
        index_copy(:,destinations(i))=[index_copy(2:end,destinations(i)); nan];
        if(next_hop==s) %Path_finished,add to final struct
          path_list{1,i}{end+1,1}=flip(path);
        end
        prev_hop=0;
        %Mientras el siguiente salto no sea la fuente, no haya siguiente
        %salto, el hop_back no sea el nodo destino.
        while (next_hop~=s && ~isnan(next_hop) && prev_hop~=destinations(i) && ~(prev_hop==next_hop && prev_hop==destinations(i)))
          prev_hop=next_hop;
          next_hop=index_copy(1,next_hop);
          index_copy(:,prev_hop)=[index_copy(2:end,prev_hop); nan];
          %quit reverse link too
          if(~isnan(next_hop))
            [row,cols,val]=find(index_copy(:,next_hop)==prev_hop);
            index_copy(row:end,next_hop)=[index_copy(row+1:end,next_hop);nan];
          end
          if((next_hop==destinations(i) || isnan(next_hop)) )%&& ~hop_back)
            %Hop back
            hop_back=true;
            duplicate_in_path=find(path==prev_hop);
            if(isnan(index_copy(1,path(duplicate_in_path(end)))))
              %Retrocede otro paso
              duplicate_in_path=duplicate_in_path-1;
            end
            if(duplicate_in_path(end)==0)
              prev_hop=path(1); %El primer nodo
              path=path(1);
            else
              prev_hop=path(duplicate_in_path(end));%El nodo previo al que da el fallo
              path=path(1:duplicate_in_path(end));
            end
            next_hop=prev_hop;
          else
            hop_back=false;
            path=[path next_hop];
          end
          if(next_hop==s) %Path_finished,add to final struct
            path_list{1,i}{end+1,1}=flip(path);
            if(second_round)
                index_copy(:,destinations(i))=nan;
            end
          end
        end
      end
    case 2
      used_nodes=[];
      matrx_cell=matrix_cell_orig;
     while (~isnan( matrx_cell{1,destinations(i)}(1)))
        path=[destinations(i)];
        next_hop=matrx_cell{1,destinations(i)}(1);
        while (any(used_nodes==next_hop))
          matrx_cell{1,destinations(i)}(1)=[];
          next_hop=matrx_cell{1,destinations(i)}(1);
        end
        if(~isnan(next_hop))
          path=[path matrx_cell{1,destinations(i)}(1)];
          matrx_cell{1,destinations(i)}(1)=[];
          if (next_hop~=s && ~isnan(next_hop))
            used_nodes=[used_nodes next_hop];
          end
          if(next_hop==s) %Path_finished,add to final struct
            path_list{1,destinations(i)}{end+1,1}=flip(path);
            end
          end
        end
        prev_hop=0;
        %Mientras el siguiente salto no sea la fuente, no haya siguiente
        %salto, el hop_back no sea el nodo destino.
        while (next_hop~=s && ~isnan(next_hop) && prev_hop~=destinations(i) && ~(prev_hop==next_hop && prev_hop==destinations(i)))
          prev_hop=next_hop;
          next_hop=matrx_cell{1,prev_hop}(1);%Get the first path from list
            matrx_cell{1,prev_hop}(1)=[];
          while(any(used_nodes ==next_hop))
            next_hop=matrx_cell{1,prev_hop}(1);
            if (next_hop~=s)
              matrx_cell{1,prev_hop}(1)=[];
            end
          end
          if (next_hop~=s && ~isnan(next_hop))
            used_nodes=[used_nodes next_hop];
          end        
          if((next_hop==destinations(i) || isnan(next_hop)) )%&& ~hop_back)
            %Hop back
            hop_back=true;
            duplicate_in_path=find(path==prev_hop);
            if(isnan(matrx_cell{1,prev_hop}(1)))
              %Retrocede otro paso
              duplicate_in_path=duplicate_in_path-1;
            end
            if(duplicate_in_path(end)==0)
              prev_hop=path(1); %El primer nodo
              path=path(1);
            else
              prev_hop=path(duplicate_in_path(end));%El nodo previo al que da el fallo
              path=path(1:duplicate_in_path(end));
            end
            next_hop=prev_hop;
          else
            hop_back=false;
            path=[path next_hop];
          end
          if(next_hop==s) %Path_finished,add to final struct
            path_list{1,destinations(i)}{end+1,1}=flip(path);
            end
            %%Falta por hacer el ckeck de lazos
          end
        end
      end
  end
end           
  %Quit cell with empty path (from source to source)
  indx=cellfun(@isempty,path_list);
  pos=find(indx);
  path_list(pos)=[];