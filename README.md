![logo](https://github.com/XuDeHong/CostList/blob/master/logo.png "logo")

# 移动记账

该项目为本人独立开发，从界面设计到代码编写，也是我学习iOS以来第一个做的较为完整的项目。

移动记账，能记录每一天的消费或收入，并以图表的形式显示统计结果。除了基本的增删查改账目以外，还加入了指纹识别、手势密码、3D Touch以及数据同步等功能。

![screenshot](https://github.com/XuDeHong/CostList/blob/master/screenshot.PNG "screenshot")

## 目标人群

普通记账用户、年轻人

## 开发工具

Xcode、Git、CocoaPods、Sketch、SourceTree

## 使用的框架或技术

Foudation、UIKit、CoreData、CoreLocation、3D Touch、Touch ID、Charts（第三方Swift图表框架）、其他一些第三方框架

## 功能列表

- **添加账目**
- **修改账目**
- **删除账目**
- **查找账目**
  - **按时间（年份和月份）查找账目**
  - **按账目备注查找账目**
- **图表统计功能**
  - **圆饼比例图统计**
  - **折线趋势图统计**
- **设置手势密码**
- **开启指纹识别**
- **数据同步**
- **3D Touch**
- **设置提醒**
- **其他**
  - **一键清空数据**
  - **意见反馈**
  - **分享给好友**
  - **评分鼓励**
  - **关于**

## 项目展示

- 各功能视频展示：[传送门](http://blog.sina.com.cn/s/blog_d77623b30102x2y0.html)
- 截图展示：[传送门](http://www.cnblogs.com/guitarandcode/p/6396660.html)


## 技术难点

APP主要是UIKit基本控件的使用，以下是部分难点：

1. **自定义TabBar样式：**[实现TabBar中间凸起“+”按钮](http://www.cnblogs.com/guitarandcode/p/5759208.html)

2. **视图控制器跳转的几种方法：**[纯代码控制视图控制器跳转的几种方法](http://www.mamicode.com/info-detail-469709.html)

3. **UITableviewCell自适应：**[根据Text计算UILabel高度](http://www.cnblogs.com/guitarandcode/p/5802473.html)

4. **Objective-C和Swift混编：**[Objective-C项目导入Swift](http://www.cnblogs.com/guitarandcode/p/5894102.html)

5. **数据同步的实现：**    利用了FTP协议，当需要上传数据时，将CoreData保存数据的几个数据库文件、图片以及配置上传到FTP服务器中，当需要下载数据时，则将之前上传的数据下载下来，并更新配置。此时该应用相当于FTP客户端，FTP服务端在服务器配置好。​



## APP视图架构

APP整体采用MVC架构，以下为APP各个视图控制器的关系

![architecture](https://github.com/XuDeHong/CostList/blob/master/architecture.jpg "architecture")

## 收获

通过这一次完整的开发体验，让我更加熟悉UIKit里面基本控件的使用，巩固了之前看书和看视频所学的知识，也学习了一些基本工具的使用，比如Git、GitHub、CocoaPods等。Git是一个分布式版本管理系统，对于管理代码来说非常高效方便；GitHub是一个代码托管平台，很多技术牛人都在上面分享他们的代码，我从中受益匪浅，这个APP中用到的第三方框架都是来自GitHub；CocoaPods是一个第三方框架管理工具，这为我复用别人的代码提供了很大的便利。

​虽然这个APP目前来说还不是很复杂，但通过不断优化更新和添加新功能，我相信这个APP会慢慢成熟起来，而我的技术也会不断地增进。开发这个APP的过程中，我已大概了解开发的流程和APP的架构，算是为我以后的学习和开发打下基础。

创造是一个愉快的过程，不断挑战自我，期待我写出更Cool的APP！