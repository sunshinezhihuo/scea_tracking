function [InitObj, InitObj_Hist, InitObj_App_Set, Match_Init, Match_Init_Hist, Match_App_Set] = matching_detections(new_set, new_set_hist, Match_Init, Match_Init_Hist, Match_App_Set, f, opt)


%     % Match_Init:  matched set in initialization step
%     % new_set:  new set of detections
InitObj = {}; % Object for initialization
InitObj_Hist = {}; % Object for initialization
InitObj_App_Set = {};


% Match_Init:  matched set in initialization step
% new_set:  new set of detections
idx = 0; idx_a = []; idx_c = [];
InitObj = {}; % Object for initialization
InitObj_Hist = {}; % Object for initialization
if(isempty(Match_Init) && ~isempty(new_set))
    for i=1:size(new_set,2)
%         if new_set(5,i)>0 % if a detection has a score
            idx = idx + 1;
            Match_Init{idx} = [new_set(1:4,i);f;idx];
            Match_Init_Hist{idx} = new_set_hist{i};
            Match_App_Set{idx} = new_set_hist{i};
%         end
    end
elseif(~isempty(Match_Init) && ~isempty(new_set))
    MS = size(Match_Init,2);  NS = size(new_set,2);
    for i=1:MS
        m_state = Match_Init{i}(1:4,end);
        Cost = 1000;  selidx = 0;
        for j=1:NS
            if(sum(idx_a==j)~=1)
%                 if new_set(5,j) > 0 % if a detection has a score
                    n_state = new_set(1:4,j);
                    thresh_dist = norm([n_state(3), n_state(3)]);
                    dist_cost = norm(m_state(1:2)-n_state(1:2));
                    if(dist_cost < thresh_dist*0.5)
                        h_ratio = abs(m_state(4) - n_state(4))/(m_state(4) + n_state(4));
                        if(h_ratio < 0.2)
                            if(Cost>h_ratio)
                                Cost = h_ratio;
                                selidx = j;
                                idx_c = [idx_c i];
                            end
                        end
                    end
%                 end
            end
        end
        if(selidx~=0)
            idx = idx + 1;
            idx_a = [idx_a selidx];
            % Associated
            add_set = [new_set(1:4,selidx);f;Match_Init{i}(5,end)];
            Match_Init{i} = [Match_Init{i},add_set];
            Match_Init_Hist{i} = new_set_hist{selidx}; % Histogram
            Match_App_Set{i} = [Match_App_Set{i},new_set_hist{selidx}];
        end
    end
    
    
    % Rearrange
    idx_c = unique(idx_c);
    match_set_temp ={};
    match_set_hist_temp = {};
    match_set_app_set_temp = {};

    idx_n=0;
    for i=1:MS
        if(sum(idx_c==i))
            idx_n = idx_n + 1;
            Size = size(Match_Init{i},2);
            match_set_temp{idx_n} = [Match_Init{i}(1:5,:);idx_n*ones(1,Size)];
            match_set_hist_temp{idx_n} = Match_Init_Hist{i};
            match_set_app_set_temp{idx_n} =  Match_App_Set{i};
        end
    end
    
    Match_Init = match_set_temp;
    Match_Init_Hist = match_set_hist_temp;
    Match_App_Set = match_set_app_set_temp;
    % Not associated
    for i=1:NS
        if(sum(idx_a==i)~=1)
%             if new_set(5,i)>0 % if a detection has a score
                idx = size(Match_Init,2) + 1;
                Match_Init{idx} = [new_set(1:4,i);f;idx];
                Match_Init_Hist{idx} = new_set_hist{i};
                Match_App_Set{idx} = new_set_hist{i};
%             end
        end
    end
else
    % there is no new set of detections
    % remove all
    Match_Init = {};
    Match_Init_Hist = {};
    Match_App_Set = {};
end


% Selecting the matched set for initialization
Match_Init_temp = {};
Match_Init_Hist_temp = {};
Match_Init_App_Set_temp = {};
if(~isempty(Match_Init))
    idx = 0; idx_n = 0;
    for i = 1:size(Match_Init,2)
        Size = size(Match_Init{i},2);
        if(Size >= opt.init_frames)
            idx = idx + 1;
            InitObj{idx} = Match_Init{i};
            InitObj_Hist{idx} = Match_Init_Hist{i};
            InitObj_App_Set{idx} = Match_App_Set{i};
        else
            idx_n = idx_n + 1;
            Match_Init_temp{idx_n} = [Match_Init{i}(1:5,:);idx_n*ones(1,Size)];
            Match_Init_Hist_temp{idx_n} = Match_Init_Hist{i};
            Match_Init_App_Set_temp{idx_n} = Match_App_Set{i};

        end
    end
    Match_Init = Match_Init_temp;
    Match_Init_Hist = Match_Init_Hist_temp;
    Match_App_Set = Match_Init_App_Set_temp;

end