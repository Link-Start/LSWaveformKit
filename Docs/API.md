# LSWaveformKit API 文档

## 目录

- [核心类](#核心类)
- [配置协议](#配置协议)
- [枚举类型](#枚举类型)
- [手势处理](#手势处理)
- [音频处理](#音频处理)
- [样式预设](#样式预设)
- [音乐播放器功能](#音乐播放器功能)

---

## 核心类

### LSWaveformView

所有波形视图的基类，提供核心功能和配置接口。

```swift
public class LSWaveformView: UIView
```

#### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `configuration` | `LSWaveformConfiguration` | 波形配置 |
| `dataSource` | `LSWaveformViewDataSource?` | 数据源代理 |
| `delegate` | `LSWaveformViewDelegate?` | 事件代理 |
| `bars` | `[LSWaveformBar]` | 条纹数组（只读） |
| `audioProcessor` | `LSWaveformAudioProcessor?` | 音频处理器（只读） |
| `gestureHandler` | `LSWaveformGestureHandler?` | 手势处理器（只读） |
| `animator` | `LSWaveformAnimator?` | 动画器（只读） |
| `currentAmplitude` | `Float` | 当前音量（只读，0.0-1.0） |
| `isRecording` | `Bool` | 是否正在录音（只读） |
| `isPlaying` | `Bool` | 是否正在播放（只读） |

#### 方法

##### 录音控制

```swift
/// 开始录音
public func startRecording()

/// 停止录音
public func stopRecording()

/// 取消录音
public func cancelRecording()

/// 暂停录音
public func pauseRecording()

/// 恢复录音
public func resumeRecording()
```

##### 播放控制

```swift
/// 播放音频
public func playAudio(at url: URL)

/// 停止播放
public func stopPlaying()

/// 暂停播放
public func pausePlaying()

/// 恢复播放
public func resumePlaying()

/// 跳转到指定时间
public func seek(to time: TimeInterval)
```

##### 波形更新

```swift
/// 更新音量
/// - Parameter amplitude: 音量值（0.0 ~ 1.0）
public func updateAmplitude(_ amplitude: Float)

/// 重置波形
public func resetWaveform()

/// 刷新波形显示
public func refreshWaveform()
```

##### 样式应用

```swift
/// 应用预设风格
/// - Parameter style: 风格枚举
public func applyStyle(_ style: LSWaveformStyle)

/// 应用自定义配置
/// - Parameter configuration: 配置对象
public func applyConfiguration(_ configuration: LSWaveformConfiguration)
```

##### 代理回调

```swift
extension LSWaveformView {
    /// 录音开始回调
    public var onRecordingStart: (() -> Void)?

    /// 录音停止回调
    public var onRecordingStop: ((URL?, TimeInterval) -> Void)?

    /// 录音取消回调
    public var onRecordingCancel: (() -> Void)?

    /// 音量更新回调
    public var onAmplitudeUpdate: ((Float) -> Void)?
}
```

---

### LSWaveformConfiguration

波形配置协议，定义所有可配置的属性。

```swift
public protocol LSWaveformConfiguration {
    // MARK: - 基础配置

    /// 条纹数量
    var numberOfBars: Int { get set }

    /// 条纹宽度
    var barWidth: CGFloat { get set }

    /// 条纹间距
    var barSpacing: CGFloat { get set }

    // MARK: - 模式配置

    /// 条纹高度模式
    var barHeightMode: LSBarHeightMode { get set }

    /// 布局模式
    var layoutMode: LSLayoutMode { get set }

    // MARK: - 高度配置

    /// 最小条形高度
    var minimumBarHeight: CGFloat { get set }

    /// 最大条形高度
    var maximumBarHeight: CGFloat { get set }

    /// 基础高度
    var baseHeight: CGFloat { get set }

    // MARK: - 颜色配置

    /// 条纹颜色模式
    var barColorMode: LSBarColorMode { get set }

    /// 条纹颜色（单一颜色快捷方式）
    var barColor: UIColor { get set }

    /// 渐变色（渐变快捷方式）
    var gradientColors: [UIColor]? { get set }

    // MARK: - 动画配置

    /// 动画时长
    var animationDuration: TimeInterval { get set }

    /// 动画曲线
    var animationCurve: UIView.AnimationCurve { get set }

    // MARK: - 描边配置

    /// 是否显示描边
    var showStroke: Bool { get set }

    /// 描边颜色
    var strokeColor: UIColor { get set }

    /// 描边宽度
    var strokeWidth: CGFloat { get set }

    /// 圆角半径
    var cornerRadius: CGFloat { get set }

    // MARK: - 间距配置

    /// 间距模式
    var spacingMode: LSSpacingMode { get set }

    // MARK: - 高级配置

    /// 刷新率（FPS）
    var refreshRate: Int { get set }

    /// 是否启用阴影
    var enableShadow: Bool { get set }

    /// 阴影颜色
    var shadowColor: UIColor? { get set }

    /// 阴影偏移
    var shadowOffset: CGSize { get set }

    /// 阴影模糊半径
    var shadowRadius: CGFloat { get set }
}
```

#### 默认实现

```swift
public struct LSDefaultWaveformConfiguration: LSWaveformConfiguration {
    public init()

    // 便捷初始化方法
    public static func symmetric(barCount: Int = 30) -> LSDefaultWaveformConfiguration
    public static func horizontal(barCount: Int = 50) -> LSDefaultWaveformConfiguration
    public static func circular(barCount: Int = 60) -> LSDefaultWaveformConfiguration
    public static func spectrum(barCount: Int = 40) -> LSDefaultWaveformConfiguration
}
```

---

## 枚举类型

### LSBarHeightMode（条纹高度模式）

```swift
public enum LSBarHeightMode: Equatable {
    case symmetric                      // 对称（中间高，两边低）
    case random                          // 随机模式
    case ascending                       // 从左到右依次升高
    case descending                      // 从左到右依次降低
    case highLow                         // 高低高低
    case lowHigh                         // 低高低高
    case highHighLowLow                  // 高高低低
    case lowLowHighHigh                  // 低低高高
    case highHighLowHigh                 // 高高低高低
    case lowLowHighLowHigh               // 低低高低高
    case uniform                         // 一样高
    case custom([Float])                 // 自定义高度数组
    case highToLow                       // 先高后低
    case lowToHigh                       // 先低后高
    case uneven(randomFactor: Float)     // 参差不齐
}
```

### LSLayoutMode（布局模式）

```swift
public enum LSLayoutMode {
    case symmetric                       // 左右对称
    case leftOnly                        // 仅左侧
    case rightOnly                       // 仅右侧
    case horizontal                      // 水平排列
    case circular                        // 圆形排列
    case arc(startAngle: CGFloat, endAngle: CGFloat)  // 弧形排列
    case spiral                         // 螺旋排列
    case grid(rows: Int, columns: Int)  // 网格排列
    case custom(layout: LSCustomLayout)  // 自定义布局
}
```

### LSBarColorMode（条纹颜色模式）

```swift
public enum LSBarColorMode {
    case single(UIColor)                                    // 单一颜色
    case multiple([UIColor], cycle: Bool)                  // 多种颜色（循环使用）
    case gradientVertical([UIColor], locations: [NSNumber])  // 垂直渐变
    case gradientHorizontal([UIColor], locations: [NSNumber]) // 水平渐变
    case gradientDiagonal([UIColor], locations: [NSNumber])   // 对角渐变
    case gradientRadial([UIColor], locations: [NSNumber])    // 径向渐变
    case perBar([UIColor])                                  // 每条独立颜色
    case amplitudeBased(low: UIColor, high: UIColor)        // 基于音量的动态颜色
    case frequencyBased([UIColor])                        // 基于频率的颜色（频谱图）
    case custom(LSBarColorProvider)                         // 自定义颜色提供者
    case rainbow                                             // 彩虹渐变
}
```

### LSSpacingMode（间距模式）

```swift
public enum LSSpacingMode {
    case equal(CGFloat)                                    // 等间距
    case unequal([CGFloat])                                // 不等间距（数组指定）
    case gradient(min: CGFloat, max: CGFloat)             // 渐变间距
    case custom((Int, Int, CGFloat) -> CGFloat)           // 自定义（block）
    case delegate(LSSpacingDelegate)                     // 代理方法
    case amplitudeBased(min: CGFloat, max: CGFloat)       // 基于音量的动态间距
    case wave(min: CGFloat, max: CGFloat, frequency: CGFloat)  // 波浪形间距
}
```

### LSWaveformStyle（波形风格）

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

---

## 手势处理

### LSWaveformGestureHandler

手势处理器，管理录音相关的所有手势操作。

```swift
public class LSWaveformGestureHandler: NSObject
```

#### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `state` | `State` | 当前手势状态 |
| `configuration` | `GestureConfiguration` | 手势配置 |
| `delegate` | `LSWaveformGestureHandlerDelegate?` | 代理 |

#### 状态枚举

```swift
public enum State {
    case idle        // 空闲
    case recording   // 录音中
    case canceling   // 取消中（手指滑动到取消区域）
    case locked      // 锁定（忽略手势）
}
```

#### 配置结构

```swift
public struct GestureConfiguration {
    var isLongPressEnabled: Bool = true          // 是否启用长按录音
    var isTapEnabled: Bool = false               // 是否启用点击录音
    var isPanToCancelEnabled: Bool = true        // 是否启用滑动取消
    var cancelThreshold: CGFloat = 100           // 滑动取消阈值（像素）
    var minimumPressDuration: TimeInterval = 0.3  // 最小长按时长
    var allowableMovement: CGFloat = 100         // 允许的滑动距离
    var cancelArea: CGRect = .zero               // 取消区域（CGRect）
}
```

#### 代理协议

```swift
public protocol LSWaveformGestureHandlerDelegate: AnyObject {
    /// 开始录音
    func gestureHandlerDidBeginRecording(_ handler: LSWaveformGestureHandler)

    /// 结束录音
    func gestureHandlerDidEndRecording(_ handler: LSWaveformGestureHandler)

    /// 取消录音
    func gestureHandlerDidCancelRecording(_ handler: LSWaveformGestureHandler)

    /// 即将取消（手指进入取消区域）
    func gestureHandlerWillCancelRecording(_ handler: LSWaveformGestureHandler)

    /// 取消进度更新
    func gestureHandler(_ handler: LSWaveformGestureHandler, updateCancelProgress progress: CGFloat)
}
```

---

## 音频处理

### LSWaveformAudioProcessor

音频处理器，负责录音、播放和音频分析。

```swift
public class LSWaveformAudioProcessor: NSObject
```

#### 属性

| 属性 | 类型 | 说明 |
|------|------|------|
| `delegate` | `LSWaveformAudioProcessorDelegate?` | 代理 |
| `state` | `State` | 当前状态 |
| `updateInterval` | `TimeInterval` | 更新间隔（秒） |
| `outputURL` | `URL` | 输出文件路径 |
| `recordingDuration` | `TimeInterval` | 录音时长（只读） |

#### 状态枚举

```swift
public enum State {
    case idle        // 空闲
    case recording   // 录音中
    case playing     // 播放中
    case paused      // 已暂停
}
```

#### 方法

```swift
/// 开始录音
public func startRecording() -> Bool

/// 停止录音
public func stopRecording()

/// 取消录音
public func cancelRecording()

/// 播放音频
public func playAudio(at url: URL)

/// 停止播放
public func stopPlaying()
```

#### 代理协议

```swift
public protocol LSWaveformAudioProcessorDelegate: AnyObject {
    /// 音量更新
    func audioProcessor(_ processor: LSWaveformAudioProcessor, didUpdateAmplitude amplitude: Float)

    /// 开始录音
    func audioProcessorDidStartRecording(_ processor: LSWaveformAudioProcessor)

    /// 停止录音
    func audioProcessorDidStopRecording(_ processor: LSWaveformAudioProcessor)

    /// 错误发生
    func audioProcessor(_ processor: LSWaveformAudioProcessor, didOccur error: Error)
}
```

---

## 样式预设

### 基础风格

| 风格 | 描述 | 适用场景 |
|------|------|----------|
| `default` | 默认风格 | 通用 |
| `qq` | QQ经典风格 | 即时通讯 |
| `wechat` | 微信风格 | 社交应用 |
| `whatsapp` | WhatsApp风格 | 即时通讯 |
| `ios` | iOS系统风格 | iOS应用 |

### 音乐播放器风格

| 风格 | 描述 | 特色 |
|------|------|------|
| `kugou` | 酷狗音乐 | 彩色频谱光柱、7色彩虹 |
| `qqmusic` | QQ音乐 | 多彩渐变、发光阴影 |
| `kuwo` | 酷我音乐 | 炫彩渐变、律动光柱 |
| `luoxue` | 落雪 | 柔和渐变、雪花飘落 |
| `netease` | 网易云音乐 | 红色主题、优雅曲线 |
| `spotify` | Spotify | 绿色渐变、简洁现代 |
| `applemusic` | Apple Music | 红色高光、弹跳动画 |

### 特效风格

| 风格 | 描述 | 特色 |
|------|------|------|
| `neon` | 霓虹风格 | 紫粉渐变、强烈发光 |
| `minimal` | 极简风格 | 单色、简洁线条 |
| `retro` | 复古风格 | 多色循环、像素感 |
| `glassmorphism` | 玻璃拟态 | 半透明、模糊效果 |

---

## 音乐播放器功能

### 歌词同步

```swift
/// 歌词同步配置
public struct LSLyricsSynchronizationConfiguration {
    var lyricsFilePath: String?                    // LRC 文件路径
    var lyricsData: [LSLyricLine]?                 // 歌词数据
    var showLyrics: Bool = true                     // 是否显示歌词
    var lyricsFont: UIFont = PingFangSCRegular(size: 16)
    var highlightColor: UIColor = UIColor_00CBE0()  // 高亮颜色
    var normalColor: UIColor = UIColor_D1D6D9()      // 普通颜色
    var lyricsPosition: LSPosition = .top           // 歌词位置
    var triggerWaveformOnLyric: Bool = true         // 歌词到达时触发特效
    var lyricAnimation: LSWaveformAnimation = .pulse // 特效类型
}
```

### 节拍检测

```swift
/// 节拍检测配置
public struct LSBeatDetectionConfiguration {
    var isEnabled: Bool = true                       // 是否启用
    var sensitivity: Float = 0.5                    // 检测灵敏度
    var minBPM: Int = 60                            // 最小 BPM
    var maxBPM: Int = 200                           // 最大 BPM
    var beatEffect: LSBeatEffect = .glow          // 节拍效果
    var showBPM: Bool = false                       // 显示 BPM
    var onBeatDetected: ((TimeInterval, Float) -> Void)?  // 节拍回调
}

public enum LSBeatEffect {
    case glow
    case scale
    case colorFlash
    case pulse
    case shake
    case custom((LSWaveformView) -> Void)
}
```

### 音乐特效

```swift
/// 音乐特效配置
public struct LSMusicEffectConfiguration {
    var enableSpectrumAnalysis: Bool = true         // 启用频谱分析
    var fftSize: Int = 2048                         // FFT 大小
    var frequencyRange: ClosedRange<Float> = 20...20000  // 频率范围
    var spectrumBarCount: Int = 64                  // 频谱柱数量
    var showFrequencyLabels: Bool = false            // 显示频率标签
    var colorMapping: LSColorMapping = .rainbow     // 颜色映射
    var smoothSpectrum: Bool = true                  // 平滑频谱
    var smoothingFactor: Float = 0.3                // 平滑因子
}

public enum LSColorMapping {
    case rainbow
    case heat
    case ocean
    case fire
    case neon
    case grayscale
    case custom((Float) -> UIColor)
}
```

---

## 使用示例

### 示例 1：基础录音

```swift
import LSWaveformKit

class ViewController: UIViewController {
    private lazy var waveformView: LSWaveformView = {
        let view = LSWaveformView()
        view.frame = CGRect(x: 0, y: 100, width: view.bounds.width, height: 60)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor_020120()
        view.addSubview(waveformView)
    }

    @objc func recordButtonTapped() {
        if waveformView.isRecording {
            waveformView.stopRecording()
        } else {
            waveformView.startRecording()
        }
    }
}
```

### 示例 2：应用音乐播放器风格

```swift
// 应用酷狗音乐风格
waveformView.applyStyle(.kugou)

// 应用QQ音乐风格
waveformView.applyStyle(.qqmusic)

// 应用自定义配置
let config = LSDefaultWaveformConfiguration()
config.numberOfBars = 40
config.barColorMode = .frequencyBased([
    UIColor(hex: "#FF0000"),
    UIColor(hex: "#00FF00"),
    UIColor(hex: "#0000FF")
])
config.layoutMode = .horizontal
waveformView.applyConfiguration(config)
```

### 示例 3：歌词同步

```swift
waveformView.lyricsConfig = LSLyricsSynchronizationConfiguration(
    lyricsFilePath: Bundle.main.path(forResource: "song", ofType: "lrc"),
    showLyrics: true,
    highlightColor: UIColor_00CBE0(),
    triggerWaveformOnLyric: true,
    lyricAnimation: .pulse
)

// 设置歌词位置
waveformView.lyricsConfig?.lyricsPosition = .bottom
```

### 示例 4：节拍检测

```swift
waveformView.beatConfig = LSBeatDetectionConfiguration(
    isEnabled: true,
    beatEffect: .glow,
    onBeatDetected: { time, intensity in
        print("节拍！时间：\(time)，强度：\(intensity)")
    }
)
```

### 示例 5：自定义颜色模式

```swift
// 基于音量的动态颜色
waveformView.configuration.barColorMode = .amplitudeBased(
    low: UIColor(hex: "#4A90E2"),
    high: UIColor(hex: "#E74C3C")
)

// 多种颜色循环
waveformView.configuration.barColorMode = .multiple([
    UIColor_00CBE0(),
    UIColor_F21F14(),
    UIColor_2F665C()
], cycle: true)

// 垂直渐变
waveformView.configuration.barColorMode = .gradientVertical(
    colors: [
        UIColor_00CBE0().withAlphaComponent(0.3),
        UIColor_00CBE0().withAlphaComponent(1.0)
    ],
    locations: [0.0, 1.0]
)
```

### 示例 6：自定义间距

```swift
// 等间距
waveformView.configuration.spacingMode = .equal(8)

// 不等间距（数组）
waveformView.configuration.spacingMode = .unequal([2, 4, 6, 8, 10, 8, 6, 4, 2])

// 渐变间距
waveformView.configuration.spacingMode = .gradient(min: 2, max: 10)

// 自定义间距（block）
waveformView.configuration.spacingMode = .custom { index, total, defaultSpacing in
    let center = Float(total) / 2.0
    let distance = abs(Float(index) - center)
    let factor = 1.0 - (distance / center)
    return defaultSpacing * (1.0 + factor)
}

// 代理方法
waveformView.configuration.spacingMode = .delegate(self)
```
