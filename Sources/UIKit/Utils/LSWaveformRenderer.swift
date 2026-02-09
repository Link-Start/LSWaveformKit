//
//  LSWaveformRenderer.swift
//  LSWaveformKit
//
//  Created by Link on 2025-02-07.
//

import UIKit
import CoreGraphics

/// 波形渲染器 - 处理波形数据的可视化渲染
public class LSWaveformRenderer {

    // MARK: - 属性

    /// 渲染配置
    public var configuration: RenderingConfiguration

    /// 渲染层
    private var renderLayer: CAShapeLayer?

    // MARK: - 初始化

    public init(configuration: RenderingConfiguration = .default) {
        self.configuration = configuration
    }

    // MARK: - 渲染方法

    /// 渲染波形到图层
    /// - Parameters:
    ///   - samples: 音频样本数组
    ///   - layer: 目标图层
    ///   - bounds: 渲染边界
    public func render(samples: [Float], to layer: CAShapeLayer, in bounds: CGRect) {
        // 移除旧的渲染层
        renderLayer?.removeFromSuperlayer()

        // 创建新路径
        let path = createPath(from: samples, in: bounds)

        // 创建渲染层
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = configuration.fillColor.cgColor
        shapeLayer.strokeColor = configuration.strokeColor.cgColor
        shapeLayer.lineWidth = configuration.lineWidth

        // 将 CGLineCap 转换为 CAShapeLayerLineCap
        switch configuration.lineCap {
        case .round:
            shapeLayer.lineCap = .round
        case .butt:
            shapeLayer.lineCap = .butt
        case .square:
            shapeLayer.lineCap = .square
        }

        // 将 CGLineJoin 转换为 CAShapeLayerLineJoin
        switch configuration.lineJoin {
        case .round:
            shapeLayer.lineJoin = .round
        case .bevel:
            shapeLayer.lineJoin = .bevel
        case .miter:
            shapeLayer.lineJoin = .miter
        }

        // 应用阴影
        if configuration.showShadow {
            shapeLayer.shadowColor = configuration.shadowColor.cgColor
            shapeLayer.shadowOffset = configuration.shadowOffset
            shapeLayer.shadowOpacity = configuration.shadowOpacity
            shapeLayer.shadowRadius = configuration.shadowRadius
        }

        layer.addSublayer(shapeLayer)
        renderLayer = shapeLayer
    }

    /// 渲染波形到图像
    /// - Parameters:
    ///   - samples: 音频样本数组
    ///   - size: 图像尺寸
    /// - Returns: UIImage
    public func renderToImage(samples: [Float], size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let bounds = CGRect(origin: .zero, size: size)
            let path = createPath(from: samples, in: bounds)

            context.cgContext.setFillColor(configuration.fillColor.cgColor)
            context.cgContext.setStrokeColor(configuration.strokeColor.cgColor)
            context.cgContext.setLineWidth(configuration.lineWidth)
            context.cgContext.setLineCap(configuration.lineCap)
            context.cgContext.setLineJoin(configuration.lineJoin)

            context.cgContext.addPath(path.cgPath)
            context.cgContext.drawPath(using: configuration.fillRule ? .fillStroke : .stroke)
        }
    }

    // MARK: - 路径创建

    /// 创建波形路径
    /// - Parameters:
    ///   - samples: 音频样本数组
    ///   - bounds: 渲染边界
    /// - Returns: UIBezierPath
    private func createPath(from samples: [Float], in bounds: CGRect) -> UIBezierPath {
        let path = UIBezierPath()

        guard !samples.isEmpty else {
            // 空数据时绘制中心线
            let centerY = bounds.midY
            path.move(to: CGPoint(x: bounds.minX, y: centerY))
            path.addLine(to: CGPoint(x: bounds.maxX, y: centerY))
            return path
        }

        switch configuration.renderStyle {
        case .waveform:
            return createWaveformPath(from: samples, in: bounds)
        case .bars:
            return createBarsPath(from: samples, in: bounds)
        case .filled:
            return createFilledPath(from: samples, in: bounds)
        case .mirrored:
            return createMirroredPath(from: samples, in: bounds)
        }
    }

    /// 创建标准波形路径
    private func createWaveformPath(from samples: [Float], in bounds: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let centerY = bounds.midY
        let maxAmplitude = bounds.height / 2

        var x: CGFloat = bounds.minX
        let step = bounds.width / CGFloat(samples.count)

        for (index, sample) in samples.enumerated() {
            let amplitude = CGFloat(sample) * maxAmplitude
            let y = centerY - amplitude

            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }

            x += step
        }

        return path
    }

    /// 创建条形路径
    private func createBarsPath(from samples: [Float], in bounds: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let centerY = bounds.midY
        let maxAmplitude = bounds.height / 2

        let barWidth = configuration.barWidth
        let barSpacing = configuration.barSpacing
        let totalBarSpace = barWidth + barSpacing

        let numberOfBars = min(samples.count, Int(bounds.width / totalBarSpace))

        for i in 0..<numberOfBars {
            let sample = samples[i]
            let amplitude = CGFloat(sample) * maxAmplitude
            let barHeight = amplitude

            let x = bounds.minX + CGFloat(i) * totalBarSpace
            let y = centerY - barHeight / 2

            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            let barPath = UIBezierPath(rect: barRect)
            path.append(barPath)
        }

        return path
    }

    /// 创建填充波形路径
    private func createFilledPath(from samples: [Float], in bounds: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let centerY = bounds.midY
        let maxAmplitude = bounds.height / 2

        path.move(to: CGPoint(x: bounds.minX, y: centerY))

        var x: CGFloat = bounds.minX
        let step = bounds.width / CGFloat(samples.count)

        for sample in samples {
            let amplitude = CGFloat(sample) * maxAmplitude
            let y = centerY - amplitude
            path.addLine(to: CGPoint(x: x, y: y))
            x += step
        }

        path.addLine(to: CGPoint(x: bounds.maxX, y: centerY))
        path.close()

        return path
    }

    /// 创建镜像波形路径
    private func createMirroredPath(from samples: [Float], in bounds: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let centerY = bounds.midY
        let maxAmplitude = bounds.height / 2

        var x: CGFloat = bounds.minX
        let step = bounds.width / CGFloat(samples.count)

        // 上半部分
        for (index, sample) in samples.enumerated() {
            let amplitude = CGFloat(sample) * maxAmplitude
            let y = centerY - amplitude

            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }

            x += step
        }

        // 下半部分（镜像）
        for sample in samples.reversed() {
            let amplitude = CGFloat(sample) * maxAmplitude
            let y = centerY + amplitude
            path.addLine(to: CGPoint(x: x, y: y))
            x -= step
        }

        path.close()

        return path
    }

    // MARK: - 更新渲染

    /// 更新已渲染的波形
    /// - Parameter samples: 新的音频样本
    public func update(samples: [Float]) {
        guard let layer = renderLayer else { return }

        // 获取当前边界
        let bounds = layer.bounds

        // 创建新路径
        let path = createPath(from: samples, in: bounds)

        // 动画更新
        CATransaction.begin()
        CATransaction.setAnimationDuration(configuration.animationDuration)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
        layer.path = path.cgPath
        CATransaction.commit()
    }

    /// 清除渲染
    public func clear() {
        renderLayer?.removeFromSuperlayer()
        renderLayer = nil
    }
}

// MARK: - RenderingConfiguration

/// 渲染配置
public struct RenderingConfiguration {
    /// 渲染风格
    public var renderStyle: RenderStyle

    /// 填充颜色
    public var fillColor: UIColor

    /// 描边颜色
    public var strokeColor: UIColor

    /// 线宽
    public var lineWidth: CGFloat

    /// 线端样式（CGLineCap，用于内部绘图）
    public var lineCap: CGLineCap = .round

    /// 线连接样式
    public var lineJoin: CGLineJoin = .round

    /// 填充规则
    public var fillRule: Bool = false

    /// 条形宽度（用于 .bars 风格）
    public var barWidth: CGFloat = 3.0

    /// 条形间距（用于 .bars 风格）
    public var barSpacing: CGFloat = 2.0

    /// 是否显示阴影
    public var showShadow: Bool = false

    /// 阴影颜色
    public var shadowColor: UIColor = .black

    /// 阴影偏移
    public var shadowOffset: CGSize = CGSize(width: 0, height: -2)

    /// 阴影透明度
    public var shadowOpacity: Float = 0.3

    /// 阴影半径
    public var shadowRadius: CGFloat = 4.0

    /// 动画时长
    public var animationDuration: TimeInterval = 0.2

    /// 默认配置
    public static let `default` = RenderingConfiguration(
        renderStyle: .waveform,
        fillColor: .clear,
        strokeColor: UIColor_00CBE0(),
        lineWidth: 2.0
    )
}

// MARK: - RenderStyle Enum

/// 渲染风格
public enum RenderStyle {
    /// 标准波形线
    case waveform
    /// 条形图
    case bars
    /// 填充波形
    case filled
    /// 镜像波形
    case mirrored
}
