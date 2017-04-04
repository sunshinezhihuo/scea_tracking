function save_figure_jpg(root_path,Title,f)

hold off
data_path_temp = sprintf('%05d.jpg',f);
Path_Result = [root_path,'\',Title,'\', data_path_temp];
imwrite(frame2im(getframe(gcf)),Path_Result);