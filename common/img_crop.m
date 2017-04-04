function d_bbox = img_crop(ss,img, hei, wid)

% if size(img,3) <2
    ss = fix(ss);
    A = max(ss(2),1);
    B = min(ss(2)+ss(4),size(img,1));
    C = max(ss(1),1);
    D = min(ss(1)+ss(3),size(img,2));
    
    
    
    d_bbox = imresize(img(A:B, C:D,:),[hei wid]);
    
% else
%     ss = fix(ss);
%     A = max(ss(2),1);
%     B = min(ss(2)+ss(4),size(img,1));
%     C = max(ss(1),1);
%     D = min(ss(1)+ss(3),size(img,2));
%     
%     
%     
%     d_bbox1 = imresize(img(A:B, C:D,1),[hei wid]);
%     d_bbox2 = imresize(img(A:B, C:D,2),[hei wid]);
%     d_bbox3 = imresize(img(A:B, C:D,3),[hei wid]);
% 
%     d_bbox = cat(3,d_bbox1,d_bbox2,d_bbox3);
% end