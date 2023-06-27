## 使用U-net作为模型主体用于训练和预测匙孔图像
---

### 目录
1. [背景介绍 Background Introduction](#背景介绍)
2. [所需环境 Environment](#所需环境)
3. [库打包步骤 How to pip ](#库打包步骤)
4. [训练步骤 How to train](#训练步骤)
5. [预测步骤 How to predict](#预测步骤)
6. [评估步骤 miou](#评估步骤)
7. [图形窗口 graphic window](#图形窗口)
8. [参考 Reference](#参考)


### 背景介绍
金属激光增材制造技术的难点在于微观结构的控制和微观缺陷的去除，由于缺乏底层数据和基本理论的支撑，在这方面的问题目前仍难以解决。为了能够从根本上探索微观结构和缺陷的演变，目前已有原位实时监测技术如同步辐射X射线高速成像技术等的发展为其提供数据上的支持。然而，由于X射线高速成像技术的亚纳秒级分辨率和高数据采集帧频（约50kHz), **1s可获得50000张X射线照片**，一方面**庞大的数据量**需要耗费大量的人力，效率非常有限；另一方面由于时间分辨率的限制，**部分数据存在模糊、重影**等即便是人眼也无法准确判断的情况，导致数据的精度水平较低。 

其中，匙孔作为一个特殊的结构，对微观缺陷和结构的演变有着重要的参考意义。在激光束的作用下，金属粉末层表面由于高温产生熔池，一方面，**匙孔作为熔池的内边界，是热源与熔池进行热量传递的媒介，能够吸收和反射激光束能量，匙孔的结构影响着熔池的热量吸收率**；另一方面**匙孔结构的不规则导致表面温度梯度，熔池内部易产生马兰戈尼对流**；除此以外，**匙孔的结构也影响着表面颗粒飞溅、液滴飞溅和底部匙孔气泡的产生**。

本项目名称为 **《金属激光增材制造同步辐射X射线高速成像中匙孔形貌的识别与分析》** 。针对匙孔图像部分模糊且数据量大和目前数据提取的局限性，引入了机器学习模型**U-net**，通过充分的数据集进行训练并对X射线照片进行预测，实现了较高的识别精度。最终实现效果能够对单张图片、视频、图片集合进行预测并输出，极大的提高了效率和精度。 

另外，通过利用模型预测的结果，运用 **图像处理技术** ，对应的匙孔形貌数据能够被快速准确的提取出来，包括 **深度、面积、倾斜角、半深宽、纵横比、圆率** 等，这些数据综合可以判断匙孔的状态，对于熔池的形状、温度分布状态、热量吸收率以及制品的微观缺陷、结构的调控具有极大的参考价值。 

### 所需环境
本项目需要通过建立虚拟环境，其中环境要求可参考**requirements.txt**中的具体内容，这里给出基本的环境要求。
```python
scipy==1.10.0

numpy==1.24.2

matplotlib==3.7.1

opencv_python==4.1.2.30

oonx==1.13.0

torch==1.7.1+cu110

torchvision==0.8.2+cu110

tqdm==4.64.1

pillow==9.4.0

h5py==3.8.0

PyQt5==5.15.7
```
 
### 库打包步骤
参考**csdn**[博客](http://t.csdn.cn/qcTpV)
文章里给出了详细的构建包和上传pypq官网的过程。


### 训练步骤
#### 一、制作数据集
1. 运行`cmd` ，激活虚拟环境，安装labelme库，执行命令`pip install labelme`
2. 安装完成后，运行labelme，命令为`labelme`，将要识别的图片进行标注。
  

#### 二、训练自己的数据集
1. 本文使用VOC格式进行训练。
2. 训练前将标签文件放在VOCdevkit文件夹下的VOC2007文件夹下的SegmentationClass中。
3. 训练前将图片文件放在VOCdevkit文件夹下的VOC2007文件夹下的JPEGImages中。
4. 在训练前利用voc_annotation.py文件生成对应的txt。
5. 注意修改train.py的num_classes为分类个数+1。
6. 运行train.py即可开始训练。 

### 预测步骤 
1. 按照训练步骤训练。    
2. 在unet.py文件里面，在如下部分修改model_path、backbone和num_classes使其对应训练好的文件；**model_path对应logs文件夹下面的权值文件**。    
```python
_defaults = {
    #-------------------------------------------------------------------#
    #   model_path指向logs文件夹下的权值文件
    #   训练好后logs文件夹下存在多个权值文件，选择验证集损失较低的即可。
    #   验证集损失较低不代表miou较高，仅代表该权值在验证集上泛化性能较好。
    #-------------------------------------------------------------------#
    "model_path"    : 'model_data/unet_vgg_voc.pth',
    #--------------------------------#
    #   所需要区分的类的个数+1
    #--------------------------------#
    "num_classes"   : 2,#这里是匙孔+背景
    #--------------------------------#
    #   所使用的的主干网络：vgg、resnet50   
    #--------------------------------#
    "backbone"      : "vgg",
    #--------------------------------#
    #   输入图片的大小
    #--------------------------------#
    "input_shape"   : [512, 512],
    #--------------------------------#
    #   blend参数用于控制是否
    #   让识别结果和原图混合
    #--------------------------------#
    "blend"         : True,
    #--------------------------------#
    #   是否使用Cuda
    #   没有GPU可以设置成False
    #--------------------------------#
    "cuda"          : True,
}
```
3. 运行predict.py，输入    
```python
img/street.jpg
```   
4. 在predict.py里面进行设置可以进行fps测试和video视频检测。    

### 评估步骤
1、设置get_miou.py里面的num_classes为预测的类的数量加1。  
2、设置get_miou.py里面的name_classes为需要去区分的类别。  
3、运行get_miou.py即可获得miou大小。  

### 图形窗口
运行__main__.py可得匙孔识别的图形窗口。

## 参考
https://github.com/ggyyzm/pytorch_segmentation  
https://github.com/bonlime/keras-deeplab-v3-plus
