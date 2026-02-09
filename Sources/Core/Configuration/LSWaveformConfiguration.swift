//
//  LSWaveformConfiguration.swift
//  LSWaveformKit
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

/// 波形配置协议
public protocol LSWaveformConfiguration: AnyObject {

    // MARK: - 基础配置

    /// 条纹数量
    var numberOfBars: Int { get set }

    /// 条纹宽度
    var barWidth: CGFloat { get set }

    /// 条纹间距（默认值，实际间距由 spacingMode 决定）
    var barSpacing: CGFloat { get set }

    // MARK: - 模式配置

    /// 条纹高度模式
    var barHeightMode: LSBarHeightMode { get set }

    /// 布局模式
    var layoutMode: LSLayoutMode { get set }

    // MARK: - 高度配置

    /// 最小条形高度
    var minimumBarHeight: CGFloat { get set }

    /// 最大条形高度
    var maximumBarHeight: CGFloat { get set }

    /// 基础高度（用于某些计算）
    var baseHeight: CGFloat { get set }

    // MARK: - 颜色配置

    /// 条纹颜色模式
    var barColorMode: LSBarColorMode { get set }

    /// 条纹颜色（单一颜色快捷方式）
    var barColor: UIColor { get set }

    /// 渐变色（渐变快捷方式）
    var gradientColors: [UIColor]? { get set }

    // MARK: - 动画配置

    /// 动画时长
    var animationDuration: TimeInterval { get set }

    /// 动画曲线
    var animationCurve: UIView.AnimationCurve { get set }

    // MARK: - 描边配置

    /// 是否显示描边
    var showStroke: Bool { get set }

    /// 描边颜色
    var strokeColor: UIColor { get set }

    /// 描边宽度
    var strokeWidth: CGFloat { get set }

    /// 圆角半径
    var cornerRadius: CGFloat { get set }

    // MARK: - 间距配置

    /// 间距模式
    var spacingMode: LSSpacingMode { get set }

    // MARK: - 高级配置

    /// 刷新率（FPS）
    var refreshRate: Int { get set }

    /// 是否启用阴影
    var enableShadow: Bool { get set }

    /// 阴影颜色
    var shadowColor: UIColor? { get set }

    /// 阴影偏移
    var shadowOffset: CGSize { get set }

    /// 阴影模糊半径
    var shadowRadius: CGFloat { get set }
}

// MARK: - Default Configuration

/// 默认波形配置
public class LSDefaultWaveformConfiguration: LSWaveformConfiguration {

    // MARK: - 基础配置

    public var numberOfBars: Int = 30
    public var barWidth: CGFloat = 3.0
    public var barSpacing: CGFloat = 8.0

    // MARK: - 模式配置

    public var barHeightMode: LSBarHeightMode = .symmetric
    public var layoutMode: LSLayoutMode = .symmetric

    // MARK: - 高度配置

    public var minimumBarHeight: CGFloat = 2.0
    public var maximumBarHeight: CGFloat = 60.0
    public var baseHeight: CGFloat = 20.0

    // MARK: - 颜色配置

    public var barColorMode: LSBarColorMode = .single(UIColor_00CBE0()) {
        didSet {
            // 更新 barColor 以保持兼容性
            if case .single(let color) = barColorMode {
                barColor = color
            }
        }
    }

    public var barColor: UIColor = UIColor_00CBE0() {
        didSet {
            // 更新 barColorMode 以保持同步
            barColorMode = .single(barColor)
        }
    }

    public var gradientColors: [UIColor]? {
        get {
            if case .gradientVertical(let colors, _) = barColorMode {
                return colors
            }
            return nil
        }
        set {
            if let colors = newValue {
                let locations = stride(from: 0.0, through: 1.0, by: 1.0 / Double(max(colors.count - 1, 1))).map { NSNumber(value: $0) }
                barColorMode = .gradientVertical(colors, locations: locations)
            }
        }
    }

    // MARK: - 动画配置

    public var animationDuration: TimeInterval = 0.2
    public var animationCurve: UIView.AnimationCurve = .easeOut

    // MARK: - 描边配置

    public var showStroke: Bool = false
    public var strokeColor: UIColor = UIColor_FFFFFF()
    public var strokeWidth: CGFloat = 1.0
    public var cornerRadius: CGFloat = 1.5

    // MARK: - 间距配置

    public var spacingMode: LSSpacingMode = .equal(8.0)

    // MARK: - 高级配置

    public var refreshRate: Int = 60
    public var enableShadow: Bool = false
    public var shadowColor: UIColor? = nil
    public var shadowOffset: CGSize = CGSize(width: 0, height: -2)
    public var shadowRadius: CGFloat = 4.0

    // MARK: - Initialization

    public init() {}

    // MARK: - Convenience Initializers

    /// 创建对称布局配置
    public static func symmetric(barCount: Int = 30) -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = barCount
        config.layoutMode = .symmetric
        config.barHeightMode = .symmetric
        config.barColorMode = .single(UIColor_00CBE0())
        config.spacingMode = .equal(8.0)
        return config
    }

    /// 创建水平布局配置
    public static func horizontal(barCount: Int = 50) -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = barCount
        config.layoutMode = .horizontal
        config.barHeightMode = .uniform
        config.barColorMode = .single(UIColor_00CBE0())
        config.spacingMode = .equal(5.0)
        return config
    }

    /// 创建圆形布局配置
    public static func circular(barCount: Int = 60) -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = barCount
        config.layoutMode = .circular
        config.barHeightMode = .uniform
        config.barColorMode = .gradientVertical(
            [UIColor_00CBE0().withAlphaComponent(0.3), UIColor_00CBE0()],
            locations: [0.0, 1.0]
        )
        config.spacingMode = .equal(4.0)
        return config
    }

    /// 创建频谱布局配置
    public static func spectrum(barCount: Int = 40) -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = barCount
        config.layoutMode = .horizontal
        config.barHeightMode = .uniform
        config.barColorMode = .frequencyBased([
            UIColor(hex: "#FF0000"), // 低频 - 红
            UIColor(hex: "#FF7F00"), // 中低频 - 橙
            UIColor(hex: "#FFFF00"), // 中频 - 黄
            UIColor(hex: "#00FF00"), // 中高频 - 绿
            UIColor(hex: "#0000FF")  // 高频 - 蓝
        ])
        config.spacingMode = .equal(3.0)
        return config
    }
}
