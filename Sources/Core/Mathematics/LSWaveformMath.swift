//
//  LSWaveformMath.swift
//  LSWaveformKit
//
//  Created by Link on 2025-02-07.
//

import Foundation
import Accelerate

/// 波形数学计算工具
public struct LSWaveformMath {

    // MARK: - RMS 计算

    /// 计算音频缓冲区的 RMS（均方根）值
    /// - Parameter buffer: 音频数据缓冲区
    /// - Returns: RMS 值（0.0 ~ 1.0）
    public static func calculateRMS(from buffer: [Int16]) -> Float {
        guard !buffer.isEmpty else { return 0 }

        var sum: Float = 0
        for sample in buffer {
            let normalized = Float(sample) / Float(Int16.max)
            sum += normalized * normalized
        }

        return sqrt(sum / Float(buffer.count))
    }

    /// 计算音频缓冲区的 RMS 值（Accelerate 框架优化）
    /// - Parameter buffer: 音频数据缓冲区
    /// - Returns: RMS 值（0.0 ~ 1.0）
    public static func calculateRMSAccelerate(from buffer: [Int16]) -> Float {
        guard !buffer.isEmpty else { return 0 }

        // 转换为 Float 数组
        let floatBuffer = buffer.map { Float($0) }

        // 计算平方和
        var sum: Float = 0
        for value in floatBuffer {
            sum += value * value
        }

        return sqrt(sum / Float(floatBuffer.count)) / Float(Int16.max)
    }

    // MARK: - 分贝转换

    /// 将线性值转换为分贝
    /// - Parameter linear: 线性值（0.0 ~ 1.0）
    /// - Returns: 分贝值（-∞ ~ 0）
    public static func linearToDecibel(_ linear: Float) -> Float {
        guard linear > 0 else { return -80 }
        return 20 * log10(linear)
    }

    /// 将分贝转换为线性值
    /// - Parameter decibel: 分贝值
    /// - Returns: 线性值（0.0 ~ 1.0）
    public static func decibelToLinear(_ decibel: Float) -> Float {
        return pow(10, decibel / 20)
    }

    // MARK: - 平滑处理

    /// 对数值进行平滑处理（一阶低通滤波器）
    /// - Parameters:
    ///   - value: 新值
    ///   - previous: 上一个值
    ///   - smoothingFactor: 平滑因子（0.0 ~ 1.0），越小越平滑
    /// - Returns: 平滑后的值
    public static func smooth(value: Float, previous: Float, smoothingFactor: Float) -> Float {
        return previous + smoothingFactor * (value - previous)
    }

    /// 对数组进行移动平均平滑
    /// - Parameters:
    ///   - array: 输入数组
    ///   - windowSize: 窗口大小
    /// - Returns: 平滑后的数组
    public static func movingAverage(_ array: [Float], windowSize: Int) -> [Float] {
        guard windowSize > 0, windowSize <= array.count else { return array }

        var result: [Float] = []
        let halfWindow = windowSize / 2

        for i in 0..<array.count {
            var sum: Float = 0
            var count = 0

            for j in max(0, i - halfWindow)...min(array.count - 1, i + halfWindow) {
                sum += array[j]
                count += 1
            }

            result.append(sum / Float(count))
        }

        return result
    }

    // MARK: - 归一化

    /// 归一化数组到指定范围
    /// - Parameters:
    ///   - array: 输入数组
    ///   - min: 最小值
    ///   - max: 最大值
    /// - Returns: 归一化后的数组
    public static func normalize(_ array: [Float], min: Float = 0, max: Float = 1) -> [Float] {
        guard let currentMin = array.min(),
              let currentMax = array.max(),
              currentMax != currentMin else {
            return array
        }

        let range = currentMax - currentMin
        let targetRange = max - min

        return array.map { ($0 - currentMin) / range * targetRange + min }
    }

    // MARK: - 插值

    /// 线性插值
    /// - Parameters:
    ///   - from: 起始值
    ///   - to: 目标值
    ///   - t: 插值因子（0.0 ~ 1.0）
    /// - Returns: 插值结果
    public static func lerp(from: Float, to: Float, t: Float) -> Float {
        return from + (to - from) * t
    }

    /// 缓动插值（Ease In Out）
    /// - Parameter t: 插值因子（0.0 ~ 1.0）
    /// - Returns: 缓动后的值
    public static func easeInOut(_ t: Float) -> Float {
        return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t
    }

    // MARK: - 频率分析

    /// 计算频谱数据（使用 FFT）
    /// - Parameter buffer: 音频缓冲区
    /// - Returns: 频谱数据（幅度数组）
    public static func calculateSpectrum(from buffer: [Float]) -> [Float] {
        let size = buffer.count
        let fftSize = vDSP_Length(size)

        // 设置 FFT
        let log2n = vDSP_Length(log2(Double(size)))
        guard let fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2)) else {
            return []
        }

        // 准备实部和虚部
        var realParts = [Float](repeating: 0, count: size / 2)
        var imagParts = [Float](repeating: 0, count: size / 2)

        // 执行 FFT
        buffer.withUnsafeBufferPointer { bufferPtr in
            realParts.withUnsafeMutableBufferPointer { realPtr in
                imagParts.withUnsafeMutableBufferPointer { imagPtr in
                    var complex = DSPSplitComplex(
                        realp: realPtr.baseAddress!,
                        imagp: imagPtr.baseAddress!
                    )

                    // 转换 Int16 数组为 DSPComplex 数组
                    var complexBuffer = [DSPComplex](repeating: DSPComplex(real: 0, imag: 0), count: Int(fftSize / 2))
                    for i in 0..<min(Int(fftSize / 2), buffer.count) {
                        complexBuffer[i].real = Float(buffer[i])
                    }

                    complexBuffer.withUnsafeMutableBufferPointer { complexPtr in
                        guard let baseAddress = complexPtr.baseAddress else { return }
                        vDSP_ctoz(baseAddress, 2, &complex, 1, vDSP_Length(fftSize / 2))
                        vDSP_fft_zrip(fftSetup, &complex, 1, log2n, FFTDirection(FFT_FORWARD))
                        vDSP_zvmags(&complex, 1, realPtr.baseAddress!, 1, vDSP_Length(fftSize / 2))
                    }
                }
            }
        }

        vDSP_destroy_fftsetup(fftSetup)

        // 归一化
        return normalize(realParts, min: 0, max: 1)
    }

    // MARK: - 峰值检测

    /// 检测数组中的峰值
    /// - Parameters:
    ///   - array: 输入数组
    ///   - threshold: 阈值（0.0 ~ 1.0）
    /// - Returns: 峰值索引数组
    public static func detectPeaks(in array: [Float], threshold: Float = 0.5) -> [Int] {
        var peaks: [Int] = []

        for i in 1..<(array.count - 1) {
            if array[i] > threshold &&
               array[i] > array[i - 1] &&
               array[i] > array[i + 1] {
                peaks.append(i)
            }
        }

        return peaks
    }

    // MARK: - 能量计算

    /// 计算音频能量
    /// - Parameter buffer: 音频缓冲区
    /// - Returns: 能量值
    public static func calculateEnergy(from buffer: [Int16]) -> Float {
        return calculateRMS(from: buffer)
    }

    /// 计算频带能量
    /// - Parameters:
    ///   - spectrum: 频谱数据
    ///   - startIndex: 起始索引
    ///   - endIndex: 结束索引
    /// - Returns: 频带能量
    public static func calculateBandEnergy(spectrum: [Float], startIndex: Int, endIndex: Int) -> Float {
        guard startIndex >= 0, endIndex <= spectrum.count, startIndex < endIndex else {
            return 0
        }

        var sum: Float = 0
        for i in startIndex..<endIndex {
            sum += spectrum[i]
        }

        return sum / Float(endIndex - startIndex)
    }
}
