function [Track] = rmn_prediction(Track, RMN, param)

% Node motion

for i=1:length(Track)
    State = Track{i}.X;
    P = Track{i}.P;
    [State,P] = KF_prediction_iccv2(State, P, param.F, param.Q, param.G); % Prediction
    Track{i}.Xp = State;
    Track{i}.Pp = P;
end


% relative motion from neighbor objects
for i=1:length(Track)
    GP = Track{i}.graph; % node index to i-th Track
    s_node = Track{i}.Xp; % predicted state of the node
    graph_x_prev = Track{i}.graph_x;
    
    %     Track{i}.graph = [];
    Track{i}.graph_x = [];
    Track{i}.graph_x = s_node(1:6); TN = s_node(3:4); WH = s_node(5:6);
    lab1 = Track{i}.lab; % the node target label
    graph_weight_idx = i;
    for j=1:size(GP,2) % Insert states from relationa function
        idx = GP(j); % the neighbor node index
        state_o = Track{idx}.Xp; % the neighbor node state
        lab2 = Track{idx}.lab; % the neighbor node target label
        Rtrans = param.Fr*RMN(lab1,lab2).state.X; % relational translation
        trans_state = state_o(1:4)+ Rtrans(1:4);
        T_state = [trans_state; WH]; % Transfered state
        % is it within the image ?
        Track{i}.graph_x = [Track{i}.graph_x, T_state];
        graph_weight_idx = [graph_weight_idx, idx];
    end
    
    % Check link
    graph_weight_idx_prev = Track{i}.graph_weight;
    not_equal = 0;
    
    if(size(graph_weight_idx_prev,2) ~= size(graph_weight_idx,2) || isempty(graph_weight_idx_prev))
        not_equal = 1;
    else
        for j=1:size(graph_weight_idx_prev,2)
            if(graph_weight_idx_prev(2,j)~=graph_weight_idx(j))
                not_equal = 1;
            end
        end
    end
    
    
    graph_weight_val = Track{i}.graph_weight;
    if(isempty(graph_weight_val) || not_equal==1)
        % Graph weight
        Track{i}.graph_weight = [1/size(graph_weight_idx,2)*ones(1,size(graph_weight_idx,2));graph_weight_idx];
    else
        Track{i}.graph_weight =  [graph_weight_val(1,:);graph_weight_idx];
    end
    
    
end

 