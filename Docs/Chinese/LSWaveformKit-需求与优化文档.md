# LSWaveformKit 需求与优化文档

> 文档状态: 持续更新中
> 最后更新: 2025-02-07
> 目的: 记录所有功能需求、优化建议和设计方案，方便开发参考

---

## 一、核心功能需求

### 1.1 多平台支持

| 平台 | 状态 | 说明 |
|------|------|------|
| 纯 Objective-C | 待开发 | 兼容老项目 |
| Objective-C + Swift 混合 | 待开发 | 桥接方案 |
| 纯 Swift (UIKit) | 待开发 | 现代iOS开发 |
| SwiftUI | 待开发 | iOS 15+ |

### 1.2 手势交互

- [ ] 长按录音
- [ ] 滑动取消
- [ ] 点击录音
- [ ] 双击暂停/恢复
- [ ] 捏合缩放波形
- [ ] 拖动选择区域
- [ ] 长按显示详细信息

### 1.3 音频处理

- [ ] 录音（支持 AAC/MP3/WAV/M4A）
- [ ] 播放（支持进度拖动）
- [ ] 暂停/恢复
- [ ] 格式转换
- [ ] 音频裁剪
- [ ] 音频合并
- [ ] 音频变速
- [ ] 音频变调
- [ ] FFT 频谱分析

### 1.4 视觉特效

- [ ] 渐变色
- [ ] 纯色
- [ ] 描边
- [ ] 条纹
- [ ] 阴影
- [ ] 发光
- [ ] 霓虹效果
- [ ] 模糊效果
- [ ] 透明度动画
- [ ] 旋转动画

---

## 二、条纹高度模式（12+种）

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

    // TODO: 后续可添加更多模式
    // - wave                           // 波浪形
    // - pulse                          // 脉冲形
    // - mirror                         // 镜像对称
}
```

---

## 三、条纹颜色设置 ⭐ 新增

### 3.1 颜色模式

```swift
/// 条纹颜色模式
public enum LSBarColorMode {
    /// 单一颜色
    case single(UIColor)

    /// 多种颜色（循环使用）
    case multiple([UIColor], cycle: Bool)

    /// 渐变色（从上到下）
    case gradientVertical([UIColor], locations: [NSNumber])

    /// 渐变色（从左到右）
    case gradientHorizontal([UIColor], locations: [NSNumber])

    /// 渐变色（对角线）
    case gradientDiagonal([UIColor], locations: [NSNumber])

    /// 径向渐变
    case gradientRadial([UIColor], locations: [NSNumber])

    /// 每条条纹独立颜色（通过数组指定）
    case perBar([UIColor])

    /// 基于音量的动态颜色
    case amplitudeBased(low: UIColor, high: UIColor)

    /// 基于频率的颜色（用于频谱图）
    case frequencyBased([UIColor])

    /// 自定义颜色（通过 block 或代理）
    case custom(LSBarColorProvider)

    /// Rainbow 渐变
    case rainbow
}

/// 条纹颜色提供者
public protocol LSBarColorProvider {
    func color(for bar: LSWaveformBar, index: Int, total: Int, amplitude: Float) -> UIColor
}
```

### 3.2 预设颜色方案

```swift
/// 预设颜色方案
public extension LSBarColorMode {

    /// 经典蓝色（默认）
    static var classicBlue: LSBarColorMode {
        return .single(UIColor_00CBE0())
    }

    /// QQ 风格渐变
    static var qqStyle: LSBarColorMode {
        return .gradientVertical([
            UIColor_2D2C2C().withAlphaComponent(0.0),
            UIColor_2C2C2C().withAlphaComponent(0.52),
            UIColor_2A2A2B().withAlphaComponent(0.81),
            UIColor_323333().withAlphaComponent(0.9),
            UIColor_2B2D30().withAlphaComponent(1.0)
        ], locations: [0.0, 0.2, 0.4, 0.7, 1.0])
    }

    /// 微信风格（绿色渐变）
    static var wechatStyle: LSBarColorMode {
        return .gradientVertical([
            UIColor(hex: "#07C160").withAlphaComponent(0.3),
            UIColor(hex: "#07C160").withAlphaComponent(1.0)
        ], locations: [0.0, 1.0])
    }

    /// 霓虹风格
    static var neon: LSBarColorMode {
        return .gradientDiagonal([
            UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),
            UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),
            UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        ], locations: [0.0, 0.5, 1.0])
    }

    /// 彩虹渐变
    static var rainbow: LSBarColorMode {
        return .rainbow
    }

    /// 火焰渐变（红黄）
    static var fire: LSBarColorMode {
        return .gradientVertical([
            UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
            UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0),
            UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        ], locations: [0.0, 0.5, 1.0])
    }

    /// 海洋渐变（蓝青）
    static var ocean: LSBarColorMode {
        return .gradientVertical([
            UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0),
            UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
        ], locations: [0.0, 1.0])
    }

    /// 基于音量的动态颜色
    static var amplitudeBased: LSBarColorMode {
        return .amplitudeBased(
            low: UIColor(hex: "#4A90E2"),
            high: UIColor(hex: "#E74C3C")
        )
    }

    /// 频谱色（低频到高频）
    static var spectrum: LSBarColorMode {
        return .frequencyBased([
            UIColor(hex: "#FF0000"),  // 低频 - 红
            UIColor(hex: "#FF7F00"),  // 中低频 - 橙
            UIColor(hex: "#FFFF00"),  // 中频 - 黄
            UIColor(hex: "#00FF00"),  // 中高频 - 绿
            UIColor(hex: "#0000FF"),  // 高频 - 蓝
            UIColor(hex: "#8B00FF")   // 超高频 - 紫
        ])
    }

    /// 夜间模式
    static var nightMode: LSBarColorMode {
        return .single(UIColor_020120())
    }

    /// 白天模式
    static var dayMode: LSBarColorMode {
        return .single(UIColor_FFFFFF())
    }
}
```

### 3.3 颜色设置 API

```swift
/// 波形视图配置
public protocol LSWaveformConfiguration {
    // ... 其他属性

    /// 条纹颜色模式
    var barColorMode: LSBarColorMode { get set }

    /// 条纹颜色（单一颜色快捷方式）
    var barColor: UIColor { get set }

    /// 渐变色（渐变快捷方式）
    var gradientColors: [UIColor]? { get set }
}

// 便捷设置
waveformView.configuration.barColorMode = .single(UIColor_00CBE0())
waveformView.configuration.barColorMode = .qqStyle
waveformView.configuration.barColorMode = .wechatStyle
waveformView.configuration.barColorMode = .rainbow
waveformView.configuration.barColorMode = .multiple([UIColor_00CBE0(), UIColor_F21F14()], cycle: true)
```

---

## 四、波形风格预设 ⭐ 新增

### 4.1 风格定义

基于研究的 25+ 库，提供以下预设风格：

```swift
/// 波形风格
public enum LSWaveformStyle: String, CaseIterable {
    /// 默认风格
    case `default`

    /// QQ 经典风格
    case qq

    /// 微信风格
    case wechat

    /// WhatsApp 风格
    case whatsapp

    /// iOS 系统风格（语音备忘录）
    case ios

    /// Telegram 风格
    case telegram

    /// Discord 风格
    case discord

    /// Spotify 风格（音频播放器）
    case spotify

    /// SoundCloud 风格
    case soundcloud

    /// Audacity 风格（音频编辑器）
    case audacity

    /// 霓虹赛博风格
    case neon

    /// 极简风格
    case minimal

    /// 复古风格
    case retro

    /// 玻璃拟态风格
    case glassmorphism

    /// 自定义风格
    case custom
}
```

### 4.2 风格配置

```swift
/// 风格配置
public struct LSWaveformStyleConfiguration {
    /// 风格名称
    public let name: String

    /// 条纹颜色模式
    public let barColorMode: LSBarColorMode

    /// 背景颜色
    public let backgroundColor: UIColor?

    /// 条纹形状
    public let barShape: LSBarShape

    /// 条纹圆角
    public let cornerRadius: CGFloat

    /// 是否显示描边
    public let showStroke: Bool

    /// 描边颜色
    public let strokeColor: UIColor?

    /// 描边宽度
    public let strokeWidth: CGFloat

    /// 阴影配置
    public let shadowConfiguration: LSShadowConfiguration?

    /// 动画配置
    public let animationConfiguration: LSAnimationConfiguration?

    /// 间距模式
    public let spacingMode: LSSpacingMode
}

/// 条纹形状
public enum LSBarShape {
    case rectangle          // 矩形
    case roundedRectangle   // 圆角矩形
    case capsule            // 胶囊形（完全圆角）
    case circle             // 圆形
    case diamond            // 菱形
    case triangle           // 三角形
    case custom(CGPath)     // 自定义路径
}

/// 阴影配置
public struct LSShadowConfiguration {
    let color: UIColor
    let offset: CGSize
    let radius: CGFloat
    let opacity: Float
}

/// 动画配置
public struct LSAnimationConfiguration {
    let duration: TimeInterval
    let curve: UIView.AnimationCurve
    let springDamping: CGFloat
    let initialVelocity: CGFloat
}
```

### 4.3 音乐播放器风格预设 ⭐ 新增

基于国内主流音乐播放器的可视化效果：

```swift
public extension LSWaveformStyleConfiguration {

    /// 酷狗音乐 - 频谱播放器风格
    /// 特点：彩色光柱、多音轨数据解析、动态光柱特效
    static var kugou: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "KuGou 频谱播放器",
            barColorMode: .frequencyBased([
                UIColor(hex: "#FF0000"),  // 低频 - 红
                UIColor(hex: "#FF7F00"),  // 中低频 - 橙
                UIColor(hex: "#FFFF00"),  // 中频 - 黄
                UIColor(hex: "#00FF00"),  // 中高频 - 绿
                UIColor(hex: "#00FFFF"),  // 高频 - 青
                UIColor(hex: "#0000FF"),  // 超高频 - 蓝
                UIColor(hex: "#FF00FF")   // 超超高频 - 紫
            ]),
            backgroundColor: UIColor_020120(),
            barShape: .capsule,
            cornerRadius: 3,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: LSShadowConfiguration(
                color: UIColor_00CBE0().withAlphaComponent(0.5),
                offset: CGSize(width: 0, height: 0),
                radius: 15,
                opacity: 1.0
            ),
            animationConfiguration: LSAnimationConfiguration(
                duration: 0.05,
                curve: .linear,
                springDamping: 1.0,
                initialVelocity: 0
            ),
            spacingMode: .equal(2)
        )
    }

    /// QQ 音乐风格
    /// 特点：嵌入式频谱、多彩渐变
    static var qqmusic: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "QQ Music",
            barColorMode: .gradientDiagonal([
                UIColor(hex: "#00D4FF").withAlphaComponent(0.3),
                UIColor(hex: "#00D4FF").withAlphaComponent(1.0),
                UIColor(hex: "#7B68EE").withAlphaComponent(1.0)
            ], locations: [0.0, 0.5, 1.0]),
            backgroundColor: UIColor_020120(),
            barShape: .roundedRectangle,
            cornerRadius: 2,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: LSShadowConfiguration(
                color: UIColor_00CBE0().withAlphaComponent(0.4),
                offset: CGSize(width: 0, height: 2),
                radius: 8,
                opacity: 1.0
            ),
            animationConfiguration: nil,
            spacingMode: .equal(3)
        )
    }

    /// 酷我音乐风格
    /// 特点：炫彩效果、律动光柱
    static var kuwo: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "KuWo Music",
            barColorMode: .gradientVertical([
                UIColor(hex: "#FF6B6B"),
                UIColor(hex: "#4ECDC4"),
                UIColor(hex: "#45B7D1"),
                UIColor(hex: "#96CEB4"),
                UIColor(hex: "#FFEAA7"),
                UIColor(hex: "#DFE6E9"),
                UIColor(hex: "#74B9FF")
            ], locations: [0.0, 0.16, 0.33, 0.5, 0.66, 0.83, 1.0]),
            backgroundColor: UIColor_020120(),
            barShape: .capsule,
            cornerRadius: 3,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: LSShadowConfiguration(
                color: UIColor(hex: "#FF6B6B").withAlphaComponent(0.6),
                offset: CGSize(width: 0, height: 0),
                radius: 20,
                opacity: 1.0
            ),
            animationConfiguration: LSAnimationConfiguration(
                duration: 0.08,
                curve: .easeOut,
                springDamping: 0.85,
                initialVelocity: 0.3
            ),
            spacingMode: .equal(4)
        )
    }

    /// 落雪（LuoXue）风格
    /// 特点：雪花飘落效果、柔和渐变
    static var luoxue: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "LuoXue",
            barColorMode: .gradientVertical([
                UIColor(hex: "#E8F4F8").withAlphaComponent(0.3),
                UIColor(hex: "#B8E6F0").withAlphaComponent(0.6),
                UIColor(hex: "#81D4FA").withAlphaComponent(0.9),
                UIColor(hex: "#4FC3F7").withAlphaComponent(1.0)
            ], locations: [0.0, 0.33, 0.66, 1.0]),
            backgroundColor: UIColor_020120(),
            barShape: .capsule,
            cornerRadius: 2,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: LSShadowConfiguration(
                color: UIColor_81D4FA.withAlphaComponent(0.3),
                offset: CGSize(width: 0, height: 0),
                radius: 10,
                opacity: 1.0
            ),
            animationConfiguration: LSAnimationConfiguration(
                duration: 0.1,
                curve: .easeInOut,
                springDamping: 0.9,
                initialVelocity: 0.2
            ),
            spacingMode: .wave(min: 2, max: 6, frequency: 0.3)
        )
    }

    /// 网易云音乐风格
    /// 特点：红色主题、优雅曲线
    static var netease: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "NetEase Cloud Music",
            barColorMode: .single(UIColor(hex: "#EC4141")),
            backgroundColor: UIColor_020120(),
            barShape: .capsule,
            cornerRadius: 2,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: LSShadowConfiguration(
                color: UIColor(hex: "#EC4141").withAlphaComponent(0.4),
                offset: CGSize(width: 0, height: 0),
                radius: 12,
                opacity: 1.0
            ),
            animationConfiguration: LSAnimationConfiguration(
                duration: 0.12,
                curve: .easeOut,
                springDamping: 0.8,
                initialVelocity: 0.4
            ),
            spacingMode: .equal(4)
        )
    }

    /// 虾米音乐风格
    /// 特点：蓝色主题、科技感
    static var xiami: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "Xiami Music",
            barColorMode: .gradientHorizontal([
                UIColor(hex: "#2196F3").withAlphaComponent(0.5),
                UIColor(hex: "#03A9F4").withAlphaComponent(1.0),
                UIColor(hex: "#00BCD4").withAlphaComponent(1.0)
            ], locations: [0.0, 0.5, 1.0]),
            backgroundColor: UIColor_020120(),
            barShape: .roundedRectangle,
            cornerRadius: 2,
            showStroke: true,
            strokeColor: UIColor_2196F3.withAlphaComponent(0.3),
            strokeWidth: 1,
            shadowConfiguration: nil,
            animationConfiguration: nil,
            spacingMode: .equal(3)
        )
    }

    /// Spotify 风格（已有）
    static var spotify: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "Spotify",
            barColorMode: .gradientVertical([
                UIColor(hex: "#1DB954").withAlphaComponent(0.5),
                UIColor(hex: "#1DB954").withAlphaComponent(1.0)
            ], locations: [0.0, 1.0]),
            backgroundColor: UIColor(hex: "#121212"),
            barShape: .roundedRectangle,
            cornerRadius: 2,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: nil,
            animationConfiguration: LSAnimationConfiguration(
                duration: 0.1,
                curve: .linear,
                springDamping: 1.0,
                initialVelocity: 0
            ),
            spacingMode: .equal(2)
        )
    }

    /// Apple Music 风格
    /// 特点：简洁优雅、红色高光
    static var applemusic: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "Apple Music",
            barColorMode: .single(UIColor(hex: "#FA233B").withAlphaComponent(0.9)),
            backgroundColor: UIColor_020120(),
            barShape: .capsule,
            cornerRadius: 2.5,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: LSShadowConfiguration(
                color: UIColor(hex: "#FA233B").withAlphaComponent(0.5),
                offset: CGSize(width: 0, height: 0),
                radius: 10,
                opacity: 1.0
            ),
            animationConfiguration: LSAnimationConfiguration(
                duration: 0.15,
                curve: .easeOut,
                springDamping: 0.7,
                initialVelocity: 0.5
            ),
            spacingMode: .equal(5)
        )
    }

    /// YouTube Music 风格
    /// 特点：多彩渐变、动感效果
    static var youtubemusic: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "YouTube Music",
            barColorMode: .gradientDiagonal([
                UIColor(hex: "#FF0000"),
                UIColor(hex: "#FF8800"),
                UIColor(hex: "#FFFF00"),
                UIColor(hex: "#00FF00"),
                UIColor(hex: "#00FFFF"),
                UIColor(hex: "#0000FF"),
                UIColor(hex: "#FF00FF")
            ], locations: [0.0, 0.16, 0.33, 0.5, 0.66, 0.83, 1.0]),
            backgroundColor: UIColor_020120(),
            barShape: .capsule,
            cornerRadius: 3,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: LSShadowConfiguration(
                color: UIColor_00CBE0().withAlphaComponent(0.5),
                offset: CGSize(width: 0, height: 0),
                radius: 18,
                opacity: 1.0
            ),
            animationConfiguration: nil,
            spacingMode: .equal(4)
        )
    }
}
```

---

### 4.4 音乐播放器特色功能 ⭐ 新增

基于音乐播放器的可视化需求：

#### 歌词同步波形

```swift
/// 歌词同步波形配置
public struct LSLyricsSynchronizationConfiguration {
    /// 歌词文件路径（LRC 格式）
    var lyricsFilePath: String?

    /// 歌词数据
    var lyricsData: [LSLyricLine]?

    /// 是否显示歌词
    var showLyrics: Bool = true

    /// 歌词字体
    var lyricsFont: UIFont = PingFangSCRegular(size: 16)

    /// 高亮歌词颜色
    var highlightColor: UIColor = UIColor_00CBE0()

    /// 普通歌词颜色
    var normalColor: UIColor = UIColor_D1D6D9()

    /// 歌词位置
    var lyricsPosition: LSPosition = .top

    /// 是否在歌词到达时触发波形特效
    var triggerWaveformOnLyric: Bool = true

    /// 歌词到达时的波形动画
    var lyricAnimation: LSWaveformAnimation = .pulse
}

/// 歌词行数据
public struct LSLyricLine {
    let time: TimeInterval     // 时间戳
    let text: String          // 歌词文本
    let duration: TimeInterval  // 持续时间
}

/// 歌词位置
public enum LSPosition {
    case top
    case bottom
    case center
    case custom(y: CGFloat)
}
```

#### 节拍检测与同步

```swift
/// 节拍检测配置
public struct LSBeatDetectionConfiguration {
    /// 是否启用节拍检测
    var isEnabled: Bool = true

    /// BPM 检测灵敏度
    var sensitivity: Float = 0.5

    /// 最小 BPM
    var minBPM: Int = 60

    /// 最大 BPM
    var maxBPM: Int = 200

    /// 节拍触发时的波形效果
    var beatEffect: LSBeatEffect = .glow

    /// 是否显示 BPM 信息
    var showBPM: Bool = false

    /// 节拍回调
    var onBeatDetected: ((TimeInterval, Float) -> Void)?
}

/// 节拍效果
public enum LSBeatEffect {
    case glow                    // 发光效果
    case scale                   // 缩放效果
    case colorFlash              // 颜色闪烁
    case pulse                   // 脉冲效果
    case shake                   // 震动效果
    case custom((LSWaveformView) -> Void)
}
```

#### 音乐特效增强

```swift
/// 音乐特效配置
public struct LSMusicEffectConfiguration {
    /// 是否启用频谱分析
    var enableSpectrumAnalysis: Bool = true

    /// FFT 大小（必须是2的幂）
    var fftSize: Int = 2048

    /// 频率范围（Hz）
    var frequencyRange: ClosedRange<Float> = 20...20000

    /// 频谱柱数量
    var spectrumBarCount: Int = 64

    /// 是否显示频率标签
    var showFrequencyLabels: Bool = false

    /// 颜色映射方式
    var colorMapping: LSColorMapping = .rainbow

    /// 是否平滑频谱数据
    var smoothSpectrum: Bool = true

    /// 平滑因子
    var smoothingFactor: Float = 0.3
}

/// 频率颜色映射
public enum LSColorMapping {
    case rainbow                 // 彩虹渐变
    case heat                    // 热力图（红-黄-绿）
    case ocean                   // 海洋（蓝-青-绿）
    case fire                    // 火焰（红-橙-黄）
    case neon                    // 霓虹（紫-粉-青）
    case grayscale              // 灰度
    case custom((Float) -> UIColor)  // 自定义映射
}
```

#### 音乐可视化模式

```swift
/// 音乐可视化模式
public enum LSMusicVisualizationMode {
    /// 频谱柱状图
    case spectrumBars

    /// 波形曲线
    case waveformCurve

    /// 圆形频谱
    case circularSpectrum

    /// 瀑布流频谱
    case waterfall

    /// 粒子效果
    case particles

    /// 3D 波形
    case waveform3D

    /// 混合模式
    case hybrid([LSMusicVisualizationMode])
}
```

---

### 4.5 预设风格详细配置

```swift
public extension LSWaveformStyleConfiguration {

    /// QQ 风格
    static var qq: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "QQ Classic",
            barColorMode: .qqStyle,
            backgroundColor: UIColor_020120(),
            barShape: .roundedRectangle,
            cornerRadius: 1.5,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: nil,
            animationConfiguration: LSAnimationConfiguration(
                duration: 0.1,
                curve: .linear,
                springDamping: 1.0,
                initialVelocity: 0
            ),
            spacingMode: .equal(8)
        )
    }

    /// 微信风格
    static var wechat: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "WeChat",
            barColorMode: .wechatStyle,
            backgroundColor: UIColor(hex: "#F2F2F2"),
            barShape: .capsule,
            cornerRadius: 2,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: nil,
            animationConfiguration: LSAnimationConfiguration(
                duration: 0.15,
                curve: .easeInOut,
                springDamping: 0.8,
                initialVelocity: 0.5
            ),
            spacingMode: .equal(3)
        )
    }

    /// WhatsApp 风格
    static var whatsapp: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "WhatsApp",
            barColorMode: .single(UIColor(hex: "#075E54")),
            backgroundColor: UIColor(hex: "#ECE5DD"),
            barShape: .capsule,
            cornerRadius: 3,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: nil,
            animationConfiguration: nil,
            spacingMode: .equal(2)
        )
    }

    /// iOS 系统风格
    static var ios: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "iOS System",
            barColorMode: .single(UIColor_00CBE0()),
            backgroundColor: UIColor_020120(),
            barShape: .capsule,
            cornerRadius: 1.5,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: LSShadowConfiguration(
                color: UIColor_00CBE0().withAlphaComponent(0.3),
                offset: CGSize(width: 0, height: 2),
                radius: 4,
                opacity: 1.0
            ),
            animationConfiguration: LSAnimationConfiguration(
                duration: 0.2,
                curve: .easeOut,
                springDamping: 0.7,
                initialVelocity: 0.3
            ),
            spacingMode: .equal(4)
        )
    }

    /// 霓虹风格
    static var neon: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "Neon",
            barColorMode: .neon,
            backgroundColor: UIColor_020120(),
            barShape: .roundedRectangle,
            cornerRadius: 2,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: LSShadowConfiguration(
                color: UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 0.8),
                offset: CGSize(width: 0, height: 0),
                radius: 20,
                opacity: 1.0
            ),
            animationConfiguration: nil,
            spacingMode: .equal(6)
        )
    }

    /// 极简风格
    static var minimal: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "Minimal",
            barColorMode: .single(UIColor_D1D6D9()),
            backgroundColor: .clear,
            barShape: .rectangle,
            cornerRadius: 0,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: nil,
            animationConfiguration: LSAnimationConfiguration(
                duration: 0.3,
                curve: .linear,
                springDamping: 1.0,
                initialVelocity: 0
            ),
            spacingMode: .equal(2)
        )
    }

    /// 复古风格
    static var retro: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "Retro",
            barColorMode: .multiple([
                UIColor(hex: "#FF6B6B"),
                UIColor(hex: "#4ECDC4"),
                UIColor(hex: "#FFE66D")
            ], cycle: true),
            backgroundColor: UIColor(hex: "#2C3E50"),
            barShape: .rectangle,
            cornerRadius: 0,
            showStroke: true,
            strokeColor: UIColor_FFFFFF(),
            strokeWidth: 1,
            shadowConfiguration: nil,
            animationConfiguration: nil,
            spacingMode: .equal(4)
        )
    }

    /// 玻璃拟态风格
    static var glassmorphism: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "Glassmorphism",
            barColorMode: .gradientVertical([
                UIColor_2D2C2C().withAlphaComponent(0.3),
                UIColor_2C2C2C().withAlphaComponent(0.6)
            ], locations: [0.0, 1.0]),
            backgroundColor: UIColor_020120(),
            barShape: .capsule,
            cornerRadius: 3,
            showStroke: true,
            strokeColor: UIColor_FFFFFF().withAlphaComponent(0.2),
            strokeWidth: 1,
            shadowConfiguration: LSShadowConfiguration(
                color: UIColor_FFFFFF().withAlphaComponent(0.1),
                offset: CGSize(width: 0, height: -2),
                radius: 10,
                opacity: 1.0
            ),
            animationConfiguration: nil,
            spacingMode: .equal(5)
        )
    }

    /// Spotify 风格
    static var spotify: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "Spotify",
            barColorMode: .gradientVertical([
                UIColor(hex: "#1DB954").withAlphaComponent(0.5),
                UIColor(hex: "#1DB954").withAlphaComponent(1.0)
            ], locations: [0.0, 1.0]),
            backgroundColor: UIColor(hex: "#121212"),
            barShape: .roundedRectangle,
            cornerRadius: 2,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: nil,
            animationConfiguration: LSAnimationConfiguration(
                duration: 0.1,
                curve: .linear,
                springDamping: 1.0,
                initialVelocity: 0
            ),
            spacingMode: .equal(2)
        )
    }

    /// Telegram 风格
    static var telegram: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "Telegram",
            barColorMode: .single(UIColor(hex: "#64B5F6")),
            backgroundColor: UIColor(hex: "#FFFFFF"),
            barShape: .capsule,
            cornerRadius: 2,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: nil,
            animationConfiguration: nil,
            spacingMode: .equal(3)
        )
    }

    /// Discord 风格
    static var discord: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "Discord",
            barColorMode: .single(UIColor(hex: "#5865F2")),
            backgroundColor: UIColor(hex: "#36393F"),
            barShape: .roundedRectangle,
            cornerRadius: 3,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: nil,
            animationConfiguration: nil,
            spacingMode: .equal(4)
        )
    }

    /// SoundCloud 风格
    static var soundcloud: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "SoundCloud",
            barColorMode: .gradientHorizontal([
                UIColor(hex: "#FF5500"),
                UIColor(hex: "#FF8800")
            ], locations: [0.0, 1.0]),
            backgroundColor: UIColor(hex: "#F2F2F2"),
            barShape: .rectangle,
            cornerRadius: 0,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: nil,
            animationConfiguration: nil,
            spacingMode: .equal(1)
        )
    }

    /// Audacity 风格
    static var audacity: LSWaveformStyleConfiguration {
        return LSWaveformStyleConfiguration(
            name: "Audacity",
            barColorMode: .single(UIColor(hex: "#0077CC")),
            backgroundColor: UIColor(hex: "#FFFFFF"),
            barShape: .rectangle,
            cornerRadius: 0,
            showStroke: false,
            strokeColor: nil,
            strokeWidth: 0,
            shadowConfiguration: nil,
            animationConfiguration: nil,
            spacingMode: .equal(1)
        )
    }
}
```

---

## 五、条纹间距控制 ⭐ 新增

### 5.1 间距模式定义

```swift
/// 条纹间距模式
public enum LSSpacingMode {
    /// 等间距
    case equal(CGFloat)

    /// 不等间距（通过数组指定）
    case unequal([CGFloat])

    /// 渐变间距（从小到大）
    case渐变(min: CGFloat, max: CGFloat)

    /// 自定义间距（通过 block）
    case custom((Int, Int, CGFloat) -> CGFloat)

    /// 代理方法设置间距
    case delegate(LSSpacingDelegate)

    /// 基于音量的动态间距
    case amplitudeBased(min: CGFloat, max: CGFloat)

    /// 波浪形间距
    case wave(min: CGFloat, max: CGFloat, frequency: CGFloat)
}

/// 间距代理
public protocol LSSpacingDelegate: AnyObject {
    /// 返回指定索引的间距
    func spacing(for barAtIndex: Int, total: Int, defaultSpacing: CGFloat) -> CGFloat
}
```

### 5.2 间距设置示例

```swift
// 等间距
waveformView.configuration.spacingMode = .equal(8)

// 不等间距（数组）
waveformView.configuration.spacingMode = .unequal([2, 4, 6, 8, 10, 8, 6, 4, 2])

// 渐变间距
waveformView.configuration.spacingMode = .渐变(min: 2, max: 10)

// 自定义间距（block）
waveformView.configuration.spacingMode = .custom { index, total, defaultSpacing in
    // 越靠近中间，间距越大
    let center = Float(total) / 2.0
    let distance = abs(Float(index) - center)
    let factor = 1.0 - (distance / center)
    return defaultSpacing * (1.0 + factor)
}

// 代理方法
waveformView.configuration.spacingMode = .delegate(self)

// 基于音量的动态间距
waveformView.configuration.spacingMode = .amplitudeBased(min: 2, max: 12)

// 波浪形间距
waveformView.configuration.spacingMode = .wave(min: 4, max: 10, frequency: 0.5)
```

---

## 六、布局模式

```swift
/// 布局模式
public enum LSLayoutMode {
    /// 左右对称
    case symmetric

    /// 仅左侧
    case leftOnly

    /// 仅右侧
    case rightOnly

    /// 水平排列
    case horizontal

    /// 圆形排列
    case circular

    /// 弧形排列
    case arc(startAngle: CGFloat, endAngle: CGFloat)

    /// 螺旋排列
    case spiral

    /// 网格排列
    case grid(rows: Int, columns: Int)

    /// 自定义布局
    case custom(layout: LSCustomLayout)
}
```

---

## 七、其他可优化项

### 7.1 动画效果

- [ ] 弹簧动画
- [ ] 缓动动画
- [ ] 波浪动画
- [ ] 脉冲动画
- [ ] 闪烁动画
- [ ] 旋转动画
- [ ] 缩放动画
- [ ] 平移动画
- [ ] 渐变动画
- [ ] 阴影动画

### 7.2 交互效果

- [ ] 点击反馈
- [ ] 长按反馈
- [ ] 滑动反馈
- [ ] 触觉反馈（Haptic Feedback）
- [ ] 声音反馈
- [ ] 震动反馈

### 7.3 性能优化

- [ ] 60 FPS 动画
- [ ] GPU 加速渲染（Metal）
- [ ] 视图复用（对象池）
- [ ] 异步绘制
- [ ] 增量更新
- [ ] 帧率独立动画
- [ ] HiDPI 适配

### 7.4 可访问性

- [ ] VoiceOver 支持
- [ ] 动态字体支持
- [ ] 高对比度模式
- [ ] 减少动画模式
- [ ] 辅助功能标签

### 7.5 国际化

- [ ] 多语言支持
- [ ] RTL 布局支持（阿拉伯语等）
- [ ] 本地化配置

### 7.6 数据持久化

- [ ] 配置保存
- [ ] 用户偏好设置
- [ ] 录音历史记录
- [ ] 风格预设管理

### 7.7 调试功能

- [ ] 波形数据可视化
- [ ] 性能监控
- [ ] 内存使用追踪
- [ ] FPS 显示
- [ ] 日志系统

### 7.8 文档与示例

- [ ] API 文档
- [ ] 使用示例
- [ ] 最佳实践
- [ ] 迁移指南
- [ ] 故障排查

### 7.9 测试

- [ ] 单元测试
- [ ] UI 测试
- [ ] 性能测试
- [ ] 兼容性测试
- [ ] 集成测试

### 7.10 扩展性

- [ ] 插件系统
- [ ] 主题系统
- [ ] 自定义渲染器
- [ ] 自定义手势识别器
- [ ] 自定义动画引擎

---

## 八、API 设计

### 8.1 基础使用

```swift
// 最简单的使用
let waveformView = LSWaveformView()
view.addSubview(waveformView)
```

### 8.2 配置使用

```swift
let waveformView = LSWaveformView()

// 配置风格
waveformView.applyStyle(.qq)

// 或者详细配置
waveformView.configuration = LSWaveformConfiguration(
    numberOfBars: 30,
    barWidth: 3,
    spacingMode: .equal(8),
    barColorMode: .qqStyle,
    barHeightMode: .symmetric,
    layoutMode: .symmetric
)
```

### 8.3 手势使用

```swift
let container = LSRecordingContainer()
container.gestureConfiguration = LSRecordingGestureConfiguration(
    longPressEnabled: true,
    tapEnabled: true,
    panToCancelEnabled: true,
    cancelThreshold: 100
)
```

### 8.4 多波形使用

```swift
let leftWaveform = LSWaveformView()
leftWaveform.configuration.layoutMode = .leftOnly
leftWaveform.frame = CGRect(x: 20, y: 100, width: 150, height: 60)

let rightWaveform = LSWaveformView()
rightWaveform.configuration.layoutMode = .rightOnly
rightWaveform.frame = CGRect(x: 200, y: 100, width: 150, height: 60)

view.addSubview(leftWaveform)
view.addSubview(rightWaveform)
```

---

## 九、后续优化建议

### 9.1 短期优化（P0）

- [ ] 完善颜色模式系统
- [ ] 完成预设风格配置
- [ ] 实现间距控制
- [ ] 添加更多高度模式

### 9.2 中期优化（P1）

- [ ] 实现手势交互
- [ ] 添加动画效果
- [ ] 性能优化
- [ ] 完善文档

### 9.3 长期优化（P2）

- [ ] GPU 加速
- [ ] 插件系统
- [ ] 跨平台支持
- [ ] 云端配置

### 9.4 创新功能

#### AI 与机器学习

- [ ] **AI 驱动的波形生成** - 基于音频内容自动生成最佳可视化效果
- [ ] **实时语音转文字** - 集成 Whisper/Speech API 进行实时转录
- [ ] **音高检测与显示** - 基于 CREPE 模型的高精度音高追踪
- [ ] **音频情感识别** - 识别音频中的情绪状态（快乐、悲伤、愤怒等）
- [ ] **AI 音频增强** - 自动降噪、回声消除、人声分离
- [ ] **AI 生成的音频检测** - 检测音频是否由 AI 生成（SONAR 框架）
- [ ] **说话人识别** - 自动识别不同的说话人并分段显示
- [ ] **音频指纹验证** - 区块链技术验证音频真实性

#### 视觉与特效

- [ ] **3D 波形效果** - 使用 Metal 进行 GPU 加速的 3D 波形渲染
- [ ] **AR 波形展示** - Vision Pro/ARKit 中的增强现实波形
- [ ] **粒子系统波形** - 使用粒子效果展示音频
- [ ] **流体动力学波形** - 模拟液体流动的波形效果
- [ ] **Memoji/Animoji 同步** - 波形与表情同步动画
- [ ] **Lottie 动画集成** - 支持导入 Lottie 动画作为波形效果

#### 音频处理

- [ ] **多轨道波形编辑器** - 支持多音轨同时编辑和显示
- [ ] **实时音频效果链** - AVAudioUnit 效果器链（EQ、压缩、混响等）
- [ ] **AUv3 插件支持** - 支持 Audio Unit 插件扩展
- [ ] **空间音频支持** - 苹果空间音频波形可视化
- [ ] **实时时间拉伸** - 不改变音高的速度调整
- [ ] **实时音调转换** - 不改变速度的音调调整

#### 交互与反馈

- [ ] **触觉反馈同步** - Core Haptics 音频触觉同步（基于音频强度触发震动）
- [ ] **音频触觉设计** - WWDC21 最佳实践的音频触觉体验
- [ ] **手势控制效果** - 捏合、滑动手势控制音频参数

#### 导出与分享

- [ ] **波形动画导出 GIF** - 导出波形动画为 GIF 格式
- [ ] **波形动画导出视频** - 导出为 MP4 视频，适配社交媒体
- [ ] **社交媒体分享** - 一键分享到 Instagram、TikTok、朋友圈等
- [ ] **Audiogram 生成** - 带波形的音频视频生成（类似 Wavve、VEED）
- [ ] **Lottie 动画导出** - 导出为 Lottie JSON 格式供 Web 使用
- [ ] **波形模板库** - 预设的波形动画模板

#### 协作与云服务

- [ ] **实时协作编辑** - 多用户同时编辑波形项目（类似 Soundtrap）
- [ ] **云端项目同步** - iCloud/云端保存和同步波形项目
- [ ] **波形分享社区** - 用户分享和下载波形配置
- [ ] **云端渲染** - 复杂波形效果云端渲染
- [ ] **版本控制** - 波形项目的版本管理和回滚

#### 主题与扩展

- [ ] **皮肤/主题系统** - 完整的主题管理系统（类似 FL Studio）
- [ ] **插件系统** - 支持 VST/AU 插件架构
- [ ] **预设管理** - 保存/加载/分享波形配置预设
- [ ] **模块化效果链** - 可拖拽重新排列的效果链（类似 T-Chain）

#### 专业功能

- [ ] **频谱分析仪** - 实时 FFT 频谱分析显示
- [ ] **音量表（VU Meter）** - 专业音频电平表
- [ ] **相位相关性表** - 立体声相位分析
- [ ] **频谱图（Spectrogram）** - 2D/3D 频谱时间图
- [ ] **波形对比工具** - 对比两个音频的波形差异
- [ ] **音频标记系统** - 在波形上添加标记和注释

#### 数据分析

- [ ] **音频特征提取** - MFCC、Chroma、Spectral Contrast 等特征提取
- [ ] **节奏检测** - 自动检测音频的 BPM 和节拍
- [ ] **和弦识别** - 自动识别音频中的和弦
- [ ] **人声分离** - 使用 AI 分离人声和伴奏
- [ ] **静音检测** - 自动检测和标记静音片段

#### 可访问性与国际化

- [ ] **VoiceOver 优化** - 为视障用户提供音频描述
- [ ] **动态布局** - 支持不同屏幕尺寸和方向
- [ ] **RTL 支持** - 阿拉伯语、希伯来语等从右到左的语言支持
- [ ] **深色模式适配** - 自动适配系统深色模式

#### 开发者功能

- [ ] **Swift Package Manager** - SPM 分发支持
- [ ] **CocoaPods 支持** - CocoaPods 集成
- [ ] **完整的 API 文档** - DocC 文档生成
- [ ] **示例项目** - OC/Mixed/Swift/SwiftUI 四套示例
- [ ] **单元测试覆盖** - 高覆盖率的测试用例

---

## 十、变更记录

| 日期 | 版本 | 变更内容 | 作者 |
|------|------|----------|------|
| 2025-02-07 | 1.0 | 初始版本，添加核心功能需求 | Claude |
| 2025-02-07 | 1.1 | 基于 25+ 库研究添加详细功能建议 | Claude |
| 2025-02-07 | 1.2 | 添加 AI/ML、协作、导出等高级功能 | Claude |

---

## 十一、参考资源

### 研究的库（30+）

1. GYSpectrum - QQ经典风格
2. iRecordView - WhatsApp手势
3. DSWaveformImage - Canvas渲染
4. FDWaveformView - 播放可视化
5. AudioKit/Waveform - GPU加速
6. SwiftWaveform - 轻量级FFT
7. SFAudioWaveformHelper - Accelerate框架
8. SoundView - 波形生成
9. SoundWaveForm - 样本提取
10. Waveform (pixlwave) - SwiftUI交互
11. tempi-fft - 实时FFT分析
12. SoundControlKit - 录音播放
13. ios-voice-processor - 异步处理
14. IQAudioRecorderController - 完整方案
15. hold-to-record-button-ios - 按住录音
16. LXFWeChat - 高仿微信
17. iOSRecorderWithVUMeter - VU表
18. OpenNoiseMeter - 噪音水平计
19. SwiftAudioKit - 播放器包装
20. SoundKit - 播放和触觉
21. EZAudio - 实时音频可视化（已弃用）
22. AudioRecorder with Waveform - WhatsApp风格
23. Building Ramble - 生产实现
24. JSWaveform - SwiftUI原生
25. AnimatedWaveform - SF Symbol动画

### 音乐播放器相关库（新增）

26. **[MTAudioTap](https://github.com/f728743/MTAudioTap)** - SwiftUI 实时频谱可视化
27. **[SoundWaveVisualizer](https://github.com/jaydeep-godhani/SoundWaveVisualizer)** - iOS 可定制均衡器视图
28. **[SwiftChartsAudioVisualizer](https://github.com/vNakamura/SwiftChartsAudioVisualizer)** - SwiftUI 图表音频可视化
29. **[AR_Audio_Visualizer](https://github.com/chrise96/AR_Audio_Visualizer)** - ARKit 3D 频谱分析器
30. **[MuVis](https://github.com/Keith-43/MuVis-v2.1.1)** - Swift 跨平台实时音乐可视化
31. **[KuGouMusic](https://github.com/tenda2014/KuGouMusic)** - 仿酷狗音乐播放效果

### 在线工具与平台

1. [Echowave](https://echowave.io/tools/audio-waveform-video-generator/) - 音频波形视频生成器
2. [WaveVisual](https://wavevisual.com/) - 声波艺术创建工具
3. [Renderforest](https://www.renderforest.com/audio-waveform-generator) - 音频波形生成器
4. [VEED.io](https://www.veed.io/tools/music-visualizer/audio-waveform-generator) - Audiogram 生成器
5. [Wavve](https://getaudiogram.com/blog/how-to-make-a-sound-waveform-video-for-social-media/) - 社交媒体波形视频
6. [LottieFiles](https://lottiefiles.com/categories/audio) - 音频 Lottie 动画库

### 协作平台

1. [Soundtrap](https://www.audiocipher.com/post/multiplayer-daw-remote-music-collaboration-apps) - Spotify 旗下的在线 DAW
2. [Pibox Music](https://musewaves.com/blog/music-production-collaboration-tools/) - 云端协作音乐制作
3. [Avid Cloud Collaboration](https://www.prolificsoundsolutions.com/post/the-best-tools-for-online-music-collaboration) - 专业云协作
4. [Audiomovers](https://www.production-expert.com/production-expert-1/we-explain-remote-collaboration-software-choices-in-2024) - 实时音频文件共享

### AI 音频工具

1. [Adobe Podcast – Enhance Speech](https://www.opus.pro/blog/best-ai-audio-denoise-echo-removal-tools) - 语音增强
2. [ElevenLabs – Voice Isolator](https://blog.alexanderfyoung.com/7-free-ai-audio-tools-that-will-blow-your-mind/) - 人声隔离
3. [Riverside.fm – Magic Audio](https://massive.io/gear-guides/the-top-ai-audio-cleanup-tools) - 音频清理
4. [Descript](https://www.bridge.audio/blog/level-up-your-podcast-best-ai-tools-in-2024/) - AI 音频编辑
5. [CREPE](https://medium.com/axinc-ai/crepe-a-machine-learning-model-for-high-precision-pitch-estimation-8562d83d44a5) - 高精度音高检测
6. [Librosa](https://librosa.org/doc/) - Python 音频分析库

### 技术文章

- [iOS 实现长按录音上滑取消的几种思路](https://www.cnblogs.com/SquirrelStock/p/6168340.html)
- [iOS开发-类似微信录音上滑取消功能](https://blog.csdn.net/weixin_41732253/article/details/110142169)
- [IM 软件中的语音录制与播放【iOS】](https://juejin.cn/post/6844903453567746055)
- [Audio Visualization in Swift Using Metal](https://betterprogramming.pub/audio-visualization-in-swift-using-metal-accelerate-part-1-390965c095d7)
- [Creating a Live Audio Waveform in SwiftUI](https://www.createwithswift.com/creating-a-live-audio-waveform-in-swiftui/)
- [Writing a High-Performance Audio Wave in SwiftUI](https://medium.com/@lucasmrowskovskypaim/writing-a-high-performance-audio-wave-in-swiftui-09bfc5bcd133)
- [Create custom visual effects with SwiftUI - WWDC24](https://developer.apple.com/videos/play/wwdc2024/10151/)
- [How to Create a Video With Audio-Reactive Haptic](https://medium.com/@jonataneduard/how-to-create-a-video-with-audio-reactive-haptic-feedback-for-ios-ios-13-using-corehaptics-cd0384412582)
- [Audio Analysis with Machine Learning](https://www.tensorway.com/post/audio-analysis-with-machine-learning)
- [灯光音乐联动节拍同步算法](https://blog.csdn.net/weixin_33628677/article/details/154852616)
- [HTML5 Canvas 实现简易绘制音乐环形频谱图](https://developer.aliyun.com/article/658212)

### 音乐播放器相关

- [酷狗音乐 - 频谱播放器介绍](https://tech.ifeng.com/c/8htiqwB8Iia) - 业内首款频谱播放器
- [频谱播放器更新说明](https://blog.csdn.net/qq_40946921/article/details/100108959) - 酷狗音乐频谱功能
- [可视化音乐应用宝介绍](https://sj.qq.com/topic/200082837) - 音乐可视化应用汇总
- [Python + Vue3 打造超炫酷音乐播放器](https://www.cnblogs.com/wangrui38/p/19141508) - Web 音频可视化教程
- [Specterr 在线音乐可视化工具](https://www.videosoftdev.com/cn/49-products-spec/video-solutions/video-editor/documentation/how-to?start=110) - 歌词视频创建
- [Writing a High-Performance Audio Wave in SwiftUI](https://medium.com/@lucasmrowskovskypaim/writing-a-high-performance-audio-wave-in-swiftui-09bfc5bcd133)
- [Create custom visual effects with SwiftUI - WWDC24](https://developer.apple.com/videos/play/wwdc2024/10151/)
- [How to Create a Video With Audio-Reactive Haptic](https://medium.com/@jonataneduard/how-to-create-a-video-with-audio-reactive-haptic-feedback-for-ios-ios-13-using-corehaptics-cd0384412582)
- [Audio Analysis with Machine Learning](https://www.tensorway.com/post/audio-analysis-with-machine-learning)

### 官方文档

- [Apple Accelerate Framework - FFT](https://developer.apple.com/documentation/accelerate/fast-fourier-transforms)
- [AVFoundation Audio Playback, Recording, and Processing](https://developer.apple.com/documentation/avfoundation/audio-playback-recording-and-processing)
- [Core Haptics | Apple Developer](https://developer.apple.com/documentation/corehaptics/)
- [Audio Units | Apple Developer](https://developer.apple.com/documentation/avfaudio/audio-units)
- [AVAudioEngine | Apple Developer](https://developer.apple.com/documentation/avfaudio/audio-engine)
