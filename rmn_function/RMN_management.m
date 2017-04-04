function [RMN, Track] = RMN_management(RMN, Track, NewT, opt, param, f)

if(~isempty(RMN) && ~isempty(Track))
    [RMN] = rmn_observation(Track, RMN); % RMN observation
end
if(isempty(RMN) && ~isempty(Track) && ~isempty(NewT))
    if(length(Track)>1)
        [RMN, Track] = rmn_initialization(Track, param, f); % RMN initialization
    end
elseif(~isempty(RMN) && ~isempty(Track))
    [RMN, Track] = rmn_update(Track, RMN, NewT, opt, param, f); % RMN Update
    if(~isempty(NewT)) % if NewTs exist
        [RMN, Track] = adding_new_rmn(Track, NewT, RMN, opt, param, f);
    end
end
for i=1:length(Track)
    Track{i}.link = unique(Track{i}.link); % setting link between objects
end

if(~isempty(Track))
    [Track] = rmn_prediction(Track, RMN, param); % Prediction Based on RMN
end