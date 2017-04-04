% Parameters

% Sequence size
[hs, ws, dims] = size(frame);
opt.imgsz = [hs,ws,dims]; % height size, width size, dimension
opt.init_frames = 4;

% Parameters
opt.d_ratio  = [1, 1]; % detection ratio (for width/height)
opt.cost_threshold = 2.5;
opt.cost_threshold2 = 2.5;


opt.max_gap = 5;
opt.init_frames = 5; %%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt.smooth_step = 5;
opt.s_size = opt.s_size_temp;
opt.margin_u = 100;
opt.margin_v = 100;
opt.img_margin_u = 50;
opt.figure_save = 0;
opt.app_off = 1;
opt.thresho_off = 0;

filter_parameters; % load filter parameters (filter parameter  수정)
opt.app_type = 2; %%삭제
opt.app_on_lda = 0; %%삭제
opt.app_on = 0; %%삭제
opt.learn = 0.9;
opt.min_prob = 0.01;
opt.missing_prob =  0.4; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
opt.ov_const = 0.3;
opt.thresho_on = 1;
opt.sz_const = 0.7;

% Initialization
opt.FrameLength = size(FrameSet,2);