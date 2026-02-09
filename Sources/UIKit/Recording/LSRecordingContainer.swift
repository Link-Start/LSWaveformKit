//
//  LSRecordingContainer.swift
//  LSWaveformKit
//
//  Created by Link on 2025-02-07.
//

import UIKit

/// 录音容器 - 组合波形视图和录音按钮的完整录音组件
public class LSRecordingContainer: UIView {

    // MARK: - 属性

    /// 波形视图
    public private(set) lazy var waveformView: LSWaveformView = {
        let view = LSWaveformView()
        return view
    }()

    /// 录音按钮
    public private(set) lazy var recordingButton: LSRecordingButton = {
        let btn = LSRecordingButton(type: .custom)
        btn.setDefaultIcons()
        return btn
    }()

    /// 时间标签
    public private(set) lazy var timeLabel: UILabel = {
        var lab = UILabel()
        lab.font = UIFont.pingFangSCRegular(ofSize: 14)
        lab.textColor = UIColor_FFFFFF()
        lab.text = "00:00"
        lab.textAlignment = .center
        return lab
    }()

    /// 提示标签
    public private(set) lazy var hintLabel: UILabel = {
        var lab = UILabel()
        lab.font = UIFont.pingFangSCRegular(ofSize: 12)
        lab.textColor = UIColor_D1D6D9()
        lab.text = "按住录音"
        lab.textAlignment = .center
        return lab
    }()

    /// 取消提示视图
    public private(set) lazy var cancelHintView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor_000000().withAlphaComponent(0.7)
        v.layer.cornerRadius = 8
        v.alpha = 0
        return v
    }()

    /// 取消图标
    private lazy var cancelIconView: UIImageView = {
        let imgV = UIImageView()
        imgV.image = UIImage(systemName: "trash.fill")
        imgV.tintColor = UIColor_FFFFFF()
        imgV.contentMode = .scaleAspectFit
        return imgV
    }()

    /// 取消文本
    private lazy var cancelLabel: UILabel = {
        var lab = UILabel()
        lab.font = UIFont.pingFangSCRegular(ofSize: 12)
        lab.textColor = UIColor_FFFFFF()
        lab.text = "松开取消"
        lab.textAlignment = .center
        return lab
    }()

    /// 配置
    public var configuration: LSWaveformConfiguration {
        get {
            return waveformView.configuration
        }
        set {
            waveformView.configuration = newValue
        }
    }

    /// 最大录音时长（秒）
    public var maximumRecordingDuration: TimeInterval = 60.0

    /// 当前录音时长
    public private(set) var currentDuration: TimeInterval = 0

    // MARK: - 回调

    /// 录音开始回调
    public var onRecordingStart: (() -> Void)?

    /// 录音停止回调
    public var onRecordingStop: ((URL?, TimeInterval) -> Void)?

    /// 录音取消回调
    public var onRecordingCancel: (() -> Void)?

    /// 音量更新回调
    public var onAmplitudeUpdate: ((Float) -> Void)?

    // MARK: - 私有属性

    private var timer: Timer?
    private var startDate: Date?

    // MARK: - 初始化

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    deinit {
        // 重要：停止录音和计时器
        stopTimer()
        waveformView.stopRecording()
        waveformView.stopPlaying()

        // 清理回调闭包（防止循环引用）
        onRecordingStart = nil
        onRecordingStop = nil
        onRecordingCancel = nil
        onAmplitudeUpdate = nil

        // 清理 waveformView 的回调
        waveformView.onRecordingStart = nil
        waveformView.onRecordingStop = nil
        waveformView.onRecordingCancel = nil
        waveformView.onAmplitudeUpdate = nil

        // 清理按钮回调
        recordingButton.onStateChange = nil
        recordingButton.removeTarget(self, action: nil, for: .allEvents)

        // 清理子视图引用（帮助释放）
        waveformView.removeFromSuperview()
        recordingButton.removeFromSuperview()
        timeLabel.removeFromSuperview()
        hintLabel.removeFromSuperview()
        cancelHintView.removeFromSuperview()
    }

    public convenience init(frame: CGRect, configuration: LSWaveformConfiguration) {
        self.init(frame: frame)
        self.configuration = configuration
    }

    // MARK: - 设置

    private func setup() {
        backgroundColor = .clear

        // 添加子视图
        addSubview(waveformView)
        addSubview(recordingButton)
        addSubview(timeLabel)
        addSubview(hintLabel)
        addSubview(cancelHintView)

        cancelHintView.addSubview(cancelIconView)
        cancelHintView.addSubview(cancelLabel)

        // 设置约束
        setupConstraints()

        // 配置按钮
        recordingButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        recordingButton.addTarget(self, action: #selector(buttonTouchUpInside(_:)), for: .touchUpInside)
        recordingButton.addTarget(self, action: #selector(buttonTouchUpOutside(_:)), for: .touchUpOutside)

        // 配置波形视图回调
        waveformView.onRecordingStart = { [weak self] in
            guard let self = self else { return }
            self.handleRecordingStart()
        }

        waveformView.onRecordingStop = { [weak self] url, duration in
            guard let self = self else { return }
            self.handleRecordingStop(url: url, duration: duration)
        }

        waveformView.onRecordingCancel = { [weak self] in
            guard let self = self else { return }
            self.handleRecordingCancel()
        }

        waveformView.onAmplitudeUpdate = { [weak self] amplitude in
            guard let self = self else { return }
            self.onAmplitudeUpdate?(amplitude)
        }
    }

    // MARK: - 布局

    private func setupConstraints() {
        waveformView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        recordingButton.translatesAutoresizingMaskIntoConstraints = false
        cancelHintView.translatesAutoresizingMaskIntoConstraints = false
        cancelIconView.translatesAutoresizingMaskIntoConstraints = false
        cancelLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // waveformView
            waveformView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            waveformView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            waveformView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            waveformView.heightAnchor.constraint(equalToConstant: 60),

            // timeLabel
            timeLabel.topAnchor.constraint(equalTo: waveformView.bottomAnchor, constant: 16),
            timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            // hintLabel
            hintLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4),
            hintLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            // recordingButton
            recordingButton.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 20),
            recordingButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            recordingButton.widthAnchor.constraint(equalToConstant: 64),
            recordingButton.heightAnchor.constraint(equalToConstant: 64),

            // cancelHintView
            cancelHintView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cancelHintView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
            cancelHintView.widthAnchor.constraint(equalToConstant: 80),
            cancelHintView.heightAnchor.constraint(equalToConstant: 60),

            // cancelIconView
            cancelIconView.topAnchor.constraint(equalTo: cancelHintView.topAnchor, constant: 8),
            cancelIconView.centerXAnchor.constraint(equalTo: cancelHintView.centerXAnchor),
            cancelIconView.widthAnchor.constraint(equalToConstant: 24),
            cancelIconView.heightAnchor.constraint(equalToConstant: 24),

            // cancelLabel
            cancelLabel.topAnchor.constraint(equalTo: cancelIconView.bottomAnchor, constant: 4),
            cancelLabel.leadingAnchor.constraint(equalTo: cancelHintView.leadingAnchor, constant: 8),
            cancelLabel.trailingAnchor.constraint(equalTo: cancelHintView.trailingAnchor, constant: -8)
        ])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        recordingButton.layer.cornerRadius = recordingButton.bounds.width / 2
    }

    // MARK: - 按钮事件

    @objc private func buttonTouchDown(_ sender: LSRecordingButton) {
        // 开始录音由手势处理器控制
    }

    @objc private func buttonTouchUpInside(_ sender: LSRecordingButton) {
        // 停止录音由手势处理器控制
    }

    @objc private func buttonTouchUpOutside(_ sender: LSRecordingButton) {
        // 取消录音由手势处理器控制
    }

    // MARK: - 录音事件处理

    private func handleRecordingStart() {
        currentDuration = 0
        startDate = Date()
        updateTimeLabel()

        hintLabel.text = "录音中..."
        timeLabel.isHidden = false

        startTimer()

        onRecordingStart?()
    }

    private func handleRecordingStop(url: URL?, duration: TimeInterval) {
        stopTimer()

        hintLabel.text = "按住录音"
        timeLabel.text = formatTime(duration)

        onRecordingStop?(url, duration)
    }

    private func handleRecordingCancel() {
        stopTimer()

        hintLabel.text = "按住录音"
        timeLabel.text = "00:00"
        currentDuration = 0

        onRecordingCancel?()
    }

    // MARK: - 计时器

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let startDate = self.startDate else { return }

            self.currentDuration = Date().timeIntervalSince(startDate)
            self.updateTimeLabel()

            // 检查最大时长
            if self.currentDuration >= self.maximumRecordingDuration {
                self.waveformView.stopRecording()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        startDate = nil
    }

    private func updateTimeLabel() {
        timeLabel.text = formatTime(currentDuration)
    }

    // MARK: - 辅助方法

    private func formatTime(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// 更新取消提示
    /// - Parameter progress: 取消进度 (0.0 ~ 1.0)
    public func updateCancelHint(progress: CGFloat) {
        let shouldShow = progress > 0.3

        UIView.animate(withDuration: 0.2) {
            self.cancelHintView.alpha = shouldShow ? 1 : 0
            self.recordingButton.cancelProgress = progress
        }

        if progress > 0.5 {
            recordingButton.transition(to: .canceling)
            hintLabel.text = "松开取消"
        } else {
            recordingButton.transition(to: .recording)
            hintLabel.text = "录音中..."
        }
    }

    // MARK: - 公开方法

    /// 开始录音
    public func startRecording() {
        waveformView.startRecording()
    }

    /// 停止录音
    public func stopRecording() {
        waveformView.stopRecording()
    }

    /// 取消录音
    public func cancelRecording() {
        waveformView.cancelRecording()
    }

    /// 重置状态
    public func reset() {
        waveformView.resetWaveform()
        timeLabel.text = "00:00"
        hintLabel.text = "按住录音"
        recordingButton.transition(to: .idle)
        cancelHintView.alpha = 0
    }
}
