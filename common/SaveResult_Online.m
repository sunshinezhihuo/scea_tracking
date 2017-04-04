%% Save results



num_frame = size(FrameSet,2);
num_obj = size(Track_Save_online,2);
stateInfo = [];

stateInfo.F = FrameSet(end);
stateInfo.X = zeros(num_frame,num_obj);
stateInfo.Y = zeros(num_frame,num_obj);
stateInfo.targetsExist = zeros(num_obj,2);
stateInfo.N = size(Track_Save_online,2);
stateInfo.tiToInd = zeros(num_frame,num_obj);
stateInfo.stateVec = [];
stateInfo.frameNums = 1:length(FrameSet);
stateInfo.Xgp = zeros(num_frame,num_obj);
stateInfo.Ygp = zeros(num_frame,num_obj);
stateInfo.Xi = zeros(num_frame,num_obj);
stateInfo.Yi = zeros(num_frame,num_obj);
stateInfo.H = zeros(num_frame,num_obj);
stateInfo.W = zeros(num_frame,num_obj);

idx = 1;
for i = 1:size(Track_Save_online,2)
    Obj = Track_Save_online{i};
    
    for o=1:size(Obj,2)
        State = Obj(:,o);
        if(FrameSet(1)==0)
            frame = State(5) + 1;
        else
            frame = State(5);
            frame = frame - FrameSet(1) + 1;
        end
        State = State(1:4);
        
        
        stateInfo.tiToInd(frame,i) =  idx;
        stateInfo.stateVec = [stateInfo.stateVec;State(1)];
        stateInfo.X(frame,i) = State(1);
        stateInfo.Y(frame,i) = State(2);
        
        stateInfo.Xgp(frame,i) =  State(1);
        stateInfo.Ygp(frame,i) =  State(2);
        stateInfo.Xi(frame,i) =  State(1);
        stateInfo.Yi(frame,i) =  State(2);
        stateInfo.H(frame,i) =  State(4);
        stateInfo.W(frame,i) =  State(3);
        idx = idx + 2;
    end
end

save([res_path, '\', res_mat_name_online],'stateInfo');

% fid = fopen(file_name,'w');
fid = fopen([res_path, '\', res_txt_name_online],'w');
for i=1:size(stateInfo.X,2);
    
    ID = i-1;
    Type = 'Human';
    Trunc = 0;
    Occ = 0;
    Alpha = 0.00;
    H = 1;
    W = 1;
    L = 3;
    t1 = -1000;
    t2 = -1000;
    t3 = -1000;
    Ry = -10;
    Score = 1.00;
    
    for j=1:size(stateInfo.X,1)
        if(stateInfo.X(j,i)~=0)
            
            Frame = FrameSet(j);
            X1 = max(fix(stateInfo.X(j,i) - stateInfo.W(j,i)/2),0);
            Y1 = max(fix(stateInfo.Y(j,i) - stateInfo.H(j,i)/2),0);
            X2 = min(fix(stateInfo.X(j,i) + stateInfo.W(j,i)/2),ws);
            Y2 = min(fix(stateInfo.Y(j,i) + stateInfo.H(j,i)/2),hs);
            
            
            Rarray = [num2str(Frame),' ', num2str(ID), ' ',Type,' ', num2str(Trunc),' ',...
                num2str(Occ),' ', num2str(Alpha),' ', num2str(X1),' ', num2str(Y1),' ', num2str(X2),' ', num2str(Y2),' ', num2str(H),' ', num2str(W),' ', num2str(L),' ', num2str(t1),' ',...
                num2str(t2),' ', num2str(t3),' ', num2str(Ry),' ', num2str(Score)];
            fprintf(fid, '%s\n',Rarray);
            
        end
    end
    
end

fclose(fid);