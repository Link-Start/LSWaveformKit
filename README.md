# LSWaveformKit

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20iOS%2013%2B-brightgreen.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-16.0%2B-blue.svg)](https://developer.apple.com/xcode/)

> 🎵 一个功能强大、高度可定制的音频波形可视化框架，专为 iOS 应用设计

## ✨ 特性

- 📊 **多种布局模式** - 支持 7 种波形布局方式
- 🎨 **15+ 预设风格** - 开箱即用的精美样式
- 🎭 **丰富的自定义选项** - 完全控制波形的外观和行为
- 🎬 **流畅的动画** - 平滑的波形动画效果
- 👆 **手势交互** - 支持点击、滑动、长按等手势
- 🎙️ **录音功能** - 内置音频录制和播放支持
- 🖼️ **图像生成** - 从音频文件生成静态波形图像
- ⚡ **高性能** - 基于 Accelerate 框架优化

## 📦 安装

### Swift Package Manager

在 Xcode 中，通过 `File > Add Package Dependencies` 添加：

```
https://github.com/Link-Start/LSWaveformKit
```

或者在 `Package.swift` 中添加：

```swift
dependencies: [
    .package(url: "https://github.com/Link-Start/LSWaveformKit.git", from: "1.0.0")
]
```

### CocoaPods

在 `Podfile` 中添加：

```ruby
pod 'LSWaveformKit'
```

然后运行：

```bash
pod install
```

## 🚀 快速开始

### 基础用法

```swift
import LSWaveformKit

// 创建波形视图
let waveformView = LSWaveformView(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
waveformView.configuration = LSDefaultWaveformConfiguration.ocean()
view.addSubview(waveformView)
```

### 更新波形

```swift
// 更新音量（实时反映音频强度）
waveformView.updateAmplitude(0.7)
```

### 录音功能

```swift
// 开始录音
waveformView.startRecording()

// 停止录音
waveformView.stopRecording()

// 播放音频
if let audioURL = waveformView.audioProcessor?.recordingURL {
    waveformView.playAudio(at: audioURL)
}
```

### 生成波形图像

```swift
// 从音频文件生成波形图像
let drawer = LSWaveformImageDrawer()
let image = try? await drawer.waveformImage(
    from: audioURL,
    config: .init(size: CGSize(width: 300, height: 100))
)
```

## 🎨 预设风格

```swift
// 经典风格
waveformView.applyStyle(.classic)
waveformView.applyStyle(.ocean)
waveformView.applyStyle(.sunset)
waveformView.applyStyle(.forest)
waveformView.applyStyle(.neon)
waveformView.applyStyle(.minimal)
waveformView.applyStyle(.cyberpunk)
waveformView.applyStyle(.gradientBlue)
waveformView.applyStyle(.gradientPurple)
waveformView.applyStyle(.gradientOrange)
waveformView.applyStyle(.gradientGreen)
waveformView.applyStyle(.waveformBars)
waveformView.applyStyle(.equalizer)
waveformView.applyStyle(.spectrum)
waveformView.applyStyle(.pulse)
waveformView.applyStyle(.mirror)
```

## ⚙️ 配置选项

### 波形配置

```swift
let config = LSDefaultWaveformConfiguration()
config.numberOfBars = 50
config.barWidth = 4
config.barSpacing = 2
config.minimumBarHeight = 5
config.maximumBarHeight = 80
config.cornerRadius = 2

// 布局模式
config.layoutMode = .symmetric

// 颜色模式
config.barColorMode = .gradientVertical(
    [.systemBlue, .systemPurple],
    locations: [0.0, 1.0]
)

// 动画
config.animationDuration = 0.2
config.animationCurve = .easeOut
```

### 布局模式

```swift
case symmetric          // 左右对称
case leftOnly           // 仅左侧
case rightOnly          // 仅右侧
case symmetricWithAnchor // 锚点对称
case horizontal         // 水平排列
case circular           // 圆形排列
case arc                // 弧形排列
```

### 高度模式

```swift
case symmetric    // 对称高度
case uniform      // 统一高度
case random       // 随机高度
case ascending    // 递增高度
case descending   // 递减高度
case highLow      // 高低交替
case peak         // 峰值模式
case valley       // 谷值模式
```

## 🎯 高级用法

### 自定义颜色提供者

```swift
class CustomColorProvider: LSBarColorProvider {
    func color(for bar: UIView, index: Int, total: Int, amplitude: Float) -> UIColor {
        // 根据位置和音量返回自定义颜色
        let hue = CGFloat(index) / CGFloat(total)
        return UIColor(hue: hue, saturation: amplitude, brightness: 1, alpha: 1)
    }
}

let config = LSDefaultWaveformConfiguration()
config.barColorMode = .custom(CustomColorProvider())
```

### 手势处理

```swift
waveformView.onBarTap { index in
    print("点击了第 \(index) 个条纹")
}

waveformView.onBarSwipe { direction, index in
    print("在 \(direction) 方向滑过第 \(index) 个条纹")
}

waveformView.onBarLongPress { index in
    print("长按了第 \(index) 个条纹")
}
```

### 波形图像生成

```swift
// 从音频文件生成
let drawer = LSWaveformImageDrawer()
let analyzer = LSWaveformAnalyzer(audioURL: audioURL)

// 异步生成
let samples = try await analyzer.analyze()
let image = drawer.waveformImage(from: samples, config: config)

// 同步生成
let image = try drawer.waveformImage(from: audioURL)
```

## 📚 文档

- [示例代码](Examples/)
- [更新日志](CHANGELOG.md)

## 🤝 贡献

欢迎贡献代码！请查看 [贡献指南](CONTRIBUTING.md) 了解详情。

## 📄 许可证

LSWaveformKit 采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

- 参考了 [DSWaveformImage](https://github.com/dmrschmidt/DSWaveformImage) 的波形图像生成实现
- 参考了 [GYSpectrum](https://github.com/rheinfuegg/GYSpectrum) 的频谱可视化设计
- 参考了 [iRecordView](https://github.com/3llomi/iRecordView) 的录音视图实现

## 📮 联系方式

- 作者: Link
- 项目主页: [https://github.com/Link-Start/LSWaveformKit](https://github.com/Link-Start/LSWaveformKit)
- 问题反馈: [GitHub Issues](https://github.com/Link-Start/LSWaveformKit/issues)

---

⭐ 如果这个项目对你有帮助，请给我们一个 Star！
