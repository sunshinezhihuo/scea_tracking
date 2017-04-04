
function  plot_rmn_prediction(Track,RMN)



for i=1:length(Track)
    lab1 = Track{i}.lab; % the node target label
    Neighbor_state = Track{i}.graph_x;  % [trans_state;TN;WH]; % Transfered state
    GP = Track{i}.graph;
    frame = Track{i}.frame(end);
    
    
    if(size(Neighbor_state,2)>1)
        
        Variation = [];
        LAB = lab1;
        for k=1:size(GP,2)
            lab2 = Track{GP(k)}.lab;
            
            frames = RMN(lab1,lab2).frames;
            if(sum(frames==frame)==1)
                Var = RMN(lab1,lab2).state.X(3:4);
                Variation = [Variation, norm(Var)];
            else
                Variation = [Variation, 100];
            end
            LAB = [LAB, lab2];
        end
        [minval minidx] = min(Variation);
        
        % mean state based on weight
%        inv_var = 1./Variation;
%         v_weight = inv_var/sum(inv_var);
%         temp_mean_state = zeros(6,1);
%         Neighbor_state(:,1) = []; % remove self motion 
%         for j=1:size(Neighbor_state,2)
%            temp_mean_state = temp_mean_state + v_weight(j) * Neighbor_state(:,j);
%         end
%         
%         
%         
%         % mean state
% %         temp_mean_state = mean(Neighbor_state,2);
%         mean_state = temp_mean_state([1,2,5,6]);
%         Color = 'm';
%         xu = [mean_state(1)-mean_state(3)/2;mean_state(2)-mean_state(4)/2];
%         xb = [mean_state(1)+mean_state(3)/2;mean_state(2)+mean_state(4)/2];
%         
%         % Draw prediction points
%         LeftU = xu; % Left up
%         RigthB = xb;% Right bottom
%         dcorners = [LeftU(1),RigthB(1),RigthB(1),LeftU(1),LeftU(1); LeftU(2),LeftU(2),RigthB(2),RigthB(2),LeftU(2)];
%         CenX = xu(1) + (xb(1)-xu(1))/2; CenY = xu(2) + (xb(2)-xu(2))/2;
%         
%         line(dcorners(1,:), dcorners(2,:), 'Color',Color, 'LineWidth',1);
%         text(CenX, CenY,sprintf('%d',lab2),'Color',Color,'Fontsize',10,'HorizontalAlignment','Center','FontWeight','bold');
%         
        
        for j =2:size(Neighbor_state,2)
            xstate = Neighbor_state([1,2,5,6],j);
            lab2 = LAB(j);
            
            Color = 'm';
            xu = [xstate(1)-xstate(3)/2;xstate(2)-xstate(4)/2];
            xb = [xstate(1)+xstate(3)/2;xstate(2)+xstate(4)/2];
            
            % Draw prediction points
            LeftU = xu; % Left up
            RigthB = xb;% Right bottom
            dcorners = [LeftU(1),RigthB(1),RigthB(1),LeftU(1),LeftU(1); LeftU(2),LeftU(2),RigthB(2),RigthB(2),LeftU(2)];
            CenX = xu(1) + (xb(1)-xu(1))/2; CenY = xu(2) + (xb(2)-xu(2))/2;
            
            line(dcorners(1,:), dcorners(2,:), 'Color',Color, 'LineWidth',1);
            text(CenX, CenY,sprintf('%d',lab2),'Color',Color,'Fontsize',10,'HorizontalAlignment','Center','FontWeight','bold');
        end
    end
end
% function  plot_rmn_prediction(Track,RMN)
% 
% 
% 
% for i=1:length(Track)
%     lab1 = Track{i}.lab; % the node target label
%     Neighbor_state = Track{i}.graph_x;  % [trans_state;TN;WH]; % Transfered state
%     GP = Track{i}.graph; 
%     frame = Track{i}.frame(end);
%     
%     
%     if(size(Neighbor_state,2)>1)
%  
%         Variation = [];
%         LAB = [];
%         for k=1:size(GP,2)
%             lab2 = Track{GP(k)}.lab;
%       
%             frames = RMN(lab1,lab2).frames;
%             if(sum(frames==frame)==1)
%                 Var = RMN(lab1,lab2).state.X(3:4);
%                 Variation = [Variation, norm(Var)];
%             else
%                 Variation = [Variation, 100];
%             end
%             LAB = [LAB, lab2];
%         end
%         [minval minidx] = min(Variation);
%         
%         xstate = Neighbor_state([1,2,5,6],minidx+1);
%         lab2 = LAB(minidx);
%     
%         Color = 'm';
%         xu = [xstate(1)-xstate(3)/2;xstate(2)-xstate(4)/2];
%         xb = [xstate(1)+xstate(3)/2;xstate(2)+xstate(4)/2];
%         
%         % Draw prediction points
%         LeftU = xu; % Left up
%         RigthB = xb;% Right bottom
%         dcorners = [LeftU(1),RigthB(1),RigthB(1),LeftU(1),LeftU(1); LeftU(2),LeftU(2),RigthB(2),RigthB(2),LeftU(2)];
%         CenX = xu(1) + (xb(1)-xu(1))/2; CenY = xu(2) + (xb(2)-xu(2))/2;
%         
%         line(dcorners(1,:), dcorners(2,:), 'Color',Color, 'LineWidth',1);
%         text(CenX, CenY,sprintf('%d',lab2),'Color',Color,'Fontsize',10,'HorizontalAlignment','Center','FontWeight','bold');
%     end 
% end