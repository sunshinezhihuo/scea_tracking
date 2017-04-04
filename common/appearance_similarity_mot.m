% Appearance similarity
function [SimMatrix, CostApp] = appearance_similarity_mot(Track, Detection_App, svmStruct, opt)

SimMatrix = [];
CostApp = [];
for i=1:length(Track)
    for j =1:length(Detection_App)
        ref_hist = Track{i}.Appearance/sum(Track{i}.Appearance(:));
        target_hist = Detection_App{j}(:,1)/sum(Detection_App{j}(:,1));
        
        app_prob = sum(sqrt(ref_hist.*target_hist));
        SimMatrix(i,j) = app_prob;
    end
end
end