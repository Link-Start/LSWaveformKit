//
//  LSGradientHelper.swift
//  LSWaveformKit
//
//  Created by Link on 2025-02-07.
//

import UIKit

/// 渐变辅助工具 - 处理渐变色创建和应用
public struct LSGradientHelper {

    // MARK: - 创建渐变层

    /// 创建垂直渐变层
    /// - Parameters:
    ///   - colors: 渐变颜色数组
    ///   - locations: 颜色位置数组（0.0 ~ 1.0）
    ///   - bounds: 渐变层边界
    /// - Returns: CAGradientLayer
    public static func createVerticalGradient(
        colors: [UIColor],
        locations: [NSNumber],
        bounds: CGRect
    ) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        return gradientLayer
    }

    /// 创建水平渐变层
    /// - Parameters:
    ///   - colors: 渐变颜色数组
    ///   - locations: 颜色位置数组（0.0 ~ 1.0）
    ///   - bounds: 渐变层边界
    /// - Returns: CAGradientLayer
    public static func createHorizontalGradient(
        colors: [UIColor],
        locations: [NSNumber],
        bounds: CGRect
    ) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        return gradientLayer
    }

    /// 创建对角渐变层
    /// - Parameters:
    ///   - colors: 渐变颜色数组
    ///   - locations: 颜色位置数组（0.0 ~ 1.0）
    ///   - bounds: 渐变层边界
    /// - Returns: CAGradientLayer
    public static func createDiagonalGradient(
        colors: [UIColor],
        locations: [NSNumber],
        bounds: CGRect
    ) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        return gradientLayer
    }

    /// 创建径向渐变层
    /// - Parameters:
    ///   - colors: 渐变颜色数组
    ///   - locations: 颜色位置数组（0.0 ~ 1.0）
    ///   - bounds: 渐变层边界
    ///   - center: 渐变中心点
    /// - Returns: CAGradientLayer
    public static func createRadialGradient(
        colors: [UIColor],
        locations: [NSNumber],
        bounds: CGRect,
        center: CGPoint? = nil
    ) -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = center ?? CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.type = .radial
        return gradientLayer
    }

    // MARK: - 应用渐变到视图

    /// 应用渐变到视图的背景
    /// - Parameters:
    ///   - view: 目标视图
    ///   - colors: 渐变颜色数组
    ///   - locations: 颜色位置数组
    ///   - direction: 渐变方向
    public static func applyGradient(
        to view: UIView,
        colors: [UIColor],
        locations: [NSNumber],
        direction: GradientDirection = .vertical
    ) {
        // 移除旧的渐变层
        view.layer.sublayers?.removeAll(where: { $0 is CAGradientLayer })

        let gradientLayer: CAGradientLayer
        switch direction {
        case .vertical:
            gradientLayer = createVerticalGradient(
                colors: colors,
                locations: locations,
                bounds: view.bounds
            )
        case .horizontal:
            gradientLayer = createHorizontalGradient(
                colors: colors,
                locations: locations,
                bounds: view.bounds
            )
        case .diagonal:
            gradientLayer = createDiagonalGradient(
                colors: colors,
                locations: locations,
                bounds: view.bounds
            )
        case .radial:
            gradientLayer = createRadialGradient(
                colors: colors,
                locations: locations,
                bounds: view.bounds
            )
        }

        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    /// 应用渐变到 CALayer
    /// - Parameters:
    ///   - layer: 目标图层
    ///   - colors: 渐变颜色数组
    ///   - locations: 颜色位置数组
    ///   - direction: 渐变方向
    /// - Returns: CAGradientLayer
    @discardableResult
    public static func applyGradient(
        to layer: CALayer,
        colors: [UIColor],
        locations: [NSNumber],
        direction: GradientDirection = .vertical
    ) -> CAGradientLayer {
        let gradientLayer: CAGradientLayer
        switch direction {
        case .vertical:
            gradientLayer = createVerticalGradient(
                colors: colors,
                locations: locations,
                bounds: layer.bounds
            )
        case .horizontal:
            gradientLayer = createHorizontalGradient(
                colors: colors,
                locations: locations,
                bounds: layer.bounds
            )
        case .diagonal:
            gradientLayer = createDiagonalGradient(
                colors: colors,
                locations: locations,
                bounds: layer.bounds
            )
        case .radial:
            gradientLayer = createRadialGradient(
                colors: colors,
                locations: locations,
                bounds: layer.bounds
            )
        }

        layer.insertSublayer(gradientLayer, at: 0)
        return gradientLayer
    }

    // MARK: - 预设渐变

    /// 创建彩虹渐变
    /// - Parameter bounds: 渐变边界
    /// - Returns: CAGradientLayer
    public static func createRainbowGradient(bounds: CGRect) -> CAGradientLayer {
        let colors: [UIColor] = [
            UIColor(red: 1, green: 0, blue: 0, alpha: 1),   // 红
            UIColor(red: 1, green: 0.5, blue: 0, alpha: 1), // 橙
            UIColor(red: 1, green: 1, blue: 0, alpha: 1),   // 黄
            UIColor(red: 0, green: 1, blue: 0, alpha: 1),   // 绿
            UIColor(red: 0, green: 0, blue: 1, alpha: 1),   // 蓝
            UIColor(red: 0.3, green: 0, blue: 0.5, alpha: 1) // 紫
        ]

        let locations = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0].map { NSNumber(value: $0) }

        return createHorizontalGradient(
            colors: colors,
            locations: locations,
            bounds: bounds
        )
    }

    /// 创建霓虹渐变
    /// - Parameter bounds: 渐变边界
    /// - Returns: CAGradientLayer
    public static func createNeonGradient(bounds: CGRect) -> CAGradientLayer {
        let colors: [UIColor] = [
            UIColor(red: 1, green: 0, blue: 1, alpha: 1),   // 品红
            UIColor(red: 0.5, green: 0, blue: 1, alpha: 1), // 紫
            UIColor(red: 0, green: 0.5, blue: 1, alpha: 1)  // 蓝
        ]

        let locations = [0.0, 0.5, 1.0].map { NSNumber(value: $0) }

        return createVerticalGradient(
            colors: colors,
            locations: locations,
            bounds: bounds
        )
    }

    /// 创建海洋渐变
    /// - Parameter bounds: 渐变边界
    /// - Returns: CAGradientLayer
    public static func createOceanGradient(bounds: CGRect) -> CAGradientLayer {
        let colors: [UIColor] = [
            UIColor(red: 0, green: 0.5, blue: 1, alpha: 1),   // 浅蓝
            UIColor(red: 0, green: 0.3, blue: 0.8, alpha: 1), // 中蓝
            UIColor(red: 0, green: 0.1, blue: 0.5, alpha: 1)  // 深蓝
        ]

        let locations = [0.0, 0.5, 1.0].map { NSNumber(value: $0) }

        return createVerticalGradient(
            colors: colors,
            locations: locations,
            bounds: bounds
        )
    }

    /// 创建火焰渐变
    /// - Parameter bounds: 渐变边界
    /// - Returns: CAGradientLayer
    public static func createFireGradient(bounds: CGRect) -> CAGradientLayer {
        let colors: [UIColor] = [
            UIColor(red: 1, green: 1, blue: 0, alpha: 1),   // 黄
            UIColor(red: 1, green: 0.5, blue: 0, alpha: 1), // 橙
            UIColor(red: 1, green: 0, blue: 0, alpha: 1)    // 红
        ]

        let locations = [0.0, 0.5, 1.0].map { NSNumber(value: $0) }

        return createVerticalGradient(
            colors: colors,
            locations: locations,
            bounds: bounds
        )
    }
}

// MARK: - GradientDirection Enum

/// 渐变方向
public enum GradientDirection {
    /// 垂直（从上到下）
    case vertical
    /// 水平（从左到右）
    case horizontal
    /// 对角（从左上到右下）
    case diagonal
    /// 径向（从中心向外）
    case radial
}
