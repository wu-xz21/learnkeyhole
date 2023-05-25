import sys
import os
if hasattr(sys, 'frozen'):
 os.environ['PATH'] = sys._MEIPASS + ";" + os.environ['PATH']

from PyQt5 import uic 
from PyQt5.QtWidgets import QListWidgetItem,QMessageBox,QApplication,QGraphicsView,QAction,QMainWindow,QGraphicsScene, QFileDialog,QStyle
from PyQt5.QtGui import QPixmap,QPainter
from PyQt5.QtCore import Qt,QUrl,QDir
from learnkeyhole.predict import predictaction
from PyQt5.QtMultimedia import QMediaPlayer, QMediaContent


class MyGraphicsView(QGraphicsView):
 
    def wheelEvent(self, event):
        # 鼠标滚轮事件，用来实现图片缩放
        zoomInFactor = 1.25
        zoomOutFactor = 1 / zoomInFactor
        oldPos = self.mapToScene(event.pos())
        if event.angleDelta().y() > 0:
            zoomFactor = zoomInFactor
        else:
            zoomFactor = zoomOutFactor
        self.scale(zoomFactor, zoomFactor)
        newPos = self.mapToScene(event.pos())
        delta = newPos - oldPos
        self.translate(delta.x(), delta.y())


class mainWindow:

    def __init__(self):
        # 从文件中加载UI定义
        ##qfile_window = QFile("window.ui")
        #qfile_window.open(QFile.ReadOnly)
        #qfile_window.close()

        self.ui = uic.loadUi("learnkeyhole/window.ui")

 


        self.ui.show()

        #打开视频
        self.ui.OpenVid.clicked.connect(self.openVideo)
        self.ui.ori_media = QMediaPlayer(self.ui)
        self.ui.ori_media.setVideoOutput(self.ui.ori_video)
        self.ui.pre_media = QMediaPlayer(self.ui)
        self.ui.pre_media.setVideoOutput(self.ui.pre_video)
       
        #视频播放开关

        self.ui.play_button.setIcon(self.ui.style().standardIcon(QStyle.SP_MediaPlay))
        self.ui.play_button.clicked.connect(self.play_video)
        #预测
        self.ui.predictVid.clicked.connect(self.predictVid)
        #视频暂停开关
        
        self.ui.pause_button.setIcon(self.ui.style().standardIcon(QStyle.SP_MediaPause))
        self.ui.pause_button.clicked.connect(self.pause_video)
        #视频停止播放
        self.ui.stop_button.setIcon(self.ui.style().standardIcon(QStyle.SP_MediaStop))
        self.ui.stop_button.clicked.connect(self.stop_video)





        #原始路径
        self.ori_imagepath = None
        self.pre_imagepath = None
        #原始路径
        self.ori_videopath = None
        #预测保存路径
        self.pre_videopath = None
        
        #原始图像
        self.ori_item = None
        #预测后的图像
        self.pre_item = None

        #打开图片或图片文件夹
        self.ui.OpenImage.clicked.connect(self.openImage)
        #打开文件夹
        self.ui.OpenDir.clicked.connect(self.openFolder)
        #预测      
        self.ui.predictImage.clicked.connect(self.predictImage)

        #打开文件夹储存路径
        self.ori_folder = None
        #预测文件夹储存路径
        self.pre_folder = None

        #打开文件夹原始图片显示重载
        self.origin_dir = self.ui.findChild(QGraphicsView, "originImg")
        self.new_origin_dir = MyGraphicsView()
        self.old_origin_dir = self.origin_dir
        self.new_origin_dir.setObjectName(self.old_origin_dir.objectName())
        layout = self.old_origin_dir.parent().layout()
        layout.replaceWidget(self.old_origin_dir, self.new_origin_dir)
        self.old_origin_dir.setParent(None)
        self.oridirscene = QGraphicsScene()
        self.new_origin_dir.setScene(self.oridirscene)

        # 设置QGraphicsView的拖拽模式和缩放模式
        self.new_origin_dir.setDragMode(QGraphicsView.ScrollHandDrag)
        self.new_origin_dir.setRenderHint(QPainter.SmoothPixmapTransform)
        
        
#         范德萨范德萨富士达
#         fadsASDFA
#         DFAS
#         AFDA
        


        #打开文件夹预测图片显示重载
        self.predict_dir = self.ui.findChild(QGraphicsView, "predictImg")
        self.new_predict_dir = MyGraphicsView()
        self.old_predict_dir = self.predict_dir
        self.new_predict_dir.setObjectName(self.old_predict_dir.objectName())
        layout = self.old_predict_dir.parent().layout()
        layout.replaceWidget(self.old_predict_dir, self.new_predict_dir)
        self.old_predict_dir.setParent(None)
        self.predirscene = QGraphicsScene()
        self.new_predict_dir.setScene(self.predirscene)

        # 设置QGraphicsView的拖拽模式和缩放模式
        self.new_predict_dir.setDragMode(QGraphicsView.ScrollHandDrag)
        self.new_predict_dir.setRenderHint(QPainter.SmoothPixmapTransform)

        self.ui.Prev_Image.clicked.connect(self.prevImage)
        self.ui.Nest_Image.clicked.connect(self.nestImage)

        #权值文件路径
        self.logsPath = None
        self.ui.dir_loadlogs.clicked.connect(self.openLogs)
        self.ui.vid_loadlogs.clicked.connect(self.openLogs)
        self.selectlog = None
        #是否已经打开图片
        self.isImage = False
        self.isVideo = False
        self.isFolder = False

        #判断图片文件夹是否可以切换
        self.image_is_changed = False
        self.logs_is_changed = False
    #打开文件夹
    def openFolder(self):
        # 打开文件选择对话框
        folder = QFileDialog.getExistingDirectory(self.ui, 'Open Folder')
        # 如果选择了文件，则加载它
        if folder and os.path.isdir(folder):
            self.ori_folder = folder
            print(self.ori_folder)
            dir = QDir(self.ori_folder)
            images = dir.entryList(['*.jpg', '*.png', '*.gif', '*.bmp'])
            self.image_is_changed = False
            self.ui.pre_list.clear()
            self.image_is_changed = True
            for image in images:
                item = QListWidgetItem(image)
                self.ui.pre_list.addItem(item)
            if images:
                #print(images[0])
                image_path = self.ori_folder + '/' + images[0]
                #print(image_path)
                img = QPixmap(image_path)
                if self.ori_item is not None:
                    self.oridirscene.removeItem(self.ori_item)
                if self.pre_item is not None:
                    self.predirscene.removeItem(self.pre_item)
                self.pre_imagepath = None
                self.ori_imagepath = None
                #self.pImgoTex('图片打开成功！')
                self.ori_item = self.oridirscene.addPixmap(img)
                self.new_origin_dir.fitInView(self.ori_item, Qt.KeepAspectRatio)
                self.ui.pre_list.setCurrentRow(0)
                self.ui.pre_list.currentItemChanged.connect(self.setImage)
                        #图片上一张下一张切换
                self.isFolder = True
                self.isImage = False


    #打开权值文件夹
    def openLogs(self):
        # if self.logsPath is not None:
        #     QMessageBox.information(self.ui,'提示',f'''权值文件已加载''')
        #     return 
        #self.logsPath = "logs"
        #print(self.ori_folder)
        # 打开文件选择对话框
        folder = QFileDialog.getExistingDirectory(self.ui, 'Open logs')
        # 如果选择了文件，则加载它
        if folder and os.path.isdir(folder):
            self.logsPath = folder
            print(self.logsPath)
            dir = QDir(self.logsPath)
            logs = dir.entryList(['*.pth'])
            self.logs_is_changed = False
            self.ui.logsList.clear()
            self.ui.vid_list.clear()

            self.logs_is_changed = True
            for log in logs:
                item = QListWidgetItem(log)
                self.ui.logsList.addItem(item)
                self.ui.logsList.setCurrentRow(0)
                self.ui.logsList.currentItemChanged.connect(self.setLogs)        

            for log in logs:
                item = QListWidgetItem(log)
                self.ui.vid_list.addItem(item)
                self.ui.vid_list.setCurrentRow(0)
                self.ui.vid_list.currentItemChanged.connect(self.setLogs)
                      
                       


    def setLogs(self,item):
        if self.logs_is_changed:
            self.selectlog = self.logsPath + '/' + item.text()
            print(self.selectlog)
            self.ui.dir_line.setText(item.text())
            self.ui.vid_line.setText(item.text())        
        #print(self.selectlogs)
   
    def setImage(self, item):
        if self.image_is_changed:
            folder_1 = self.ori_folder + '/' + item.text()
            image_1 = QPixmap(folder_1)

            if self.ori_item is not None:
                self.oridirscene.removeItem(self.ori_item)
            #self.pImgoTex('图片打开成功！')
            self.ori_item = self.oridirscene.addPixmap(image_1)
            self.new_origin_dir.fitInView(self.ori_item, Qt.KeepAspectRatio)


            if self.pre_folder is not None:
                folder_2 = self.pre_folder + '/' + item.text()
                image_2 = QPixmap(folder_2)
                if self.pre_item is not None:
                    self.predirscene.removeItem(self.pre_item)
                #self.pImgoTex('图片打开成功！')
                self.pre_item = self.predirscene.addPixmap(image_2)
                self.new_predict_dir.fitInView(self.pre_item, Qt.KeepAspectRatio)
       
    def nestImage(self):

  
        row = self.ui.pre_list.currentRow()
        if row < self.ui.pre_list.count() - 1:
            self.ui.pre_list.setCurrentRow(row + 1)

    def prevImage(self):           
        row = self.ui.pre_list.currentRow()
        
        if row > 0:
            self.ui.pre_list.setCurrentRow(row - 1)




    def openVideo(self):
        # 打开文件选择对话框
        file_name, _ = QFileDialog.getOpenFileName(self.ui, "Open Video", "", "Video Files (*.mp4 *.avi)")
        # 如果选择了文件，则加载它
        if file_name != '':
            self.ori_videopath = file_name
            self.ui.ori_media.setMedia(QMediaContent(QUrl.fromLocalFile(file_name)))
            self.play_video()
            self.isVideo = True


    def play_video(self):
        self.ui.ori_media.play()
        self.ui.pre_media.play()        
    def pause_video(self):
        self.ui.ori_media.pause()
        self.ui.pre_media.pause()
    def stop_video(self):
        self.ui.ori_media.stop()
        self.ui.pre_media.stop()



    def openImage(self):
        # 打开图片文件并加载到QGraphicsScene中
       
        fileName, _ = QFileDialog.getOpenFileName(self.ui, "Open Image", "", "Image Files (*.png *.jpg *.bmp)")

        if fileName != '':
            self.ori_imagepath = fileName
            print(self.ori_imagepath)
            image = QPixmap(fileName)
            #再次打开时清除原来已经打开的文件
            if self.ori_item is not None:
                self.oridirscene.removeItem(self.ori_item)
            if self.pre_item is not None:
                self.predirscene.removeItem(self.pre_item)
            self.ori_folder = None
            self.pre_folder = None
            self.image_is_changed = False
            self.ui.pre_list.clear()
            self.image_is_changed = True           
            #self.pImgoTex('图片打开成功！')
            self.ori_item = self.oridirscene.addPixmap(image)
            self.new_origin_dir.fitInView(self.ori_item, Qt.KeepAspectRatio)
            self.isImage = True
            self.isFolder = False

            #print(self.isImage)

    def predictImage(self):
        if self.isImage and not self.isFolder:
            self.predictImg()
            return
        elif not self.isImage and self.isFolder:
            self.predictDir()
            return
        else:
            QMessageBox.warning(self.ui,'warning',f'''请先打开图片''')
        #print("预测图片出错")
        return
    def predictImg(self):
        
        #self.pImgoTex('正在标记，请稍后···')

        mode = "predict"
        if self.selectlog is None:
            QMessageBox.warning(self.ui,'warning',f'''请选择权值文件''')
            return  
        self.pre_imagepath = QFileDialog.getExistingDirectory(self.ui, '结果另存为')
        if self.pre_imagepath:
            feedback = predictaction(mode,self.ori_imagepath,self.pre_imagepath,self.selectlog)
            if feedback:
                pimage = QPixmap(feedback)
                if self.pre_item is not None:
                    self.predirscene.removeItem(self.pre_item)
                #self.pImgoTex('标记成功！')
                self.pre_item = self.predirscene.addPixmap(pimage)
                self.new_predict_dir.fitInView(self.pre_item, Qt.KeepAspectRatio)



    def predictVid(self):
        mode = "video"

        if self.isVideo is not True:
            QMessageBox.warning(self.ui,'warning',f'''请先打开视频''')
            return
        if self.selectlog is None:
            QMessageBox.warning(self.ui,'warning',f'''请选择权值文件''')
            return  

        self.pre_videopath = QFileDialog.getExistingDirectory(self.ui, '结果另存为')
        if self.pre_videopath:
            feedback = predictaction(mode,self.ori_videopath,self.pre_videopath,self.selectlog)
            if feedback:
                self.ui.pre_media.setMedia(QMediaContent(QUrl.fromLocalFile(feedback)))
                self.play_video()         


    def predictDir(self):
        mode = "dir_predict"
        if self.selectlog is None:
            QMessageBox.warning(self.ui,'warning',f'''请选择权值文件''')
            return       
        self.pre_folder = QFileDialog.getExistingDirectory(self.ui, '结果另存为')
        if self.pre_folder:
            #print(self.pre_folder)
            feedback = predictaction(mode,self.ori_folder,self.pre_folder,self.selectlog)

            if feedback:
                dir = QDir(feedback)
                images = dir.entryList(['*.jpg', '*.png', '*.gif', '*.bmp'])

                if images:
                    #print(images[0])
                    image_path = self.pre_folder + '/' + images[0]
                    #print(image_path)
                    img = QPixmap(image_path)
                    if self.pre_item is not None:
                        self.predirscene.removeItem(self.pre_item)
                    #self.pImgoTex('图片打开成功！')
                    self.pre_item = self.predirscene.addPixmap(img)
                    self.new_predict_dir.fitInView(self.pre_item, Qt.KeepAspectRatio)


def main():
    app = QApplication(sys.argv)
    mainw = mainWindow()
    sys.exit(app.exec_())


if __name__ == '__main__':
    main()
