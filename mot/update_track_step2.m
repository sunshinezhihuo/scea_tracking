function [Track, used_track_idx, det_asso_idx] = update_track_step2(Track, Cost2ndMat, Cost2ndMatNoApp, new_set, new_set_hist, det_asso_idx, used_track_idx, opt)


if(~isempty(Track) && ~isempty(new_set))
    
    [Assignment2, ~] = munkres(Cost2ndMat); %% Corrected (Track by Detection)
    
    [MR,MC] = size(Cost2ndMat);
    if(MR<MC)
        [Assignment2, ~] = munkres(Cost2ndMat'); %% Corrected (Track by Detection)
        Assignment2 = Assignment2';
    end
    for i=1:length(Track)
        idx_m = find(Assignment2(i,:)==1);
        Cost2nd = Cost2ndMatNoApp(i,idx_m);
        if(Cost2nd< opt.cost_threshold2-eps)
            Track{i}.detection = [new_set(1:2,idx_m)+new_set(3:4,idx_m)/2;new_set(3:4,idx_m)]; % associated (Track Label;Detection Label)
            Track{i}.HSV = new_set_hist{idx_m};
            Track{i}.asso_spatial = 0.5;
            det_asso_idx = [det_asso_idx, idx_m]; % collecting associated detections
%             associated_idx = [associated_idx, idx_m]; % Associated detection label
            used_track_idx = unique([used_track_idx, i]);
        end
    end
end