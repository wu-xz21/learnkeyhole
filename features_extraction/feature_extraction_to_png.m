clc;clear;close;
% 读取二值图像
data = cell(1,126);
for i = 1:126
    % 使用dir函数来获取文件夹中的所有文件信息
    files = dir('C:\Users\19877\Documents\Tencent Files\1987760449\FileRecv\University\MATLAB\png2\*png');
    % 使用regexp函数来匹配文件名中的数字，并将结果转换为数值
    num = str2double(regexp(files(i).name,'\d+','match'));
    % 使用sprintf函数来生成图像的文件名，其中num(3)是文件名中的第三个数字
    filename = fullfile('C:\Users\19877\Documents\Tencent Files\1987760449\FileRecv\University\MATLAB\png2',sprintf('abd1587_s1-%05d.png',num(3)));
    % 使用imread函数来读取图像，并将结果存入data数组中
    data{i} = imread(filename);
    % 如果需要，可以在这里对data{i}进行其他操作，比如提取A、B、C、D四种数据
end

% for j=1:126
j=15;
img = data{j};
% img = imread('C:\Users\19877\Desktop\s1_images\abd1587_s1-00075.png');
% % 提取原图片的编号，假设编号是文件名中最后一个'-'和'.'之间的数字
% filename = 'C:\Users\19877\Desktop\s1_images\abd1587_s1-00075.png';
% index1 = find(filename == '-', 1, 'last'); % 找到最后一个'-'的位置
% index2 = find(filename == '.', 1, 'last'); % 找到最后一个'.'的位置
% num = str2double(filename(index1+1:index2-1)); % 提取编号并转换为数值
% 计算时间，假设时间是(编号-1)*20微秒
time = (j-1)*20;
% 将时间转换为字符串，添加单位
time_str = [num2str(time),' μs'];

fig = figure

% 提取白色图案的边界坐标
[B,L] = bwboundaries(img,'noholes');
% 假设只有一个白色图案，取第一个边界
boundary = B{1};
% 绘制原始图像和边界
imshow(img);
hold on;
plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2);

%--------------------------------------
% 求前壁角、深度、宽度

% 求匙孔的深度和宽度
depth = max(boundary(:,1)) - min(boundary(:,1));
width1 = max(boundary(:,2)) - min(boundary(:,2));
% 找到锁孔顶部最右像素的坐标
top_right = boundary(find(boundary(:,2) == max(boundary(:,2)), 1), :);
% 找到锁孔3/4深度处最右像素的坐标
candidates = find(abs(boundary(:,1) - (min(boundary(:,1)) + 0.75 * depth)) <= 2);
bottom_right = boundary(max(candidates), :);
% 计算前壁角的弧度值
angle_rad = atan((top_right(1) - bottom_right(1)) / (top_right(2) - bottom_right(2)));
% 转换为角度值
angle_deg = abs(angle_rad * 180 / pi);
% 绘制前壁角对应的直线
x = [top_right(2), bottom_right(2)];
y = [top_right(1), bottom_right(1)];
plot(x, y, 'r', 'LineWidth', 2);
% 在锁孔右上角标出前壁角的大小
text(top_right(2) + 15, top_right(1) - 10, ['前壁角:' num2str(angle_deg) '°'], 'Color', 'red', 'FontSize', 12);

%--------------------------------------

%--------------------------------------
% 求匙孔半深宽、面积

% 获取白色图案的连通区域和质心
stats = regionprops(img, 'Area', 'Centroid', 'BoundingBox');
centroids = cat(1, stats.Centroid);
% 找到面积最大的连通区域作为目标图案
max_area = 0;
max_index = 0;
for i = 1:length(stats)
    if stats(i).Area > max_area
        max_area = stats(i).Area;
        max_index = i;
    end
end
% 获取目标图案的外接矩形坐标和尺寸
bbox = stats(max_index).BoundingBox;
x_min = bbox(1);
y_min = bbox(2);
width = bbox(3);
height = bbox(4);
% 在原图像上绘制红色实线矩形框
rectangle('Position', [x_min y_min width height], 'EdgeColor', 'r', 'LineWidth', 2);
hold on;
y_max=y_min+height;
x_max=x_min+width;
% 计算矩形的高度
height = y_max - y_min;
% 在图像上矩形的右下角用红色数字标注高度
% 计算白色图案在一半深度的地方的左右宽度
half_y = y_min + height / 2;
half_row = img(floor(half_y), :);
half_width = sum(half_row);
aspect_ratio=height/width;

total = bwarea(~img); % 计算所有 on 像素的面积
back = bwarea(img); % 计算所有 off 像素的面积
area = back; % 计算白色图案的面积

%--------------------------------------

%--------------------------------------
% 求圆率

BW2 = bwperim (img);
% 计算边缘的长度，即周长
stats = regionprops (BW2, 'Perimeter');
perimeter = stats.Perimeter;
metric=4*pi*area/perimeter^2;

%--------------------------------------
title('匙孔图象特征')
% 在图像上矩形的右下角用红色文字标注匙孔深度和匙孔半深宽
text(x_max+15, y_max-30, ['面积:', num2str(area), sprintf('\n圆率:%s\n', num2str(metric)),'深度:', num2str(depth), ...
    sprintf('\n纵横比:%s\n', num2str(aspect_ratio)),'半深宽:', num2str(half_width)], 'Color', 'r', 'FontSize', 12);
text(10, size(img,1)-20, 'Scale:100\mum', 'FontName', 'Arial', 'FontSize', 12, 'Color', 'white');
% 添加比例尺线条标注，假设在文本右边，长度为 51.8 像素点，宽度为 2 像素点，颜色为白色
line([100, 100+51.8], [size(img,1)-18, size(img,1)-18], 'Color', 'white', 'LineWidth', 2);
% 添加时间文本标注，假设在右下角，字体为 Arial，大小为 12，颜色为白色
text(size(img,2)-80, size(img,1)-20, time_str, 'FontName', 'Arial', 'FontSize', 12, 'Color', 'white');
figure
% 生成一个带有循环次数的文件名
%   filename1 = sprintf("C:\Users\19877\Documents\Tencent Files\1987760449\FileRecv\University\MATLAB\s1_images_handled\s1-%05d.png", j);
  filename2 = fullfile('C:\Users\19877\Documents\Tencent Files\1987760449\FileRecv\University\MATLAB\s1_images_handled',sprintf('s1-%05d.png',j));
  % 将图形对象保存为PNG文件
  saveas(fig, filename2, 'png')
% end


