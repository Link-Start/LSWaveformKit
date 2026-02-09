//
//  LSSpacingMode.swift
//  LSWaveformKit
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import Foundation
import CoreGraphics

/// 间距模式
public enum LSSpacingMode {
    /// 等间距
    case equal(CGFloat)

    /// 百分比间距
    case percentage(CGFloat)

    /// 自动计算间距
    case automatic

    /// 不等间距（数组指定，会循环使用）
    case unequal([CGFloat])

    /// 渐变间距（从最小到最大）
    case gradient(min: CGFloat, max: CGFloat)

    /// 自定义间距（block）
    case custom((Int, Int, CGFloat) -> CGFloat)

    /// 代理方法
    case delegate(LSSpacingDelegate)

    /// 基于音量的动态间距（音量小时间距大，音量大时间距小）
    case amplitudeBased(min: CGFloat, max: CGFloat)

    /// 波浪形间距
    case wave(min: CGFloat, max: CGFloat, frequency: CGFloat)
}

// MARK: - Equatable

extension LSSpacingMode: Equatable {
    public static func == (lhs: LSSpacingMode, rhs: LSSpacingMode) -> Bool {
        switch (lhs, rhs) {
        case (.equal(let l), .equal(let r)):
            return l == r
        case (.percentage(let l), .percentage(let r)):
            return l == r
        case (.automatic, .automatic):
            return true
        case (.unequal(let l), .unequal(let r)):
            return l == r
        case (.gradient(let lmin, let lmax), .gradient(let rmin, let rmax)):
            return lmin == rmin && lmax == rmax
        case (.amplitudeBased(let lmin, let lmax), .amplitudeBased(let rmin, let rmax)):
            return lmin == rmin && lmax == rmax
        case (.wave(let lmin, let lmax, let lfreq), .wave(let rmin, let rmax, let rfreq)):
            return lmin == rmin && lmax == rmax && lfreq == rfreq
        default:
            return false
        }
    }
}

// MARK: - CustomStringConvertible

extension LSSpacingMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .equal(let spacing):
            return "等间距(\(spacing))"
        case .unequal(let spacings):
            return "不等间距(\(spacings.count)个)"
        case .gradient(let min, let max):
            return "渐变(\(min)~\(max))"
        case .custom:
            return "自定义"
        case .delegate:
            return "代理"
        case .amplitudeBased(let min, let max):
            return "基于音量(\(min)~\(max))"
        case .wave(let min, let max, let freq):
            return "波浪(\(min)~\(max),频率\(freq))"
        case .percentage(let value):
            return "百分比(\(value))"
        case .automatic:
            return "自动"
        }
    }
}

// MARK: - LSSpacingDelegate Protocol

/// 间距代理协议
public protocol LSSpacingDelegate: AnyObject {
    /// 返回指定索引的间距
    /// - Parameters:
    ///   - index: 条纹索引
    ///   - total: 条纹总数
    /// - Returns: 间距值
    func spacing(for index: Int, total: Int) -> CGFloat
}
