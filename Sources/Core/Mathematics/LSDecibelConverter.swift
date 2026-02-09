//
//  LSDecibelConverter.swift
//  LSWaveformKit
//
//  Created by Link on 2025-02-07.
//

import Foundation
import AVFoundation

/// 分贝转换器 - 处理音频分贝计算和转换
public struct LSDecibelConverter {

    // MARK: - 常量

    /// 最小分贝值（静音）
    public static let minDecibels: Float = -80.0

    /// 最大分贝值（0 dB FS）
    public static let maxDecibels: Float = 0.0

    /// 分贝动态范围
    public static let decibelRange: Float = 80.0

    // MARK: - 分贝计算

    /// 计算音频缓冲区的平均功率
    /// - Parameter buffer: 音频缓冲区
    /// - Returns: 平均分贝值
    public static func averagePower(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else {
            return minDecibels
        }

        var sum: Float = 0
        let frameLength = Int(buffer.frameLength)

        for i in 0..<frameLength {
            let sample = channelData[i]
            sum += sample * sample
        }

        let rms = sqrt(sum / Float(frameLength))
        return linearToDecibel(rms)
    }

    /// 计算音频缓冲区的峰值功率
    /// - Parameter buffer: 音频缓冲区
    /// - Returns: 峰值分贝值
    public static func peakPower(from buffer: AVAudioPCMBuffer) -> Float {
        guard let channelData = buffer.floatChannelData?[0] else {
            return minDecibels
        }

        var peak: Float = 0
        let frameLength = Int(buffer.frameLength)

        for i in 0..<frameLength {
            let sample = abs(channelData[i])
            if sample > peak {
                peak = sample
            }
        }

        return linearToDecibel(peak)
    }

    // MARK: - 线性转换

    /// 将线性值转换为分贝
    /// - Parameter linear: 线性值（0.0 ~ 1.0）
    /// - Returns: 分贝值（-80 ~ 0）
    public static func linearToDecibel(_ linear: Float) -> Float {
        guard linear > 0 else { return minDecibels }
        let db = 20 * log10(linear)
        return max(minDecibels, min(maxDecibels, db))
    }

    /// 将分贝转换为线性值
    /// - Parameter decibel: 分贝值（-80 ~ 0）
    /// - Returns: 线性值（0.0 ~ 1.0）
    public static func decibelToLinear(_ decibel: Float) -> Float {
        let clampedDecibel = max(minDecibels, min(maxDecibels, decibel))
        return pow(10, clampedDecibel / 20)
    }

    // MARK: - 归一化

    /// 将分贝归一化到 0.0 ~ 1.0 范围
    /// - Parameter decibel: 分贝值
    /// - Returns: 归一化值（0.0 ~ 1.0）
    public static func normalizeDecibel(_ decibel: Float) -> Float {
        let clampedDecibel = max(minDecibels, min(maxDecibels, decibel))
        return (clampedDecibel - minDecibels) / decibelRange
    }

    /// 将归一化值转换为分贝
    /// - Parameter normalized: 归一化值（0.0 ~ 1.0）
    /// - Returns: 分贝值
    public static func denormalizeDecibel(_ normalized: Float) -> Float {
        let clamped = max(0, min(1, normalized))
        return minDecibels + clamped * decibelRange
    }

    // MARK: - 音量级别

    /// 获取音量级别描述
    /// - Parameter decibel: 分贝值
    /// - Returns: 音量级别描述
    public static func volumeLevel(for decibel: Float) -> VolumeLevel {
        switch decibel {
        case ..<(-60):
            return .silent
        case -60..<(-40):
            return .veryLow
        case -40..<(-20):
            return .low
        case -20..<(-10):
            return .medium
        case -10..<(-5):
            return .high
        default:
            return .veryHigh
        }
    }

    // MARK: - 实用工具

    /// 应用 A-Weighting 滤波（模拟人耳对频率的敏感度）
    /// - Parameter decibel: 原始分贝值
    /// - Returns: A-Weighted 分贝值
    public static func applyAWeighting(to decibel: Float) -> Float {
        // 简化的 A-Weighting 曲线
        // 实际实现需要更复杂的频率分析
        return decibel - 2.0
    }

    /// 计算两个分贝值的差异
    /// - Parameters:
    ///   - decibel1: 第一个分贝值
    ///   - decibel2: 第二个分贝值
    /// - Returns: 分贝差（正值表示 decibel1 更大）
    public static func difference(decibel1: Float, decibel2: Float) -> Float {
        return decibel1 - decibel2
    }

    /// 混合两个分贝值
    /// - Parameters:
    ///   - decibel1: 第一个分贝值
    ///   - decibel2: 第二个分贝值
    /// - Returns: 混合后的分贝值
    public static func mix(decibel1: Float, decibel2: Float) -> Float {
        let linear1 = decibelToLinear(decibel1)
        let linear2 = decibelToLinear(decibel2)
        let mixedLinear = (linear1 + linear2) / 2
        return linearToDecibel(mixedLinear)
    }
}

// MARK: - VolumeLevel Enum

/// 音量级别
public enum VolumeLevel {
    /// 静音
    case silent
    /// 非常低
    case veryLow
    /// 低
    case low
    /// 中等
    case medium
    /// 高
    case high
    /// 非常高
    case veryHigh

    /// 本地化描述
    public var localizedDescription: String {
        switch self {
        case .silent: return "静音"
        case .veryLow: return "非常低"
        case .low: return "低"
        case .medium: return "中等"
        case .high: return "高"
        case .veryHigh: return "非常高"
        }
    }

    /// 对应的归一化值范围
    public var normalizedRange: ClosedRange<Float> {
        switch self {
        case .silent: return 0.0...0.0
        case .veryLow: return 0.0...0.25
        case .low: return 0.25...0.5
        case .medium: return 0.5...0.75
        case .high: return 0.75...0.875
        case .veryHigh: return 0.875...1.0
        }
    }
}
