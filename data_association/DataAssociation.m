%% reference : Development of Multi-target Tracking System for Automotive Radar in Road Environment pp.51 - pp.53
%% YJH, jhyoon@gist.ac.kr
function [Hypoth,Allev] = DataAssociation(OHm,VM,clu_inten,PD)
%OHm : validation matrix, zero row removed
%VM : validated measurement index
%Allev : number of all possible events
%Hypoth : Joint Event

[M Tn] = size(OHm);

%Divide validation matrix
for i=1:Tn-1
    if(i==Tn-1)
        Ohmm(Tn-i).new = OHm(:,i:end);
    else
        Ohmm(Tn-i).new = OHm(:,i);
    end
end

Ohm_new = Ohmm(1).new; %inital matrix
[Hypoth Allev] = two_col_association1(Ohm_new,VM,clu_inten,PD);% first step: two last targets


if(Tn>2)
    for i=2:Tn-1
        [Hypoth,Allev] = all_association(Ohmm,Allev,Hypoth,i,VM,clu_inten,PD);
    end
end