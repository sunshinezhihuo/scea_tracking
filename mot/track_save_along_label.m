% Save Track along the lable
function  [Track_Save] = track_save_along_label(Track_Save,Track,fidx,FrameLength)

if(~isempty(Track))
    for i=1:length(Track)
        if(Track{i}.survival == 0)
            Lab = Track{i}.lab;
            Track_Save{Lab} = [Track{i}.states_online(1:4,:);Track{i}.frame_online];
        end
    end
end
if(fidx==FrameLength)
    for i=1:length(Track)
        Lab = Track{i}.lab;
        Track_Save{Lab} = [Track{i}.states_online(1:4,:);Track{i}.frame_online];
    end
end