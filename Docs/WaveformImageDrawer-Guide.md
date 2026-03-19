# LSWaveformImageDrawer 使用指南

## 概述

`LSWaveformImageDrawer` 是 LSWaveformKit 的新功能，用于从音频文件生成静态波形图像。

---

## 快速开始

### 基础用法

```swift
import LSWaveformKit

// 方式 1: 使用静态方法（最简单）
let image = try await LSWaveformImageDrawer.image(
    from: audioURL,
    size: CGSize(width: 300, height: 100)
)

// 方式 2: 创建实例，复用配置
let drawer = LSWaveformImageDrawer(
    configuration: .init(
        size: CGSize(width: 400, height: 150),
        waveform: .symmetric(barCount: 50)
    )
)
let image = try await drawer.waveformImage(from: audioURL)
```

### 同步方法

```swift
let drawer = LSWaveformImageDrawer()

// 同步生成（会阻塞当前线程）
let image = try drawer.waveformImage(from: audioURL)
```

### 从样本生成

```swift
// 如果已有样本数据，可以直接生成图像
let samples: [Float] = [0.5, 0.8, 0.3, 0.9, ...]
let image = LSWaveformImageDrawer.image(from: samples, size: CGSize(width: 300, height: 100))
```

---

## 配置选项

### 图像配置 (ImageConfiguration)

```swift
var config = LSWaveformImageDrawer.ImageConfiguration(
    size: CGSize(width: 400, height: 150),
    waveform: LSDefaultWaveformConfiguration.symmetric(),
    backgroundColor: .white,        // 背景色
    scale: 3,                        // Retina 缩放
    padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)  // 边距
)
```

### 波形配置 (复用现有配置)

```swift
let waveformConfig = LSDefaultWaveformConfiguration()

// 条纹数量
waveformConfig.numberOfBars = 50

// 条纹样式
waveformConfig.barWidth = 4
waveformConfig.barHeightMode = .symmetric
waveformConfig.layoutMode = .symmetric

// 颜色
waveformConfig.barColorMode = .gradientVertical([
    UIColor_00CBE0().withAlphaComponent(0.3),
    UIColor_00CBE0()
], locations: [0.0, 1.0])

// 描边和圆角
waveformConfig.showStroke = true
waveformConfig.strokeColor = .white
waveformConfig.cornerRadius = 2
```

---

## 使用示例

### 示例 1: 基本波形图

```swift
Task {
    do {
        let image = try await LSWaveformImageDrawer.image(
            from: audioURL,
            size: CGSize(width: 300, height: 100)
        )
        imageView.image = image
    } catch {
        print("生成失败: \(error)")
    }
}
```

### 示例 2: 频谱风格

```swift
let config = LSDefaultWaveformConfiguration.spectrum(barCount: 40)

let image = try await LSWaveformImageDrawer.image(
    from: audioURL,
    size: CGSize(width: 400, height: 100),
    configuration: config
)
```

### 示例 3: 圆形布局

```swift
let config = LSDefaultWaveformConfiguration.circular(barCount: 60)

let image = try await LSWaveformImageDrawer.image(
    from: audioURL,
    size: CGSize(width: 300, height: 300),
    configuration: config
)
```

### 示例 4: 自定义渐变

```swift
let config = LSDefaultWaveformConfiguration()
config.numberOfBars = 50
config.layoutMode = .symmetric
config.barColorMode = .gradientHorizontal(
    [UIColor(red: 1, green: 0, blue: 0, alpha: 1),
     UIColor(red: 1, green: 1, blue: 0, alpha: 1),
     UIColor(red: 0, green: 1, blue: 0, alpha: 1)],
    locations: [0.0, 0.5, 1.0]
)

let image = try await LSWaveformImageDrawer.image(
    from: audioURL,
    size: CGSize(width: 400, height: 150),
    configuration: config
)
```

---

## API 参考

### LSWaveformImageDrawer

#### 初始化

```swift
init(configuration: ImageConfiguration = .default())
```

#### 方法

```swift
// 异步生成（推荐）
func waveformImage(from audioURL: URL, config: ImageConfiguration? = nil) async throws -> UIImage

// 同步生成
func waveformImage(from audioURL: URL, config: ImageConfiguration? = nil) throws -> UIImage

// 从样本生成
func waveformImage(from samples: [Float], config: ImageConfiguration? = nil) -> UIImage
```

#### 静态方法

```swift
// 异步
static func image(from audioURL: URL, size: CGSize, configuration: LSWaveformConfiguration) async throws -> UIImage

// 同步（从样本）
static func image(from samples: [Float], size: CGSize, configuration: LSWaveformConfiguration) -> UIImage
```

### LSWaveformAnalyzer

用于从音频文件提取样本数据的分析器。

```swift
let analyzer = LSWaveformAnalyzer(audioURL: url)

// 自定义分析配置
analyzer.configuration = .init(
    sampleRate: 100,              // 每秒采样数
    shouldNormalize: true,        // 是否归一化
    minimumSampleCount: 100,      // 最小样本数
    maximumSampleCount: 10000     // 最大样本数
)

// 分析音频
let samples = try await analyzer.analyze()
```

---

## 性能优化

### 调整采样率

```swift
// 高质量（更多样本，更慢）
analyzer.configuration.sampleRate = 200

// 快速生成（更少样本，更快）
analyzer.configuration.sampleRate = 50
```

### 缓存生成的图像

```swift
// 使用文件名作为缓存键
let cacheKey = audioURL.lastPathComponent
let cachedPath = FileManager.default.temporaryDirectory.appendingPathComponent("waveform_\(cacheKey).png")

if let cachedImage = UIImage(contentsOfFile: cachedPath.path) {
    return cachedImage
}

// 生成并缓存
let image = try await drawer.waveformImage(from: audioURL)
try? image.pngData()?.write(to: cachedPath)
```

---

## 错误处理

```swift
do {
    let image = try await LSWaveformImageDrawer.image(from: audioURL)
    imageView.image = image
} catch LSWaveformAnalyzer.AnalyzerError.fileNotFound(let url) {
    print("文件未找到: \(url)")
} catch LSWaveformAnalyzer.AnalyzerError.invalidFormat {
    print("无效的音频格式")
} catch {
    print("其他错误: \(error)")
}
```

---

## 常见问题

### Q: 支持哪些音频格式？

A: 支持 AVFoundation 支持的所有格式，包括 MP3、M4A、WAV、AAC 等。

### Q: 如何生成更清晰的波形？

A: 增加 `numberOfBars` 和 `sampleRate`：
```swift
config.numberOfBars = 100
analyzer.configuration.sampleRate = 200
```

### Q: 可以生成带背景的图像吗？

A: 可以，设置 `backgroundColor`：
```swift
var config = LSWaveformImageDrawer.ImageConfiguration.default(size: size)
config.backgroundColor = .white
```

### Q: 如何调整波形的位置？

A: 使用 `padding` 属性：
```swift
config.padding = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
```
