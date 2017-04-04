function [Track] = track_update_kf_sc(Track, used_track_idx, RMN, opt, param, f, L, Sg)

x = linspace(-L / 2, L / 2, L);
Gw = exp(-x .^ 2 / (2 * Sg ^ 2));
Gw = Gw / sum (Gw); % normalize

for i = 1:length(Track)
    Gp_x = Track{i}.graph_x; % predicted states from self motion and relational function
    P = Track{i}.Pp; % predicted covariance
    s_asso = Track{i}.asso_spatial;
    Det = Track{i}.detection;
    graph_weight = Track{i}.graph_weight;
    states = Track{i}.states; 
    
    if(~isempty(Det) && max(s_asso) >= opt.ov_const) % Update with observations (Smoothness)
        
        
        graph_weight(1,:) = graph_weight(1,:).*s_asso';
        graph_weight(1,:) = graph_weight(1,:)/sum(graph_weight(1,:));
        Track{i}.graph_weight = graph_weight;
        
        % select the most reliable node or neighbor
        [~, max_idx] = max(s_asso);
        x_max = Gp_x(:,max_idx);   
        cov_dist = diag(Det(3:4)/2 + x_max(5:6)/2).^2;
        R = [cov_dist, zeros(2,2);zeros(2,2), param.R(3:4,3:4)];
        S = param.H*P*param.H' + R;
        K = P*param.H'*inv(S);
        x = x_max + K*(Det - param.H*x_max);
        P = P - K*S*K';
        
        W = mean([states(3,end) Det(3)]);
        H = mean([states(4,end) Det(4)]);
        
        Track{i}.X = [Det(1:2); x(3:4);W;H];
        Track{i}.P = P;
        xstate = [Det(1:2); W;H; x(3:4)]; % [center u, v, w, h, ut, vt]
        
        Track{i}.states = [Track{i}.states, xstate];
        
        posx = Track{i}.states(1,:); % position x
        [smooth_x] = g_smoothing(posx, Gw, L);
        posy = Track{i}.states(2,:); % position y
        [smooth_y] = g_smoothing(posy, Gw, L);
        w = Track{i}.states(3,:); % w
        [smooth_w] = g_smoothing(w, Gw, L);
        h = Track{i}.states(4,:); % h
        [smooth_h] = g_smoothing(h, Gw, L);
        xstate_on = [smooth_x(end);smooth_y(end);smooth_w(end);smooth_h(end);xstate(5:6)];
        
        
        Track{i}.states_online = [Track{i}.states_online, xstate_on];
        Track{i}.frame = [Track{i}.frame, f];
        Track{i}.frame_online = [Track{i}.frame_online, f];
        Track{i}.Appearance = opt.learn*Track{i}.Appearance + (1-opt.learn)*Track{i}.HSV(:,1);
        Track{i}.AppearanceSet = [Track{i}.AppearanceSet, Track{i}.HSV(:,1)];
        
        % Learning (ON)
        Track{i}.learn_on = 1;
        
        
        if(Track{i}.not_detected == 0) % If the object is detected at the previous frame.
            Track{i}.re_detected = 0;
        else % If the object is not detected at the previous frame.
            Track{i}.re_detected = 1;
        end
        
        Track{i}.not_detected = 0;
        
        
        
        if(Track{i}.unreliable >0)
            Track{i}.unreliable = 0;
        end
        x = param.F*x;
        xu = x(1:2)-x(5:6)/2; xb = x(1:2)+x(5:6)/2;
        Size_H = x(6);
        if(xu(1)<1-opt.margin_u || xu(2)<1-opt.margin_v || xb(1)>opt.imgsz(2)+opt.margin_u || xb(2)>opt.imgsz(1)+opt.margin_v || Size_H < opt.s_size(1) || Size_H > opt.s_size(3) ) % Out of View + too small or too large
            Track{i}.survival = 0;
            Track{i}.learn_on = 0;
            Track{i}.graph_weight = [];
        end
    else % If detections are not associated
        
        diff_frame = f - Track{i}.frame(end);
        lab_i = Track{i}.lab;
        X = zeros(6,1);
        idx = 0;
        if diff_frame == 1 && ~isempty(used_track_idx)
            for j = 1:size(used_track_idx,2)
                t_idx = used_track_idx(j);
                lab_j = Track{t_idx}.lab;
                if ~isempty(RMN(lab_i,lab_j).state)
                    idx = idx + 1;
                    pred_trans = param.Fr * RMN(lab_i,lab_j).state.X;
                    X = X + [Track{t_idx}.X(1:4)+pred_trans(1:4);0;0] + [0;0;0;0;Track{i}.X(5:6)];
                end
            end
            if idx~=0
                X = X/idx;
                xstate = [X(1:2);X(5:6);X(3:4)];
                states = [Track{i}.states,xstate];
                
                posx = states(1,:); % position x
                [smooth_x] = g_smoothing(posx, Gw, L);
                posy = states(2,:); % position y
                [smooth_y] = g_smoothing(posy, Gw, L);
                w = states(3,:); % w
                [smooth_w] = g_smoothing(w, Gw, L);
                h = states(4,:); % h
                [smooth_h] = g_smoothing(h, Gw, L);
                xstate_on = [smooth_x(end);smooth_y(end);smooth_w(end);smooth_h(end);xstate(5:6)];
                
                
                Track{i}.states_online = [Track{i}.states_online, xstate_on];
                Track{i}.frame_online = [Track{i}.frame_online, f];
            end
        end
        
        
        Track{i}.X = Track{i}.Xp;
        Track{i}.P = Track{i}.Pp;
        Track{i}.graph_weight = [];
        x = Track{i}.X;
        xstate = [x(1:2); x(5:6); x(3:4)];
        Track{i}.unreliable = Track{i}.unreliable + 1;
        Track{i}.learn_on = 0;
        Track{i}.not_detected = 1;
        Track{i}.re_detected = 0;
        x = param.F*x;
        xu = x(1:2)-x(5:6)/2; xb = x(1:2)+x(5:6)/2;
        Size_H = x(6);
        if(xu(1)<1-opt.margin_u || xu(2)<1-opt.margin_v || xb(1)>opt.imgsz(2)+opt.margin_u || xb(2)>opt.imgsz(1)+opt.margin_v || Size_H < opt.s_size(1) || Size_H > opt.s_size(3) ) % Out of View + too small or too large
            Track{i}.survival = 0;
        end
        
        T_frame = Track{i}.frame(end);
        if(f - T_frame > opt.max_gap ) % Out of View + too small or too large
            Track{i}.survival = 0;
        end
    end
end