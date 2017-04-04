function [Cost2ndMat, Cost2ndMatNoApp] = data_association_step2(Track, RMN, AppModel, new_set, new_set_hist,  used_track_idx, det_asso_idx, opt, param, SimMatrix)


% Histogram
new_set_hist_temp = new_set_hist;
new_set_hist = [];
for i=1:size(new_set_hist_temp,2)
    new_set_hist = [new_set_hist new_set_hist_temp{i}(:,1)];
end

% Second Layer 
not_used_track_idx = [];
for i=1:length(Track)
    if(sum(used_track_idx == i)==0)
        not_used_track_idx = [not_used_track_idx, i];
    end
end



Cost2ndMat = opt.cost_threshold*ones(length(Track),size(new_set,2));
Cost2ndMatNoApp = opt.cost_threshold*ones(length(Track),size(new_set,2));
 
for i = 1:length(Track)
    not_detected = Track{i}.not_detected;
    Label_i = Track{i}.lab;
    frame = Track{i}.frame(end);
     
    Pred_Set = [];
    Label_G = [];
    Track_idx = [];
    Link_Weight = [];
    HSV_Set = [];
    if(not_detected == 1)
        Graph = Track{i}.graph; % representing the j to i edge
        for k=1:size(Graph,2)
            idx_k = Graph(k);
            if(sum(used_track_idx==idx_k)==1) % Only currently tracked object
                Label_k = Track{idx_k}.lab;
                Track_Pos = Track{idx_k}.detection;
                temp_state_i = [Track_Pos(1:2);0;0;Track_Pos(3:4)];
                Relative_Trans = param.Fr*RMN(Label_i,Label_k).state.X;
                WidhtHeight = Track{i}.X(5:6);
                pred_rmn = [temp_state_i(1:2);0;0;0;0] + [Relative_Trans(1:2); Relative_Trans(3:4); WidhtHeight]; % The i-th object is associated with the j-th detection
                Pred_Set = [Pred_Set, pred_rmn(:)];
                Label_G = [Label_G, Label_k];
                Track_idx = [Track_idx, idx_k];
                hsv_link_app = Track{idx_k}.Appearance;
                HSV_Set = [HSV_Set, hsv_link_app];
                
                
                Var = norm(RMN(Label_i,Label_k).state.X(3:4));
                Link_Weight = [Link_Weight, 1/(Var)^2];
                
            end
        end
        if(~isempty(Link_Weight))
            Link_Weight = Link_Weight/sum(Link_Weight);
        end
    end
    
    
    
    
    
    % Linked Event
    for k=1:size(new_set,2)
        if(sum(det_asso_idx==k)==0)
            det_state = [new_set(1:2,k)+new_set(3:4,k)/2;new_set(3:4,k)]; % center u,v,w,h
            if(~isempty(Pred_Set))
                Cost = 0;
                Cost_S = [];
                Cost_S_No_App = [];

                for kk=1:size(Pred_Set,2)
                    pred_state = [Pred_Set(1:2,kk);Pred_Set(5:6,kk)]; % center u,v,w,h

                    MotionConst = 0.3; SizeConst = 0.8;
                    [size_prob, motion_prob] = MotionAffinityModel(pred_state,det_state,1,1, MotionConst, SizeConst); % Model1(Overlap) Model2(Dist), Constraint1 (ON)
                
                    if(opt.app_off ==0)
                        app_prob =  SimMatrix(i,k);
                    else
                        app_prob = 1;
                    end
                    
                    Cost_S(kk) = min((-log(app_prob*motion_prob*size_prob)),opt.cost_threshold);
                    Cost_S_No_App(kk) =  min((-log(1*motion_prob*size_prob)),opt.cost_threshold);
                end
                % Option 1
                %                 [minval mindix] = min((1./Link_Weight).*Cost_S);
                % Option 2
                [~, mindix] = min(Cost_S);

                 Cost2ndMat(i,k) =   Cost_S(mindix);    
                 
                 Cost2ndMatNoApp(i,k) = Cost_S_No_App(mindix);     
            end
        end
    end
    
    
    
    
end


