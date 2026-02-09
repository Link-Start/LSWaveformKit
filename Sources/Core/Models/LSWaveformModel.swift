//
//  LSWaveformModel.swift
//  LSWaveformKit
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import Foundation

/// 波形数据模型
public struct LSWaveformModel {

    // MARK: - 属性

    /// 音频数据（幅值数组，0.0 ~ 1.0）
    public let amplitudes: [Float]

    /// 采样率
    public let sampleRate: Double

    /// 时长（秒）
    public let duration: TimeInterval

    /// 通道数
    public let channels: Int

    // MARK: - 初始化

    public init(amplitudes: [Float], sampleRate: Double = 44100, duration: TimeInterval = 0, channels: Int = 1) {
        self.amplitudes = amplitudes
        self.sampleRate = sampleRate
        self.duration = duration
        self.channels = channels
    }

    // MARK: - 计算属性

    /// 幅值数量
    public var count: Int {
        return amplitudes.count
    }

    /// 平均幅值
    public var averageAmplitude: Float {
        guard !amplitudes.isEmpty else { return 0 }
        let sum = amplitudes.reduce(0) { $0 + $1 }
        return sum / Float(amplitudes.count)
    }

    /// 最大幅值
    public var maxAmplitude: Float {
        return amplitudes.max() ?? 0
    }

    /// 最小幅值
    public var minAmplitude: Float {
        return amplitudes.min() ?? 0
    }
}

// MARK: - Empty Model

extension LSWaveformModel {
    /// 空模型
    public static var empty: LSWaveformModel {
        return LSWaveformModel(amplitudes: [], sampleRate: 44100, duration: 0, channels: 1)
    }

    /// 是否为空
    public var isEmpty: Bool {
        return amplitudes.isEmpty
    }
}

// MARK: - Subscript

extension LSWaveformModel {
    /// 获取指定索引的幅值
    public subscript(index: Int) -> Float {
        return amplitudes[index]
    }

    /// 获取指定范围的幅值
    public subscript(range: Range<Int>) -> ArraySlice<Float> {
        return amplitudes[range]
    }
}

// MARK: - Downsample

extension LSWaveformModel {
    /// 降采样到指定数量
    /// - Parameter count: 目标数量
    /// - Returns: 降采样后的模型
    public func downsample(to count: Int) -> LSWaveformModel {
        guard amplitudes.count > count else { return self }

        let stride = max(1, Float(amplitudes.count) / Float(count))
        var result: [Float] = []

        for i in 0..<count {
            let startIndex = Int(Float(i) * stride)
            let endIndex = min(Int(Float(i + 1) * stride), amplitudes.count)

            if startIndex < endIndex {
                let slice = amplitudes[startIndex..<endIndex]
                let avg = slice.reduce(0) { $0 + $1 } / Float(slice.count)
                result.append(avg)
            }
        }

        return LSWaveformModel(
            amplitudes: result,
            sampleRate: sampleRate,
            duration: duration,
            channels: channels
        )
    }
}

// MARK: - Normalize

extension LSWaveformModel {
    /// 标准化幅值到 0.0 ~ 1.0
    public func normalized() -> LSWaveformModel {
        guard let maxAmp = amplitudes.max(), maxAmp > 0 else { return self }

        let normalized = amplitudes.map { $0 / maxAmp }
        return LSWaveformModel(
            amplitudes: normalized,
            sampleRate: sampleRate,
            duration: duration,
            channels: channels
        )
    }
}

// MARK: - Codable

extension LSWaveformModel: Codable {
    enum CodingKeys: String, CodingKey {
        case amplitudes
        case sampleRate
        case duration
        case channels
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        amplitudes = try container.decode([Float].self, forKey: .amplitudes)
        sampleRate = try container.decode(Double.self, forKey: .sampleRate)
        duration = try container.decode(TimeInterval.self, forKey: .duration)
        channels = try container.decode(Int.self, forKey: .channels)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amplitudes, forKey: .amplitudes)
        try container.encode(sampleRate, forKey: .sampleRate)
        try container.encode(duration, forKey: .duration)
        try container.encode(channels, forKey: .channels)
    }
}
