# LSWaveformKit 架构设计文档

## 概述

LSWaveformKit 采用分层架构设计，核心逻辑与平台特定代码分离，实现代码复用和多平台支持。

## 架构分层

```
┌─────────────────────────────────────────────────────────────┐
│                    应用层 (Application)                      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   UIKit App  │  │ SwiftUI App  │  │   Objective-C │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                   平台适配层 (Platform)                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   UIKit      │  │   SwiftUI    │  │  ObjectiveC  │      │
│  │   Views      │  │   Views      │  │   Views      │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                   核心逻辑层 (Core) - 共享                    │
│  ┌─────────────────────────────────────────────────────┐  │
│  │  Audio │ Mathematics │ Animation │ Gesture │ Config │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│                   系统框架层 (Framework)                      │
│  AVFoundation │ Core Audio │ Accelerate │ Metal │ CoreHaptics│
└─────────────────────────────────────────────────────────────┘
```

## 目录结构

```
LSWaveformKit/
├── LSWaveformKit.podspec              # Podspec 配置
├── README.md                          # 项目说明
├── LICENSE                            # MIT 许可证
├── CHANGELOG.md                       # 变更日志
├── Docs/                              # 文档目录
│   ├── API.md                         # API 文档
│   ├── ARCHITECTURE.md                # 架构文档（本文件）
│   └── Examples.md                    # 使用示例
│
├── Example/                           # 示例项目
│   ├── iOS/                          # iOS 示例
│   │   ├── LSWaveformKitDemo/        # 主项目
│   │   ├── Assets.xcassets/         # 资源文件
│   │   └── ViewController.swift    # 示例代码
│   ├── SwiftUI/                     # SwiftUI 示例
│   └── ObjectiveC/                  # OC 示例
│
└── Sources/                           # 源代码
    ├── Core/                         # 核心逻辑（所有平台共享）
    │   ├── Audio/
    │   │   ├── LSWaveformAudioProcessor.swift      # 音频处理器
    │   │   ├── LSWaveformRecorder.swift             # 录音器
    │   │   ├── LSWaveformPlayer.swift               # 播放器
    │   │   └── LSFFTAnalyzer.swift                   # FFT分析器
    │   │
    │   ├── Mathematics/
    │   │   ├── LSWaveformMath.swift                 # 波形数学
    │   │   ├── LSDecibelConverter.swift             # dB转换
    │   │   └── LSAmplitudeNormalizer.swift          # 幅值标准化
    │   │
    │   ├── Animation/
    │   │   ├── LSWaveformAnimator.swift             # 动画器
    │   │   ├── LSAnimationTiming.swift               # 动画时序
    │   │   └── LSSmoothInterpolator.swift            # 平滑插值
    │   │
    │   ├── Gesture/
    │   │   ├── LSWaveformGestureHandler.swift       # 手势处理器
    │   │   ├── LSLongPressGestureRecognizer.swift   # 长按手势
    │   │   ├── LSPanCancelGestureRecognizer.swift    # 滑动取消
    │   │   └── LSTapRecordGestureRecognizer.swift     # 点击录音
    │   │
    │   ├── Configuration/
    │   │   ├── LSWaveformConfiguration.swift         # 配置协议
    │   │   ├── LSBarHeightMode.swift                 # 高度模式
    │   │   ├── LSLayoutMode.swift                    # 布局模式
    │   │   └── LSWaveformStyle.swift                 # 波形风格
    │   │
    │   ├── Models/
    │   │   ├── LSWaveformBar.swift                   # 条纹模型
    │   │   ├── LSWaveformModel.swift                 # 波形模型
    │   │   └── LSAudioSession.swift                  # 音频会话
    │   │
    │   └── Extensions/
    │       ├── UIColor+LSWaveformKit.swift          # 颜色扩展
    │       └── Array+LSWaveformKit.swift            # 数组扩展
    │
    ├── UIKit/                         # UIKit 实现
    │   ├── Views/
    │   │   ├── LSWaveformView.swift                 # 基类波形视图
    │   │   ├── LSSymmetricWaveformView.swift         # 对称波形
    │   │   ├── LSHorizontalWaveformView.swift        # 水平波形
    │   │   ├── LSCircularWaveformView.swift          # 圆形波形
    │   │   └── LSSpectrumWaveformView.swift          # 频谱波形
    │   │
    │   ├── Recording/
    │   │   ├── LSRecordingButton.swift               # 录音按钮
    │   │   ├── LSRecordingContainer.swift            # 录音容器
    │   │   └── LSRecordingHUD.swift                  # 录音HUD
    │   │
    │   └── Utils/
    │       ├── LSWaveformRenderer.swift              # 渲染器
    │       └── LSGradientHelper.swift                # 渐变辅助
    │
    ├── SwiftUI/                      # SwiftUI 实现
    │   ├── Views/
    │   │   ├── LSWaveformView.swift                 # SwiftUI波形
    │   │   ├── LSSymmetricWaveformView.swift
    │   │   ├── LSRecordingButton.swift
    │   │   └── LSWaveformPicker.swift                # 波形选择器
    │   │
    │   └── ViewModifiers/
    │       ├── LSWaveformStyleModifier.swift
    │       └── LSAnimationModifier.swift
    │
    ├── ObjectiveC/                    # Objective-C 实现
    │   ├── LSWaveformView.h/m                 # 主视图
    │   ├── LSSymmetricWaveformView.h/m         # 对称波形
    │   └── LSWaveformRecorder.h/m             # 录音器
    │
    └── Presets/                       # 预设配置
        ├── LSDefaultConfiguration.swift    # 默认配置
        ├── LSWaveformStylePresets.swift       # 风格预设
        └── LSMusicPlayerPresets.swift        # 音乐播放器预设
```

## 核心类设计

### LSWaveformView（基类）

所有波形视图的基类，提供核心功能：

```swift
public class LSWaveformView: UIView {
    // 配置
    public var configuration: LSWaveformConfiguration

    // 数据源
    public weak var dataSource: LSWaveformViewDataSource?
    public weak var delegate: LSWaveformViewDelegate?

    // 核心组件
    private(set) public var bars: [LSWaveformBar] = []
    private(set) public var audioProcessor: LSWaveformAudioProcessor?
    private(set) public var gestureHandler: LSWaveformGestureHandler?
    private(set) public var animator: LSWaveformAnimator?

    // 公开方法
    public func startRecording()
    public func stopRecording()
    public func cancelRecording()
    public func updateAmplitude(_ amplitude: Float)
    public func resetWaveform()

    // 样式应用
    public func applyStyle(_ style: LSWaveformStyle)
}
```

### LSWaveformConfiguration（配置协议）

```swift
public protocol LSWaveformConfiguration {
    // 基础配置
    var numberOfBars: Int { get set }
    var barWidth: CGFloat { get set }
    var barSpacing: CGFloat { get set }

    // 模式配置
    var barHeightMode: LSBarHeightMode { get set }
    var layoutMode: LSLayoutMode { get set }

    // 高度配置
    var minimumBarHeight: CGFloat { get set }
    var maximumBarHeight: CGFloat { get set }

    // 颜色配置
    var barColorMode: LSBarColorMode { get set }

    // 动画配置
    var animationDuration: TimeInterval { get set }

    // 间距配置
    var spacingMode: LSSpacingMode { get set }
}
```

### LSWaveformStyle（风格枚举）

```swift
public enum LSWaveformStyle: String, CaseIterable {
    // 基础风格
    case `default`
    case qq
    case wechat
    case whatsapp
    case ios

    // 音乐播放器风格
    case kugou
    case qqmusic
    case kuwo
    case luoxue
    case netease
    case xiami
    case spotify
    case applemusic
    case youtubemusic

    // 特效风格
    case neon
    case minimal
    case retro
    case glassmorphism
}
```

## 数据流图

```
┌──────────────┐
│  Audio File  │
└──────┬───────┘
       │
       ▼
┌──────────────────────────────┐
│  AVAudioRecorder / Player   │
└──────┬───────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│  LSWaveformAudioProcessor   │
│  - extract audio data        │
│  - FFT analysis             │
│  - calculate amplitude       │
└──────┬───────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│   updateAmplitude()         │
└──────┬───────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│  updateBarsHeight()         │
│  - 根据 barHeightMode       │
│  - 应用间距模式            │
│  - 应用颜色模式            │
└──────┬───────────────────────┘
       │
       ▼
┌──────────────────────────────┐
│      draw() / setNeedsDisplay() │
│  - Core Graphics 渲染       │
│  - 或 Canvas 渲染           │
│  - 或 Metal 渲染            │
└──────────────────────────────┘
```

## 关键技术点

### 1. 音频数据处理

- **AVAudioRecorder**: 录音时获取音频数据
- **AVAudioPlayer**: 播放时使用模拟数据
- **updateMeters()**: 获取平均音量（dB）
- **normalizePower()**: 转换为 0.0-1.0 幅值

### 2. 波形高度计算

```swift
private func updateBarsHeight() {
    switch configuration.barHeightMode {
    case .symmetric:
        updateBarsSymmetrically(with: amplitude)
    case .random:
        updateBarsRandomly(with: amplitude)
    case .ascending:
        updateBarsAscending(with: amplitude)
    case .highLow:
        updateBarsHighLow(with: amplitude)
    // ... 其他模式
    }
}
```

### 3. 颜色应用

```swift
private func applyBarColor(_ bar: LSWaveformBar, index: Int) {
    switch configuration.barColorMode {
    case .single(let color):
        bar.backgroundColor = color
    case .multiple(let colors, let cycle):
        bar.backgroundColor = colors[index % colors.count]
    case .gradientVertical(let colors, let locations):
        // 应用渐变
    case .frequencyBased(let colors):
        // 根据频率应用颜色
    case .amplitudeBased(let low, let high):
        // 根据音量应用颜色
    }
}
```

### 4. 间距计算

```swift
private func calculateSpacing(for index: Int) -> CGFloat {
    switch configuration.spacingMode {
    case .equal(let spacing):
        return spacing
    case .unequal(let spacings):
        return spacings[index % spacings.count]
    case .custom(let calculator):
        return calculator(index, bars.count, defaultSpacing)
    case .delegate(let delegate):
        return delegate.spacing(for: index, total: bars.count)
    }
}
```

### 5. 手势处理

```swift
@objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
    switch gesture.state {
    case .began:
        startRecording()
    case .changed:
        if isInCancelArea(gesture) {
            cancelRecording()
        }
    case .ended:
        stopRecording()
    default:
        break
    }
}
```

## 性能优化策略

### 1. 渲染优化

- **对象池**: 复用 UIView 对象，减少创建/销毁开销
- **CAShapeLayer**: 使用图层代替大量视图
- **异步绘制**: 在后台线程绘制，主线程渲染
- **增量更新**: 只更新变化的条纹

### 2. 动画优化

- **CADisplayLink**: 与屏幕刷新同步
- **帧率独立**: 基于时间而非帧数的动画
- **Delta 限制**: 限制最大 Delta 避免动画爆发

### 3. 内存优化

- **[weak self]**: 所有闭包使用弱引用
- **及时释放**: 不用时释放定时器、音频资源

## 扩展性设计

### 添加新的高度模式

```swift
// 1. 在 LSBarHeightMode 中添加 case
public enum LSBarHeightMode {
    // ... existing cases
    case wave  // 新增
}

// 2. 在 updateBarsHeight() 中添加处理
case .wave:
    updateBarsWave(with: amplitude)
```

### 添加新的布局模式

```swift
// 1. 实现 LSCustomLayout 协议
class MyCustomLayout: LSCustomLayout {
    func position(for index: Int, total: Int, in bounds: CGRect) -> CGPoint {
        // 自定义位置计算
    }

    func transform(for index: Int, total: Int) -> CGAffineTransform {
        // 自定义变换
    }
}

// 2. 使用
waveformView.configuration.layoutMode = .custom(layout: MyCustomLayout())
```

### 添加新的颜色模式

```swift
// 1. 在 LSBarColorMode 中添加 case
public enum LSBarColorMode {
    // ... existing cases
    case custom(LSCustomColorProvider)
}

// 2. 实现 LSCustomColorProvider 协议
class MyColorProvider: LSCustomColorProvider {
    func color(for bar: LSWaveformBar, index: Int, total: Int, amplitude: Float) -> UIColor {
        // 自定义颜色计算
    }
}
```

## 多平台实现策略

### Swift 共享代码

核心逻辑层使用 Swift 编写，所有平台共享：

```
Core/
├── Audio/          (Swift)
├── Mathematics/   (Swift)
├── Animation/      (Swift)
└── Configuration/  (Swift)
```

### 平台特定代码

#### UIKit

```swift
// UIKit 实现
import UIKit

class LSWaveformView: UIView {
    // UIKit 特定实现
}
```

#### SwiftUI

```swift
// SwiftUI 实现
import SwiftUI

struct LSWaveformView: View {
    var body: some View {
        // SwiftUI 实现
    }
}
```

#### Objective-C

```objc
// Objective-C 实现
@interface LSWaveformView: UIView
// OC 实现
@end
```

## 测试策略

### 单元测试

- 配置计算测试
- 颜色模式测试
- 间距计算测试
- 高度模式测试

### UI 测试

- 录音功能测试
- 手势交互测试
- 样式切换测试

### 性能测试

- FPS 监控
- 内存使用监控
- CPU 占用测试
