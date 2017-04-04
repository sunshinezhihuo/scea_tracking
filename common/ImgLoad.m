% Ioad image
function [frame_img frame] = ImgLoad(dataPath, f)
data_path_temp = sprintf('%06d.png',f);
frame = imread([dataPath data_path_temp]);
if size(frame,3)==3
    frame_img	= rgb2gray(frame);
else
    frame_img	= frame;
end
frame_img = double(frame_img);