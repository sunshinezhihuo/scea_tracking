%% When target is two
%% YJH, jhyoon@gist.ac.kr

function [Hypoth Allev] = two_col_association1(Ohm,VM,clu_inten,PD)

[M Tn] = size(Ohm);
flag1 = 1; % indicating the event when the target 1 is not detected
Allev = 1; % number of hypothesis
Hypoth(Allev).asso= [0 0];
Hypoth(Allev).prob = ((1-PD)^2);
NM = 0;
for i=1:M % number of measurement
    if(Ohm(i,1)~=0) %target 1
        Allev=Allev+1;
        Hypoth(Allev).asso = [VM(i) 0];
        Hypoth(Allev).prob = (Ohm(i,1)/(1/clu_inten))*PD*(1-PD)*(clu_inten);
        %         [i 0]%%%%%%%%%%%%%%%%%%%%%%%%%%%
        for j=1:M % number of measurement
            
            if(Ohm(j,2)~=0) %target 2
                if(flag1==1)
                    Allev=Allev+1;
                    Hypoth(Allev).asso = [0 VM(j)];
                    Hypoth(Allev).prob = (Ohm(j,2)/(1/clu_inten))*PD*(1-PD);
                    %                         [0 j]%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                if (i~=j)
                    Allev=Allev+1; %total event that all targets are detected.
                    Hypoth(Allev).asso = [VM(i) VM(j)];
                    Hypoth(Allev).prob = (Ohm(i,1)/(1/clu_inten))*(Ohm(j,2)/(1/clu_inten))*PD*PD;
                    %                     [i j]%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
            end
        end
        flag1 = 0;
    else
        NM = NM + 1;
    end
    if(NM==M)
        for j=1:M % number of measurement
            if(Ohm(j,2)~=0) %target 2
                
                Allev=Allev+1;
                Hypoth(Allev).asso = [0 VM(j)];
                Hypoth(Allev).prob = Ohm(j,2)*PD*(1-PD)/(1/clu_inten);
                %                         [0 j]%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end
        end
    end
end