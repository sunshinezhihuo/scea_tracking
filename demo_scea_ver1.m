clc;
clear;


addpath('common');
addpath('mot');
addpath('rmn_function');
addpath('data_association');
addpath('parameters');

base_path = 'dataset\';
det_path = [ base_path, 'KITTI\' ] ;
seq_path = [ base_path, '\sequence' ] ;
res_path ='result\'; 

TimeSeq = [];

for SeqIdx =1
    kitti_data;
    load( [det_path, Title,'\detection\',det_name] );
 
    
    % Read the first frame
    img_path = [det_path, '\',Title,'\img\'];
 
    [frame_img, frame] = ImgLoad(img_path, FrameSet(1));
    
    
    mot_parameters; % load parameters
    
    Match_Init = {};
    Match_Init_Hist = {};
    Match_App_Set = {};
    Track = {};
    param.MAX_LAB = 0;
    RMN = [];
    Track_Save_Smooth = [];
    Track_Save = [];
    
    tic
    for fidx= 1:opt.FrameLength
        disp(['frame index: ',num2str(fidx)]);
        [frame, frameimg, frameimgrgb, f] = load_img(img_path, FrameSet, fidx);
        
%         figure(1)
%         set(gca,'Position',[0,0,1,1],'visible','off');
%         imshow(frame);
%         axis tight off;
%         hold on;
        
        
        [Detect, Detection_App, NofDet, det_bbox] =...
            detection_rearrange(observation, fidx, opt, frameimgrgb);   % arrange detections
        [SimMatrix, CostApp] = appearance_similarity_mot(Track, Detection_App, [], opt);
        [Track, LinkOn, new_set, new_set_hist, opt] = track_reset(Track,Detect,Detection_App,opt); % Reset track
        
        
        if(LinkOn==1 && ~isempty(new_set)) 
            
            % Gating 
            [prob_mat, pos_mat] = GatingTechnique(Track, new_set, SimMatrix);
            % SCEA
            [threshold_mat, assignment1, event_prob_set, joint_cost, event_set,Num_Event] = graph_event_aggregation2(Track, RMN, new_set, SimMatrix, prob_mat, frameimg, opt, param);
            [Track, associated_idx, used_track_idx, det_asso_idx] = update_scea_result(Track, assignment1, new_set, new_set_hist);
  
            % Recovery of missing objects
            [Track, used_track_idx, det_asso_idx] = recovery_missing_objects(Track, RMN, SimMatrix, used_track_idx, det_asso_idx, new_set, new_set_hist, param, opt);
        else
            % for a single object case
            [Cost2ndMat] = data_association_smm(Track, new_set, new_set_hist,  opt, param); % a case for single object trakcking
            [Track, used_track_idx, det_asso_idx] =...
                update_track_step_smm(Track, Cost2ndMat, new_set, new_set_hist, opt);
        end
        
        [new_set, new_set_hist] = remove_used_detection(new_set,new_set_hist,det_asso_idx); % Removing assigned detection
 
        % Track management
         [Track, NewT, Match_Init, Match_Init_Hist, Match_App_Set, Track_Save_Smooth, param, f] =...
             Track_management(Track, RMN, new_set, new_set_hist, used_track_idx, Match_Init,...
             Match_Init_Hist, Match_App_Set, Track_Save_Smooth, param, opt, f);
        % RMN management
        [RMN, Track] = RMN_management(RMN, Track, NewT, opt, param, f); 
        
        % demonstration result
%         track_result_demonstration2015(Track,f); % Showing Detections
%         drawnow;
%         hold off
    end
    t_time= toc;
    TimeSeq = [TimeSeq,[t_time;opt.FrameLength]];
    
    
    SaveResult;     % Save the result
end





