# LSWaveformKit

## 概述

LSWaveformKit 是一个功能丰富、完整、类型多样且高度可控的 iOS 音频波形可视化库。

## 集成步骤

### CocoaPods

1. 在 Podfile 中添加：

```ruby
pod 'LSWaveformKit'
```

2. 执行安装：

```bash
pod install
```

3. 在需要使用的地方导入：

```swift
import LSWaveformKit
```

### Swift Package Manager

在 Xcode 中：
1. File → Add Packages
2. 输入：`https://github.com/yourusername/LSWaveformKit.git`
3. 选择版本并添加

### 手动集成

1. 下载源码
2. 将 `Sources` 目录拖入项目
3. 确保勾选 "Copy items if needed"

## 快速开始

### 基础使用

```swift
import LSWaveformKit

// 创建波形视图
let waveformView = LSWaveformView()
waveformView.frame = CGRect(x: 0, y: 100, width: view.bounds.width, height: 60)
view.addSubview(waveformView)

// 开始录音
waveformView.startRecording()
```

### 应用预设风格

```swift
// 酷狗音乐风格
waveformView.applyStyle(.kugou)

// QQ 音乐风格
waveformView.applyStyle(.qqmusic)

// 微信风格
waveformView.applyStyle(.wechat)
```

### 自定义配置

```swift
let config = LSDefaultWaveformConfiguration()
config.numberOfBars = 40
config.barColorMode = .frequencyBased([
    UIColor(hex: "#FF0000"),  // 低频
    UIColor(hex: "#00FF00"),  // 中频
    UIColor(hex: "#0000FF")   // 高频
])
config.spacingMode = .equal(6)

waveformView.configuration = config
```

## 主要功能

### 12+ 种条纹高度模式

- `symmetric` - 对称（中间高，两边低）
- `random` - 随机
- `ascending` - 从左到右升高
- `descending` - 从左到右降低
- `highLow` - 高低高低
- `uniform` - 一样高
- `uneven` - 参差不齐
- 自定义高度数组

### 10+ 种颜色模式

- 单色
- 多色循环
- 垂直/水平/对角/径向渐变
- 基于音量的动态颜色
- 基于频率的颜色（频谱）
- 彩虹渐变
- 自定义颜色提供者

### 15+ 种预设风格

**基础风格**：默认、QQ、微信、WhatsApp、iOS

**音乐播放器**：酷狗、QQ音乐、酷我、落雪、网易云音乐、虾米、Apple Music、YouTube Music、Spotify

**特效风格**：霓虹、极简、复古、玻璃拟态

### 手势交互

- 长按录音
- 滑动取消
- 点击录音
- 双击暂停/恢复
- 捏合缩放

### 音乐特效

- 歌词同步（LRC 格式）
- 节拍检测（BPM）
- FFT 频谱分析
- 频率颜色映射

## 权限配置

在 `Info.plist` 中添加：

```xml
<!-- 麦克风权限 -->
<key>NSMicrophoneUsageDescription</key>
<string>需要访问麦克风以录制音频</string>
```

## API 文档

完整的 API 文档请参考：
- [API.md](Docs/API.md) - API 参考手册
- [ARCHITECTURE.md](Docs/ARCHITECTURE.md) - 架构设计
- [Examples.md](Docs/Examples.md) - 使用示例

## 常见问题

### Q: 录音没有声音？

A: 检查：
1. 是否添加了麦克风权限
2. 是否调用了 `startRecording()`
3. 音频会话是否正确配置

### Q: 波形不更新？

A: 确保：
1. `updateAmplitude` 方法被调用
2. 音幅值在 0.0 ~ 1.0 范围内
3. 主线程更新 UI

### Q: 如何自定义颜色？

A: 使用 `barColorMode` 配置：

```swift
waveformView.configuration.barColorMode = .single(UIColor.red)

// 或使用渐变
waveformView.configuration.barColorMode = .gradientVertical(
    [UIColor.blue, UIColor.purple],
    locations: [0.0, 1.0]
)
```

## 系统要求

- iOS 13.0+ / macOS 10.15+
- Xcode 12.0+
- Swift 5.5+

## 许可证

MIT License. 详见 [LICENSE](LICENSE)

## 联系方式

- GitHub Issues: [提交问题](https://github.com/yourusername/LSWaveformKit/issues)
- Email: your.email@example.com

## 致谢

本项目研究和参考了以下开源库：
- GYSpectrum
- iRecordView
- DSWaveformImage
- AudioKit/Waveform
- 以及其他 25+ 库

完整列表请参考 [库对比分析文档](录音动画库深度对比分析-完整版.md)
