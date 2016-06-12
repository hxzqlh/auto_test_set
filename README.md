# Auto_Sample 

## 一句话介绍功能

输入一个媒体文件，自动生成各种格式的视频、音频、图片，具体的格式可根据需要定制、扩展。

## 适用平台

Linux／Mac OS X ，且系统已预装好 ffmpeg，建议下载官网最新版。否则，可能因版本太老导致无法对某些媒体格式进行编解码。

## 如何使用

### 视频

* ./make_video.sh -i media -d out_dir
    * media: 源媒体
    * out_dir: 生成的目标视频将放在这个目录

* 要生成的视频格式记录在 `video.txt` 文件中，每一行按照 `start,duration,wxh,fps,bitrate` 的格式分别配置好要生成的视频格式。

    * start: 从原始媒体什么位置（s）开始截取
    * duration: 截取时长（s）
    * wxh: 要生成的视频分辨率
    * fps: 要生成的视频帧率
    * bitrate: 要生成的视频码率(b)

各个特征之间用 `,` 分隔开，如果想保持某个特征和原视频一致，则将该字段置为 `-`。

如：

> 10,20,320x240,25,128k //从原视频的第10秒开始，截取20秒，目标视频的分辨率为320x240，视频帧率为25fps，码率为128kb
> 20,8,-,-,-            //从原视频的第20秒开始，截取8秒，目标视频的分辨率、帧率、码率均保持和原视频一致

### 音频

* ./make_audio.sh -i media -d out_dir
    * media: 源媒体
    * out_dir: 生成的目标音频将放在这个目录

* 要生成的音频格式记录在 `audio.txt` 文件中，每一行按照 `start,duration,sample_rate,channel_num,bitrate` 的格式分别配置好要生成的视频格式。

    * start: 从原始媒体什么位置（s）开始截取
    * duration: 截取时长（s）
    * sample_rate: 要生成的音频采样频率（Hz）
    * channel_num: 要生成的音频声道数
    * bitrate: 要生成的音频码率(b)

各个特征之间用 `,` 分隔开，如果想保持某个特征和原视频一致，则将该字段置为 `-`。

如：

> 10,20,8000,1,128k     //从源媒体的第10秒开始，截取20秒，目标音频的采样频率为8000Hz，单声道，码率为128kb
> 20,8,-,-,-            //从源媒体的第20秒开始，截取8秒，目标音频的采样频率、声道数、码率均保持和原视频一致

### 图片

* ./make_image.sh -i media -d out_dir
    * media: 源图片
    * out_dir: 生成的目标图片将放在这个目录

* 要生成的图片格式记录在 `image.txt` 文件中，每一行按照 `wxh` 的格式配置好要生成的图片分辨率。


