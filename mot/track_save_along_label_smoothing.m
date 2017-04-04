% Save Track along the lable
function  [Track_Save] = track_save_along_label_smoothing(Track_Save,Track,fidx,FrameLength, L, Sg) % L : length, Sg: sigma


% x = linspace(-L / 2, L / 2, L);
% Gw = exp(-x .^ 2 / (2 * Sg ^ 2));
% Gw = Gw / sum (Gw); % normalize

if(~isempty(Track))
    for i=1:length(Track)
        if(Track{i}.survival == 0)
            WinL = min(size(Track{i}.states,2),L);
            
            x = linspace(-WinL / 2, WinL / 2, WinL);
            Gw = exp(-x .^ 2 / (2 * Sg ^ 2));
            Gw = Gw / sum (Gw); % normalize


            Lab = Track{i}.lab;
            posx = Track{i}.states(1,:); % position x
            [smooth_x] = g_smoothing(posx, Gw, WinL);
            posy = Track{i}.states(2,:); % position y
            [smooth_y] = g_smoothing(posy, Gw, WinL);
            w = Track{i}.states(3,:); % w
            [smooth_w] = g_smoothing(w, Gw, WinL);
            h = Track{i}.states(4,:); % h
            [smooth_h] = g_smoothing(h, Gw, WinL);
            
            
            Track{i}.states = [smooth_x;smooth_y;smooth_w;smooth_h];
            
            
            Track_Save{Lab} = [Track{i}.states(1:4,:);Track{i}.frame];
        end
    end
end


if(fidx==FrameLength)
    for i=1:length(Track)
        
        WinL = min(size(Track{i}.states,2),L);
        
        x = linspace(-WinL / 2, WinL / 2, WinL);
        Gw = exp(-x .^ 2 / (2 * Sg ^ 2));
        Gw = Gw / sum (Gw); % normalize
        
        
        Lab = Track{i}.lab;
        
        posx = Track{i}.states(1,:); % position x
        [smooth_x] = g_smoothing(posx, Gw, WinL);
        posy = Track{i}.states(2,:); % position y
        [smooth_y] = g_smoothing(posy, Gw, WinL);
        w = Track{i}.states(3,:); % w
        [smooth_w] = g_smoothing(w, Gw, WinL);
        h = Track{i}.states(4,:); % h
        [smooth_h] = g_smoothing(h, Gw, WinL);
        
        
        Track{i}.states = [smooth_x;smooth_y;smooth_w;smooth_h];
        
        
        
        
        Track_Save{Lab} = [Track{i}.states(1:4,:);Track{i}.frame];
    end
end