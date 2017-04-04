%% Save results

num_frame = size(FrameSet,2);
num_obj = size(Track_Save_Smooth,2);
stateInfo = [];

stateInfo.F = FrameSet(end);
stateInfo.X = zeros(num_frame,num_obj);
stateInfo.Y = zeros(num_frame,num_obj);
stateInfo.targetsExist = zeros(num_obj,2);
stateInfo.N = size(Track_Save_Smooth,2);
stateInfo.tiToInd = zeros(num_frame,num_obj);
stateInfo.stateVec = [];
stateInfo.frameNums = 1:length(FrameSet);
stateInfo.Xgp = zeros(num_frame,num_obj);
stateInfo.Ygp = zeros(num_frame,num_obj);
stateInfo.Xi = zeros(num_frame,num_obj);
stateInfo.Yi = zeros(num_frame,num_obj);
stateInfo.H = zeros(num_frame,num_obj);
stateInfo.W = zeros(num_frame,num_obj);

for f = 1:num_frame
    ObjectSetFrame{f} = [];    
end
for i = 1:num_obj
    ColorSet{i} = rand(1,3);
end


idx = 1;
for i = 1:size(Track_Save_Smooth,2)
    Obj = Track_Save_Smooth{i};
    
    for o=1:size(Obj,2)
        State = Obj(:,o);
        if(FrameSet(1)==0)
            frame = State(5) + 1;
        else
            frame = State(5);
            frame = frame - FrameSet(1) + 1;
        end
        State = State(1:4);
        
        ObjectSetFrame{frame} = [ObjectSetFrame{frame}, [State(:);i]]; 
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


res_file_name = [ Title, '.txt' ] ;                 
Rarray = [];
for i=1:size(stateInfo.X,1); % frame

    frame = FrameSet(i); 
    conf = -1;
    x = -1;
    y = -1;
    z = -1;

    for j=1:size(stateInfo.X,2)
        if(stateInfo.X(i,j)~=0)
            id = j;
            bb_left = fix(stateInfo.X(i,j) - stateInfo.W(i,j)/2);
            bb_top = fix(stateInfo.Y(i,j) - stateInfo.H(i,j)/2);
            bb_width = fix(stateInfo.W(i,j));
            bb_height = fix(stateInfo.H(i,j));

            Rarray = [Rarray; ...
                      frame, id, bb_left, bb_top, bb_width, bb_height,...
                      conf, x, y, z ];
        end
    end    
end  
mkdir(res_path);
csvwrite([res_path, res_file_name], Rarray);