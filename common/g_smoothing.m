function [data_smoothed] = g_smoothing(data, Gw, L)


data_smoothed = conv (data, Gw, 'same');






c_v = ceil(L/2);
for i=1:c_v-1
    g = Gw(c_v-i+1:L);
    d = data(1:length(g));
    g = g/sum(g);
    
    data_smoothed(i) = sum(d.*g);
end

d_size = size(data_smoothed,2);
for i=1:c_v-1
    g = Gw(c_v:c_v+i-1);
    d = data(d_size-length(g)+1:d_size); 
    g = g/sum(g);
    
    data_smoothed(d_size-i+1) = sum(d.*g);
end