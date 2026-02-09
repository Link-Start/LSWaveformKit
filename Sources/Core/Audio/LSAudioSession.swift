//
//  LSAudioSession.swift
//  LSWaveformKit
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import Foundation
import AVFoundation

/// 音频会话管理器
public class LSAudioSession {

    // MARK: - Singleton

    public static let shared = LSAudioSession()

    private init() {}

    // MARK: - Properties

    /// 音频会话
    private let session = AVAudioSession.sharedInstance()

    /// 是否已配置
    private(set) var isConfigured = false

    // MARK: - Configuration

    /// 配置音频会话用于录音
    /// - Throws: AVAudioSession 错误
    public func configureForRecording() throws {
        try session.setCategory(
            .playAndRecord,
            mode: .default,
            options: [.defaultToSpeaker, .allowBluetooth]
        )
        try session.setActive(true)
        isConfigured = true
    }

    /// 配置音频会话用于播放
    /// - Throws: AVAudioSession 错误
    public func configureForPlayback() throws {
        try session.setCategory(
            .playback,
            mode: .moviePlayback,
            options: []
        )
        try session.setActive(true)
        isConfigured = true
    }

    /// 配置音频会话用于录音和播放（同时）
    /// - Throws: AVAudioSession 错误
    public func configureForRecordingAndPlayback() throws {
        try session.setCategory(
            .playAndRecord,
            mode: .default,
            options: [.defaultToSpeaker, .allowBluetoothA2DP]
        )
        try session.setActive(true)
        isConfigured = true
    }

    /// 停用音频会话
    /// - Throws: AVAudioSession 错误
    public func deactivate() throws {
        try session.setActive(false)
        isConfigured = false
    }

    // MARK: - Permission

    /// 请求麦克风权限
    /// - Parameter completion: 完成回调，返回是否授权
    public static func requestMicrophonePermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    /// 检查麦克风权限状态
    /// - Returns: 权限状态
    public static func microphoneAuthorizationStatus() -> AVAudioSession.RecordPermission {
        return AVAudioSession.sharedInstance().recordPermission
    }

    // MARK: - Hardware Sample Rate

    /// 获取硬件采样率
    public var hardwareSampleRate: Double {
        return session.sampleRate
    }

    /// 设置首选采样率
    /// - Parameter sampleRate: 采样率
    /// - Throws: AVAudioSession 错误
    public func setPreferredSampleRate(_ sampleRate: Double) throws {
        try session.setPreferredSampleRate(sampleRate)
    }

    // MARK: - Duration

    /// 获取当前音频会话的其他音频是否正在播放
    public var isOtherAudioPlaying: Bool {
        return session.isOtherAudioPlaying
    }

    /// 获取音频会话的 secondary audio 是否应该被静音
    public var secondaryAudioShouldBeSilenced: Bool {
        return session.secondaryAudioShouldBeSilencedHint
    }

    // MARK: - Interruption

    /// 音频中断通知
    public static let interruptionNotification = Notification.Name("LSAudioSessionInterruptionNotification")

    /// 路由变更通知
    public static let routeChangeNotification = Notification.Name("LSAudioSessionRouteChangeNotification")

    /// 监听音频中断
    public func observeInterruptions() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
    }

    /// 停止监听
    public func stopObserving() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleInterruption(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }

        NotificationCenter.default.post(
            name: Self.interruptionNotification,
            object: self,
            userInfo: ["type": type]
        )
    }

    @objc private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        NotificationCenter.default.post(
            name: Self.routeChangeNotification,
            object: self,
            userInfo: ["reason": reason]
        )
    }

    deinit {
        stopObserving()
    }
}
