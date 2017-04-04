% loading image
function   [frame, frameimg, frameimgrgb, f] = load_img(img_path,FrameSet, fidx)

f = FrameSet(fidx);

data_path_temp = sprintf('%06d.png',f);

% disp(['frame: ',num2str(f)]);
frame = imread([img_path data_path_temp]);
frameimg = single(rgb2gray(imread([img_path data_path_temp])));
frameimgrgb = single((imread([img_path data_path_temp])));