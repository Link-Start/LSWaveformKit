//
//  LSAmplitudeNormalizer.swift
//  LSWaveformKit
//
//  Created by Link on 2025-02-07.
//

import Foundation

/// 振幅归一化器 - 处理音频振幅的归一化和缩放
public class LSAmplitudeNormalizer {

    // MARK: - 属性

    /// 最小振幅值
    public var minimumAmplitude: Float = 0.0

    /// 最大振幅值
    public var maximumAmplitude: Float = 1.0

    /// 目标最小值
    public var targetMinimum: Float = 0.0

    /// 目标最大值
    public var targetMaximum: Float = 1.0

    /// 是否启用自适应范围
    public var isAdaptiveEnabled: Bool = false

    /// 自适应窗口大小
    public var adaptiveWindowSize: Int = 100

    // MARK: - 私有属性

    private var amplitudeHistory: [Float] = []
    private var currentMin: Float = 0.0
    private var currentMax: Float = 1.0

    // MARK: - 初始化

    public init() {}

    public init(minimumAmplitude: Float, maximumAmplitude: Float) {
        self.minimumAmplitude = minimumAmplitude
        self.maximumAmplitude = maximumAmplitude
    }

    // MARK: - 归一化方法

    /// 归一化单个振幅值
    /// - Parameter amplitude: 原始振幅值
    /// - Returns: 归一化后的振幅值（0.0 ~ 1.0）
    public func normalize(_ amplitude: Float) -> Float {
        let clampedAmplitude = max(minimumAmplitude, min(maximumAmplitude, amplitude))
        let range = maximumAmplitude - minimumAmplitude

        guard range > 0 else { return 0.5 }

        let normalized = (clampedAmplitude - minimumAmplitude) / range
        return targetMinimum + normalized * (targetMaximum - targetMinimum)
    }

    /// 归一化振幅数组
    /// - Parameter amplitudes: 原始振幅数组
    /// - Returns: 归一化后的振幅数组
    public func normalize(_ amplitudes: [Float]) -> [Float] {
        return amplitudes.map { normalize($0) }
    }

    /// 自适应归一化
    /// - Parameter amplitude: 原始振幅值
    /// - Returns: 归一化后的振幅值
    public func adaptiveNormalize(_ amplitude: Float) -> Float {
        guard isAdaptiveEnabled else {
            return normalize(amplitude)
        }

        // 更新历史记录
        amplitudeHistory.append(amplitude)
        if amplitudeHistory.count > adaptiveWindowSize {
            amplitudeHistory.removeFirst()
        }

        // 计算当前范围
        updateAdaptiveRange()

        // 使用当前范围进行归一化
        let range = currentMax - currentMin
        guard range > 0 else { return 0.5 }

        let clampedAmplitude = max(currentMin, min(currentMax, amplitude))
        let normalized = (clampedAmplitude - currentMin) / range
        return targetMinimum + normalized * (targetMaximum - targetMinimum)
    }

    // MARK: - 反归一化

    /// 将归一化值转换回原始振幅
    /// - Parameter normalized: 归一化值（0.0 ~ 1.0）
    /// - Returns: 原始振幅值
    public func denormalize(_ normalized: Float) -> Float {
        let t = (normalized - targetMinimum) / (targetMaximum - targetMinimum)
        return minimumAmplitude + t * (maximumAmplitude - minimumAmplitude)
    }

    // MARK: - 缩放

    /// 缩放振幅值到新范围
    /// - Parameters:
    ///   - amplitude: 振幅值
    ///   - newMin: 新最小值
    ///   - newMax: 新最大值
    /// - Returns: 缩放后的振幅值
    public func scale(_ amplitude: Float, to newMin: Float, newMax: Float) -> Float {
        let normalized = normalize(amplitude)
        return newMin + normalized * (newMax - newMin)
    }

    // MARK: - 平滑

    /// 应用平滑曲线到振幅值
    /// - Parameters:
    ///   - amplitude: 振幅值
    ///   - curve: 平滑曲线类型
    /// - Returns: 平滑后的振幅值
    public func applyCurve(_ amplitude: Float, curve: SmoothingCurve) -> Float {
        let normalized = normalize(amplitude)

        switch curve {
        case .linear:
            return normalized

        case .easeIn:
            return normalized * normalized

        case .easeOut:
            return 1 - pow(1 - normalized, 2)

        case .easeInOut:
            return normalized < 0.5 ?
                2 * normalized * normalized :
                1 - pow(-2 * normalized + 2, 2) / 2

        case .exponential(let factor):
            return pow(normalized, factor)

        case .logarithmic:
            return log(normalized * (Constants.e - 1) + 1)
        }
    }

    // MARK: - 自适应范围

    private func updateAdaptiveRange() {
        guard !amplitudeHistory.isEmpty else { return }

        let sorted = amplitudeHistory.sorted()
        let lowerIndex = Int(Float(sorted.count) * 0.1) // 排除最低 10%
        let upperIndex = Int(Float(sorted.count) * 0.9) // 排除最高 10%

        currentMin = sorted[lowerIndex]
        currentMax = sorted[upperIndex]
    }

    // MARK: - 重置

    /// 重置归一化器状态
    public func reset() {
        amplitudeHistory.removeAll()
        currentMin = minimumAmplitude
        currentMax = maximumAmplitude
    }
}

// MARK: - SmoothingCurve Enum

/// 平滑曲线类型
public enum SmoothingCurve {
    /// 线性
    case linear
    /// 缓入
    case easeIn
    /// 缓出
    case easeOut
    /// 缓入缓出
    case easeInOut
    /// 指数（factor 为指数因子）
    case exponential(factor: Float)
    /// 对数
    case logarithmic
}

// MARK: - Constants

private enum Constants {
    static let e: Float = 2.718281828459045
}

// MARK: - Convenience Extensions

extension LSAmplitudeNormalizer {

    /// 创建默认配置的归一化器
    public static func `default`() -> LSAmplitudeNormalizer {
        return LSAmplitudeNormalizer()
    }

    /// 创建用于录音可视化的归一化器
    public static func forRecording() -> LSAmplitudeNormalizer {
        let normalizer = LSAmplitudeNormalizer()
        normalizer.minimumAmplitude = 0.0
        normalizer.maximumAmplitude = 1.0
        normalizer.targetMinimum = 0.1  // 最小可见高度
        normalizer.targetMaximum = 1.0
        normalizer.isAdaptiveEnabled = true
        normalizer.adaptiveWindowSize = 50
        return normalizer
    }

    /// 创建用于播放可视化的归一化器
    public static func forPlayback() -> LSAmplitudeNormalizer {
        let normalizer = LSAmplitudeNormalizer()
        normalizer.minimumAmplitude = 0.0
        normalizer.maximumAmplitude = 1.0
        normalizer.targetMinimum = 0.0
        normalizer.targetMaximum = 1.0
        normalizer.isAdaptiveEnabled = false
        return normalizer
    }
}
