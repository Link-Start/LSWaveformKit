//
//  UIFont+LSWaveformKit.swift
//  LSWaveformKit
//
//  Created by Link on 2025/02/09.
//  Copyright © 2025 Link. All rights reserved.
//

import UIKit

// MARK: - Font Constants

public let PingFangSCRegular_FontName = "PingFangSC-Regular"
public let PingFangSCMedium_FontName = "PingFangSC-Medium"
public let PingFangSCSemibold_FontName = "PingFangSC-Semibold"

// 向后兼容别名
public let PingFangSCRegular = PingFangSCRegular_FontName
public let PingFangSCMedium = PingFangSCMedium_FontName
public let PingFangSCSemibold = PingFangSCSemibold_FontName

// MARK: - UIFont Extensions

public extension UIFont {
    /// PingFang SC Regular 字体
    @nonobjc public static func pingFangSCRegular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: PingFangSCRegular_FontName, size: size) ?? .systemFont(ofSize: size)
    }

    /// PingFang SC Medium 字体
    @nonobjc public static func pingFangSCMedium(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: PingFangSCMedium_FontName, size: size) ?? .systemFont(ofSize: size, weight: .medium)
    }

    /// PingFang SC Semibold 字体
    @nonobjc public static func pingFangSCSemibold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: PingFangSCSemibold_FontName, size: size) ?? .systemFont(ofSize: size, weight: .semibold)
    }
}

// MARK: - Font Helper Functions (全局函数)

/// 快捷字体创建函数
public func PingFangSCRegular(_ size: CGFloat) -> UIFont {
    UIFont.pingFangSCRegular(ofSize: size)
}

public func PingFangSCMedium(_ size: CGFloat) -> UIFont {
    UIFont.pingFangSCMedium(ofSize: size)
}

public func PingFangSCSemibold(_ size: CGFloat) -> UIFont {
    UIFont.pingFangSCSemibold(ofSize: size)
}
