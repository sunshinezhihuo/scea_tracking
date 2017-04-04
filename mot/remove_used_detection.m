% removing assigned detection

function  [new_set,new_set_hist] = remove_used_detection(new_set,new_set_hist,det_asso_idx)

if(~isempty(det_asso_idx))
    new_set(:,det_asso_idx) = []; % remove assoicated detections
    Idx = 0;
    new_set_hist_temp = new_set_hist;
    new_set_hist = {};
    for i=1:size(new_set_hist_temp,2)
        if(sum(det_asso_idx==i)==0)
            Idx = Idx + 1;
            new_set_hist{Idx} = new_set_hist_temp{i};
        end
    end
end