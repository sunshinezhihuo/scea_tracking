% JPDA joint event generation
% output:
% Row: event
% Col: tracks
% element: measurement index

function [event_set, prob_set] = jpda_joint_event(OHm)

[M Tn] = size(OHm);
VM = 1:M;
%Divide validation matrix
for i=1:Tn-1
    if(i==Tn-1)
        Ohmm(Tn-i).new = OHm(:,i:end);
    else
        Ohmm(Tn-i).new = OHm(:,i);
    end
end

Ohm_new = Ohmm(1).new; %inital matrix
[Hypoth Allev] = two_col_association1(Ohm_new,VM,1,0.9);% first step: two last targets


if(Tn>2)
    for i=2:Tn-1
        [Hypoth,Allev] = all_association(Ohmm,Allev,Hypoth,i,VM,1,0.9);
    end
end


event_set = zeros(size(Hypoth,2),size(Hypoth(1).asso,2));
for i = 1:size(Hypoth,2)
    event_set(i,:) = [Hypoth(i).asso];
end

prob_set = zeros(size(Hypoth,2),1);
for i = 1:size(Hypoth,2)
    prob_set(i,:)  = [-log(prod(Hypoth(i).prob))/size(Hypoth(1).asso,2)];
end