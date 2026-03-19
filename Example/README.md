# LSWaveformKit 示例项目

本目录包含 LSWaveformKit 的完整示例项目，展示各种功能和用法。

## 目录结构

```
Example/
├── iOS/                    # iOS UIKit 示例
│   ├── LSWaveformKitDemo/        # 主项目
│   ├── Assets.xcassets/         # 资源文件
│   └── ViewController.swift    # 示例代码
│
├── SwiftUI/                 # SwiftUI 示例
│   ├── LSWaveformKitSwiftUIDemo/
│   ├── ContentView.swift
│   └── Assets.xcassets/
│
└── ObjectiveC/              # Objective-C 示例
    ├── LSWaveformKitOCDemo/
    ├── ViewController.m
    └── Assets.xcassets/
```

## 快速开始

### iOS UIKit 示例

```bash
cd Example/iOS/LSWaveformKitDemo
pod install
open LSWaveformKitDemo.xcworkspace
```

### SwiftUI 示例

```bash
cd Example/SwiftUI/LSWaveformKitSwiftUIDemo
pod install
open LSWaveformKitSwiftUIDemo.xcworkspace
```

### Objective-C 示例

```bash
cd Example/ObjectiveC/LSWaveformKitOCDemo
pod install
open LSWaveformKitOCDemo.xcworkspace
```

## 示例功能

### 基础示例
- ✅ 简单录音
- ✅ 音频播放
- ✅ 波形可视化
- ✅ 长按录音手势
- ✅ 滑动取消录音

### 高级示例
- ✅ 自定义配置
- ✅ 多种颜色模式
- ✅ 多种高度模式
- ✅ 自定义间距
- ✅ 多个波形实例

### 音乐播放器示例
- ✅ 酷狗音乐风格
- ✅ QQ 音乐风格
- ✅ 酷我音乐风格
- ✅ 落雪风格
- ✅ 网易云音乐风格
- ✅ Apple Music 风格
- ✅ Spotify 风格
- ✅ 歌词同步
- ✅ 节拍检测
- ✅ 频谱分析

## 运行要求

- iOS 13.0+ / macOS 10.15+
- Xcode 12.0+
- Swift 5.5+
- CocoaPods 1.10+

## 截图

![基础波形](Screenshots/basic.png)
![对称波形](Screenshots/symmetric.png)
![频谱波形](Screenshots/spectrum.png)
![圆形波形](Screenshots/circular.png)
![酷狗风格](Screenshots/kugou.png)
![QQ音乐风格](Screenshots/qqmusic.png)

## 许可证

示例代码使用 MIT 许可证。详见 [LICENSE](../LICENSE)。
