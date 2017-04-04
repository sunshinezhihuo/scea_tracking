% plot detections
function plot_detections(det_bbox)


for i=1:size(det_bbox,1)
    left_u = det_bbox(i,1:2); % Left up             % det_bbox: [center u, v, width, height]
    right_b = det_bbox(i,1:2)+det_bbox(i,3:4);% Right bottom
    bbox_point = [left_u(1),right_b(1),right_b(1),left_u(1),left_u(1)
        left_u(2),left_u(2),right_b(2),right_b(2),left_u(2)];
    line(bbox_point(1,:), bbox_point(2,:), 'Color','b', 'LineWidth',2.5);
end