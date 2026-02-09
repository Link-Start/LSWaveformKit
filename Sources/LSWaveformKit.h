//
//  LSWaveformKit.h
//  LSWaveformKit
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for LSWaveformKit.
FOUNDATION_EXPORT double LSWaveformKitVersionNumber;

//! Project version string for LSWaveformKit.
FOUNDATION_EXPORT const unsigned char LSWaveformKitVersionString[];

// 导出 Swift 类到 Objective-C
#if __swift__
@import LSWaveformKitSwift;
#endif

// MARK: - Core Classes

/**
 * LSWaveformView - 波形视图基类
 *
 * 所有波形视图的基类，提供核心功能和配置接口。
 */
#if __swift__
@interface LSWaveformView : UIView
#else
@interface LSWaveformView : NSObject // 实际在 Swift 中定义
#endif

/**
 * 开始录音
 */
- (void)startRecording;

/**
 * 停止录音
 */
- (void)stopRecording;

/**
 * 取消录音
 */
- (void)cancelRecording;

/**
 * 更新音量
 * @param amplitude 音量值（0.0 ~ 1.0）
 */
- (void)updateAmplitude:(float)amplitude;

/**
 * 重置波形
 */
- (void)resetWaveform;

/**
 * 刷新波形显示
 */
- (void)refreshWaveform;

/**
 * 应用预设风格
 * @param style 风格枚举
 */
- (void)applyStyle:(LSWaveformStyle)style;

/**
 * 应用自定义配置
 * @param configuration 配置对象
 */
- (void)applyConfiguration:(id<LSWaveformConfiguration>)configuration;

@end

// MARK: - Enums

/**
 * 条纹高度模式
 */
typedef NS_ENUM(NSInteger, LSBarHeightMode) {
    LSBarHeightModeSymmetric,           // 对称（中间高，两边低）
    LSBarHeightModeRandom,              // 随机模式
    LSBarHeightModeAscending,           // 从左到右依次升高
    LSBarHeightModeDescending,          // 从左到右依次降低
    LSBarHeightModeHighLow,             // 高低高低
    LSBarHeightModeLowHigh,             // 低高低高
    LSBarHeightModeUniform,             // 一样高
};

/**
 * 布局模式
 */
typedef NS_ENUM(NSInteger, LSLayoutMode) {
    LSLayoutModeSymmetric,              // 左右对称
    LSLayoutModeLeftOnly,               // 仅左侧
    LSLayoutModeRightOnly,              // 仅右侧
    LSLayoutModeHorizontal,             // 水平排列
    LSLayoutModeCircular,               // 圆形排列
};

/**
 * 波形风格
 */
typedef NS_ENUM(NSInteger, LSWaveformStyle) {
    LSWaveformStyleDefault,             // 默认
    LSWaveformStyleQQ,                  // QQ
    LSWaveformStyleWechat,              // 微信
    LSWaveformStyleWhatsApp,            // WhatsApp
    LSWaveformStyleIOS,                 // iOS
    LSWaveformStyleKugou,               // 酷狗音乐
    LSWaveformStyleQQMusic,             // QQ音乐
    LSWaveformStyleKuwo,                // 酷我音乐
    LSWaveformStyleLuoxue,              // 落雪
    LSWaveformStyleNetease,             // 网易云音乐
    LSWaveformStyleXiami,               // 虾米音乐
    LSWaveformStyleAppleMusic,          // Apple Music
    LSWaveformStyleYouTubeMusic,        // YouTube Music
    LSWaveformStyleSpotify,             // Spotify
    LSWaveformStyleNeon,                // 霓虹
    LSWaveformStyleMinimal,             // 极简
    LSWaveformStyleRetro,               // 复古
    LSWaveformStyleGlassmorphism,       // 玻璃拟态
};

// MARK: - NSString Constants

/**
 * 风格名称常量
 */
FOUNDATION_EXPORT NSString * const LSWaveformStyleNameDefault;
FOUNDATION_EXPORT NSString * const LSWaveformStyleNameQQ;
FOUNDATION_EXPORT NSString * const LSWaveformStyleNameWechat;
FOUNDATION_EXPORT NSString * const LSWaveformStyleNameWhatsApp;
FOUNDATION_EXPORT NSString * const LSWaveformStyleNameIOS;
FOUNDATION_EXPORT NSString * const LSWaveformStyleNameKugou;
FOUNDATION_EXPORT NSString * const LSWaveformStyleNameQQMusic;
FOUNDATION_EXPORT NSString * const LSWaveformStyleNameKuwo;
FOUNDATION_EXPORT NSString * const LSWaveformStyleNameLuoxue;
FOUNDATION_EXPORT NSString * const LSWaveformStyleNameNetease;
FOUNDATION_EXPORT NSString * const LSWaveformStyleNameAppleMusic;
FOUNDATION_EXPORT NSString * const LSWaveformStyleNameSpotify;

// MARK: - Error Domain

/**
 * LSWaveformKit 错误域
 */
FOUNDATION_EXPORT NSErrorDomain const LSWaveformKitErrorDomain;

/**
 * 错误代码
 */
typedef NS_ENUM(NSInteger, LSWaveformKitErrorCode) {
    LSWaveformKitErrorCodeRecordingFailed = 1000,     // 录音失败
    LSWaveformKitErrorCodePlaybackFailed = 1001,     // 播放失败
    LSWaveformKitErrorCodeMicrophoneDenied = 1002,    // 麦克风权限被拒绝
    LSWaveformKitErrorCodeInvalidConfiguration = 1003, // 无效配置
    LSWaveformKitErrorCodeFileNotFound = 1004,        // 文件未找到
};
