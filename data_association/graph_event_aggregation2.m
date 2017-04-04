function [threshold_mat, assignment1, event_prob_set, joint_cost, event_set,Num_Event] = graph_event_aggregation2(Track, RMN, new_set, fct_prob_d, kcf_prob_mat, frameimg, opt, param)

Num_Event = [];

abmigous_matrix = kcf_prob_mat > 0;
% N_amb = size(abmigous_matrix);
N_amb = sum(sum(abmigous_matrix));
Max_Case = 20; Max_Case_Obj = 10;
num_track = 0;
for i=1:length(Track)
    if Track{i}.not_detected == 0 
        num_track = num_track + 1;
    end
end
if N_amb <= Max_Case && num_track < Max_Case_Obj 
    
    
    [event_set, event_prob] = jpda_joint_event(kcf_prob_mat');

    
    % the maximum number of Tracks
    num_track = 0;
    for i=1:length(Track)
        if Track{i}.not_detected == 0
            num_track = num_track + 1;
        end
    end

    
    [event_prob_set]...
        = fusion_mot_costs_amb_mat_jpda_event(Track, RMN, event_set, new_set, fct_prob_d, abmigous_matrix, param, opt);
    
    event_prob_set_temp = event_prob_set;
    event_set_temp = event_set;
    event_set = [];
    event_prob_set = {};
    sum_joint_probabaility={};sum_probability=[];joint_probability=[];joint_cost = [];
    idx = 1;
    for i=1:size(event_set_temp,1)
        if ~isempty(event_prob_set_temp{i})
            event_set = [event_set;event_set_temp(i,:)];
            event_prob_set{idx} = event_prob_set_temp{i};
            joint_probability(idx) = prod(prod(event_prob_set_temp{i}));
            [jr,jc] = size(event_prob_set_temp{i});
            joint_cost(idx) = -log(joint_probability(idx))/(jr*jc);
            sum_probability(idx) = sum(sum(event_prob_set_temp{i}));
            sum_joint_probabaility{idx} = prod(event_prob_set_temp{i},2);
                            Num_Event(idx) = jr;

            idx = idx + 1;
        end
    end
    [~,maxidx_jp] = min(joint_cost);
    est_event = event_set(maxidx_jp,:);
%     disp(['estimated event: ', num2str(est_event)]);
    est_prob_event = prod(event_prob_set{maxidx_jp},1);
    est_prob_event_norm = size(event_prob_set{maxidx_jp},1);
    
    assignment1 = zeros(length(Track),size(new_set,2));
    threshold_mat =  -log(zeros(length(Track),size(new_set,2))+0.1^num_track);
    for i = 1:size(est_event,2)
        if(est_event(i)~=0)
            midx = est_event(i);
            threshold_mat(i,midx) = -log(est_prob_event(i))/est_prob_event_norm;
            if threshold_mat(i,midx)<opt.cost_threshold || opt.thresho_off
                assignment1(i,midx) = 1;
            end
        end
    end
    
    
else
     
    
    
    Iter1 = ceil(N_amb/Max_Case);
    Iter2 = ceil(num_track/Max_Case_Obj);
    Iter = max([Iter1, Iter2]);
%     [nc,cc] = size(kcf_prob_mat);
%     NN = ceil(nc/Iter); 
%     Set = [];
%     for i=1:Iter
%         Set(1,i) = 1 + NN*(i-1);
%         Set(2,i) = min(NN*i,nc);
%     end
    
        
%     idx = 1;
%     for i=Iter:-1:1
%         kcf_prob_mat_temp = zeros(length(Track),size(new_set,2));
%         kcf_prob_mat_temp(Set(1,i):Set(2,i),:) = kcf_prob_mat(Set(1,i):Set(2,i),:);
%         kcf_prob_mat_temp_set{i} = kcf_prob_mat_temp;
%         idx = idx + 1;
%     end

    
    Xc = [];Xlab=[];
    for i = 1:length(Track) 
        if  Track{i}.not_detected ==0
            lab1 = Track{i}.lab;  
            Xr = Track{i}.X(1:2);
            Xc = [Xc,Xr];
            Xlab = [Xlab, i];
        end
    end
    
    [C, ~] = vl_kmeans(Xc, Iter);
    NN = ceil(size(Xc,2)/Iter);
    Set_C = {};
    for i=1:size(C,2)
        Dist = sqrt(sum((repmat(C(:,i),1,size(Xc,2)) - Xc).^2,1));
       [aa, idx] = sort(Dist,'ascend');
       sidx = idx(1:min(NN,size(Xc,2)));
       Set_C{i} = Xlab(sidx);
       Xc(:,sidx) = [];
       Xlab(sidx) = [];
    end
 
    
    
    idx = 1;
    for i=Iter:-1:1
        kcf_prob_mat_temp = zeros(length(Track),size(new_set,2));
        kcf_prob_mat_temp(Set_C{i}(:),:) = kcf_prob_mat(Set_C{i}(:),:);
        kcf_prob_mat_temp_set{i} = kcf_prob_mat_temp;
        idx = idx + 1;
    end
    
    
    
    
    for j=1:Iter
        kcf_prob_mat = kcf_prob_mat_temp_set{j};
        tic
        [event_set, event_prob] = jpda_joint_event(kcf_prob_mat');
        toc
        
        abmigous_matrix = kcf_prob_mat > 0;
 
        % the maximum number of Tracks
        num_track = 0;
        for i=1:length(Track)
            if Track{i}.not_detected == 0
                num_track = num_track + 1;
            end
        end
        
    
          
        [event_prob_set]...
            = fusion_mot_costs_amb_mat_jpda_event(Track, RMN, event_set, new_set, fct_prob_d, abmigous_matrix, param, opt);
         
        
        event_prob_set_temp = event_prob_set;
        event_set_temp = event_set;
        event_set = [];
        event_prob_set = {};
        sum_joint_probabaility={};sum_probability=[];joint_probability=[];joint_cost = []; 
        idx = 1;
        for i=1:size(event_set_temp,1)
            if ~isempty(event_prob_set_temp{i})
                event_set = [event_set;event_set_temp(i,:)];
                event_prob_set{idx} = event_prob_set_temp{i};
                joint_probability(idx) = prod(prod(event_prob_set_temp{i}));
                [jr,jc] = size(event_prob_set_temp{i});
                joint_cost(idx) = -log(joint_probability(idx))/(jr*jc);
                sum_probability(idx) = sum(sum(event_prob_set_temp{i}));
                sum_joint_probabaility{idx} = prod(event_prob_set_temp{i},2);
                Num_Event(idx) = jr;
                idx = idx + 1;
            end
        end
        [~,maxidx_jp] = min(joint_cost);
        est_event = event_set(maxidx_jp,:);
%         disp(['estimated event: ', num2str(est_event)]);
        est_prob_event = prod(event_prob_set{maxidx_jp},1);
        est_prob_event_norm = size(event_prob_set{maxidx_jp},1);
        
        assignment1 = zeros(length(Track),size(new_set,2));
        threshold_mat =  -log(zeros(length(Track),size(new_set,2))+0.1^num_track);
        for i = 1:size(est_event,2)
            if(est_event(i)~=0)
                midx = est_event(i);
                threshold_mat(i,midx) = -log(est_prob_event(i))/est_prob_event_norm;
                if threshold_mat(i,midx)<opt.cost_threshold || opt.thresho_off
                    assignment1(i,midx) = 1;
                end
            end
        end 
        assignment{j} = assignment1; 
    end
    
    assignment1 = zeros(length(Track),size(new_set,2));
    for i=1:size(assignment,2)
        assignment1 = assignment1 + assignment{i};
    end 
    
    
end