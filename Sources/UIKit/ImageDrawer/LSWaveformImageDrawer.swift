//
//  LSWaveformImageDrawer.swift
//  LSWaveformKit
//
//  Created by Link on 2025/02/09.
//  Copyright © 2025 Link. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - LSWaveformImageDrawer

/// 波形图像生成器 - 从音频文件生成静态波形图像
public final class LSWaveformImageDrawer {

    // MARK: - Types

    /// 图像生成配置
    public struct ImageConfiguration {
        /// 图像尺寸
        public var size: CGSize

        /// 波形配置
        public var waveform: LSWaveformConfiguration

        /// 背景颜色
        public var backgroundColor: UIColor?

        /// 缩放因子（用于 Retina 屏幕）
        public var scale: CGFloat

        /// 边距
        public var padding: UIEdgeInsets

        public init(
            size: CGSize,
            waveform: LSWaveformConfiguration,
            backgroundColor: UIColor? = nil,
            scale: CGFloat = UIScreen.main.scale,
            padding: UIEdgeInsets = .zero
        ) {
            self.size = size
            self.waveform = waveform
            self.backgroundColor = backgroundColor
            self.scale = scale
            self.padding = padding
        }

        /// 默认配置
        public static func `default`(size: CGSize = CGSize(width: 300, height: 100)) -> ImageConfiguration {
            return ImageConfiguration(
                size: size,
                waveform: LSDefaultWaveformConfiguration.symmetric()
            )
        }
    }

    // MARK: - Properties

    /// 图像配置
    public var configuration: ImageConfiguration

    // MARK: - Initialization

    /// 初始化图像生成器
    /// - Parameter configuration: 图像配置
    public init(configuration: ImageConfiguration = .default()) {
        self.configuration = configuration
    }

    // MARK: - Public Methods

    /// 从音频文件生成波形图像（异步）
    /// - Parameters:
    ///   - audioURL: 音频文件 URL
    ///   - config: 图像配置（可选，默认使用实例配置）
    /// - Returns: 生成的 UIImage
    public func waveformImage(
        from audioURL: URL,
        config: ImageConfiguration? = nil
    ) async throws -> UIImage {
        let config = config ?? configuration

        // 分析音频文件
        let analyzer = LSWaveformAnalyzer(audioURL: audioURL)
        let samples = try await analyzer.analyze()

        // 生成图像
        return render(samples: samples, config: config)
    }

    /// 从音频文件生成波形图像（同步）
    /// - Parameters:
    ///   - audioURL: 音频文件 URL
    ///   - config: 图像配置（可选，默认使用实例配置）
    /// - Returns: 生成的 UIImage
    public func waveformImage(
        from audioURL: URL,
        config: ImageConfiguration? = nil
    ) throws -> UIImage {
        let config = config ?? configuration

        // 分析音频文件
        let analyzer = LSWaveformAnalyzer(audioURL: audioURL)
        let samples = try analyzer.analyzeSync()

        // 生成图像
        return render(samples: samples, config: config)
    }

    /// 从样本数组生成波形图像
    /// - Parameters:
    ///   - samples: 样本数组
    ///   - config: 图像配置（可选，默认使用实例配置）
    /// - Returns: 生成的 UIImage
    public func waveformImage(
        from samples: [Float],
        config: ImageConfiguration? = nil
    ) -> UIImage {
        let config = config ?? configuration
        return render(samples: samples, config: config)
    }

    // MARK: - Private Methods

    /// 渲染波形图像
    private func render(samples: [Float], config: ImageConfiguration) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: config.size)

        return renderer.image { context in
            // 绘制背景
            if let bgColor = config.backgroundColor {
                context.cgContext.setFillColor(bgColor.cgColor)
                context.cgContext.fill(CGRect(origin: .zero, size: config.size))
            }

            // 计算绘制区域
            let drawRect = CGRect(
                x: config.padding.left,
                y: config.padding.top,
                width: config.size.width - config.padding.left - config.padding.right,
                height: config.size.height - config.padding.top - config.padding.bottom
            )

            // 根据配置绘制波形
            drawWaveform(samples: samples, in: context.cgContext, rect: drawRect, config: config)
        }
    }

    /// 绘制波形
    private func drawWaveform(
        samples: [Float],
        in context: CGContext,
        rect: CGRect,
        config: ImageConfiguration
    ) {
        let waveformConfig = config.waveform

        // 获取绘制参数
        let numberOfBars = min(samples.count, waveformConfig.numberOfBars)
        let barWidth = waveformConfig.barWidth
        let spacing = calculateSpacing(for: rect, barWidth: barWidth, count: numberOfBars, config: waveformConfig)

        // 设置绘制属性
        context.setShouldAntialias(true)

        // 绘制每个条纹
        for i in 0..<numberOfBars {
            let sample = samples[i]
            let barHeight = calculateBarHeight(
                from: sample,
                in: rect.height,
                config: waveformConfig
            )

            let position = calculateBarPosition(
                index: i,
                barWidth: barWidth,
                spacing: spacing,
                in: rect,
                config: waveformConfig
            )

            let barRect = calculateBarRect(
                position: position,
                width: barWidth,
                height: barHeight,
                in: rect,
                config: waveformConfig
            )

            // 获取颜色
            let color = getBarColor(for: i, total: numberOfBars, config: waveformConfig)

            // 绘制条纹
            drawBar(in: context, rect: barRect, color: color, config: waveformConfig)
        }
    }

    /// 计算间距
    private func calculateSpacing(
        for rect: CGRect,
        barWidth: CGFloat,
        count: Int,
        config: LSWaveformConfiguration
    ) -> CGFloat {
        switch config.spacingMode {
        case .equal(let spacing):
            return spacing
        case .percentage(let percentage):
            let totalWidth = rect.width
            let totalBarWidth = CGFloat(count) * barWidth
            let remainingSpace = totalWidth - totalBarWidth
            return remainingSpace / CGFloat(count - 1) * percentage
        case .automatic:
            let totalWidth = rect.width
            let totalBarWidth = CGFloat(count) * barWidth
            let remainingSpace = totalWidth - totalBarWidth
            return remainingSpace / CGFloat(count + 1)
        case .unequal(let spacings):
            // 不等间距，返回第一个值
            return spacings.first ?? 0
        case .gradient(let min, let max):
            // 渐变间距，返回中间值
            return (min + max) / 2
        case .custom(let closure):
            // 自定义间距
            return closure(0, count, rect.width)
        case .delegate:
            // 代理模式，返回默认值
            return 2.0
        case .amplitudeBased(let min, let max):
            // 基于音量的动态间距，返回中间值
            return (min + max) / 2
        case .wave(let min, let max, _):
            // 波浪间距，返回中间值
            return (min + max) / 2
        }
    }

    /// 计算条纹高度
    private func calculateBarHeight(
        from sample: Float,
        in maxHeight: CGFloat,
        config: LSWaveformConfiguration
    ) -> CGFloat {
        let baseHeight = max(min(config.minimumBarHeight, maxHeight), 0)
        let maxBarHeight = min(config.maximumBarHeight, maxHeight)

        switch config.barHeightMode {
        case .uniform:
            return CGFloat(sample) * maxBarHeight
        case .symmetric:
            let height = CGFloat(sample) * maxBarHeight / 2
            return max(height, baseHeight)
        case .random:
            let randomFactor = Float.random(in: 0.5...1.0)
            return CGFloat(sample * randomFactor) * maxBarHeight
        case .ascending:
            // 暂时使用样本值
            return CGFloat(sample) * maxBarHeight
        case .descending:
            // 暂时使用样本值
            return CGFloat(sample) * maxBarHeight
        case .highLow, .lowHigh, .highHighLowLow, .lowLowHighHigh, .highHighLowHigh, .lowLowHighLowHigh:
            // 模式由位置决定，这里使用样本值
            return CGFloat(sample) * maxBarHeight
        case .peak:
            return maxBarHeight
        case .valley:
            return baseHeight
        case .custom(let heights):
            // 自定义高度数组，使用样本值作为索引
            let index = min(Int(sample * Float(heights.count)), heights.count - 1)
            return CGFloat(max(0, min(1, heights[index]))) * maxBarHeight
        case .highToLow, .lowToHigh:
            // 渐变模式，使用样本值
            return CGFloat(sample) * maxBarHeight
        case .uneven:
            // 参差不齐，使用样本值
            return CGFloat(sample) * maxBarHeight
        }
    }

    /// 计算条纹位置
    private func calculateBarPosition(
        index: Int,
        barWidth: CGFloat,
        spacing: CGFloat,
        in rect: CGRect,
        config: LSWaveformConfiguration
    ) -> CGPoint {
        let totalBarSpace = barWidth + spacing
        var x: CGFloat
        var y: CGFloat

        switch config.layoutMode {
        case .symmetric:
            // 居中对称
            let totalWidth = CGFloat(config.numberOfBars) * totalBarSpace
            x = rect.minX + (rect.width - totalWidth) / 2 + CGFloat(index) * totalBarSpace
            y = rect.minY

        case .leftOnly:
            // 左侧对齐
            x = rect.minX + CGFloat(index) * totalBarSpace
            y = rect.minY

        case .rightOnly:
            // 右侧对齐
            let totalWidth = CGFloat(config.numberOfBars) * totalBarSpace
            x = rect.maxX - totalWidth + CGFloat(index) * totalBarSpace
            y = rect.minY

        case .symmetricWithAnchor:
            // 锚点对称（简化处理，居中对称）
            let totalWidth = CGFloat(config.numberOfBars) * totalBarSpace
            x = rect.minX + (rect.width - totalWidth) / 2 + CGFloat(index) * totalBarSpace
            y = rect.minY

        case .horizontal:
            // 水平布局
            x = rect.minX + CGFloat(index) * totalBarSpace
            y = rect.minY

        case .circular:
            // 圆形布局（简化处理，按水平排列）
            x = rect.minX + CGFloat(index) * totalBarSpace
            y = rect.minY

        case .arc:
            // 弧形布局（简化处理）
            x = rect.minX + CGFloat(index) * totalBarSpace
            y = rect.minY

        case .spiral:
            // 螺旋布局（简化处理）
            x = rect.minX + CGFloat(index) * totalBarSpace
            y = rect.minY

        case .grid:
            // 网格布局（简化处理，单行）
            x = rect.minX + CGFloat(index) * totalBarSpace
            y = rect.minY

        case .custom:
            // 自定义布局（简化处理，水平排列）
            x = rect.minX + CGFloat(index) * totalBarSpace
            y = rect.minY
        }

        return CGPoint(x: x, y: y)
    }

    /// 计算条纹矩形
    private func calculateBarRect(
        position: CGPoint,
        width: CGFloat,
        height: CGFloat,
        in rect: CGRect,
        config: LSWaveformConfiguration
    ) -> CGRect {
        var x = position.x
        var y = position.y
        var barWidth = width
        var barHeight = height

        switch config.layoutMode {
        case .symmetric:
            // 对称，从中心向上下延伸
            y = rect.midY - height / 2

        case .leftOnly, .rightOnly, .horizontal, .symmetricWithAnchor:
            // 从底部向上
            y = rect.maxY - height

        case .circular:
            // 圆形，从中心向外
            let radius = min(rect.width, rect.height) / 2
            let angle = CGFloat.pi * 2 * CGFloat(x - rect.minX) / rect.width
            x = rect.midX + cos(angle) * radius * 0.8
            y = rect.midY + sin(angle) * radius * 0.8
            barWidth = 4
            barHeight = 4

        case .arc, .spiral, .grid, .custom:
            // 其他布局保持默认
            y = rect.maxY - height
        }

        return CGRect(x: x, y: y, width: barWidth, height: barHeight)
    }

    /// 获取条纹颜色
    private func getBarColor(
        for index: Int,
        total: Int,
        config: LSWaveformConfiguration
    ) -> UIColor {
        switch config.barColorMode {
        case .single(let color):
            return color

        case .multiple(let colors, _):
            // 多种颜色循环使用
            return colors[index % colors.count]

        case .gradientVertical(let colors, let locations):
            // 根据位置选择颜色
            let progress = CGFloat(index) / CGFloat(max(total - 1, 1))
            return colorFromGradient(colors: colors, locations: locations, progress: progress)

        case .gradientHorizontal(let colors, let locations):
            // 水平渐变
            let progress = CGFloat(index) / CGFloat(max(total - 1, 1))
            return colorFromGradient(colors: colors, locations: locations, progress: progress)

        case .gradientDiagonal(let colors, let locations):
            // 对角渐变（使用与水平渐变相同的逻辑）
            let progress = CGFloat(index) / CGFloat(max(total - 1, 1))
            return colorFromGradient(colors: colors, locations: locations, progress: progress)

        case .gradientRadial(let colors, let locations):
            // 径向渐变（使用与水平渐变相同的逻辑）
            let progress = CGFloat(index) / CGFloat(max(total - 1, 1))
            return colorFromGradient(colors: colors, locations: locations, progress: progress)

        case .perBar(let colors):
            // 每条独立颜色
            guard index < colors.count else { return config.barColor }
            return colors[index]

        case .amplitudeBased(let low, let high):
            // 基于音量的动态颜色（暂时返回中间色）
            return config.barColor

        case .frequencyBased(let colors):
            // 基于频率的颜色（简化处理，根据索引）
            let colorIndex = (index * colors.count) / max(total, 1)
            return colors[min(colorIndex, colors.count - 1)]

        case .custom(let provider):
            // 自定义颜色提供者
            return provider.color(for: UIView(), index: index, total: total, amplitude: 0.5)

        case .rainbow:
            // 彩虹色
            let hue = CGFloat(index) / CGFloat(max(total - 1, 1))
            return UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)

        case .dynamic:
            // 动态颜色（暂时返回单色）
            return config.barColor
        }
    }

    /// 从渐变中获取颜色
    private func colorFromGradient(
        colors: [UIColor],
        locations: [NSNumber],
        progress: CGFloat
    ) -> UIColor {
        guard colors.count > 1 else {
            return colors.first ?? .black
        }

        // 找到对应的渐变段
        for i in 0..<(colors.count - 1) {
            let start = locations[i].CGFloatValue
            let end = locations[i + 1].CGFloatValue

            if progress >= start && progress <= end {
                let segmentProgress = (progress - start) / (end - start)
                return interpolateBetween(
                    colors[i],
                    and: colors[i + 1],
                    progress: segmentProgress
                )
            }
        }

        return colors.last ?? .black
    }

    /// 颜色插值
    private func interpolateBetween(_ color1: UIColor, and color2: UIColor, progress: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        let r = r1 + (r2 - r1) * progress
        let g = g1 + (g2 - g1) * progress
        let b = b1 + (b2 - b1) * progress
        let a = a1 + (a2 - a1) * progress

        return UIColor(red: r, green: g, blue: b, alpha: a)
    }

    /// 绘制单个条纹
    private func drawBar(
        in context: CGContext,
        rect: CGRect,
        color: UIColor,
        config: LSWaveformConfiguration
    ) {
        context.setFillColor(color.cgColor)

        // 绘制圆角矩形
        if config.cornerRadius > 0 {
            let path = UIBezierPath(
                roundedRect: rect,
                byRoundingCorners: .allCorners,
                cornerRadii: CGSize(width: config.cornerRadius, height: config.cornerRadius)
            )
            context.addPath(path.cgPath)
            context.fillPath()
        } else {
            context.fill(rect)
        }

        // 绘制描边
        if config.showStroke {
            context.setStrokeColor(config.strokeColor.cgColor)
            context.setLineWidth(config.strokeWidth)

            if config.cornerRadius > 0 {
                let path = UIBezierPath(
                    roundedRect: rect,
                    byRoundingCorners: .allCorners,
                    cornerRadii: CGSize(width: config.cornerRadius, height: config.cornerRadius)
                )
                context.addPath(path.cgPath)
            } else {
                context.addRect(rect)
            }

            context.strokePath()
        }

        // 绘制阴影
        if config.enableShadow {
            context.setShadow(
                offset: config.shadowOffset,
                blur: config.shadowRadius,
                color: (config.shadowColor ?? .black).cgColor
            )
        }
    }
}

// MARK: - Convenience Extensions

private extension NSNumber {
    var CGFloatValue: CGFloat {
        return CGFloat(truncating: self)
    }
}

// MARK: - Static Convenience Methods

public extension LSWaveformImageDrawer {

    /// 快捷方法：从音频文件生成波形图像
    /// - Parameters:
    ///   - audioURL: 音频文件 URL
    ///   - size: 图像尺寸
    ///   - configuration: 波形配置
    /// - Returns: 生成的 UIImage
    static func image(
        from audioURL: URL,
        size: CGSize = CGSize(width: 300, height: 100),
        configuration: LSWaveformConfiguration = LSDefaultWaveformConfiguration.symmetric()
    ) async throws -> UIImage {
        let drawer = LSWaveformImageDrawer(
            configuration: .init(size: size, waveform: configuration)
        )
        return try await drawer.waveformImage(from: audioURL)
    }

    /// 快捷方法：从样本数组生成波形图像
    /// - Parameters:
    ///   - samples: 样本数组
    ///   - size: 图像尺寸
    ///   - configuration: 波形配置
    /// - Returns: 生成的 UIImage
    static func image(
        from samples: [Float],
        size: CGSize = CGSize(width: 300, height: 100),
        configuration: LSWaveformConfiguration = LSDefaultWaveformConfiguration.symmetric()
    ) -> UIImage {
        let drawer = LSWaveformImageDrawer(
            configuration: .init(size: size, waveform: configuration)
        )
        return drawer.waveformImage(from: samples)
    }
}
