function [Track, used_track_idx, det_asso_idx] = recovery_missing_objects(Track, RMN, SimMatrix, used_track_idx, det_asso_idx, new_set, new_set_hist,  param, opt)

% Controlling partial detections
for i=1:length(Track)
    if (~isempty(Track{i}.detection))
        for k=1:size(new_set,2) 
            state_det =  Track{i}.detection;
            dett = new_set(:,k);
            dett(1:2) = dett(1:2) + dett(3:4)/2;
            
            OV = p_computePascalScoreRect(state_det, dett);
            if OV > 0.3
                det_asso_idx = [det_asso_idx,k];
            end
        end
    end
end
det_asso_idx = unique(det_asso_idx);

%% 2nd step (DA for missing objects using reliable objects)
[Cost2ndMat, Cost2ndMatNoApp] = data_association_step2(Track, RMN, [], new_set,...
    new_set_hist, used_track_idx, det_asso_idx, opt, param, SimMatrix);
[Track, used_track_idx, det_asso_idx] = update_track_step2(Track,...
    Cost2ndMat, Cost2ndMatNoApp, new_set, new_set_hist, det_asso_idx, used_track_idx, opt);