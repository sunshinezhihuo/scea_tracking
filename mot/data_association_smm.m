function [CostMat] = data_association_smm(Track, new_set, new_set_hist,  opt, param)


% Histogram
new_set_hist_temp = new_set_hist;
new_set_hist = [];
for i=1:size(new_set_hist_temp,2)
    new_set_hist = [new_set_hist new_set_hist_temp{i}(:,1)];
end

% Second Layer
% Not associated detection with
% Not detected object at previous frames
% Collecting not associated object index
not_used_track_idx = [];
for i=1:length(Track)
    not_used_track_idx = [not_used_track_idx, i];
end



CostMat = opt.cost_threshold*ones(length(Track),size(new_set,2));
%


for i = 1:length(Track)
    
    X = Track{i}.X;
    Xp = param.F*X;
    HSV_app = Track{i}.Appearance;
    pred_state = [Xp(1),Xp(2),Xp(5),Xp(6)];
    
    for k=1:size(new_set,2)
        det_state = [new_set(1:2,k)+new_set(3:4,k)/2;new_set(3:4,k)]; % center u,v,w,h
        MotionConst = 0.3; SizeConst = 0.7;
        [size_prob, motion_prob] = MotionAffinityModel(pred_state,det_state,1,1, MotionConst, SizeConst); % Model1(Overlap) Model2(Dist), Constraint1 (ON)
        app_prob = sum(sqrt(HSV_app.*new_set_hist(:,k)));
        
        if(opt.app_off ==0)
%             App_Const = 0.5;
%             if(app_prob<App_Const)
%                 app_prob = eps;
%             end
        else
            app_prob = 1;
        end
        CostMat(i,k) = min((-log(app_prob*motion_prob*size_prob)),opt.cost_threshold);
    end    
end
    