function [prob_mat, pos_mat] = GatingTechnique(Track, new_set, SimMatrix)

% heuristic gating technique

prob_mat = zeros(length(Track),size(new_set,2));
pos_mat = zeros(length(Track),size(new_set,2));
for i=1:length(Track)
    obj_patch = Track{i}.states(1:4,end);
    if Track{i}.not_detected == 0
        for j=1:size(new_set,2)
            det_pos = new_set(1:2,j) + new_set(3:4,j)/2;
            det_size = new_set(3:4,j);
            
            norm_size = [obj_patch(3) + det_size(1);obj_patch(4) + det_size(2)];
            disterr = abs(obj_patch(1:2) - det_pos(1:2));
            dist_error = abs(obj_patch(1:2) - det_pos(1:2))./norm_size;
            pos_prob  = max(1- 0.5*dist_error(1) - 0.5*dist_error(2),0);
            if pos_prob < 0.5 % 0.5
                pos_prob = 0;
            elseif(disterr(1)>obj_patch(3))
                pos_prob = 0;
            elseif(disterr(2)>obj_patch(3))
                pos_prob = 0;
            end
            app_prob  = SimMatrix(i,j);
            if app_prob < 0.5
                app_prob = 0;
            end
            size_prob = 1 - (0.5*abs(det_size(1)-obj_patch(3))/(det_size(1)+obj_patch(3))...
                + 0.5*abs(det_size(2)-obj_patch(4))/(det_size(2)+obj_patch(4)));
            if size_prob < 0.8 % 0.8
                size_prob = 0;
            end
            
            prob_mat(i,j) = pos_prob * app_prob * size_prob;
            pos_mat(i,j) = pos_prob;
        end
    end
end