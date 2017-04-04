function [Detect, Detection_App, NofDet, det_bbox] = detection_rearrange(observation, f, opt, frameimgrgb)

A = 1:128*64;
AA = reshape(A,128,64);
Label_idx = [];
for i=1:10:64-15
    for j=1:10:128-15
        Temp = AA(j:j+15,i:i+15);
        Label_idx = [Label_idx,  Temp(:)];
    end
end

det_bbox = observation{f}.bbox;
det_hist = {};

for i=1:size(det_bbox,1)
        detb = det_bbox(i,:);
        detb(1) = detb(1) + detb(3)/2;
        detb(2) = detb(2) + detb(4)/2;
        detb(3) = detb(3)*1;
        detb(4) = detb(4)*1;
        detb(1) = detb(1) - detb(3)/2;
        detb(2) = detb(2) - detb(4)/2;
        d_bbox_rgb = (img_crop(detb,frameimgrgb, 128, 64));

        r_crop = d_bbox_rgb(:,:,1);  g_crop = d_bbox_rgb(:,:,2); b_crop = d_bbox_rgb(:,:,3);
        rtemp = r_crop(Label_idx);
        gtemp = g_crop(Label_idx);
        btemp = b_crop(Label_idx);
        
        d_bbox_hsv = rgb2hsv(d_bbox_rgb);
        h_crop = d_bbox_hsv(:,:,1);  s_crop = d_bbox_hsv(:,:,2); v_crop = d_bbox_hsv(:,:,3);
        htemp = h_crop(Label_idx);
        stemp = s_crop(Label_idx);
        vtemp = v_crop(Label_idx);
        
        d_r_feat = hist(rtemp,8)/(16*16);
        d_g_feat = hist(gtemp,8)/(16*16);
        d_b_feat = hist(btemp,8)/(16*16);
        d_h_feat = hist(htemp,8)/(16*16);
        d_s_feat = hist(stemp,8)/(16*16);
        d_v_feat = hist(vtemp,8)/(16*16);
        
        d_all_feat = [d_h_feat, d_s_feat, d_v_feat, d_r_feat, d_g_feat, d_b_feat];
        det_hist{i} = d_all_feat(:)/sum(d_all_feat(:));
end

Detect=[]; Idx = 0;
Detection_App = {}; % Input Detection Appearance (HSV histogram)
NofDet = size(det_bbox,1);
for i=1:NofDet
    if( det_bbox(i,1)>-1*opt.img_margin_u && det_bbox(i,2)>-opt.img_margin_u && fix(det_bbox(i,1) + det_bbox(i,3))<opt.imgsz(2)+opt.img_margin_u && fix(det_bbox(i,2) + det_bbox(i,4))<opt.imgsz(1)+opt.img_margin_u)
        Size_H = det_bbox(i,4)*opt.d_ratio(2);
        if(Size_H >= opt.s_size(1) && Size_H <= opt.s_size(3))
            Idx = Idx + 1;
            Detect = [Detect; det_bbox(i,:)]; % Detection Input
            Detection_App{Idx} = det_hist{i};
        end
    end
end
NofDet = Idx; % Number of detections