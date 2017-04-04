function [Hypothe,Allev] = all_association(Ohmm,Allev,Hypoth,i,VM,clu_inten,PD)
%% When number of target > 2
%% YJH, jhyoon@gist.ac.kr
flag1 = 1; % indicating the event when the target 1 is not detected
M = Allev;
NM = 0;% No measurement associated
Allev = 0; % number of hypothesis
Nt = size(Hypoth(1).asso,2);
for j=1:size(Ohmm(i).new,1) % number of measurement  
    if(Ohmm(i).new(j,1)~=0) % if loop when the target is detected      
        for co1=1:M        
            check_m = 0;
            for co2=1:Nt%check the measurement
                if(VM(j) - Hypoth(co1).asso(1,co2)~=0)
                    check_m = check_m+1;
                end
            end
            if(check_m==Nt) % there is no j measurement coinciding
                Allev = Allev + 1;
                Hypothe(Allev).asso = [VM(j) Hypoth(co1).asso];
                Hypothe(Allev).prob = (Ohmm(i).new(j,1)/(1/clu_inten))*PD*Hypoth(co1).prob;
                % [j Hypoth(co1).asso]%%%%%%%%%%%%%%%%%%% for checking   
            end      
            if(flag1==1)% if the target is not detected
                Allev = Allev + 1;
                Hypothe(Allev).asso = [0 Hypoth(co1).asso];
                Hypothe(Allev).prob = (1-PD)*Hypoth(co1).prob;
                % [0 Hypoth(co1).asso]%%%%%%%%%%%%%%%%%%%% for checking
            end          
        end    
        flag1=0;       
    else
        NM = NM+1;
    end
    if(size(Ohmm(i).new,1) == NM)
        for co1=1:M  % number of hypothesis
            Allev = Allev + 1;
            Hypothe(Allev).asso = [0 Hypoth(co1).asso];
            Hypothe(Allev).prob = (1-PD)*Hypoth(co1).prob;
        end
    end  
end