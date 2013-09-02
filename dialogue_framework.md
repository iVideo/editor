Dialogue Framework
=========================
所有的课程内容按照 chapter - lesson 划分。主菜单按照 chapter 分页，左右滑动切换。

### Screenshots

---

![](https://raw.github.com/yiplee/editor/master/screenshots/screen.png)

### Data Structure

---

![](https://raw.github.com/yiplee/editor/master/screenshots/dialogue.png)

### data

---

* audioDic : 存放音频字典所有的音频文件，支持 `mp3`,`wav`,`caf`格式，推荐`caf`格式。
* chapters : 存放所有 chapter 文件夹。
* font : 所有用到的位图字体图片及配置文件。
* masks: 用于形成菜单圆角图标的遮罩图片和缺省菜单图标。
* option.plist : 存放设置选项的键值对。

> use afconvert to convert wav to caf

    afconvert -f caff -d ima4 *.wav



### option.plist

---

| Property                      | Default value           | 描述                         |
| ----------------------------- | ----------------------- | --------------------------: |
| allowSkipVideo                | `YES`                   | 是否允许视频播放时跳过（无效）   |
| punctuationCharacters         | ` ,.:""''!?-(){}[];<>/` | 用于分割句子的分割字符          |
| startAtLastExit               | `NO`                    | 是否从上次退出时的页数开始       |
| dynamicLabel                  | `NO`                    | 字幕动态出现（无效             |
| colorfulLabel                 | `YES`                   | 字幕是否有颜色                 |
| colorOfNormalWord             | `#ffffff`               | 普通单词颜色                   |
| colorOfCurrentWord            | `#dcde59`               | 正在读的单词的颜色              |
| colorOfAudioableWord          | `#50dcb8`               | 可点击发音的单词的颜色          |
| refreshAudioDicOnLaunch       | `YES`                   | 是否在启动时刷新音频字典缓存     |
| shouldAidioDicPreloadSound    | `YES`                   | 是否在课程开始前预先加在音频字典  |
| dialogueBackgroundStartColor  | `#393c38`               | 对话背景起始色                 |
| dialogueBackgroundEndColor    | `#393c38`               | 对话背景结束颜色               |
| dialogueBackgroundColorVector | `{1,0}`                 | 对话背景颜色渐变方向            |
| mainMenuBackgroundStartColor  | `#393c38`               | 主菜单背景起始色               |
| mainMenuBackgroundEndColor    | `#393c38`               | 主菜单背景结束色               |
| mainMenuBackgroundColorVector | `{0,-1}`                | 主菜单背景颜色渐变方向          |


### work flow

---

* 在 data/chapters 文件夹下新建一个文件夹（新的 chapter），例如 Fruit .
* 将使用编辑器生成的 lesson 复制到 Fruit 下。
* Re-compile .
* Done.

### lesson icon on main menu

---

图标大小 ipad 128x128 px , ipadhd 256x256 px ，必须是这个大小。

框架会自动去`Lesson`的文件夹下找 thumbnail.png (ipad下是 thumbnail-ipad.png,ipadhd下是 thumbnail-ipadhd.png) 来当作图标，如果没有的话，就用一个内置的渐变色图标代替。

本来我打算把生成缩略图的功能集成在编辑器中的，但是局限性太大，不能自定义其他样式的图标。并且在 Mac 下也有生成缩略图的简单方法：（以 video.mp4 为例）

    qlmanager -ti video.mp4 -f 1.0 -o ./ #create video.mp4.png with size 128x128
    mv video.mp4.png thumbnail-ipad.png  # for ipad
    qlmanager -ti video.mp4 -f 2.0 -o ./ #create video.mp4.png with size 256x256
    mv video.mp4.png thumbnail-ipadhd.png  # for ipadhd
    
    
### Warning

---

* 一个 chapter 下最多8个 lesson ，多余的不显示。
* 这次采用了外挂文件夹的方式存放资源文件，优点是添加图片等不用在 Xcode 里面注册，缺点是本地资源与设备端同步有点问题，比如在 chapters 下删除了一些 lessons ，但是重新编译后设备上还有这些 lessons 。在本地对资源进行删除或者重命名操作之后这个问题都会出现，解决办法就是删除设备上的 app，在 Xcode 重新编译运行前在 Xcode 菜单 Product 下按住option键然后选  clean build folder … ，然后再编译运行。  


### Todo

---

* Chapter/Lesson 指定顺序。
* Loading scene between main menu and dialogue.




