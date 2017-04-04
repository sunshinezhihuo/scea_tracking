function [Track, LinkOn, new_set, new_set_hist, opt] = track_reset(Track,Detect,Detection_App,opt)


new_set = Detect'; % (detection dimension by number of detections)
opt.det_exist = ~isempty(new_set);
opt.num_det = size(new_set,2);
new_set_hist = Detection_App;


for i=1:length(Track)
    Track{i}.Assignment = {};
    Track{i}.AssignmentCost = {};
    Track{i}.Penalty = {};
    Track{i}.EventCost = [];
end

LinkOn = 0;
if(size(Track,2)>1)
    for i=1:length(Track)
        if ~isempty(Track{i}.link)
            LinkOn = 1;
        end
    end
end