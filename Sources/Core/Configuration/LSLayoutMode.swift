//
//  LSLayoutMode.swift
//  LSWaveformKit
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import Foundation
import CoreGraphics

/// 布局模式
public enum LSLayoutMode {
    /// 左右对称（默认）
    case symmetric

    /// 仅左侧
    case leftOnly

    /// 仅右侧
    case rightOnly

    /// 锚点对称模式（波形分布在锚点视图两侧，自动适配锚点宽度）
    case symmetricWithAnchor

    /// 水平排列
    case horizontal

    /// 圆形排列
    case circular

    /// 弧形排列
    case arc(startAngle: CGFloat, endAngle: CGFloat)

    /// 螺旋排列
    case spiral

    /// 网格排列
    case grid(rows: Int, columns: Int)

    /// 自定义布局
    case custom(layout: LSCustomLayout)
}

// MARK: - Equatable

extension LSLayoutMode: Equatable {
    public static func == (lhs: LSLayoutMode, rhs: LSLayoutMode) -> Bool {
        switch (lhs, rhs) {
        case (.symmetric, .symmetric),
             (.leftOnly, .leftOnly),
             (.rightOnly, .rightOnly),
             (.symmetricWithAnchor, .symmetricWithAnchor),
             (.horizontal, .horizontal),
             (.circular, .circular),
             (.spiral, .spiral):
            return true
        case (.arc(let lStart, let lEnd), .arc(let rStart, let rEnd)):
            return lStart == rStart && lEnd == rEnd
        case (.grid(let lRows, let lCols), .grid(let rRows, let rCols)):
            return lRows == rRows && lCols == rCols
        case (.custom, .custom):
            return true
        default:
            return false
        }
    }
}

// MARK: - CustomStringConvertible

extension LSLayoutMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .symmetric:
            return "左右对称"
        case .leftOnly:
            return "仅左侧"
        case .rightOnly:
            return "仅右侧"
        case .symmetricWithAnchor:
            return "锚点对称"
        case .horizontal:
            return "水平排列"
        case .circular:
            return "圆形排列"
        case .arc(let start, let end):
            return "弧形(\(start)° ~ \(end)°)"
        case .spiral:
            return "螺旋"
        case .grid(let rows, let cols):
            return "网格(\(rows)×\(cols))"
        case .custom:
            return "自定义"
        }
    }
}

// MARK: - LSCustomLayout Protocol

/// 自定义布局协议
public protocol LSCustomLayout {
    /// 计算指定索引条纹的位置
    /// - Parameters:
    ///   - index: 条纹索引
    ///   - total: 条纹总数
    ///   - bounds: 可用边界
    /// - Returns: 条纹中心点位置
    func position(for index: Int, total: Int, in bounds: CGRect) -> CGPoint

    /// 计算指定索引条纹的变换
    /// - Parameters:
    ///   - index: 条纹索引
    ///   - total: 条纹总数
    /// - Returns: 变换矩阵
    func transform(for index: Int, total: Int) -> CGAffineTransform
}

/// 默认自定义布局实现
public struct LSDefaultCustomLayout: LSCustomLayout {
    public init() {}

    public func position(for index: Int, total: Int, in bounds: CGRect) -> CGPoint {
        let spacing = bounds.width / CGFloat(total + 1)
        return CGPoint(x: spacing * CGFloat(index + 1), y: bounds.midY)
    }

    public func transform(for index: Int, total: Int) -> CGAffineTransform {
        return .identity
    }
}
