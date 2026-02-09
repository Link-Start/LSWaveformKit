//
//  LSBarHeightMode.swift
//  LSWaveformKit
//
//  Created by Link on 2025-02-07.
//

import Foundation
import UIKit

/// 条纹高度模式（12+种）
public enum LSBarHeightMode: Equatable {
    /// 对称（中间高，两边低）
    case symmetric
    /// 随机模式
    case random
    /// 从左到右依次升高
    case ascending
    /// 从左到右依次降低
    case descending
    /// 高低高低
    case highLow
    /// 低高低高
    case lowHigh
    /// 高高低低
    case highHighLowLow
    /// 低低高高
    case lowLowHighHigh
    /// 高高低高低
    case highHighLowHigh
    /// 低低高低高
    case lowLowHighLowHigh
    /// 一样高
    case uniform
    /// 峰值模式（所有条纹都是最大高度）
    case peak
    /// 谷值模式（所有条纹都是最小高度）
    case valley
    /// 自定义高度数组（0.0 - 1.0）
    case custom([Float])
    /// 先高后低
    case highToLow
    /// 先低后高
    case lowToHigh
    /// 参差不齐（randomFactor: 随机因子，0.0 无随机，1.0 完全随机）
    case uneven(randomFactor: Float)

    /// 计算指定索引的条纹高度比例（0.0 - 1.0）
    /// - Parameters:
    ///   - index: 条纹索引
    ///   - totalCount: 条纹总数
    /// - Returns: 高度比例（0.0 - 1.0）
    public func heightRatio(for index: Int, totalCount: Int) -> Float {
        guard totalCount > 0 else { return 0.5 }
        let normalizedIndex = Float(index) / Float(max(1, totalCount - 1))

        switch self {
        case .symmetric:
            // 对称模式：中间高，两边低
            // 使用抛物线函数：1 - 4*(x-0.5)^2
            let x = normalizedIndex
            return max(0.1, 1.0 - 4.0 * pow(x - 0.5, 2))

        case .random:
            // 随机模式：每次调用都生成不同的值
            return Float.random(in: 0.2...1.0)

        case .ascending:
            // 从左到右依次升高
            return 0.2 + 0.8 * normalizedIndex

        case .descending:
            // 从左到右依次降低
            return 1.0 - 0.8 * normalizedIndex

        case .highLow:
            // 高低高低
            return index % 2 == 0 ? 0.9 : 0.3

        case .lowHigh:
            // 低高低高
            return index % 2 == 0 ? 0.3 : 0.9

        case .highHighLowLow:
            // 高高低低
            let pattern = index % 4
            switch pattern {
            case 0, 1: return 0.9
            case 2, 3: return 0.3
            default: return 0.5
            }

        case .lowLowHighHigh:
            // 低低高高
            let pattern = index % 4
            switch pattern {
            case 0, 1: return 0.3
            case 2, 3: return 0.9
            default: return 0.5
            }

        case .highHighLowHigh:
            // 高高低高低
            let pattern = index % 4
            switch pattern {
            case 0, 1: return 0.9
            case 2: return 0.3
            case 3: return 0.9
            default: return 0.5
            }

        case .lowLowHighLowHigh:
            // 低低高低高
            let pattern = index % 5
            switch pattern {
            case 0, 1: return 0.3
            case 2: return 0.9
            case 3: return 0.3
            case 4: return 0.9
            default: return 0.5
            }

        case .uniform:
            // 一样高
            return 0.7

        case .peak:
            // 峰值模式：最大高度
            return 1.0

        case .valley:
            // 谷值模式：最小高度
            return 0.1

        case .custom(let ratios):
            // 自定义高度数组
            guard index < ratios.count else { return 0.5 }
            return max(0.0, min(1.0, ratios[index]))

        case .highToLow:
            // 先高后低：使用正弦波的一半
            let x = normalizedIndex * .pi
            return 0.2 + 0.8 * sin(x)

        case .lowToHigh:
            // 先低后高：使用正弦波的上升部分
            let x = normalizedIndex * .pi / 2.0
            return 0.2 + 0.8 * sin(x)

        case .uneven(let randomFactor):
            // 参差不齐：基础高度 + 随机偏移
            let baseRatio: Float = 0.5
            let randomOffset = (Float.random(in: -1...1)) * randomFactor * 0.5
            return max(0.1, min(1.0, baseRatio + randomOffset))
        }
    }

    /// 生成所有条纹的高度比例数组
    /// - Parameter count: 条纹数量
    /// - Returns: 高度比例数组
    public func generateHeightRatios(count: Int) -> [Float] {
        return (0..<count).map { index in
            heightRatio(for: index, totalCount: count)
        }
    }
}

// MARK: - CustomStringConvertible

extension LSBarHeightMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .symmetric:
            return "对称"
        case .random:
            return "随机"
        case .ascending:
            return "从左到右升高"
        case .descending:
            return "从左到右降低"
        case .highLow:
            return "高低高低"
        case .lowHigh:
            return "低高低高"
        case .highHighLowLow:
            return "高高低低"
        case .lowLowHighHigh:
            return "低低高高"
        case .highHighLowHigh:
            return "高高低高低"
        case .lowLowHighLowHigh:
            return "低低高低高"
        case .uniform:
            return "一样高"
        case .custom(let heights):
            return "自定义(\(heights.count)个)"
        case .highToLow:
            return "先高后低"
        case .lowToHigh:
            return "先低后高"
        case .uneven(let factor):
            return "参差不齐(\(factor))"
        case .peak:
            return "峰值"
        case .valley:
            return "谷值"
        }
    }
}
