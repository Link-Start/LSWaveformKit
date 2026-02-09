//
//  LSWaveformAudioProcessor.swift
//  LSWaveformKit
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: - State Enum

/// 音频处理器状态
public enum LSWaveformAudioProcessorState {
    /// 空闲
    case idle

    /// 录音中
    case recording

    /// 播放中
    case playing

    /// 已暂停
    case paused
}

// MARK: - Delegate Protocol

/// 音频处理器代理协议
public protocol LSWaveformAudioProcessorDelegate: AnyObject {
    /// 音量更新
    func audioProcessor(_ processor: LSWaveformAudioProcessor, didUpdateAmplitude amplitude: Float)

    /// 开始录音
    func audioProcessorDidStartRecording(_ processor: LSWaveformAudioProcessor)

    /// 停止录音
    func audioProcessorDidStopRecording(_ processor: LSWaveformAudioProcessor)

    /// 开始播放
    func audioProcessorDidStartPlaying(_ processor: LSWaveformAudioProcessor)

    /// 停止播放
    func audioProcessorDidStopPlaying(_ processor: LSWaveformAudioProcessor)

    /// 错误发生
    func audioProcessor(_ processor: LSWaveformAudioProcessor, didOccur error: Error)
}

// MARK: - Audio Processor Class

/// 音频处理器 - 负责录音、播放和音频分析
public class LSWaveformAudioProcessor: NSObject {

    // MARK: - Properties

    /// 代理
    public weak var delegate: LSWaveformAudioProcessorDelegate?

    /// 当前状态
    public private(set) var state: LSWaveformAudioProcessorState = .idle

    /// 更新间隔（秒）
    public var updateInterval: TimeInterval = 0.05

    /// 输出文件路径
    public var outputURL: URL {
        let filename = "LSWaveform_\(UUID().uuidString).m4a"
        return FileManager.default.temporaryDirectory.appendingPathComponent(filename)
    }

    /// 录音时长（只读）
    public private(set) var recordingDuration: TimeInterval = 0

    /// 录音 URL（只读）
    public private(set) var recordingURL: URL?

    /// 录音器
    private var recorder: AVAudioRecorder?

    /// 播放器
    private var player: AVAudioPlayer?

    /// 更新定时器
    private var updateTimer: Timer?

    /// 录音开始时间
    private var recordingStartTime: Date?

    // MARK: - Initialization

    public override init() {
        super.init()
    }

    deinit {
        // 重要：停止所有音频操作，防止页面销毁后继续录音
        stopUpdateTimer()
        stopRecording()
        stopPlaying()

        // 清理代理引用
        delegate = nil
    }

    // MARK: - Recording

    /// 开始录音
    /// - Returns: 是否成功
    public func startRecording() -> Bool {
        guard state == .idle else { return false }

        // 配置音频会话
        do {
            try LSAudioSession.shared.configureForRecording()
        } catch {
            notifyError(error)
            return false
        }

        // 创建录音器
        let url = outputURL

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recordingURL = url  // 保存录音 URL
            recorder?.delegate = self
            recorder?.isMeteringEnabled = true
            recorder?.record()

            state = .recording
            recordingStartTime = Date()
            recordingDuration = 0

            startUpdateTimer()
            delegate?.audioProcessorDidStartRecording(self)

            return true
        } catch {
            notifyError(error)
            return false
        }
    }

    /// 停止录音
    /// nonisolated(unsafe): 此方法执行同步的线程安全操作，可从任何线程调用
    public nonisolated(unsafe) func stopRecording() {
        guard state == .recording else { return }

        recorder?.stop()
        stopUpdateTimer()

        state = .idle
        recordingDuration = Date().timeIntervalSince(recordingStartTime ?? Date())

        delegate?.audioProcessorDidStopRecording(self)
    }

    /// 取消录音
    /// nonisolated(unsafe): 此方法执行同步的线程安全操作，可从任何线程调用
    public nonisolated(unsafe) func cancelRecording() {
        guard state == .recording else { return }

        recorder?.stop()
        stopUpdateTimer()

        // 删除临时文件
        if let url = recorder?.url {
            try? FileManager.default.removeItem(at: url)
        }

        state = .idle
        recordingDuration = 0
    }

    // MARK: - Playing

    /// 播放音频
    /// - Parameter url: 音频文件路径
    public func playAudio(at url: URL) {
        guard state == .idle else { return }

        // 配置音频会话
        do {
            try LSAudioSession.shared.configureForPlayback()
        } catch {
            notifyError(error)
            return
        }

        // 创建播放器
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.play()

            state = .playing

            startUpdateTimer()
            delegate?.audioProcessorDidStartPlaying(self)
        } catch {
            notifyError(error)
        }
    }

    /// 停止播放
    /// nonisolated(unsafe): 此方法执行同步的线程安全操作，可从任何线程调用
    public nonisolated(unsafe) func stopPlaying() {
        guard state == .playing || state == .paused else { return }

        player?.stop()
        stopUpdateTimer()

        state = .idle
        delegate?.audioProcessorDidStopPlaying(self)
    }

    /// 暂停播放
    public func pausePlaying() {
        guard state == .playing else { return }

        player?.pause()
        state = .paused
    }

    /// 恢复播放
    public func resumePlaying() {
        guard state == .paused else { return }

        player?.play()
        state = .playing
    }

    /// 跳转到指定时间
    /// - Parameter time: 目标时间（秒）
    public func seek(to time: TimeInterval) {
        player?.currentTime = time
    }

    // MARK: - Update Timer

    private func startUpdateTimer() {
        stopUpdateTimer()

        updateTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.updateAmplitude()
        }

        if let timer = updateTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }

    private func stopUpdateTimer() {
        updateTimer?.invalidate()
        updateTimer = nil
    }

    // MARK: - Amplitude Update

    private func updateAmplitude() {
        var amplitude: Float = 0

        switch state {
        case .recording:
            recorder?.updateMeters()
            let power = recorder?.averagePower(forChannel: 0) ?? -80
            amplitude = normalizePower(power)

        case .playing:
            // 播放时使用模拟数据
            amplitude = Float.random(in: 0.3...0.8)

        default:
            amplitude = 0
        }

        delegate?.audioProcessor(self, didUpdateAmplitude: amplitude)
    }

    /// 将 dB 功率转换为 0.0 ~ 1.0 的幅值
    private func normalizePower(_ power: Float) -> Float {
        // -80 dB ~ 0 dB -> 0.0 ~ 1.0
        let minPower: Float = -80
        let maxPower: Float = 0

        let normalized = (power - minPower) / (maxPower - minPower)
        return max(0, min(1, normalized))
    }

    // MARK: - Error Notification

    private func notifyError(_ error: Error) {
        delegate?.audioProcessor(self, didOccur: error)
    }
}

// MARK: - AVAudioRecorderDelegate

extension LSWaveformAudioProcessor: AVAudioRecorderDelegate {
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            notifyError(NSError(
                domain: "LSWaveformKit",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "录音失败"]
            ))
        }
    }

    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        if let error = error {
            notifyError(error)
        }
    }
}

// MARK: - AVAudioPlayerDelegate

extension LSWaveformAudioProcessor: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlaying()
    }

    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            notifyError(error)
        }
    }
}
