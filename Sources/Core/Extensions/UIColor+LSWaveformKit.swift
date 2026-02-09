//
//  UIColor+LSWaveformKit.swift
//  LSWaveformKit
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import UIKit

extension UIColor {
    /// 从十六进制字符串创建颜色
    /// - Parameter hex: 十六进制字符串（格式："#RGB" 或 "#RGBA" 或 "#RRGGBB" 或 "#RRGGBBAA"）
    public convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r, g, b, a: CGFloat

        switch hexSanitized.count {
        case 3: // RGB (12-bit)
            (r, g, b, a) = (
                CGFloat((rgb >> 8) * 17) / 255,
                CGFloat((rgb >> 4 & 0xF) * 17) / 255,
                CGFloat((rgb & 0xF) * 17) / 255,
                1.0
            )
        case 4: // RGBA (12-bit)
            (r, g, b, a) = (
                CGFloat((rgb >> 12) * 17) / 255,
                CGFloat((rgb >> 8 & 0xF) * 17) / 255,
                CGFloat((rgb >> 4 & 0xF) * 17) / 255,
                CGFloat((rgb & 0xF) * 17) / 255
            )
        case 6: // RGB (24-bit)
            (r, g, b, a) = (
                CGFloat((rgb >> 16) & 0xFF) / 255,
                CGFloat((rgb >> 8 & 0xFF) / 255),
                CGFloat(rgb & 0xFF) / 255,
                1.0
            )
        case 8: // RGBA (32-bit)
            (r, g, b, a) = (
                CGFloat((rgb >> 24) & 0xFF) / 255,
                CGFloat((rgb >> 16 & 0xFF) / 255),
                CGFloat((rgb >> 8 & 0xFF) / 255),
                CGFloat(rgb & 0xFF) / 255
            )
        default:
            (r, g, b, a) = (0, 0, 0, 1)
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }

    /// 从 RGB 值创建颜色
    /// - Parameters:
    ///   - red: 红色值 (0-255)
    ///   - green: 绿色值 (0-255)
    ///   - blue: 蓝色值 (0-255)
    ///   - alpha: 透明度 (0-1)
    public convenience init(r red: Int, g green: Int, b blue: Int, a alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: alpha
        )
    }

    /// 从 HSB 值创建颜色
    /// - Parameters:
    ///   - hue: 色相 (0-1)
    ///   - saturation: 饱和度 (0-1)
    ///   - brightness: 亮度 (0-1)
    ///   - alpha: 透明度 (0-1)
    public convenience init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat = 1.0) {
        self.init(
            hue: hue,
            saturation: saturation,
            brightness: brightness,
            alpha: alpha
        )
    }
}

// MARK: - Quick Color Functions

/// 快捷颜色创建函数
public func UIColor_00CBE0() -> UIColor {
    return UIColor(hex: "#00CBE0")
}

public func UIColor_D1D6D9() -> UIColor {
    return UIColor(hex: "#D1D6D9")
}

public func UIColor_000000() -> UIColor {
    return UIColor(hex: "#000000")
}

public func UIColor_FFFFFF() -> UIColor {
    return UIColor(hex: "#FFFFFF")
}

public func UIColor_F2F2F7() -> UIColor {
    return UIColor(hex: "#F2F2F7")
}

public func UIColor_E5E5EA() -> UIColor {
    return UIColor(hex: "#E5E5EA")
}

public func UIColor_8E8E93() -> UIColor {
    return UIColor(hex: "#8E8E93")
}

public func UIColor_007AFF() -> UIColor {
    return UIColor(hex: "#007AFF")
}

public func UIColor_FF3B30() -> UIColor {
    return UIColor(hex: "#FF3B30")
}

public func UIColor_34C759() -> UIColor {
    return UIColor(hex: "#34C759")
}

public func UIColor_FF9500() -> UIColor {
    return UIColor(hex: "#FF9500")
}

public func UIColor_AF52DE() -> UIColor {
    return UIColor(hex: "#AF52DE")
}

public func UIColor_5856D6() -> UIColor {
    return UIColor(hex: "#5856D6")
}

public func UIColor_32ADE6() -> UIColor {
    return UIColor(hex: "#32ADE6")
}

public func UIColor_64D2FF() -> UIColor {
    return UIColor(hex: "#64D2FF")
}
