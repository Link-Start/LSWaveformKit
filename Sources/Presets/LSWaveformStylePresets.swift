//
//  LSWaveformStylePresets.swift
//  LSWaveformKit
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import Foundation
import UIKit

// MARK: - Style Preset Provider

/// 波形风格预设提供者
public class LSWaveformStylePresets {

    // MARK: - 基础风格预设

    /// 默认风格
    public static func defaultStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 30
        config.barColorMode = .single(UIColor_00CBE0())
        config.spacingMode = .equal(8)
        return config
    }

    /// QQ 风格
    public static func qqStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 30
        config.barColorMode = .single(UIColor(hex: "#12B7F5"))
        config.spacingMode = .equal(8)
        config.cornerRadius = 2
        return config
    }

    /// 微信风格
    public static func wechatStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 30
        config.barColorMode = .single(UIColor(hex: "#07C160"))
        config.spacingMode = .equal(8)
        config.cornerRadius = 1.5
        return config
    }

    /// WhatsApp 风格
    public static func whatsappStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 25
        config.barColorMode = .single(UIColor(hex: "#25D366"))
        config.spacingMode = .equal(10)
        config.barWidth = 4
        config.cornerRadius = 2
        return config
    }

    /// iOS 系统风格
    public static func iosStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 30
        config.barColorMode = .single(UIColor.systemBlue)
        config.spacingMode = .equal(8)
        config.cornerRadius = 1.5
        return config
    }

    // MARK: - 音乐播放器风格预设

    /// 酷狗音乐 - 彩色频谱光柱，7色彩虹
    public static func kugouStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 40
        config.layoutMode = .horizontal
        config.barColorMode = .rainbow
        config.spacingMode = .equal(3)
        config.barWidth = 4
        config.enableShadow = true
        config.shadowColor = UIColor.white
        config.shadowRadius = 8
        config.shadowOffset = .zero
        return config
    }

    /// QQ 音乐 - 多彩渐变，发光阴影
    public static func qqmusicStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 50
        config.layoutMode = .horizontal
        config.barColorMode = .gradientHorizontal(
            [UIColor(hex: "#FF6B6B"), UIColor(hex: "#4ECDC4"), UIColor(hex: "#45B7D1"), UIColor(hex: "#96CEB4")],
            locations: [0.0, 0.33, 0.66, 1.0]
        )
        config.spacingMode = .equal(4)
        config.barWidth = 3
        config.enableShadow = true
        config.shadowColor = UIColor(hex: "#4ECDC4")
        config.shadowRadius = 10
        return config
    }

    /// 酷我音乐 - 炫彩渐变，律动光柱
    public static func kuwoStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 45
        config.layoutMode = .horizontal
        config.barColorMode = .gradientVertical(
            [UIColor(hex: "#FF9FF3"), UIColor(hex: "#FECA57"), UIColor(hex: "#FF6B6B"), UIColor(hex: "#48DBFB")],
            locations: [0.0, 0.33, 0.66, 1.0]
        )
        config.spacingMode = .equal(4)
        config.barWidth = 3.5
        config.cornerRadius = 2
        config.enableShadow = true
        return config
    }

    /// 落雪 - 柔和渐变，雪花飘落
    public static func luoxueStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 35
        config.layoutMode = .horizontal
        config.barColorMode = .gradientVertical(
            [UIColor(hex: "#E0F7FA").withAlphaComponent(0.5), UIColor(hex: "#80DEEA"), UIColor(hex: "#26C6DA")],
            locations: [0.0, 0.5, 1.0]
        )
        config.spacingMode = .wave(min: 4, max: 10, frequency: 0.2)
        config.barWidth = 3
        config.cornerRadius = 1.5
        config.animationDuration = 0.3
        return config
    }

    /// 网易云音乐 - 红色主题，优雅曲线
    public static func neteaseStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 50
        config.layoutMode = .horizontal
        config.barColorMode = .gradientVertical(
            [UIColor(hex: "#C20C0C").withAlphaComponent(0.3), UIColor(hex: "#C20C0C")],
            locations: [0.0, 1.0]
        )
        config.spacingMode = .equal(5)
        config.barWidth = 3
        config.cornerRadius = 2
        return config
    }

    /// 虾米音乐 - 蓝色科技主题
    public static func xiamiStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 40
        config.layoutMode = .horizontal
        config.barColorMode = .gradientVertical(
            [UIColor(hex: "#2196F3").withAlphaComponent(0.3), UIColor(hex: "#2196F3"), UIColor(hex: "#00BCD4")],
            locations: [0.0, 0.5, 1.0]
        )
        config.spacingMode = .equal(5)
        config.barWidth = 3
        config.cornerRadius = 1
        return config
    }

    /// Apple Music - 红色高光，弹跳动画
    public static func applemusicStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 45
        config.layoutMode = .horizontal
        config.barColorMode = .single(UIColor(hex: "#FA2D48"))
        config.spacingMode = .equal(4)
        config.barWidth = 4
        config.cornerRadius = 2
        config.animationDuration = 0.25
        // 使用 easeInOut 替代不可用的 spring
        config.animationCurve = .easeInOut
        return config
    }

    /// YouTube Music - 7色彩虹渐变
    public static func youtubemusicStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 50
        config.layoutMode = .horizontal
        config.barColorMode = .rainbow
        config.spacingMode = .equal(3)
        config.barWidth = 4
        config.cornerRadius = 2
        config.enableShadow = true
        config.shadowColor = UIColor.white
        config.shadowRadius = 6
        return config
    }

    /// Spotify - 绿色渐变，简洁现代
    public static func spotifyStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 40
        config.layoutMode = .horizontal
        config.barColorMode = .gradientVertical(
            [UIColor(hex: "#1DB954").withAlphaComponent(0.4), UIColor(hex: "#1DB954")],
            locations: [0.0, 1.0]
        )
        config.spacingMode = .equal(6)
        config.barWidth = 5
        config.cornerRadius = 2.5
        config.animationDuration = 0.15
        return config
    }

    // MARK: - 特效风格预设

    /// 霓虹风格 - 紫粉渐变，强烈发光
    public static func neonStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 30
        config.barColorMode = .gradientVertical(
            [UIColor(hex: "#FF00FF"), UIColor(hex: "#00FFFF")],
            locations: [0.0, 1.0]
        )
        config.spacingMode = .equal(8)
        config.barWidth = 4
        config.enableShadow = true
        config.shadowColor = UIColor(hex: "#FF00FF")
        config.shadowRadius = 15
        config.shadowOffset = .zero
        return config
    }

    /// 极简风格 - 单色，简洁线条
    public static func minimalStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 30
        config.barColorMode = .single(UIColor_FFFFFF())
        config.spacingMode = .equal(10)
        config.barWidth = 2
        config.cornerRadius = 1
        return config
    }

    /// 复古风格 - 多色循环，像素感
    public static func retroStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 32
        config.barColorMode = .multiple([
            UIColor(hex: "#E74C3C"),
            UIColor(hex: "#F39C12"),
            UIColor(hex: "#F1C40F"),
            UIColor(hex: "#2ECC71"),
            UIColor(hex: "#3498DB"),
            UIColor(hex: "#9B59B6")
        ], cycle: true)
        config.spacingMode = .equal(6)
        config.barWidth = 4
        config.cornerRadius = 0
        return config
    }

    /// 玻璃拟态 - 半透明，模糊效果
    public static func glassmorphismStyle() -> LSDefaultWaveformConfiguration {
        let config = LSDefaultWaveformConfiguration()
        config.numberOfBars = 30
        config.barColorMode = .single(UIColor_FFFFFF().withAlphaComponent(0.3))
        config.spacingMode = .equal(8)
        config.barWidth = 3
        config.cornerRadius = 2
        config.showStroke = true
        config.strokeColor = UIColor_FFFFFF().withAlphaComponent(0.5)
        config.strokeWidth = 1
        return config
    }

    // MARK: - Apply Style Method

    /// 应用风格到配置
    /// - Parameters:
    ///   - style: 风格枚举
    ///   - configuration: 要修改的配置对象
    public static func applyStyle(_ style: LSWaveformStyle, to configuration: LSDefaultWaveformConfiguration) {
        let presetConfig: LSDefaultWaveformConfiguration

        switch style {
        case .default:
            presetConfig = defaultStyle()
        case .qq:
            presetConfig = qqStyle()
        case .wechat:
            presetConfig = wechatStyle()
        case .whatsapp:
            presetConfig = whatsappStyle()
        case .ios:
            presetConfig = iosStyle()
        case .kugou:
            presetConfig = kugouStyle()
        case .qqmusic:
            presetConfig = qqmusicStyle()
        case .kuwo:
            presetConfig = kuwoStyle()
        case .luoxue:
            presetConfig = luoxueStyle()
        case .netease:
            presetConfig = neteaseStyle()
        case .xiami:
            presetConfig = xiamiStyle()
        case .applemusic:
            presetConfig = applemusicStyle()
        case .youtubemusic:
            presetConfig = youtubemusicStyle()
        case .spotify:
            presetConfig = spotifyStyle()
        case .neon:
            presetConfig = neonStyle()
        case .minimal:
            presetConfig = minimalStyle()
        case .retro:
            presetConfig = retroStyle()
        case .glassmorphism:
            presetConfig = glassmorphismStyle()
        }

        // 复制预设配置的属性到目标配置
        configuration.numberOfBars = presetConfig.numberOfBars
        configuration.layoutMode = presetConfig.layoutMode
        configuration.barColorMode = presetConfig.barColorMode
        configuration.spacingMode = presetConfig.spacingMode
        configuration.barWidth = presetConfig.barWidth
        configuration.cornerRadius = presetConfig.cornerRadius
        configuration.animationDuration = presetConfig.animationDuration
        configuration.animationCurve = presetConfig.animationCurve
        configuration.enableShadow = presetConfig.enableShadow
        configuration.shadowColor = presetConfig.shadowColor
        configuration.shadowRadius = presetConfig.shadowRadius
        configuration.shadowOffset = presetConfig.shadowOffset
        configuration.showStroke = presetConfig.showStroke
        configuration.strokeColor = presetConfig.strokeColor
        configuration.strokeWidth = presetConfig.strokeWidth
    }
}

// MARK: - UIView.AnimationCurve Extension

private extension UIView.AnimationCurve {
    var isSpring: Bool {
        // 自定义检查，实际使用时可以扩展
        return false
    }
}
