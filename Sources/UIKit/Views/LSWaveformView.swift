//
//  LSWaveformView.swift
//  LSWaveformKit
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import UIKit

// MARK: - Data Source Protocol

/// 波形视图数据源协议
public protocol LSWaveformViewDataSource: AnyObject {
    /// 返回条纹数量
    func numberOfBars(in waveformView: LSWaveformView) -> Int

    /// 返回指定索引的条纹颜色
    /// - Parameters:
    ///   - waveformView: 波形视图
    ///   - index: 条纹索引
    /// - Returns: 条纹颜色
    func waveformView(_ waveformView: LSWaveformView, colorForBarAt index: Int) -> UIColor
}

// MARK: - Delegate Protocol

/// 波形视图代理协议
public protocol LSWaveformViewDelegate: AnyObject {
    /// 录音开始
    func waveformViewDidStartRecording(_ waveformView: LSWaveformView)

    /// 录音停止
    /// - Parameters:
    ///   - waveformView: 波形视图
    ///   - url: 音频文件路径
    ///   - duration: 录音时长
    func waveformView(_ waveformView: LSWaveformView, didStopRecordingWithURL url: URL?, duration: TimeInterval)

    /// 录音取消
    func waveformViewDidCancelRecording(_ waveformView: LSWaveformView)

    /// 音量更新
    func waveformView(_ waveformView: LSWaveformView, didUpdateAmplitude amplitude: Float)
}

// MARK: - Main Waveform View Class

/// 波形视图 - 所有波形视图的基类，提供核心功能和配置接口
public class LSWaveformView: UIView {

    // MARK: - 属性

    /// 锚点视图（用于对称布局，波形分布在其两侧）
    public weak var anchorView: UIView?

    /// 配置
    public var configuration: LSWaveformConfiguration {
        get {
            return _configuration
        }
        set {
            _configuration = newValue
            applyConfiguration()
        }
    }

    private var _configuration: LSWaveformConfiguration = LSDefaultWaveformConfiguration()

    /// 数据源
    public weak var dataSource: LSWaveformViewDataSource?

    /// 代理
    public weak var delegate: LSWaveformViewDelegate?

    /// 条纹数组（只读）
    public private(set) var bars: [LSWaveformBar] = []

    /// 音频处理器（只读）
    public private(set) var audioProcessor: LSWaveformAudioProcessor?

    /// 手势处理器（只读）
    public private(set) var gestureHandler: LSWaveformGestureHandler?

    /// 动画器（只读）
    public private(set) var animator: LSWaveformAnimator?

    /// 当前音量（只读，0.0-1.0）
    public private(set) var currentAmplitude: Float = 0

    /// 是否正在录音（只读）
    public var isRecording: Bool {
        return audioProcessor?.state == .recording
    }

    /// 是否正在播放（只读）
    public var isPlaying: Bool {
        return audioProcessor?.state == .playing
    }

    // MARK: - 回调闭包

    /// 录音开始回调
    /// 重要：使用 [weak self] 避免循环引用
    /// 示例：
    /// ```swift
    /// waveformView.onRecordingStart = { [weak self] in
    ///     guard let self = self else { return }
    ///     self.handleStart()
    /// }
    /// ```
    public var onRecordingStart: (() -> Void)?

    /// 录音停止回调
    /// 重要：使用 [weak self] 避免循环引用
    public var onRecordingStop: ((URL?, TimeInterval) -> Void)?

    /// 录音取消回调
    /// 重要：使用 [weak self] 避免循环引用
    public var onRecordingCancel: (() -> Void)?

    /// 音量更新回调
    /// 注意：此回调会频繁调用，建议使用 [weak self] 避免循环引用
    public var onAmplitudeUpdate: ((Float) -> Void)?

    // MARK: - 锚点布局相关

    /// 占位视图（宽度与 anchorView 保持同步，用于定位左右波形）
    private lazy var placeholderView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    /// 左侧容器视图
    private lazy var leftContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    /// 右侧容器视图
    private lazy var rightContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()

    /// 布局约束已设置标志
    private var layoutConstraintsEstablished = false

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
        // 重要：清理资源，防止页面销毁后继续录音
        // 停止录音和播放
        audioProcessor?.stopRecording()
        audioProcessor?.stopPlaying()

        // 停止所有动画
        animator?.stopAllAnimations()

        // 清理回调闭包（防止循环引用）
        onRecordingStart = nil
        onRecordingStop = nil
        onRecordingCancel = nil
        onAmplitudeUpdate = nil

        // 清理代理
        delegate = nil
        dataSource = nil

        // 清理核心组件
        animator = nil
        audioProcessor = nil
        gestureHandler = nil

        // 移除所有条纹
        bars.forEach { $0.removeFromSuperview() }
        bars.removeAll()
    }

    // MARK: - 设置

    private func setup() {
        backgroundColor = .clear

        // 创建核心组件
        animator = LSWaveformAnimator(waveformView: self)
        audioProcessor = LSWaveformAudioProcessor()
        gestureHandler = LSWaveformGestureHandler(view: self)

        // 设置代理
        audioProcessor?.delegate = self
        gestureHandler?.delegate = self

        // 添加容器视图（用于锚点布局模式）
        addSubview(placeholderView)
        addSubview(leftContainerView)
        addSubview(rightContainerView)

        // 应用初始配置
        applyConfiguration()

        // 创建条纹
        createBars()
    }

    // MARK: - 布局

    public override func layoutSubviews() {
        super.layoutSubviews()

        updateBarsLayout()
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            setupAnchoredLayoutIfNeeded()
        }
    }

    // MARK: - 创建条纹

    private func createBars() {
        // 清除旧条纹
        bars.forEach { $0.removeFromSuperview() }
        bars.removeAll()

        let count = configuration.numberOfBars

        for i in 0..<count {
            let bar = LSWaveformBar(index: i)
            bar.backgroundColor = getBarColor(at: i)
            bar.layer.cornerRadius = configuration.cornerRadius

            if configuration.showStroke {
                bar.layer.borderWidth = configuration.strokeWidth
                bar.layer.borderColor = configuration.strokeColor.cgColor
            }

            if configuration.enableShadow,
               let shadowColor = configuration.shadowColor {
                bar.applyShadow(
                    color: shadowColor,
                    offset: configuration.shadowOffset,
                    radius: configuration.shadowRadius,
                    opacity: 1.0
                )
            }

            // 根据布局模式决定添加到哪个视图
            switch configuration.layoutMode {
            case .symmetricWithAnchor:
                // 锚点模式：条纹添加到左右容器
                if i < count / 2 {
                    leftContainerView.addSubview(bar)
                } else {
                    rightContainerView.addSubview(bar)
                }
            default:
                // 其他模式：直接添加到自身
                addSubview(bar)
            }

            bars.append(bar)
        }

        updateBarsLayout()
    }

    // MARK: - 更新条纹布局

    private func updateBarsLayout() {
        guard !bars.isEmpty else { return }

        switch configuration.layoutMode {
        case .symmetricWithAnchor:
            updateAnchoredBarsLayout()
        default:
            updateNormalBarsLayout()
        }
    }

    /// 更新普通模式的条纹布局
    private func updateNormalBarsLayout() {
        let count = bars.count
        let barWidth = configuration.barWidth
        let totalBarsWidth = CGFloat(count) * barWidth

        // 计算起始位置（根据布局模式）
        let startX: CGFloat
        switch configuration.layoutMode {
        case .symmetric:
            startX = (bounds.width - totalBarsWidth) / 2
        case .leftOnly:
            startX = 20
        case .rightOnly:
            startX = bounds.width - totalBarsWidth - 20
        case .horizontal:
            startX = (bounds.width - totalBarsWidth) / 2
        default:
            startX = (bounds.width - totalBarsWidth) / 2
        }

        // 为每个条纹设置约束
        for (index, bar) in bars.enumerated() {
            var heightConstraint: NSLayoutConstraint?

            // 移除旧的约束
            bar.removeConstraints(bar.constraints)

            // 创建新的约束
            let widthConstraint = bar.widthAnchor.constraint(equalToConstant: barWidth)
            heightConstraint = bar.heightAnchor.constraint(equalToConstant: configuration.baseHeight)
            let centerYConstraint = bar.centerYAnchor.constraint(equalTo: self.centerYAnchor)

            let spacing = getSpacing(for: index, total: count)
            let x = startX + CGFloat(index) * (barWidth + spacing)

            let leadingConstraint = bar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: x)

            // 设置约束优先级
            leadingConstraint.priority = .required
            widthConstraint.priority = .required
            if let heightConstraint = heightConstraint {
                heightConstraint.priority = .required - 1
            }
            centerYConstraint.priority = .required

            var constraintsToActivate: [NSLayoutConstraint] = [
                widthConstraint,
                centerYConstraint,
                leadingConstraint
            ]
            if let heightConstraint = heightConstraint {
                constraintsToActivate.append(heightConstraint)
            }

            NSLayoutConstraint.activate(constraintsToActivate)

            // 保存高度约束引用以便后续安全更新
            if let constraint = heightConstraint {
                bar.setHeightConstraint(constraint)
            }
        }
    }

    /// 更新锚点模式的条纹布局
    private func updateAnchoredBarsLayout() {
        let halfCount = (bars.count + 1) / 2
        let barWidth = configuration.barWidth
        let barSpacing = configuration.barSpacing

        // 左侧条纹（从右向左排列）
        for (index, bar) in bars.enumerated() where index < halfCount {
            let reversedIndex = halfCount - 1 - index
            bar.translatesAutoresizingMaskIntoConstraints = false

            let heightConstraint = bar.heightAnchor.constraint(equalToConstant: configuration.baseHeight)
            NSLayoutConstraint.activate([
                bar.widthAnchor.constraint(equalToConstant: barWidth),
                heightConstraint,
                bar.centerYAnchor.constraint(equalTo: centerYAnchor),
                bar.trailingAnchor.constraint(equalTo: leftContainerView.trailingAnchor, constant: -CGFloat(reversedIndex) * (barWidth + barSpacing))
            ])
            bar.setHeightConstraint(heightConstraint)
        }

        // 右侧条纹（从左向右排列）
        for (index, bar) in bars.enumerated() where index >= halfCount {
            let rightIndex = index - halfCount
            bar.translatesAutoresizingMaskIntoConstraints = false

            let heightConstraint = bar.heightAnchor.constraint(equalToConstant: configuration.baseHeight)
            NSLayoutConstraint.activate([
                bar.widthAnchor.constraint(equalToConstant: barWidth),
                heightConstraint,
                bar.centerYAnchor.constraint(equalTo: centerYAnchor),
                bar.leadingAnchor.constraint(equalTo: rightContainerView.leadingAnchor, constant: CGFloat(rightIndex) * (barWidth + barSpacing))
            ])
            bar.setHeightConstraint(heightConstraint)
        }
    }

    // MARK: - 锚点布局设置

    /// 设置锚点布局约束（如果需要）
    private func setupAnchoredLayoutIfNeeded() {
        guard configuration.layoutMode == .symmetricWithAnchor,
              !layoutConstraintsEstablished else {
            return
        }

        layoutConstraintsEstablished = true

        // placeholderView 居中，宽度动态匹配 anchorView
        placeholderView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            placeholderView.heightAnchor.constraint(equalToConstant: 50),
            placeholderView.widthAnchor.constraint(equalToConstant: 60) // 默认宽度
        ])

        let spacing: CGFloat = 8
        let waveformWidth = calculateWaveformWidth()

        // 左侧容器
        leftContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leftContainerView.trailingAnchor.constraint(equalTo: placeholderView.leadingAnchor, constant: -spacing),
            leftContainerView.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor),
            leftContainerView.widthAnchor.constraint(equalToConstant: waveformWidth),
            leftContainerView.heightAnchor.constraint(equalToConstant: 50)
        ])

        // 右侧容器
        rightContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightContainerView.leadingAnchor.constraint(equalTo: placeholderView.trailingAnchor, constant: spacing),
            rightContainerView.centerYAnchor.constraint(equalTo: placeholderView.centerYAnchor),
            rightContainerView.widthAnchor.constraint(equalToConstant: waveformWidth),
            rightContainerView.heightAnchor.constraint(equalToConstant: 50)
        ])

        // 如果有锚点视图，立即更新宽度
        updatePlaceholderWidth()
    }

    /// 更新 placeholderView 的宽度以匹配 anchorView
    private func updatePlaceholderWidth() {
        guard configuration.layoutMode == .symmetricWithAnchor,
              layoutConstraintsEstablished,  // 确保约束已设置
              let anchorView = anchorView else {
            return
        }

        // 获取 anchorView 的内容宽度
        let labelWidth = anchorView.intrinsicContentSize.width

        // 更新 placeholderView 的宽度约束
        placeholderView.constraints.forEach { constraint in
            if constraint.firstAttribute == .width && constraint.firstItem as? UIView == placeholderView {
                constraint.constant = labelWidth
            }
        }
    }

    /// 当 anchorView 的内容变化时调用此方法更新波形位置
    public func updateLayoutForAnchorLabel() {
        updatePlaceholderWidth()
    }

    /// 计算单侧波形宽度
    private func calculateWaveformWidth() -> CGFloat {
        let halfCount = (configuration.numberOfBars + 1) / 2
        return CGFloat(halfCount) * (configuration.barWidth + configuration.barSpacing)
    }

    // MARK: - 获取条纹颜色

    private func getBarColor(at index: Int) -> UIColor {
        if let dataSource = dataSource {
            return dataSource.waveformView(self, colorForBarAt: index)
        }

        switch configuration.barColorMode {
        case .single(let color):
            return color
        case .multiple(let colors, let cycle):
            return colors[index % colors.count]
        case .perBar(let colors):
            return index < colors.count ? colors[index] : colors.last!
        case .amplitudeBased(let low, let high):
            let t = Float(index) / Float(max(bars.count - 1, 1))
            return interpolateColor(from: low, to: high, t: t)
        case .rainbow:
            return rainbowColor(at: index, total: bars.count)
        case .gradientVertical(let colors, let locations):
            let t = Float(index) / Float(max(bars.count - 1, 1))
            return gradientColor(from: colors, locations: locations, t: t)
        case .gradientHorizontal(let colors, let locations):
            let t = Float(index) / Float(max(bars.count - 1, 1))
            return gradientColor(from: colors, locations: locations, t: t)
        case .gradientDiagonal(let colors, let locations):
            let t = Float(index) / Float(max(bars.count - 1, 1))
            return gradientColor(from: colors, locations: locations, t: t)
        case .gradientRadial(let colors, let locations):
            let t = Float(index) / Float(max(bars.count - 1, 1))
            return gradientColor(from: colors, locations: locations, t: t)
        case .frequencyBased(let colors):
            return colors[index % colors.count]
        case .custom(let provider):
            return provider.color(for: UIView(), index: index, total: bars.count, amplitude: currentAmplitude)
        case .dynamic:
            return UIColor_00CBE0()
        }
    }

    // MARK: - 获取间距

    private func getSpacing(for index: Int, total: Int) -> CGFloat {
        switch configuration.spacingMode {
        case .equal(let spacing):
            return spacing
        case .percentage(let percentage):
            let totalWidth = bounds.width - CGFloat(total) * configuration.barWidth
            return totalWidth * percentage / CGFloat(max(total - 1, 1))
        case .automatic:
            let totalWidth = bounds.width - CGFloat(total) * configuration.barWidth
            return totalWidth / CGFloat(max(total + 1, 1))
        case .unequal(let spacings):
            return spacings[index % spacings.count]
        case .gradient(let minValue, let maxValue):
            let t = Float(index) / Float(max(total - 1, 1))
            return CGFloat(Float(minValue) + t * (Float(maxValue) - Float(minValue)))
        case .custom(let calculator):
            return calculator(index, total, configuration.barSpacing)
        case .delegate(let delegate):
            return delegate.spacing(for: index, total: total)
        case .amplitudeBased(let minValue, let maxValue):
            let t = 1.0 - currentAmplitude
            return CGFloat(Float(minValue) + t * (Float(maxValue) - Float(minValue)))
        case .wave(let minValue, let maxValue, let frequency):
            let phase = Float(index) * Float(frequency)
            let amplitude = (Float(maxValue) - Float(minValue)) / 2
            let offset = sin(phase) * amplitude
            return CGFloat(Float(minValue) + (Float(maxValue) - Float(minValue)) / 2 + offset)
        }
    }

    // MARK: - 应用配置

    private func applyConfiguration() {
        // 重新创建条纹（如果数量变化）
        if bars.count != configuration.numberOfBars {
            createBars()
        } else {
            // 更新现有条纹的属性
            for (index, bar) in bars.enumerated() {
                bar.backgroundColor = getBarColor(at: index)
                bar.layer.cornerRadius = configuration.cornerRadius

                if configuration.showStroke {
                    bar.layer.borderWidth = configuration.strokeWidth
                    bar.layer.borderColor = configuration.strokeColor.cgColor
                } else {
                    bar.layer.borderWidth = 0
                }
            }

            updateBarsLayout()
        }

        // 更新动画器配置
        animator?.duration = configuration.animationDuration
        animator?.animationCurve = configuration.animationCurve

        // 如果切换到锚点模式，设置布局
        if configuration.layoutMode == .symmetricWithAnchor && !layoutConstraintsEstablished {
            setupAnchoredLayoutIfNeeded()
        }
    }

    // MARK: - 录音控制

    /// 开始录音
    public func startRecording() {
        audioProcessor?.startRecording()
    }

    /// 停止录音
    /// nonisolated(unsafe): 此方法执行同步的线程安全操作，可从任何线程调用
    public nonisolated(unsafe) func stopRecording() {
        audioProcessor?.stopRecording()
    }

    /// 取消录音
    /// nonisolated(unsafe): 此方法执行同步的线程安全操作，可从任何线程调用
    public nonisolated(unsafe) func cancelRecording() {
        audioProcessor?.cancelRecording()
    }

    /// 暂停录音
    public func pauseRecording() {
        // AVAudioRecorder 不支持暂停，需要实现自定义逻辑
    }

    /// 恢复录音
    public func resumeRecording() {
        // AVAudioRecorder 不支持暂停，需要实现自定义逻辑
    }

    // MARK: - 播放控制

    /// 播放音频
    /// - Parameter url: 音频文件路径
    public func playAudio(at url: URL) {
        audioProcessor?.playAudio(at: url)
    }

    /// 停止播放
    /// nonisolated(unsafe): 此方法执行同步的线程安全操作，可从任何线程调用
    public nonisolated(unsafe) func stopPlaying() {
        audioProcessor?.stopPlaying()
    }

    /// 暂停播放
    public func pausePlaying() {
        audioProcessor?.pausePlaying()
    }

    /// 恢复播放
    public func resumePlaying() {
        audioProcessor?.resumePlaying()
    }

    /// 跳转到指定时间
    /// - Parameter time: 目标时间（秒）
    public func seek(to time: TimeInterval) {
        audioProcessor?.seek(to: time)
    }

    // MARK: - 波形更新

    /// 更新音量
    /// - Parameter amplitude: 音量值（0.0 ~ 1.0）
    public func updateAmplitude(_ amplitude: Float) {
        currentAmplitude = amplitude
        updateBarsHeight(with: amplitude)
    }

    /// 更新条纹高度
    private func updateBarsHeight(with amplitude: Float) {
        let heights = calculateBarHeights(amplitude: amplitude)

        for (index, bar) in bars.enumerated() {
            bar.targetHeight = heights[index]

            // 更新颜色（如果是基于音量的颜色模式）
            if case .amplitudeBased = configuration.barColorMode {
                // 可选：实时更新颜色
            }
        }

        // 使用动画器更新
        animator?.animateBars(bars, toHeights: heights)
    }

    /// 计算条纹高度
    private func calculateBarHeights(amplitude: Float) -> [CGFloat] {
        let count = bars.count
        var heights: [CGFloat] = []

        for i in 0..<count {
            let height: CGFloat

            switch configuration.barHeightMode {
            case .symmetric:
                let center = Float(count) / 2.0
                let distance = abs(Float(i) - center)
                let factor = 1.0 - (distance / center)
                height = configuration.baseHeight + CGFloat(amplitude * factor) * (configuration.maximumBarHeight - configuration.baseHeight)

            case .uniform:
                height = configuration.baseHeight + CGFloat(amplitude) * (configuration.maximumBarHeight - configuration.baseHeight)

            case .random:
                let randomFactor = Float.random(in: 0.5...1.0)
                height = configuration.baseHeight + CGFloat(amplitude * randomFactor) * (configuration.maximumBarHeight - configuration.baseHeight)

            case .ascending:
                let factor = Float(i) / Float(max(count - 1, 1))
                height = configuration.baseHeight + CGFloat(amplitude * factor) * (configuration.maximumBarHeight - configuration.baseHeight)

            case .descending:
                let factor = 1.0 - Float(i) / Float(max(count - 1, 1))
                height = configuration.baseHeight + CGFloat(amplitude * factor) * (configuration.maximumBarHeight - configuration.baseHeight)

            case .highLow:
                height = (i % 2 == 0) ? configuration.maximumBarHeight : configuration.minimumBarHeight

            case .lowHigh:
                height = (i % 2 == 0) ? configuration.minimumBarHeight : configuration.maximumBarHeight

            case .custom(let customHeights):
                let t = customHeights[i % customHeights.count]
                height = configuration.baseHeight + CGFloat(amplitude * t) * (configuration.maximumBarHeight - configuration.baseHeight)

            case .uneven(let factor):
                let randomOffset = Float.random(in: -factor...factor)
                let baseFactor = 1.0 + randomOffset
                height = configuration.baseHeight + CGFloat(amplitude * baseFactor) * (configuration.maximumBarHeight - configuration.baseHeight)

            case .highHighLowLow, .lowLowHighHigh, .highHighLowHigh, .lowLowHighLowHigh:
                let factor = Float(i % 4) / 3.0
                height = configuration.baseHeight + CGFloat(amplitude * factor) * (configuration.maximumBarHeight - configuration.baseHeight)

            case .peak:
                height = configuration.maximumBarHeight

            case .valley:
                height = configuration.minimumBarHeight

            case .highToLow, .lowToHigh:
                let factor = Float(i) / Float(max(count - 1, 1))
                height = configuration.baseHeight + CGFloat(amplitude * factor) * (configuration.maximumBarHeight - configuration.baseHeight)
            }

            heights.append(max(configuration.minimumBarHeight, min(configuration.maximumBarHeight, height)))
        }

        return heights
    }

    // MARK: - 重置波形

    /// 重置波形
    public func resetWaveform() {
        currentAmplitude = 0

        for bar in bars {
            bar.reset()
        }

        updateBarsLayout()
    }

    /// 刷新波形显示
    public func refreshWaveform() {
        applyConfiguration()
    }

    // MARK: - 样式应用

    /// 应用预设风格
    /// - Parameter style: 风格枚举
    public func applyStyle(_ style: LSWaveformStyle) {
        if var defaultConfig = _configuration as? LSDefaultWaveformConfiguration {
            LSWaveformStylePresets.applyStyle(style, to: defaultConfig)
            _configuration = defaultConfig
            applyConfiguration()
        }
    }

    /// 应用自定义配置
    /// - Parameter configuration: 配置对象
    public func applyConfiguration(_ configuration: LSWaveformConfiguration) {
        _configuration = configuration
        applyConfiguration()
    }

    // MARK: - 辅助方法

    /// 渐变颜色
    private func gradientColor(from colors: [UIColor], locations: [NSNumber], t: Float) -> UIColor {
        guard colors.count > 1 else {
            return colors.first ?? UIColor_00CBE0()
        }

        // 找到对应的渐变段
        let normalizedT = max(0, min(1, t))

        // 找到 t 对应的颜色区间
        for i in 0..<(locations.count - 1) {
            let startLocation = locations[i].floatValue
            let endLocation = locations[i + 1].floatValue

            if normalizedT >= startLocation && normalizedT <= endLocation {
                // 在这个区间内进行插值
                let segmentT = (normalizedT - startLocation) / (endLocation - startLocation)
                return interpolateColor(from: colors[i], to: colors[i + 1], t: segmentT)
            }
        }

        return colors.last ?? UIColor_00CBE0()
    }

    /// 颜色插值
    private func interpolateColor(from: UIColor, to: UIColor, t: Float) -> UIColor {
        var fR: CGFloat = 0, fG: CGFloat = 0, fB: CGFloat = 0, fA: CGFloat = 0
        var tR: CGFloat = 0, tG: CGFloat = 0, tB: CGFloat = 0, tA: CGFloat = 0

        from.getRed(&fR, green: &fG, blue: &fB, alpha: &fA)
        to.getRed(&tR, green: &tG, blue: &tB, alpha: &tA)

        let r = fR + (tR - fR) * CGFloat(t)
        let g = fG + (tG - fG) * CGFloat(t)
        let b = fB + (tB - fB) * CGFloat(t)
        let a = fA + (tA - fA) * CGFloat(t)

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    /// 彩虹颜色
    private func rainbowColor(at index: Int, total: Int) -> UIColor {
        let hue = Float(index) / Float(max(total - 1, 1))
        return UIColor(hue: CGFloat(hue), saturation: 1.0, brightness: 1.0, alpha: 1.0)
    }
}

// MARK: - LSWaveformAudioProcessorDelegate

extension LSWaveformView: LSWaveformAudioProcessorDelegate {
    public func audioProcessorDidStartRecording(_ processor: LSWaveformAudioProcessor) {
        onRecordingStart?()
        delegate?.waveformViewDidStartRecording(self)
    }

    public func audioProcessorDidStopRecording(_ processor: LSWaveformAudioProcessor) {
        let url = processor.recordingURL
        let duration = processor.recordingDuration

        onRecordingStop?(url, duration)
        delegate?.waveformView(self, didStopRecordingWithURL: url, duration: duration)
    }

    public func audioProcessor(_ processor: LSWaveformAudioProcessor, didUpdateAmplitude amplitude: Float) {
        updateAmplitude(amplitude)

        onAmplitudeUpdate?(amplitude)
        delegate?.waveformView(self, didUpdateAmplitude: amplitude)
    }

    public func audioProcessorDidStartPlaying(_ processor: LSWaveformAudioProcessor) {
        // 播放开始回调
    }

    public func audioProcessorDidStopPlaying(_ processor: LSWaveformAudioProcessor) {
        // 播放停止回调
    }

    public func audioProcessor(_ processor: LSWaveformAudioProcessor, didOccur error: Error) {
        // 错误处理
    }
}

// MARK: - LSWaveformGestureHandlerDelegate

extension LSWaveformView: LSWaveformGestureHandlerDelegate {
    public func gestureHandlerDidBeginRecording(_ handler: LSWaveformGestureHandler) {
        startRecording()
    }

    public func gestureHandlerDidEndRecording(_ handler: LSWaveformGestureHandler) {
        stopRecording()
    }

    public func gestureHandlerDidCancelRecording(_ handler: LSWaveformGestureHandler) {
        cancelRecording()
        onRecordingCancel?()
        delegate?.waveformViewDidCancelRecording(self)
    }

    public func gestureHandlerWillCancelRecording(_ handler: LSWaveformGestureHandler) {
        // 即将取消时的反馈
    }

    public func gestureHandler(_ handler: LSWaveformGestureHandler, updateCancelProgress progress: CGFloat) {
        // 取消进度更新
    }
}
