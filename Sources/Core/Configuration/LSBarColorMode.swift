//
//  LSBarColorMode.swift
//  LSWaveformKit
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import Foundation
import UIKit

/// 条纹颜色模式
public enum LSBarColorMode {
    /// 单一颜色
    case single(UIColor)

    /// 多种颜色（循环使用）
    case multiple([UIColor], cycle: Bool)

    /// 垂直渐变
    case gradientVertical([UIColor], locations: [NSNumber])

    /// 水平渐变
    case gradientHorizontal([UIColor], locations: [NSNumber])

    /// 对角渐变
    case gradientDiagonal([UIColor], locations: [NSNumber])

    /// 径向渐变
    case gradientRadial([UIColor], locations: [NSNumber])

    /// 每条独立颜色
    case perBar([UIColor])

    /// 基于音量的动态颜色（低音量~高音量）
    case amplitudeBased(low: UIColor, high: UIColor)

    /// 基于频率的颜色（频谱图）
    case frequencyBased([UIColor])

    /// 自定义颜色提供者
    case custom(LSBarColorProvider)

    /// 彩虹渐变
    case rainbow

    /// 动态颜色（实时变化）
    case dynamic
}

// MARK: - Equatable

extension LSBarColorMode: Equatable {
    public static func == (lhs: LSBarColorMode, rhs: LSBarColorMode) -> Bool {
        switch (lhs, rhs) {
        case (.single(let l), .single(let r)):
            return l.isEqual(r)
        case (.multiple(let lc, let lcyc), .multiple(let rc, let rcyc)):
            return lc.count == rc.count && lcyc == rcyc
        case (.amplitudeBased(let ll, let lh), .amplitudeBased(let rl, let rh)):
            return ll.isEqual(rl) && lh.isEqual(rh)
        case (.rainbow, .rainbow):
            return true
        default:
            return false
        }
    }
}

// MARK: - CustomStringConvertible

extension LSBarColorMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .single:
            return "单色"
        case .multiple(let colors, _):
            return "多色(\(colors.count)个)"
        case .gradientVertical:
            return "垂直渐变"
        case .gradientHorizontal:
            return "水平渐变"
        case .gradientDiagonal:
            return "对角渐变"
        case .gradientRadial:
            return "径向渐变"
        case .perBar(let colors):
            return "每条独立(\(colors.count)个)"
        case .amplitudeBased:
            return "基于音量"
        case .frequencyBased(let colors):
            return "基于频率(\(colors.count)色)"
        case .custom:
            return "自定义"
        case .rainbow:
            return "彩虹"
        case .dynamic:
            return "动态"
        }
    }
}

// MARK: - LSBarColorProvider Protocol

/// 自定义颜色提供者协议
public protocol LSBarColorProvider {
    /// 返回指定条纹的颜色
    /// - Parameters:
    ///   - bar: 条纹视图
    ///   - index: 条纹索引
    ///   - total: 条纹总数
    ///   - amplitude: 当前音量（0.0 ~ 1.0）
    /// - Returns: 条纹颜色
    func color(for bar: UIView, index: Int, total: Int, amplitude: Float) -> UIColor
}

/// 默认颜色提供者
public struct LSDefaultBarColorProvider: LSBarColorProvider {
    public init() {}

    public func color(for bar: UIView, index: Int, total: Int, amplitude: Float) -> UIColor {
        return UIColor_00CBE0()
    }
}
