Dialogue Editor
===================

Dialogue Editor 用于生成 dialogue framework 所需的资源配置文件。

### video

---
![](https://github.com/yiplee/editor/blob/master/screenshots/video%20editor.png)

窗口弹出时先选择要保存的位置，输入project name.

#### work flow

* load video. 支持 `@"mp4"` 和 `@"m4v"` 格式。
* Publish.

### image

---
![](https://github.com/yiplee/editor/blob/master/screenshots/image%20editor.png)

窗口弹出时先选择要保存的位置，输入project name.图片类型的对话相当于一本书，每页是一个`scene`,包括一副图片和一段话，还有时间信息等。音频波形图可以点击来直接从指定时间播放。

#### work flow

* load audio. 支持 `@"AIFF", @"aif", @"aiff", @"aifc", @"wav", @"WAV",@"mp3"` 格式音频文件.
* add image. 支持不同的`scene`对应同一张图片。
* 编辑内容和时间信息等。
* add `scene`. Loop….

#### Functions

* start time button:设置 start time 为当前音频播放时间。start time 为`scene`在音频中的开始时间。
* end time button  :设置 end time 为当前音频播放时间。end time 为`scene`在音频中的结束时间。
* timeline button  :添加当前音频播放时间到 timeline。
* publish setting  :如果 pvr.ccz 不选的话就会默认转成 png 格式图片，如果 TexturePacker 没装的话也会转成 png 格式。

#### Timeline

格式示例：
> `2.34/3.34/5.34/6.34/` 每两个数字代表一个单词的时间段，必须填入所有单词的时间段，标点符号不用管。

我试了下用编辑器的取时间点功能来生成 timeline，效果很差，本来当初设计的时候没有考虑取每个单词的时间段的需求，只考虑了取`scene`的时间段的需求。编辑器的音频波形图在交互上远比不上 Audacity ,下面说说如何用Audacity来完成这项工作。

#### Audacity

![](https://github.com/yiplee/editor/blob/master/screenshots/audacity.png)

先标记出`scene`中所有单词（如上图所示），然后导出标记到文件，例如 label track.txt .然后用以下shell脚本处理一下。

    mac2unix "$1"
    touch $$.temp

    for time in `cut -f 1-2 "$1"`;do
      echo $time >> $$.temp
    done

    cat $$.temp | tr "\\n" "/" | pbcopy
    echo "have put formatted data on Clipboard..."
    rm $$.temp
    
保存上述脚本为（例如）timeline.sh,赋予运行权限,再处理数据：
    
    sudo chmod +x timeline.sh
    ./timeline.sh label\ track.txt

脚本会将格式化好的 timeline 数据复制到剪切板，然后回到编辑器粘贴到 timeline 文本框中即可。

#### Bugs

导出 pvr.ccz 格式图片莫名其妙只能导出 `ipadhd`分辨率的，但是在 Xcode 中编译运行时明明可以导出`ipadhd`和`ipad`的。选择导出 png 格式则没问题。

### todo

---

编辑器还有很多可以改进的地方，比如：

* 像 Audacity 那样的音频编辑界面。
* 根据 start time 和 end time 自动剪切音频文件。
* 可以保存 project 以便以后修改。
* `scene`列表排序。
* copy `scene`.
* video preview.(我觉得这个必要性不大，所以跳过了)






 