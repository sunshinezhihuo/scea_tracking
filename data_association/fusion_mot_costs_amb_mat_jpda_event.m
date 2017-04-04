function [event_prob_set]...
    = fusion_mot_costs_amb_mat_jpda_event(Track, RMN, event_set, new_set, ProbD, abmigous_matrix, param, opt)


NofDet = size(new_set,2);

event_prob_set = cell(1,size(event_set,1));
event_set(event_set==0) = NofDet + 1;


[tidx_set, didx_set] = find(abmigous_matrix==1);
idx_set = [tidx_set,didx_set];


for s=1:size(idx_set,1) 
    i = idx_set(s,1); % track index
    j = idx_set(s,2); % detection index
    
    label_i         = Track{i}.lab; % track label
    Link            = Track{i}.link; % track link information
    pred_state_node = param.F*Track{i}.X; % predicted position of tracks
    pred_state_node = [pred_state_node(1:2);pred_state_node(5:6)];
%     d_frame = (Track{i}.frame(end)-Track{i}.frame(end-1));
%     del_pos = Track{i}.states(1:2,end)-Track{i}.states(1:2,end-1);
%     pos_iidx = Track{i}.states(1:2,end) - del_pos/d_frame;
    
    if(~isempty(Link)) % if link information is given
        % Associating Detection
        temp_state_i = new_set(1:2,j) + new_set(3:4,j)/2;
        [~, s_prob] = size_cost(new_set(3:4,j),pred_state_node(3:4));
%                 pos_prob = exp(-norm(pred_state_node(1:2) - temp_state_i(1:2))/sum(pred_state_node(3:4)/2 + new_set(3:4,j)/2));
        temp_i_bbox = [temp_state_i;new_set(3:4,j)];
        pos_prob = (p_computePascalScoreRect(temp_i_bbox, pred_state_node));
        pos_prob = max(0.1,pos_prob);
        % Predict other object states with RMN
        template.reference_patch = [];
        template.reference_patch_prev = [];
        template.reference_idx = [];
        template.patch = [];
        
        fct_rmn.reference_patch = [];
        fct_rmn.label_link      = [];
        fct_rmn.track_idx       = [];
        fct_rmn.direction       = [];
        fct_rmn.direction_set = {};
        
        idk = 1;
        for k=1:size(Link,2)
            idx_k = Link(k);
            not_detected = Track{idx_k}.not_detected;
            if(not_detected ~= 1) % If the object is not detected at previous frame, we do not consider it in the first layer
                label_k                 = Track{idx_k}.lab;
                relative_motion_trans   = param.Fr*RMN(label_k,label_i).state.X;
                
                % template information
                patch_pos               = temp_state_i(1:2) + relative_motion_trans(1:2); % The i-th object is associated with the j-th detection
                template.reference_patch = [template.reference_patch, [patch_pos(:);Track{idx_k}.states(3:4,end)]];
                patch_pos_prev = temp_state_i(1:2) + RMN(label_k,label_i).state.X(1:2);
                template.reference_patch_prev = [template.reference_patch_prev, patch_pos_prev];
                template.reference_idx = [template.reference_idx, idx_k];
                
                
                
                % direction
%                 rmn_set = RMN(label_k,label_i).set(1:2,:);
%                 if size(rmn_set,2) < 2
%                     d_frame = (Track{idx_k}.frame(end)-Track{idx_k}.frame(end-1));
%                     del_pos = Track{idx_k}.states(1:2,end)-Track{idx_k}.states(1:2,end-1);
%                     pos_tidx = Track{idx_k}.states(1:2,end) - del_pos/d_frame;
%                     rmn_prev = pos_tidx - pos_iidx;
%                     rmn_set_temp = [rmn_prev, rmn_set];
%                     fct_rmn.direction_set{idk} = rmn_set_temp;
%                     fct_rmn.direction       = [fct_rmn.direction, rmn_set(1:2,end)];
%                 else
%                     [pred_rmn, coeff] = svd_prediction(rmn_set, 5);
%                     fct_rmn.direction_set{idk} = rmn_set;
%                     fct_rmn.direction       = [fct_rmn.direction, pred_rmn(:)];
%                 end
                idk = idk + 1;
            end
        end
        if s_prob<0.7
            s_prob = opt.min_prob; %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
        pos_prob = 1;
        init_total_prob =  pos_prob * s_prob * max(pos_prob, opt.min_prob) * max(ProbD(i,j), opt.min_prob);
        
        % template (state) cost with rmn
        event_prob_matrix = zeros(length(Track), NofDet+1);
        event_prob_matrix(i,j) = init_total_prob;
        
        
        event_idx = zeros(size(template.reference_patch,2),NofDet,2);
        
        for k = 1:size(template.reference_patch,2)
            % template
            temp_patch = template.reference_patch(:,k);
            temp_idx = template.reference_idx(k);
            
            % direction
%             rmn_set = fct_rmn.direction_set{k};
            
            idx_m = 1;
            for m = 1:NofDet + 1 % considering missing case
                if m ~= j
                    % Template
                    if m <= NofDet
                        temp_det = [new_set(1:2,m) + new_set(3:4,m)/2; new_set(3:4,m)];
                        p_prob_temp = (p_computePascalScoreRect(temp_patch, temp_det));
                        [~, s_prob] = size_cost(temp_patch(3:4),temp_det(3:4));
                        if p_prob_temp < opt.ov_const %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            p_prob_temp = opt.min_prob;
                        end
                        if s_prob < opt.sz_const %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            s_prob = opt.min_prob;
                        end
                        p_prob = p_prob_temp *  s_prob * max(ProbD(temp_idx,m), opt.min_prob);
                        prob_rmn = 1;
                    else
                        p_prob_temp = opt.missing_prob;
                        s_prob = opt.missing_prob;
                        app_prob = opt.missing_prob; 
                        p_prob = p_prob_temp *  s_prob * app_prob; %%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        prob_rmn = 1;
                    end
%                     temp_prob_matrix(k,idx_m) = p_prob * prob_rmn;
                    event_idx(k,idx_m,1) = temp_idx; % track idx
                    event_idx(k,idx_m,2) = m; % detection idx
                    event_prob_matrix(temp_idx,m) = p_prob * prob_rmn;
                    idx_m = idx_m + 1;
                end
            end
        end
        
        eventid = find(event_set(:,i) == j);
        event_set_temp = event_set(eventid,:);
        for k = 1:size(eventid,1)
            asso_idx = event_set_temp(k,:);
            prob_event = zeros(1,size(asso_idx,2));
            for kk = 1:size(asso_idx,2) % track index
                m = asso_idx(kk);
                prob_event(kk) = event_prob_matrix(kk,m);
            end
            prob_event(prob_event==0) = opt.missing_prob^3;
            event_prob_set{eventid(k)} = [event_prob_set{eventid(k)}; prob_event];
        end
    end
end







