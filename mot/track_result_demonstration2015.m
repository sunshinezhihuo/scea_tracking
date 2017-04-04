%% Show track result

function track_result_demonstration2015(Track,f)

if(~isempty(Track))
    NofTrack = length(Track);
    for i=1:NofTrack
        if(~isempty(Track{i}.detection))
            track_s = Track{i}.states(:,end);
            track_f = Track{i}.frame(end);
            lab = Track{i}.lab;
            GP = Track{i}.graph;
            if(track_f==f)
                LeftU = track_s(1:2)-track_s(3:4)/2; % Left up
                RigthB = track_s(1:2)+track_s(3:4)/2;% Right bottom
                dcorners = [LeftU(1),RigthB(1),RigthB(1),LeftU(1),LeftU(1)
                    LeftU(2),LeftU(2),RigthB(2),RigthB(2),LeftU(2)];
                line(dcorners(1,:), dcorners(2,:), 'Color','r', 'LineWidth',2.5);
                
                CenX = track_s(1); CenY = track_s(2)-track_s(4)/2;
                text(CenX, CenY-18,sprintf('%d',lab),'Color','r','Fontsize',15,'HorizontalAlignment','Center','FontWeight','bold');
            
%                 for q=1:size(GP,2)
%                     idx = GP(q);
%                     track_s_n = Track{idx}.states(:,end);
%                     links = [track_s(1),track_s_n(1);track_s(2),track_s_n(2)];
%                     line(links(1,:), links(2,:), 'Color',[1 0.7 0], 'LineWidth',1.5);
%                 end
            
            end
        end
    end
end