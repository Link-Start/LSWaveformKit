//
//  LSWaveformStyle.swift
//  LSWaveformKit
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import Foundation

/// 波形风格
public enum LSWaveformStyle: String, CaseIterable {
    // MARK: - 基础风格

    /// 默认风格
    case `default`

    /// QQ 风格
    case qq

    /// 微信风格
    case wechat

    /// WhatsApp 风格
    case whatsapp

    /// iOS 系统风格
    case ios

    // MARK: - 音乐播放器风格

    /// 酷狗音乐 - 彩色频谱光柱，7色彩虹
    case kugou

    /// QQ 音乐 - 多彩渐变，发光阴影
    case qqmusic

    /// 酷我音乐 - 炫彩渐变，律动光柱
    case kuwo

    /// 落雪 - 柔和渐变，雪花飘落
    case luoxue

    /// 网易云音乐 - 红色主题，优雅曲线
    case netease

    /// 虾米音乐 - 蓝色科技主题
    case xiami

    /// Apple Music - 红色高光，弹跳动画
    case applemusic

    /// YouTube Music - 7色彩虹渐变
    case youtubemusic

    /// Spotify - 绿色渐变，简洁现代
    case spotify

    // MARK: - 特效风格

    /// 霓虹风格 - 紫粉渐变，强烈发光
    case neon

    /// 极简风格 - 单色，简洁线条
    case minimal

    /// 复古风格 - 多色循环，像素感
    case retro

    /// 玻璃拟态 - 半透明，模糊效果
    case glassmorphism
}

// MARK: - Properties

extension LSWaveformStyle {
    /// 风格显示名称
    var displayName: String {
        switch self {
        case .default: return "默认"
        case .qq: return "QQ"
        case .wechat: return "微信"
        case .whatsapp: return "WhatsApp"
        case .ios: return "iOS"
        case .kugou: return "酷狗音乐"
        case .qqmusic: return "QQ音乐"
        case .kuwo: return "酷我音乐"
        case .luoxue: return "落雪"
        case .netease: return "网易云音乐"
        case .xiami: return "虾米音乐"
        case .applemusic: return "Apple Music"
        case .youtubemusic: return "YouTube Music"
        case .spotify: return "Spotify"
        case .neon: return "霓虹"
        case .minimal: return "极简"
        case .retro: return "复古"
        case .glassmorphism: return "玻璃拟态"
        }
    }

    /// 是否为音乐播放器风格
    var isMusicPlayerStyle: Bool {
        switch self {
        case .kugou, .qqmusic, .kuwo, .luoxue, .netease, .xiami, .applemusic, .youtubemusic, .spotify:
            return true
        default:
            return false
        }
    }

    /// 是否为基础风格
    var isBasicStyle: Bool {
        switch self {
        case .default, .qq, .wechat, .whatsapp, .ios:
            return true
        default:
            return false
        }
    }

    /// 是否为特效风格
    var isEffectStyle: Bool {
        switch self {
        case .neon, .minimal, .retro, .glassmorphism:
            return true
        default:
            return false
        }
    }
}
