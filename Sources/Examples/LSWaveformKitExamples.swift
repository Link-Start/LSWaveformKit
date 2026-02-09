//
//  LSWaveformKitExamples.swift
//  LSWaveformKit
//
//  Created by Link on 2025-02-07.
//  使用示例 - 展示 LSWaveformKit 的各种功能
//

import UIKit

// MARK: - 示例 1: 基础录音组件（开箱即用）

/// 示例：使用 LSRecordingContainer 快速集成录音功能
class BasicRecordingExample: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. 创建录音容器（一行代码集成）
        let container = LSRecordingContainer(frame: CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 200))

        // 2. 设置回调
        container.onRecordingStart = {
            print("开始录音")
        }

        container.onRecordingStop = { url, duration in
            print("录音完成: \(url?.path ?? ""), 时长: \(duration)秒")
        }

        container.onRecordingCancel = {
            print("录音已取消")
        }

        view.addSubview(container)
    }
}

// MARK: - 示例 2: 自定义波形视图

/// 示例：创建自定义配置的波形视图
class CustomWaveformExample: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. 创建波形视图
        let waveformView = LSWaveformView(frame: CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 60))

        // 2. 配置波形
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 30
        config.barWidth = 3.0
        config.barHeightMode = .symmetric
        config.barColor = UIColor_00CBE0()
        waveformView.configuration = config

        // 3. 设置代理
        waveformView.delegate = self

        view.addSubview(waveformView)
    }
}

extension CustomWaveformExample: LSWaveformViewDelegate {
    func waveformViewDidStartRecording(_ waveformView: LSWaveformView) {
        print("录音开始")
    }

    func waveformView(_ waveformView: LSWaveformView, didStopRecordingWithURL url: URL?, duration: TimeInterval) {
        print("录音完成: \(duration)秒")
    }

    func waveformViewDidCancelRecording(_ waveformView: LSWaveformView) {
        print("录音取消")
    }

    func waveformView(_ waveformView: LSWaveformView, didUpdateAmplitude amplitude: Float) {
        print("当前音量: \(amplitude)")
    }
}

// MARK: - 示例 3: 多种高度模式

/// 示例：展示不同的条纹高度模式
class BarHeightModesExample: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor_020120()

        let examples: [(LSBarHeightMode, String, CGFloat)] = [
            (.symmetric, "对称模式（中间高两边低）", 100),
            (.random, "随机模式", 180),
            (.ascending, "从左到右升高", 260),
            (.descending, "从左到右降低", 340),
            (.highLow, "高低高低", 420),
            (.lowHigh, "低高低高", 500),
            (.uniform, "一样高", 580),
            (.uneven(randomFactor: 0.3), "参差不齐", 660)
        ]

        for (mode, title, y) in examples {
            // 标题
            let label = UILabel()
            label.text = title
            label.font = PingFangSCRegular(size: 12)
            label.textColor = UIColor_FFFFFF()
            label.frame = CGRect(x: 20, y: y - 20, width: view.bounds.width - 40, height: 16)
            view.addSubview(label)

            // 波形
            let waveformView = LSWaveformView(frame: CGRect(x: 20, y: y, width: view.bounds.width - 40, height: 60))
            waveformView.configuration.barHeightMode = mode
            waveformView.configuration.barColor = UIColor_00CBE0()
            view.addSubview(waveformView)
        }
    }
}

// MARK: - 示例 4: 锚点视图自动布局（方案二）

/// 示例：使用锚点视图自动布局 - 波形自动适配时间标签宽度
class AnchorWaveformExample: UIViewController {

    private var waveformView: LSWaveformView!
    private var timeLabel: UILabel!
    private var timer: Timer?
    private var seconds = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor_020120()

        setupUI()
        startTimer()
    }

    private func setupUI() {
        // 1. 创建时间标签（锚点视图）
        timeLabel = UILabel()
        timeLabel.font = PingFangSCMedium(size: 18)
        timeLabel.textColor = UIColor_FFFFFF()
        timeLabel.text = "00:00"
        timeLabel.textAlignment = .center
        view.addSubview(timeLabel)

        timeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // 2. 创建波形视图
        waveformView = LSWaveformView()
        waveformView.backgroundColor = .clear

        // 3. 设置锚点视图（关键步骤！）
        waveformView.anchorView = timeLabel

        // 4. 配置使用锚点对称模式
        let config = LSDefaultWaveformConfiguration()
        config.layoutMode = .symmetricWithAnchor
        config.numberOfBars = 20
        config.barWidth = 3.0
        config.barColor = UIColor_00CBE0()
        waveformView.configuration = config

        // 5. 添加到视图（与 timeLabel 同一个父视图）
        view.addSubview(waveformView)

        waveformView.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(60)
        }

        // 6. 添加说明文字
        let hintLabel = UILabel()
        hintLabel.text = "时间标签宽度变化时，波形自动调整位置"
        hintLabel.font = PingFangSCRegular(size: 12)
        hintLabel.textColor = UIColor_D1D6D9()
        hintLabel.textAlignment = .center
        view.addSubview(hintLabel)

        hintLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.seconds += 1

            let minutes = self.seconds / 60
            let secs = self.seconds % 60
            self.timeLabel.text = String(format: "%02d:%02d", minutes, secs)

            // 关键：时间更新时，调用此方法同步波形位置
            self.waveformView.updateLayoutForAnchorLabel()

            // 模拟音量变化
            let amplitude = Float.random(in: 0.3...0.9)
            self.waveformView.updateAmplitude(amplitude)
        }
    }

    deinit {
        timer?.invalidate()
    }
}

// MARK: - 示例 5: 左右分离波形（方案一对比）

/// 示例：手动布局的左右分离波形 - 与方案二对比
class SplitWaveformManualExample: UIViewController {

    private var leftWaveform: LSWaveformView!
    private var rightWaveform: LSWaveformView!
    private var timeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor_020120()

        setupUI()
    }

    private func setupUI() {
        // 创建时间标签
        timeLabel = UILabel()
        timeLabel.font = PingFangSCMedium(size: 18)
        timeLabel.textColor = UIColor_FFFFFF()
        timeLabel.text = "00:00"
        timeLabel.textAlignment = .center
        view.addSubview(timeLabel)

        timeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // 创建左侧波形（手动配置）
        leftWaveform = LSWaveformView()
        let leftConfig = LSDefaultWaveformConfiguration()
        leftConfig.layoutMode = .rightOnly  // 条纹靠右对齐
        leftConfig.numberOfBars = 10
        leftConfig.barColor = UIColor_00CBE0()
        leftWaveform.configuration = leftConfig
        view.addSubview(leftWaveform)

        leftWaveform.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel)
            make.trailing.equalTo(timeLabel.snp.leading).offset(-8)
            make.width.equalTo(80)
            make.height.equalTo(60)
        }

        // 创建右侧波形（手动配置）
        rightWaveform = LSWaveformView()
        let rightConfig = LSDefaultWaveformConfiguration()
        rightConfig.layoutMode = .leftOnly   // 条纹靠左对齐
        rightConfig.numberOfBars = 10
        rightConfig.barColor = UIColor_00CBE0()
        rightWaveform.configuration = rightConfig
        view.addSubview(rightWaveform)

        rightWaveform.snp.makeConstraints { make in
            make.centerY.equalTo(timeLabel)
            make.leading.equalTo(timeLabel.snp.trailing).offset(8)
            make.width.equalTo(80)
            make.height.equalTo(60)
        }

        // 注意：这种方案需要手动处理时间标签宽度变化
        // 方案二（锚点视图）会自动处理
    }
}

// MARK: - 示例 6: 多种高度模式

/// 示例：展示不同的条纹高度模式
class BarHeightModesExample: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor_020120()

        let examples: [(LSBarHeightMode, String, CGFloat)] = [
            (.symmetric, "对称模式（中间高两边低）", 100),
            (.random, "随机模式", 180),
            (.ascending, "从左到右升高", 260),
            (.descending, "从左到右降低", 340),
            (.highLow, "高低高低", 420),
            (.lowHigh, "低高低高", 500),
            (.uniform, "一样高", 580),
            (.uneven(randomFactor: 0.3), "参差不齐", 660)
