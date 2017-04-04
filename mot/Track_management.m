function [Track, NewT, Match_Init, Match_Init_Hist, Match_App_Set, Track_Save_Smooth, param, f] =...
    Track_management(Track, RMN, new_set, new_set_hist, used_track_idx, Match_Init, Match_Init_Hist, Match_App_Set, Track_Save_Smooth, param, opt, f)

if(~isempty(Track))
    [Track] = track_update_kf_sc(Track, used_track_idx, RMN, opt, param, f, 3, 1);   % Smoothing
    [Track] = track_linking(Track);
end

[Track_Save_Smooth] = track_save_along_label_smoothing(Track_Save_Smooth,Track,f, opt.FrameLength,  opt.smooth_step, 1);
[Track] = track_deletion(Track); 
[InitObj, InitObj_Hist, InitObj_App_Set, Match_Init, Match_Init_Hist, Match_App_Set]...
    = matching_detections(new_set, new_set_hist, Match_Init, Match_Init_Hist, Match_App_Set, f, opt); % Matching for Initialization

NewT = []; % New Track Index
[Track, NewT, param] = track_initialization(InitObj, InitObj_Hist, InitObj_App_Set, Track, NewT, param); % Object Initialization
