function [Track, associated_idx, used_track_idx, det_asso_idx] = update_scea_result(Track, assignment1, new_set, new_set_hist)


% Initialization for Track Association
for i=1:length(Track)
    Track{i}.detection = {};
    Track{i}.asso_spatial = {};
end

associated_idx = [];
used_track_idx = [];
det_asso_idx = [];

for i=1:length(Track)
    Track{i}.not_detected = 1; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
for i=1:length(Track)
    for j=1:size(new_set,2)
        if(assignment1(i,j)==1)
            det_asso_idx = [det_asso_idx, j]; % collecting associated detections
            associated_idx = [associated_idx, j]; % Associated detection label
            used_track_idx = [used_track_idx, i];
            Track{i}.detection = [new_set(1:2,j)+new_set(3:4,j)/2;new_set(3:4,j)]; % associated (Track Label;Detection Label)
            Track{i}.HSV = new_set_hist{j};
            Track{i}.asso_spatial = 0.5;
            Track{i}.not_detected = 0; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end
    end
end

