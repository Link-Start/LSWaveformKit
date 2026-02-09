//
//  LSWaveformBar.swift
//  LSWaveformKit
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import UIKit

/// 约束类型别名（兼容 SnapKit）
public typealias Constraint = NSLayoutConstraint

/// 波形条纹视图
public class LSWaveformBar: UIView {

    // MARK: - 属性

    /// 条纹索引
    public var index: Int = 0

    /// 目标高度
    public var targetHeight: CGFloat = 0

    /// 当前高度
    public var currentHeight: CGFloat = 0 {
        didSet {
            updateHeight()
        }
    }

    /// 初始高度
    public var initialHeight: CGFloat = 0

    /// 高度约束引用（用于安全更新）
    private var heightConstraint: Constraint?

    // MARK: - 初始化

    public init(index: Int = 0) {
        self.index = index
        super.init(frame: .zero)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - 方法

    /// 设置高度约束（由 LSWaveformView 调用）
    /// - Parameter constraint: 约束对象
    /// 重要：保存约束引用以便安全更新，避免使用 updateConstraints 时崩溃
    /// updateConstraints 只能更新之前设置过的约束，否则会崩溃
    func setHeightConstraint(_ constraint: Constraint) {
        heightConstraint = constraint
    }

    /// 更新高度
    private func updateHeight() {
        // 使用保存的约束引用直接更新常量值
        if let constraint = heightConstraint {
            constraint.constant = currentHeight
        }
    }

    /// 设置圆角
    public func setCornerRadius(_ radius: CGFloat, corners: UIRectCorner = .allCorners) {
        if corners == .allCorners {
            layer.cornerRadius = radius
            layer.masksToBounds = true
        } else {
            let path = UIBezierPath(
                roundedRect: bounds,
                byRoundingCorners: corners,
                cornerRadii: CGSize(width: radius, height: radius)
            )
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
        }
    }

    /// 应用阴影
    public func applyShadow(color: UIColor, offset: CGSize, radius: CGFloat, opacity: Float) {
        layer.shadowColor = color.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }

    /// 重置条纹
    public func reset() {
        currentHeight = initialHeight
        targetHeight = initialHeight
        alpha = 1.0
        transform = .identity
    }
}
