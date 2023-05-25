clc;clear;
% 假设图像都存放在一个文件夹中，文件名为abd1587_s4_00001, abd1587_s4_00002, ...,abd1587_s4_00126
% 创建一个空的cell数组来存放读取的数据
data = cell(1,126);
% 使用for循环来依次读取每张图像的数据
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
% 读取二值图像

% M数组用来存储匙孔的6个特征数据，126为文件夹中图片个数
M=zeros(6,126);
% 像素宽度为1.9305微米，之后深度、半深宽等长度单位皆为微米
pixel_width=1.9305;

for j=1:126
img = data{j};
% 提取白色图案的边界坐标
[B,L] = bwboundaries(img,'noholes');
% 假设只有一个白色图案，取第一个边界
boundary = B{1};

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

%--------------------------------------

%--------------------------------------
% 求匙孔半深宽、面积

% 获取白色图案的连通区域和质心
stats = regionprops(img, 'Area', 'Centroid', 'BoundingBox');
centroids = cat(1, stats.Centroid);
% 找到面积最大的连通区域作为目标图案
max_area = 0;
max_index = 0;
for k = 1:length(stats)
    if stats(k).Area > max_area
        max_area = stats(k).Area;
        max_index = k;
    end
end
% 获取目标图案的外接矩形坐标和尺寸
bbox = stats(max_index).BoundingBox;
x_min = bbox(1);
y_min = bbox(2);
width = bbox(3);
height = bbox(4);
y_max=y_min+height;
x_max=x_min+width;
% 计算矩形的高度
height = y_max - y_min;
% 在图像上矩形的右下角用红色数字标注高度
% 计算白色图案在一半深度的地方的左右宽度
half_y = y_min + height / 2;
half_row = img(floor(half_y), :);
half_width = sum(half_row);
aspect_ratio=height/half_width;

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

%--------------------------------------
% M数组填充匙孔各特征数据
M(1,j)=pixel_width*pixel_width*area;
M(2,j)=metric;
M(3,j)=pixel_width*depth;
M(4,j)=aspect_ratio;
M(5,j)=pixel_width*half_width;
M(6,j)=angle_deg;

%--------------------------------------
% 利用各项数据构造训练集
data_AE = M'; 
data_P = zeros(126,1); % 调用函数获取现象向量
data_P(19,1)=1;
data_P(21,1)=1;
data_P(24,1)=1;
data_P(48,1)=1;
data_P(57,1)=1;
data_P(61,1)=1;

% 复制数组
data_C = data_P;

% 找到原始数组中为1的元素的索引
idx = find(data_P==1);

% 把上下各两个元素设为1
data_C(idx-2) = 1;
data_C(idx-1) = 1;
data_C(idx+1) = 1;
data_C(idx+2) = 1;

% 将data_AE和data_P按列合并成一个N*7的矩阵，假设命名为data_all
data_all = [data_AE,data_C]; % 使用方括号将两个矩阵按列拼接
save('keyhole_shu_ju.mat','data_all');

%--------------------------------------
end

%--------------------------------------
% 数据图像化

M1 = mean (M (1,:));
M2 = mean (M (2,:));
M3 = mean (M (3,:));
M4 = mean (M (4,:));
M5 = mean (M (5,:));
M6 = mean (M (6,:));

%index=find(data_C==1);
index=[19 21 24 48 57 61];

subplot(3,2,1)
plot(0:20:2500,M(1,:)) % 调用函数作图，选择第三行数据
hold on
% 对于每一个要圈出的数据点，计算它的纵坐标并画出一个散点

x = (index-ones(1,length(index)))* 20; % 横坐标乘以间隔得到真实值
y=ones(1,length(index));
for i=1:length(index)
 y(i)=M(1,index (i)); % 纵坐标从数组中取出
end
scatter (x,y,50,'ro'); % 用红色空心圆形散点表示，大小为50
clear x y;
hold on
plot (0:20:2500,M1*ones(1,126),'k--');
legend("面积","气泡出现","平均值")
title('面积/平方微米')
xlabel('时间/μs')
ylabel('面积/μm^2')

subplot(3,2,2)
plot(0:20:2500,M(2,:))
hold on;
x = (index-ones(1,length(index)))* 20; % 横坐标乘以间隔得到真实值
y=ones(1,length(index));
for i=1:length(index)
 y(i)=M(2,index (i)); % 纵坐标从数组中取出
end
scatter (x,y,50,'ro'); % 用红色空心圆形散点表示，大小为50
clear x y;
hold on
plot ([0 2500],[M2 M2],'k--');
hold off
legend("圆率","气泡出现","平均值")
title('圆率')
xlabel('时间/μs')
ylabel('圆率')

subplot(3,2,3)
plot(0:20:2500,M(3,:))
hold on;
x = (index-ones(1,length(index)))* 20; % 横坐标乘以间隔得到真实值
y=ones(1,length(index));
for i=1:length(index)
 y(i)=M(3,index (i)); % 纵坐标从数组中取出
end
scatter (x,y,50,'ro'); % 用红色空心圆形散点表示，大小为50
clear x y;
hold on
plot ([0 2500],[M3 M3],'k--');
hold off
legend("深度","气泡出现","平均值")
title('深度/微米')
xlabel('时间/μs')
ylabel('深度/μm')

subplot(3,2,4)
plot(0:20:2500,M(4,:))
hold on;
x = (index-ones(1,length(index)))* 20; % 横坐标乘以间隔得到真实值
y=ones(1,length(index));
for i=1:length(index)
 y(i)=M(4,index (i)); % 纵坐标从数组中取出
end
scatter (x,y,50,'ro'); % 用红色空心圆形散点表示，大小为50
clear x y;
hold on
plot ([0 2500],[M4 M4],'k--');
hold off
legend("纵横比","气泡出现","平均值")
title('纵横比')
xlabel('时间/μs')
ylabel('纵横比')

subplot(3,2,5)
plot(0:20:2500,M(5,:))
hold on;
x = (index-ones(1,length(index)))* 20; % 横坐标乘以间隔得到真实值
y=ones(1,length(index));
for i=1:length(index)
 y(i)=M(5,index (i)); % 纵坐标从数组中取出
end
scatter (x,y,50,'ro'); % 用红色空心圆形散点表示，大小为50
clear x y;
hold on
plot ([0 2500],[M5 M5],'k--');
hold off
legend("半深宽","气泡出现","平均值")
title('半深宽/微米')
xlabel('时间/μs')
ylabel('半深宽/μm')

subplot(3,2,6)
plot(0:20:2500,M(6,:))
hold on;
x = (index-ones(1,length(index)))* 20; % 横坐标乘以间隔得到真实值
y=ones(1,length(index));
for i=1:length(index)
 y(i)=M(6,index (i)); % 纵坐标从数组中取出
end
scatter (x,y,50,'ro'); % 用红色空心圆形散点表示，大小为50
clear x y;
hold on
plot ([0 2500],[M6 M6],'k--');
hold off
legend("前壁角","气泡出现","平均值")
title('前壁角')
xlabel('时间/μs')
ylabel('前壁角/°')