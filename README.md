## 使用U-net作为模型主体用于训练和预测匙孔图像
---

### 目录
1. [仓库更新 Top News](#Topnews)
2. [相关仓库 Related code](#相关仓库)
3. [性能情况 Performance](#性能情况)
4. [所需环境 Environment](#所需环境)
5. [训练步骤 How2train](#训练步骤)
6. [预测步骤 How2predict](#预测步骤)
7. [评估步骤 miou](#评估步骤)
8. [参考资料 Reference](#Reference)

## Top News
**`2022-03`**:**进行大幅度更新、支持step、cos学习率下降法、支持adam、sgd优化器选择、支持学习率根据batch_size自适应调整。**  
BiliBili视频中的原仓库地址为：https://github.com/bubbliiiing/unet-pytorch/tree/bilibili

**`2020-08`**:**创建仓库、支持多backbone、支持数据miou评估、标注数据处理、大量注释等。**  

## 相关仓库
| 模型 | 路径 |
| :----- | :----- |
Unet | https://github.com/bubbliiiing/unet-pytorch  
PSPnet | https://github.com/bubbliiiing/pspnet-pytorch
deeplabv3+ | https://github.com/bubbliiiing/deeplabv3-plus-pytorch

### 性能情况
**unet并不适合VOC此类数据集，其更适合特征少，需要浅层特征的医药数据集之类的。**
| 训练数据集 | 权值文件名称 | 测试数据集 | 输入图片大小 | mIOU | 
| :-----: | :-----: | :------: | :------: | :------: | 
| VOC12+SBD | [unet_vgg_voc.pth](https://github.com/bubbliiiing/unet-pytorch/releases/download/v1.0/unet_vgg_voc.pth) | VOC-Val12 | 512x512| 58.78 | 
| VOC12+SBD | [unet_resnet_voc.pth](https://github.com/bubbliiiing/unet-pytorch/releases/download/v1.0/unet_resnet_voc.pth) | VOC-Val12 | 512x512| 67.53 | 

### 所需环境
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
 

### 训练步骤
#### 一、训练voc数据集
1、将我提供的voc数据集放入VOCdevkit中（无需运行voc_annotation.py）。  
2、运行train.py进行训练，默认参数已经对应voc数据集所需要的参数了。  

#### 二、训练自己的数据集
1、本文使用VOC格式进行训练。  
2、训练前将标签文件放在VOCdevkit文件夹下的VOC2007文件夹下的SegmentationClass中。    
3、训练前将图片文件放在VOCdevkit文件夹下的VOC2007文件夹下的JPEGImages中。    
4、在训练前利用voc_annotation.py文件生成对应的txt。    
5、注意修改train.py的num_classes为分类个数+1。    
6、运行train.py即可开始训练。  

### 预测步骤
#### 一、使用预训练权重
##### a、VOC预训练权重
1. 下载完库后解压，如果想要利用voc训练好的权重进行预测，在百度网盘或者release下载权值，放入model_data，运行即可预测。  
```python
img/street.jpg
```    
2. 在predict.py里面进行设置可以进行fps测试和video视频检测。    


#### 二、使用自己训练的权重
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
    "num_classes"   : 21,
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

## Reference
https://github.com/ggyyzm/pytorch_segmentation  
https://github.com/bonlime/keras-deeplab-v3-plus
