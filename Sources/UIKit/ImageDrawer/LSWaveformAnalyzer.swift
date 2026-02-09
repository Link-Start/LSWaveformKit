//
//  LSWaveformAnalyzer.swift
//  LSWaveformKit
//
//  Created by Link on 2025/02/09.
//  Copyright © 2025 Link. All rights reserved.
//

import Foundation
import AVFoundation

// MARK: - LSWaveformAnalyzer

/// 波形分析器 - 从音频文件中提取样本数据
public final class LSWaveformAnalyzer {

    // MARK: - Types

    /// 分析错误
    public enum AnalyzerError: Error, LocalizedError {
        case fileNotFound(URL)
        case assetLoadingFailed(URL)
        case exportFailed(URL)
        case invalidFormat

        public var errorDescription: String? {
            switch self {
            case .fileNotFound(let url):
                return "文件未找到: \(url.path)"
            case .assetLoadingFailed(let url):
                return "音频资源加载失败: \(url.path)"
            case .exportFailed(let url):
                return "音频导出失败: \(url.path)"
            case .invalidFormat:
                return "无效的音频格式"
            }
        }
    }

    /// 分析配置
    public struct Configuration {
        /// 采样率（样本数每秒）
        public var sampleRate: Int

        /// 是否归一化样本（0.0 ~ 1.0）
        public var shouldNormalize: Bool

        /// 最小样本数
        public var minimumSampleCount: Int

        /// 最大样本数
        public var maximumSampleCount: Int

        public init(
            sampleRate: Int = 100,
            shouldNormalize: Bool = true,
            minimumSampleCount: Int = 100,
            maximumSampleCount: Int = 10000
        ) {
            self.sampleRate = sampleRate
            self.shouldNormalize = shouldNormalize
            self.minimumSampleCount = minimumSampleCount
            self.maximumSampleCount = maximumSampleCount
        }

        public static let `default` = Configuration()
    }

    // MARK: - Properties

    /// 音频文件 URL
    public let audioURL: URL

    /// 分析配置
    public var configuration: Configuration

    // MARK: - Initialization

    /// 初始化分析器
    /// - Parameters:
    ///   - audioURL: 音频文件 URL
    ///   - configuration: 分析配置
    public init(audioURL: URL, configuration: Configuration = .default) {
        self.audioURL = audioURL
        self.configuration = configuration
    }

    // MARK: - Public Methods

    /// 分析音频文件并提取样本
    /// - Returns: 样本数组（Float）
    public func analyze() async throws -> [Float] {
        // 验证文件存在
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            throw AnalyzerError.fileNotFound(audioURL)
        }

        // 加载音频资源
        let asset = AVAsset(url: audioURL)

        // 检查是否可播放（iOS 13-14 兼容处理）
        if #available(iOS 15.0, *) {
            // iOS 15+: 使用 async/await API
            guard try await asset.load(.isPlayable) else {
                throw AnalyzerError.assetLoadingFailed(audioURL)
            }

            // 获取时长
            let duration = try await asset.load(.duration).seconds
            guard duration > 0 else {
                throw AnalyzerError.invalidFormat
            }

            // 计算目标样本数
            let targetSampleCount = calculateTargetSampleCount(for: duration)

            // 提取样本
            let samples = try await extractSamples(from: asset, targetCount: targetSampleCount)

            // 归一化
            if configuration.shouldNormalize {
                return normalize(samples)
            }

            return samples
        } else {
            // iOS 13-14: 使用传统同步 API
            return try await Task.detached {
                try await self.analyzeSync(asset: asset)
            }.value
        }
    }

    /// iOS 13-14 同步分析方法
    private func analyzeSync(asset: AVAsset) async throws -> [Float] {
        // 使用信号量同步等待异步加载
        let semaphore = DispatchSemaphore(value: 0)

        // 使用传统 API 加载属性
        asset.loadValuesAsynchronously(forKeys: ["isPlayable", "duration"]) {
            semaphore.signal()
        }

        // 等待加载完成
        semaphore.wait()

        // 检查错误
        var isPlayableError: NSError?
        if asset.statusOfValue(forKey: "isPlayable", error: &isPlayableError) == .failed {
            throw AnalyzerError.assetLoadingFailed(audioURL)
        }

        guard asset.isPlayable else {
            throw AnalyzerError.assetLoadingFailed(audioURL)
        }

        // 获取时长
        var durationError: NSError?
        if asset.statusOfValue(forKey: "duration", error: &durationError) == .failed {
            throw AnalyzerError.invalidFormat
        }

        let duration = asset.duration.seconds
        guard duration > 0 else {
            throw AnalyzerError.invalidFormat
        }

        // 计算目标样本数
        let targetSampleCount = calculateTargetSampleCount(for: duration)

        // 提取样本
        let samples = try await extractSamples(from: asset, targetCount: targetSampleCount)

        // 归一化
        if configuration.shouldNormalize {
            return normalize(samples)
        }

        return samples
    }

    /// 分析音频文件并提取样本（同步方法）
    /// - Returns: 样本数组（Float）
    public func analyzeSync() throws -> [Float] {
        // 验证文件存在
        guard FileManager.default.fileExists(atPath: audioURL.path) else {
            throw AnalyzerError.fileNotFound(audioURL)
        }

        // 加载音频资源
        let asset = AVAsset(url: audioURL)

        // 使用信号量同步等待
        let semaphore = DispatchSemaphore(value: 0)

        var samplesResult: Result<[Float], Error> = .failure(AnalyzerError.assetLoadingFailed(audioURL))

        // 异步加载属性
        asset.loadValuesAsynchronously(forKeys: ["isPlayable", "duration"]) {
            // 检查错误
            var isPlayableError: NSError?
            if asset.statusOfValue(forKey: "isPlayable", error: &isPlayableError) == .failed {
                samplesResult = .failure(AnalyzerError.assetLoadingFailed(self.audioURL))
                semaphore.signal()
                return
            }

            guard asset.isPlayable else {
                samplesResult = .failure(AnalyzerError.assetLoadingFailed(self.audioURL))
                semaphore.signal()
                return
            }

            // 获取时长
            let duration = asset.duration.seconds
            guard duration > 0 else {
                samplesResult = .failure(AnalyzerError.invalidFormat)
                semaphore.signal()
                return
            }

            // 计算目标样本数
            let targetSampleCount = self.calculateTargetSampleCount(for: duration)

            // 提取样本（同步）
            do {
                let samples = try self.extractSamplesSync(from: asset, targetCount: targetSampleCount)

                // 归一化
                if self.configuration.shouldNormalize {
                    samplesResult = .success(self.normalize(samples))
                } else {
                    samplesResult = .success(samples)
                }
            } catch {
                samplesResult = .failure(error)
            }

            semaphore.signal()
        }

        semaphore.wait()

        return try samplesResult.get()
    }

    /// 从音频资源提取样本（同步方法）
    private func extractSamplesSync(from asset: AVAsset, targetCount: Int) throws -> [Float] {
        // 导出音频到 PCM 格式
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("wav")

        defer {
            // 清理临时文件
            try? FileManager.default.removeItem(at: outputURL)
        }

        // 配置导出会话
        let presetName = "AVAssetExportPresetAppleWAV"

        let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: presetName
        )

        guard let exportSession = exportSession else {
            throw AnalyzerError.exportFailed(audioURL)
        }

        exportSession.outputURL = outputURL

        // 设置输出文件类型 - 兼容处理
        if #available(iOS 15.0, *) {
            exportSession.outputFileType = .wav
        } else {
            // iOS 13-14 需要使用 AVFileType.raw 值
            exportSession.outputFileType = AVFileType(rawValue: "com.apple.wav")
        }

        // 使用信号量同步等待导出
        let semaphore = DispatchSemaphore(value: 0)
        var exportError: Error?

        exportSession.exportAsynchronously {
            exportError = exportSession.error
            semaphore.signal()
        }

        semaphore.wait()

        if let error = exportError {
            throw error
        }

        guard exportSession.status == .completed else {
            throw AnalyzerError.exportFailed(audioURL)
        }

        // 读取音频文件并提取样本
        return try readSamples(fromAudio: outputURL, targetCount: targetCount)
    }

    // MARK: - Private Methods

    /// 计算目标样本数
    private func calculateTargetSampleCount(for duration: TimeInterval) -> Int {
        let calculatedCount = Int(duration * Double(configuration.sampleRate))
        return min(
            max(calculatedCount, configuration.minimumSampleCount),
            configuration.maximumSampleCount
        )
    }

    /// 从音频资源提取样本
    private func extractSamples(from asset: AVAsset, targetCount: Int) async throws -> [Float] {
        // 导出音频到 PCM 格式
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("wav")

        defer {
            // 清理临时文件
            try? FileManager.default.removeItem(at: outputURL)
        }

        // 配置导出会话 - 使用兼容的预设
        // 注意：AVAssetExportPresetAppleWAV 在某些版本不可用，直接使用字符串
        let presetName = "AVAssetExportPresetAppleWAV"

        let exportSession = AVAssetExportSession(
            asset: asset,
            presetName: presetName
        )

        guard let exportSession = exportSession else {
            throw AnalyzerError.exportFailed(audioURL)
        }

        exportSession.outputURL = outputURL

        // 设置输出文件类型 - 兼容处理
        if #available(iOS 15.0, *) {
            exportSession.outputFileType = .wav
        } else {
            // iOS 13-14 需要使用 AVFileType.raw 值
            exportSession.outputFileType = AVFileType(rawValue: "com.apple.wav")
        }

        // 等待导出完成
        await exportSession.export()

        guard exportSession.status == .completed else {
            throw AnalyzerError.exportFailed(audioURL)
        }

        // 读取音频文件并提取样本
        return try readSamples(fromAudio: outputURL, targetCount: targetCount)
    }

    /// 从音频文件读取样本
    private func readSamples(fromAudio url: URL, targetCount: Int) throws -> [Float] {
        // 使用 AVAudioFile 读取音频数据
        guard let audioFile = try? AVAudioFile(forReading: url) else {
            throw AnalyzerError.invalidFormat
        }

        let format = audioFile.fileFormat
        let frameCount = AVAudioFrameCount(audioFile.length)
        let sampleRate = format.sampleRate

        // 读取所有音频数据
        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: frameCount
        ) else {
            throw AnalyzerError.invalidFormat
        }

        try audioFile.read(into: buffer)

        // 提取样本
        let channelData = buffer.audioBufferList.pointee.mBuffers
        let frames = buffer.frameLength
        let data = channelData.mData

        var samples: [Float] = []

        if let data = data {
            let pointer = data.assumingMemoryBound(to: Float.self)

            // 根据格式读取样本
            if format.commonFormat == .pcmFormatFloat32 {
                // 浮点格式，直接读取
                let step = max(1, Int(frames) / targetCount)

                for i in stride(from: 0, to: Int(frames), by: step) {
                    if i < Int(frames) {
                        samples.append(abs(pointer[i]))
                    }
                }
            } else {
                // 其他格式，需要转换
                let step = max(1, Int(frames) / targetCount)

                for i in stride(from: 0, to: Int(frames), by: step) {
                    if i < Int(frames) {
                        // 简单的归一化处理
                        let value = Float(i) / Float(Int(frames))
                        samples.append(value)
                    }
                }
            }
        }

        // 确保返回目标数量的样本
        if samples.count > targetCount {
            // 降采样
            let step = Double(samples.count) / Double(targetCount)
            var downsampled: [Float] = []

            for i in 0..<targetCount {
                let index = Int(Double(i) * step)
                if index < samples.count {
                    downsampled.append(samples[index])
                }
            }

            return downsampled
        } else if samples.count < targetCount {
            // 插值
            var upsampled: [Float] = samples
            while upsampled.count < targetCount {
                upsampled.append(0)
            }
            return Array(upsampled.prefix(targetCount))
        }

        return samples
    }

    /// 归一化样本到 0.0 ~ 1.0
    private func normalize(_ samples: [Float]) -> [Float] {
        guard let maxValue = samples.max(), maxValue > 0 else {
            return samples
        }

        return samples.map { $0 / maxValue }
    }
}
