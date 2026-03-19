# LSWaveformKit 使用示例

本文档提供了 LSWaveformKit 的详细使用示例，涵盖从基础到高级的各种场景。

## 目录

- [基础示例](#基础示例)
- [样式应用](#样式应用)
- [手势交互](#手势交互)
- [歌词同步](#歌词同步)
- [节拍检测](#节拍检测)
- [音乐播放器集成](#音乐播放器集成)
- [多波形实例](#多波形实例)
- [高级配置](#高级配置)

---

## 基础示例

### 示例 1：最简单的使用

```swift
import LSWaveformKit

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // 创建波形视图
        let waveformView = LSWaveformView()
        waveformView.frame = CGRect(x: 0, y: 100, width: view.bounds.width, height: 60)
        view.addSubview(waveformView)
    }
}
```

### 示例 2：录音按钮控制

```swift
class ViewController: UIViewController {
    private lazy var waveformView: LSWaveformView = {
        let view = LSWaveformView()
        view.frame = CGRect(x: 0, y: 100, width: self.view.bounds.width, height: 60)
        return view
    }()

    private lazy var recordButton: UIButton = {
        var btn = UIButton(type: .custom)
        btn.setTitle("按住录音", for: .normal)
        btn.setTitle("松开结束", for: .selected)
        btn.setTitleColor(UIColor_FFFFFF(), for: .normal)
        btn.backgroundColor = UIColor_00CBE0()
        btn.layer.cornerRadius = 25
        btn.addTarget(self, action: #selector(recordButtonTapped(_:)), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor_020120()
        view.addSubview(waveformView)
        view.addSubview(recordButton)

        waveformView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(60)
        }

        recordButton.snp.makeConstraints { make in
            make.top.equalTo(waveformView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(50)
        }

        setupCallbacks()
    }

    private func setupCallbacks() {
        waveformView.onRecordingStop = { [weak self] url, duration in
            guard let self = self else { return }
            print("录音完成，时长：\(duration)秒")
            self.recordButton.isSelected = false
        }

        waveformView.onRecordingCancel = { [weak self] in
            guard let self = self else { return }
            print("录音取消")
            self.recordButton.isSelected = false
        }
    }

    @objc private func recordButtonTapped(_ sender: UIButton) {
        if waveformView.isRecording {
            waveformView.stopRecording()
        } else {
            waveformView.startRecording()
        }
    }
}
```

---

## 样式应用

### 示例 3：应用预设风格

```swift
// QQ 经典风格
waveformView.applyStyle(.qq)

// 微信风格
waveformView.applyStyle(.wechat)

// 酷狗音乐风格（彩色频谱）
waveformView.applyStyle(.kugou)

// QQ 音乐风格
waveformView.applyStyle(.qqmusic)

// 酷我音乐风格
waveformView.applyStyle(.kuwo)

// 网易云音乐风格
waveformView.applyStyle(.netease)

// Spotify 风格
waveformView.applyStyle(.spotify)

// Apple Music 风格
waveformView.applyStyle(.applemusic)

// 霓虹风格
waveformView.applyStyle(.neon)

// 极简风格
waveformView.applyStyle(.minimal)
```

### 示例 4：自定义颜色配置

```swift
// 单一颜色
waveformView.configuration.barColorMode = .single(UIColor_00CBE0())

// 多种颜色循环
waveformView.configuration.barColorMode = .multiple([
    UIColor_00CBE0(),
    UIColor_F21F14(),
    UIColor_2F665C()
], cycle: true)

// 垂直渐变
waveformView.configuration.barColorMode = .gradientVertical(
    colors: [
        UIColor_2D2C2C().withAlphaComponent(0.0),
        UIColor_2C2C2C().withAlphaComponent(0.52),
        UIColor_2A2A2B().withAlphaComponent(0.81)
    ],
    locations: [0.0, 0.2, 0.4]
)

// 水平渐变
waveformView.configuration.barColorMode = .gradientHorizontal(
    colors: [
        UIColor_00CBE0(),
        UIColor_2F665C()
    ],
    locations: [0.0, 1.0]
)

// 径向渐变
waveformView.configuration.barColorMode = .gradientRadial(
    colors: [
        UIColor_00CBE0().withAlphaComponent(0.3),
        UIColor_00CBE0().withAlphaComponent(1.0)
    ],
    locations: [0.0, 1.0]
)

// 彩虹渐变
waveformView.configuration.barColorMode = .rainbow

// 基于音量的动态颜色
waveformView.configuration.barColorMode = .amplitudeBased(
    low: UIColor(hex: "#4A90E2"),
    high: UIColor(hex: "#E74C3C")
)

// 基于频率的颜色（频谱图）
waveformView.configuration.barColorMode = .frequencyBased([
    UIColor(hex: "#FF0000"),  // 低频 - 红
    UIColor(hex: "#FF7F00"),  // 中低频 - 橙
    UIColor(hex: "#FFFF00"),  // 中频 - 黄
    UIColor(hex: "#00FF00"),  // 中高频 - 绿
    UIColor(hex: "#0000FF"),  // 高频 - 蓝
    UIColor(hex: "#8B00FF")   // 超高频 - 紫
])
```

### 示例 5：自定义高度模式

```swift
// 对称模式（中间高两边低）
waveformView.configuration.barHeightMode = .symmetric

// 随机模式
waveformView.configuration.barHeightMode = .random

// 从左到右依次升高
waveformView.configuration.barHeightMode = .ascending

// 从左到右依次降低
waveformView.configuration.barHeightMode = .descending

// 高低高低
waveformView.configuration.barHeightMode = .highLow

// 低高低高
waveformView.configuration.barHeightMode = .lowHigh

// 高高低低
waveformView.configuration.barHeightMode = .highHighLowLow

// 低低高高
waveformView.configuration.barHeightMode = .lowLowHighHigh

// 一样高
waveformView.configuration.barHeightMode = .uniform

// 自定义高度数组
waveformView.configuration.barHeightMode = .custom([0.3, 0.5, 0.8, 1.0, 0.8, 0.5, 0.3])

// 先高后低
waveformView.configuration.barHeightMode = .highToLow

// 先低后高
waveformView.configuration.barHeightMode = .lowToHigh

// 参差不齐（带随机因子）
waveformView.configuration.barHeightMode = .uneven(randomFactor: 0.3)
```

---

## 手势交互

### 示例 6：长按录音 + 滑动取消

```swift
class ViewController: UIViewController {
    private lazy var waveformView: LSWaveformView = {
        let view = LSWaveformView()
        view.frame = CGRect(x: 0, y: 100, width: self.view.bounds.width, height: 60)
        return view
    }()

    private lazy var hintLabel: UILabel = {
        var lab = UILabel()
        lab.font = PingFangSCRegular(size: 14)
        lab.textColor = UIColor_D1D6D9()
        lab.textAlignment = .center
        return lab
    }()

    private lazy var cancelButton: UIButton = {
        var btn = UIButton(type: .custom)
        btn.setTitle("取消", for: .normal)
        btn.setTitleColor(UIColor_FFFFFF(), for: .normal)
        btn.backgroundColor = UIColor_DCE1E8()
        btn.layer.cornerRadius = 15
        btn.isHidden = true
        btn.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGestures()
    }

    private func setupViews() {
        view.addSubview(waveformView)
        view.addSubview(hintLabel)
        view.addSubview(cancelButton)

        hintLabel.text = "按住下方按钮开始录音"
    }

    private func setupGestures() {
        // 配置手势
        let gestureConfig = LSWaveformGestureHandler.GestureConfiguration(
            longPressEnabled: true,
            panToCancelEnabled: true,
            cancelThreshold: 100
        )

        waveformView.gestureHandler?.configuration = gestureConfig
        waveformView.gestureHandler?.delegate = self
    }
}

// MARK: - 手势代理
extension ViewController: LSWaveformGestureHandlerDelegate {
    func gestureHandlerDidBeginRecording(_ handler: LSWaveformGestureHandler) {
        hintLabel.text = "松开结束，上滑取消"
        cancelButton.isHidden = false
    }

    func gestureHandlerWillCancelRecording(_ handler: LSWaveformGestureHandler) {
        hintLabel.text = "松开取消录音"
        cancelButton.isHidden = false
    }

    func gestureHandler(_ handler: LSWaveformGestureHandler, updateCancelProgress progress: CGFloat) {
        // 更新取消进度指示器
        print("取消进度：\(progress)")
    }

    func gestureHandlerDidEndRecording(_ handler: LSWaveformGestureHandler) {
        hintLabel.text = "录音完成"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.cancelButton.isHidden = true
        }
    }

    func gestureHandlerDidCancelRecording(_ handler: LSWaveformGestureHandler) {
        hintLabel.text = "录音取消"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.cancelButton.isHidden = true
        }
    }

    @objc private func cancelButtonTapped() {
        waveformView.cancelRecording()
        cancelButton.isHidden = true
        hintLabel.text = "按住下方按钮开始录音"
    }
}
```

---

## 歌词同步

### 示例 7：LRC 歌词同步波形

```swift
class MusicPlayerViewController: UIViewController {
    private lazy var waveformView: LSWaveformView = {
        let view = LSWaveformView()
        view.applyStyle(.kuwo)
        return view
    }()

    private lazy var lyricsLabel: UILabel = {
        var lab = UILabel()
        lab.font = PingFangSCRegular(size: 16)
        lab.textColor = UIColor_FFFFFF()
        lab.textAlignment = .center
        lab.numberOfLines = 0
        return lab
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLyricsSync()
    }

    private func setupViews() {
        view.addSubview(waveformView)
        view.addSubview(lyricsLabel)

        waveformView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }

        lyricsLabel.snp.makeConstraints { make in
            make.top.equalTo(waveformView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(40)
        }
    }

    private func setupLyricsSync() {
        // 配置歌词同步
        waveformView.lyricsConfig = LSLyricsSynchronizationConfiguration(
            lyricsFilePath: Bundle.main.path(forResource: "song", ofType: "lrc"),
            showLyrics: true,
            highlightColor = UIColor_00CBE0(),
            normalColor = UIColor_D1D6D9(),
            lyricsPosition = .bottom,
            triggerWaveformOnLyric = true,
            lyricAnimation = .pulse
        )

        // 歌词回调
        waveformView.onLyricUpdate = { [weak self] lyricLine in
            guard let self = self else { return }
            self.lyricsLabel.text = lyricLine.text
        }
    }
}
```

---

## 节拍检测

### 示例 8：BPM 检测与节拍效果

```swift
class MusicPlayerViewController: UIViewController {
    private lazy var waveformView: LSWaveformView = {
        let view = LSWaveformView()
        view.applyStyle(.neon)
        return view
    }()

    private lazy var bpmLabel: UILabel = {
        var lab = UILabel()
        lab.font = PingFangSCMedium(size: 14)
        lab.textColor = UIColor_00CBE0()
        lab.text = "BPM: --"
        return lab
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBeatDetection()
    }

    private func setupViews() {
        view.addSubview(waveformView)
        view.addSubview(bpmLabel)

        waveformView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(60)
        }

        bpmLabel.snp.makeConstraints { make in
            make.top.equalTo(waveformView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }

    private func setupBeatDetection() {
        // 配置节拍检测
        waveformView.beatConfig = LSBeatDetectionConfiguration(
            isEnabled: true,
            sensitivity: 0.5,
            minBPM: 60,
            maxBPM: 200,
            beatEffect: .glow,
            showBPM: true,
            onBeatDetected: { [weak self] time, intensity in
                guard let self = self else { return }

                // 更新 BPM 显示
                self.waveformView.beatConfig?.currentBPM.flatMap { bpm in
                    self.bpmLabel.text = String(format: "BPM: %.0f", bpm)
                }

                // 触发触觉反馈
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        )
    }
}
```

---

## 音乐播放器集成

### 示例 9：完整音乐播放器集成

```swift
class MusicPlayerViewController: UIViewController {
    private lazy var waveformView: LSWaveformView = {
        let view = LSWaveformView()
        return view
    }()

    private lazy var playButton: UIButton = {
        var btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "play_icon"), for: .normal)
        btn.setImage(UIImage(named: "pause_icon"), for: .selected)
        btn.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        return btn
    }()

    private var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        loadAudioFile()
    }

    private func setupViews() {
        view.addSubview(waveformView)
        view.addSubview(playButton)

        waveformView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(100)
        }

        playButton.snp.makeConstraints { make in
            make.top.equalTo(waveformView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
    }

    private func loadAudioFile() {
        guard let url = Bundle.main.url(forResource: "music", withExtension: "mp3") else {
            print("音频文件不存在")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()

            // 配置音频分析
            waveformView.musicEffectConfig = LSMusicEffectConfiguration(
                enableSpectrumAnalysis: true,
                fftSize: 2048,
                frequencyRange: 20...20000,
                spectrumBarCount: 64,
                colorMapping: .rainbow
            )
        } catch {
            print("音频加载失败：\(error)")
        }
    }

    @objc private func playButtonTapped(_ sender: UIButton) {
        guard let player = audioPlayer else { return }

        if player.isPlaying {
            player.pause()
            sender.isSelected = false
            waveformView.stopAnimating()
        } else {
            player.play()
            sender.isSelected = true
            waveformView.startAnimating()
        }
    }
}

// MARK: - AVAudioPlayerDelegate
extension MusicPlayerViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.isSelected = false
        waveformView.stopAnimating()
    }
}
```

---

## 多波形实例

### 示例 10：左右对称波形

```swift
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // 创建左侧波形
        let leftWaveform = LSWaveformView()
        leftWaveform.configuration.layoutMode = .leftOnly
        leftWaveform.configuration.numberOfBars = 20
        leftWaveform.configuration.barColorMode = .single(UIColor_00CBE0())
        leftWaveform.frame = CGRect(x: 20, y: 100, width: 150, height: 60)
        view.addSubview(leftWaveform)

        // 创建右侧波形
        let rightWaveform = LSWaveformView()
        rightWaveform.configuration.layoutMode = .rightOnly
        rightWaveform.configuration.numberOfBars = 20
        rightWaveform.configuration.barColorMode = .single(UIColor_F21F14())
        rightWaveform.frame = CGRect(x: 200, y: 100, width: 150, height: 60)
        view.addSubview(rightWaveformView)

        // 同时开始录音
        leftWaveform.startRecording()
        rightWaveform.startRecording()
    }
}
```

### 示例 11：三个不同风格的波形

```swift
class ViewController: UIViewController {
    private var waveformViews: [LSWaveformView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let styles: [LSWaveformStyle] = [.kugou, .qqmusic, .kuwo]
        let colors: [UIColor] = [.red, .green, .blue]

        for (index, style) in styles.enumerated() {
            let waveformView = LSWaveformView()
            waveformView.applyStyle(style)
            waveformView.frame = CGRect(
                x: 20,
                y: 100 + CGFloat(index) * 120,
                width: view.bounds.width - 40,
                height: 60
            )
            waveformView.tag = index
            view.addSubview(waveformView)
            waveformViews.append(waveformView)
        }
    }

    func startAllRecording() {
        waveformViews.forEach { $0.startRecording() }
    }

    func stopAllRecording() {
        waveformViews.forEach { $0.stopRecording() }
    }
}
```

---

## 高级配置

### 示例 12：完全自定义配置

```swift
class CustomWaveformViewController: UIViewController {
    private lazy var waveformView: LSWaveformView = {
        let view = LSWaveformView()

        // 完全自定义配置
        let config = LSDefaultWaveformConfiguration()

        // 基础配置
        config.numberOfBars = 50
        config.barWidth = 4
        config.barSpacing = 3

        // 高度配置
        config.minimumBarHeight = 5
        config.maximumBarHeight = 80
        config.baseHeight = 10

        // 模式配置
        config.barHeightMode = .highLow
        config.layoutMode = .symmetric

        // 颜色配置
        config.barColorMode = .gradientVertical(
            colors: [
                UIColor(hex: "#FF6B6B"),
                UIColor(hex: "#4ECDC4"),
                UIColor(hex: "#45B7D1")
            ],
            locations: [0.0, 0.5, 1.0]
        )

        // 动画配置
        config.animationDuration = 0.15
        config.animationCurve = .easeInOut

        // 描边配置
        config.showStroke = false

        // 间距配置
        config.spacingMode = .equal(3)

        // 刷新率
        config.refreshRate = 60

        view.configuration = config
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(waveformView)

        waveformView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(80)
        }
    }
}
```

### 示例 13：自定义间距配置

```swift
// 等间距
waveformView.configuration.spacingMode = .equal(5)

// 不等间距（数组）
waveformView.configuration.spacingMode = .unequal([2, 3, 4, 5, 6, 5, 4, 3, 2])

// 渐变间距（从小到大）
waveformView.configuration.spacingMode = .gradient(min: 2, max: 8)

// 自定义间距（block）
waveformView.configuration.spacingMode = .custom { index, total, defaultSpacing in
    // 越靠近中心，间距越大
    let center = Float(total) / 2.0
    let distance = abs(Float(index) - center)
    let factor = distance / center
    return defaultSpacing * (1.0 + factor * 0.5)
}

// 代理方法
class MySpacingProvider: UIViewController, LSSpacingDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()

        waveformView.configuration.spacingMode = .delegate(self)
    }

    func spacing(for barAtIndex: Int, total: Int, defaultSpacing: CGFloat) -> CGFloat {
        // 根据条形索引返回不同间距
        let position = Double(barAtIndex) / Double(total)
        return defaultSpacing * (1.0 + sin(position * .pi * 2))
    }
}

// 基于音量的动态间距
waveformView.configuration.spacingMode = .amplitudeBased(min: 2, max: 10)

// 波浪形间距
waveformView.configuration.spacingMode = .wave(min: 3, max: 8, frequency: 0.5)
```

### 示例 14：自定义颜色提供者

```swift
class CustomColorProvider: UIViewController, LSBarColorProvider {
    override func viewDidLoad() {
        super.viewDidLoad()

        // 使用自定义颜色提供者
        waveformView.configuration.barColorMode = .custom(self)
    }

    func color(for bar: LSWaveformBar, index: Int, total: Int, amplitude: Float) -> UIColor {
        // 根据条纹索引和音量返回颜色
        let hue = Double(index) / Double(total)
        let saturation = 1.0
        let brightness = 0.5 + amplitude * 0.5
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
    }
}
```

---

## 完整示例项目

### 示例 15：录音播放器完整实现

```swift
import LSWaveKit
import AVFoundation
import SnapKit

class RecorderPlayerViewController: UIViewController {

    // MARK: - UI Components

    private lazy var waveformView: LSWaveformView = {
        let view = LSWaveformView()
        view.applyStyle(.kugou)
        return view
    }()

    private lazy var timeLabel: UILabel = {
        var lab = UILabel()
        lab.font = PingFangSCRegular(size: 14)
        lab.textColor = UIColor_FFFFFF()
        lab.text = "00:00"
        lab.textAlignment = .center
        return lab
    }()

    private lazy var recordButton: UIButton = {
        var btn = UIButton(type: .custom)
        btn.setTitle("按住录音", for: .normal)
        btn.setTitleColor(UIColor_FFFFFF(), for: .normal)
        btn.backgroundColor = UIColor_00CBE0()
        btn.layer.cornerRadius = 25
        btn.adjustsImageWhenHighlighted = false
        btn.addTarget(self, action: #selector(recordButtonTouchDown(_:)), for: .touchDown)
        btn.addTarget(self, action: #selector(recordButtonTouchUp(_:)), for: .touchUpInside)
        btn.addTarget(self, action: #selector(recordButtonTouchUpOutside(_:)), for: .touchUpOutside)
        return btn
    }()

    private lazy var playButton: UIButton = {
        var btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "play_icon"), for: .normal)
        btn.setImage(UIImage(named: "pause_icon"), for: .selected)
        btn.adjustsImageWhenHighlighted = false
        btn.addTarget(self, action: #selector(playButtonTapped(_:)), for: .touchUpInside)
        return btn
    }()

    private lazy var deleteButton: UIButton = {
        var btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "delete_icon"), for: .normal)
        btn.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        return btn
    }()

    // MARK: - Properties

    private var recordingTimer: Timer?
    private var playbackTimer: Timer?
    private var audioPlayer: AVAudioPlayer?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "录音播放器"
        view.backgroundColor = UIColor_020120()
        setupViews()
        setupCallbacks()
    }

    // MARK: - Setup

    private func setupViews() {
        view.addSubview(waveformView)
        view.addSubview(timeLabel)
        view.addSubview(recordButton)
        view.addSubview(playButton)
        view.addSubview(deleteButton)

        waveformView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.centerX.equalToSuperview()
            make.width.equalTo(280)
            make.height.equalTo(60)
        }

        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(waveformView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }

        recordButton.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(50)
        }

        playButton.snp.makeConstraints { make in
            make.leading.equalTo(recordButton.snp.trailing).offset(20)
            make.centerY.equalTo(recordButton)
            make.width.height.equalTo(recordButton)
        }

        deleteButton.snp.makeConstraints { make in
            make.leading.equalTo(playButton.snp.trailing).offset(20)
            make.centerY.equalTo(recordButton)
            make.width.height.equalTo(recordButton)
        }
    }

    private func setupCallbacks() {
        // 录音回调
        waveformView.onRecordingStart = { [weak self] in
            self?.startRecordingTimer()
        }

        waveformView.onRecordingStop = { [weak self] url, duration in
            self?.stopRecordingTimer()
            self?.saveRecording(url: url)
            self?.enablePlayback(true)
        }

        waveformView.onRecordingCancel = { [weak self] in
            self?.stopRecordingTimer()
            self?.enablePlayback(false)
        }

        waveformView.onAmplitudeUpdate = { [weak self] amplitude in
            self?.updateBars(with: amplitude)
        }
    }

    // MARK: - Actions

    @objc private func recordButtonTouchDown(_ sender: UIButton) {
        waveformView.startRecording()
        timeLabel.text = "00:00"
        enableButtons(false)
    }

    @objc private func recordButtonTouchUp(_ sender: UIButton) {
        waveformView.stopRecording()
    }

    @objc private func recordButtonTouchUpOutside(_ sender: UIButton) {
        waveformView.cancelRecording()
    }

    @objc private func playButtonTapped(_ sender: UIButton) {
        if let player = audioPlayer {
            if player.isPlaying {
                player.pause()
                sender.isSelected = false
                stopPlaybackTimer()
            } else {
                player.play()
                sender.isSelected = true
                startPlaybackTimer()
            }
        }
    }

    @objc private func deleteButtonTapped(_ sender: UIButton) {
        // 删除录音文件
        enablePlayback(false)
    }

    // MARK: - Helper Methods

    private func startRecordingTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let duration = self.waveformView.audioProcessor?.recordingDuration ?? 0
            self.timeLabel.text = self.formatTime(duration)
        }
    }

    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }

    private func startPlaybackTimer() {
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            let currentTime = player.currentTime
            self.timeLabel.text = self.formatTime(currentTime)
        }
    }

    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func saveRecording(url: URL?) {
        // 保存录音文件
    }

    private func enablePlayback(_ enable: Bool) {
        playButton.isEnabled = enable
        deleteButton.isEnabled = enable
    }

    private func updateBars(with amplitude: Float) {
        // 更新波形显示
    }
}
```
