//
//  LSWaveformAnimator.swift
//  LSWaveformKit
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import Foundation
import UIKit

/// 波形动画器 - 负责条纹动画效果
public class LSWaveformAnimator {

    // MARK: - Properties

    /// 关联的视图
    public weak var waveformView: UIView?

    /// 动画时长
    public var duration: TimeInterval = 0.2

    /// 动画曲线
    public var animationCurve: UIView.AnimationCurve = .easeOut

    /// 是否正在动画
    public private(set) var isAnimating = false

    /// 动画选项
    private var animationOptions: UIView.AnimationOptions {
        switch animationCurve {
        case .easeIn:
            return .curveEaseIn
        case .easeOut:
            return .curveEaseOut
        case .easeInOut:
            return .curveEaseInOut
        case .linear:
            return .curveLinear
        @unknown default:
            return .curveEaseOut
        }
    }

    // MARK: - Initialization

    public init(waveformView: UIView? = nil) {
        self.waveformView = waveformView
    }

    deinit {
        // 清理引用
        waveformView = nil
    }

    // MARK: - Animation Methods

    /// 动画更新条纹高度
    /// - Parameters:
    ///   - bars: 条纹数组
    ///   - heights: 目标高度数组
    ///   - completion: 完成回调
    public func animateBars(_ bars: [UIView], toHeights heights: [CGFloat], completion: (() -> Void)? = nil) {
        guard bars.count == heights.count else { return }

        isAnimating = true

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: animationOptions,
            animations: { [weak self] in
                guard let self = self else { return }

                for (index, bar) in bars.enumerated() {
                    let targetHeight = heights[index]

                    // 优先使用 LSWaveformBar 保存的约束引用
                    if let waveformBar = bar as? LSWaveformBar {
                        waveformBar.currentHeight = targetHeight
                    } else {
                        // 如果不是 LSWaveformBar，使用 remakeConstraints（安全但稍慢）
                        bar.snp.remakeConstraints { make in
                            make.height.equalTo(targetHeight)
                        }
                    }
                }

                self.waveformView?.layoutIfNeeded()

            }, completion: { [weak self] finished in
                self?.isAnimating = false
                completion?()
            })
    }

    /// 动画更新单个条纹
    /// - Parameters:
    ///   - bar: 条纹视图
    ///   - height: 目标高度
    ///   - delay: 延迟时间
    ///   - completion: 完成回调
    public func animateBar(_ bar: UIView, toHeight height: CGFloat, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        isAnimating = true

        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: animationOptions,
            animations: { [weak self] in
                guard let self = self else { return }
                // 优先使用 LSWaveformBar 保存的约束引用
                if let waveformBar = bar as? LSWaveformBar {
                    waveformBar.currentHeight = height
                } else {
                    // 如果不是 LSWaveformBar，使用 remakeConstraints
                    bar.snp.remakeConstraints { make in
                        make.height.equalTo(height)
                    }
                }
                self.waveformView?.layoutIfNeeded()
            },
            completion: { [weak self] finished in
                self?.isAnimating = false
                completion?()
            })
    }

    /// 波浪动画（依次动画）
    /// - Parameters:
    ///   - bars: 条纹数组
    ///   - heights: 目标高度数组
    ///   - waveDelay: 波浪延迟
    ///   - completion: 完成回调
    public func animateBarsWithWave(_ bars: [UIView], toHeights heights: [CGFloat], waveDelay: TimeInterval = 0.01, completion: (() -> Void)? = nil) {
        guard bars.count == heights.count else { return }

        isAnimating = true

        // 为每个条纹创建延迟动画
        let group = DispatchGroup()

        for (index, bar) in bars.enumerated() {
            group.enter()

            let delay = TimeInterval(index) * waveDelay

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self else {
                    group.leave()
                    return
                }

                UIView.animate(
                    withDuration: self.duration,
                    delay: 0,
                    options: self.animationOptions,
                    animations: {
                        // 优先使用 LSWaveformBar 保存的约束引用
                        if let waveformBar = bar as? LSWaveformBar {
                            waveformBar.currentHeight = heights[index]
                        } else {
                            // 如果不是 LSWaveformBar，使用 remakeConstraints
                            bar.snp.remakeConstraints { make in
                                make.height.equalTo(heights[index])
                            }
                        }
                        self.waveformView?.layoutIfNeeded()
                    },
                    completion: { _ in
                        group.leave()
                    })
            }
        }

        // 所有动画完成后的回调
        group.notify(queue: .main) { [weak self] in
            self?.isAnimating = false
            completion?()
        }
    }

    /// 弹跳动画
    /// - Parameters:
    ///   - bar: 条纹视图
    ///   - height: 目标高度
    ///   - completion: 完成回调
    public func animateBarWithBounce(_ bar: UIView, toHeight height: CGFloat, completion: (() -> Void)? = nil) {
        isAnimating = true

        // 使用弹簧动画
        UIView.animate(
            withDuration: duration * 1.5,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 0.8,
            options: animationOptions,
            animations: { [weak self] in
                guard let self = self else { return }
                // 优先使用 LSWaveformBar 保存的约束引用
                if let waveformBar = bar as? LSWaveformBar {
                    waveformBar.currentHeight = height
                } else {
                    // 如果不是 LSWaveformBar，使用 remakeConstraints
                    bar.snp.remakeConstraints { make in
                        make.height.equalTo(height)
                    }
                }
                self.waveformView?.layoutIfNeeded()
            },
            completion: { [weak self] finished in
                self?.isAnimating = false
                completion?()
            })
    }

    /// 脉冲动画（缩放效果）
    /// - Parameters:
    ///   - bar: 条纹视图
    ///   - scale: 缩放比例
    ///   - completion: 完成回调
    public func animateBarWithPulse(_ bar: UIView, scale: CGFloat = 1.2, completion: (() -> Void)? = nil) {
        isAnimating = true

        UIView.animate(
            withDuration: duration / 2,
            delay: 0,
            options: animationOptions,
            animations: {
                bar.transform = CGAffineTransform(scaleX: scale, y: scale)
            },
            completion: { [weak self] _ in
                guard let self = self else { return }
                UIView.animate(
                    withDuration: self.duration / 2,
                    delay: 0,
                    options: self.animationOptions,
                    animations: {
                        bar.transform = .identity
                    },
                    completion: { [weak self] finished in
                        self?.isAnimating = false
                        completion?()
                    })
            })
    }

    /// 震动动画
    /// - Parameters:
    ///   - bar: 条纹视图
    ///   - offset: 震动偏移量
    ///   - completion: 完成回调
    public func animateBarWithShake(_ bar: UIView, offset: CGFloat = 3, completion: (() -> Void)? = nil) {
        isAnimating = true

        let shakeAnimation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        shakeAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
        shakeAnimation.duration = duration
        shakeAnimation.values = [-offset, offset, -offset, offset, -offset, 0]
        shakeAnimation.isAdditive = true

        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.isAnimating = false
            completion?()
        }
        bar.layer.add(shakeAnimation, forKey: "shake")
        CATransaction.commit()
    }

    /// 发光动画
    /// - Parameters:
    ///   - bar: 条纹视图
    ///   - color: 发光颜色
    ///   - completion: 完成回调
    public func animateBarWithGlow(_ bar: UIView, color: UIColor, completion: (() -> Void)? = nil) {
        isAnimating = true

        let glowAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        glowAnimation.fromValue = 0
        glowAnimation.toValue = 1
        glowAnimation.duration = duration / 2
        glowAnimation.autoreverses = true
        glowAnimation.repeatCount = 1

        // 设置阴影
        bar.layer.shadowColor = color.cgColor
        bar.layer.shadowOffset = .zero
        bar.layer.shadowRadius = 10

        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            bar.layer.shadowOpacity = 0
            self?.isAnimating = false
            completion?()
        }
        bar.layer.add(glowAnimation, forKey: "glow")
        CATransaction.commit()
    }

    // MARK: - Stop Animation

    /// 停止所有动画
    /// nonisolated(unsafe): 此方法执行同步的线程安全操作，可从任何线程调用
    public nonisolated(unsafe) func stopAllAnimations() {
        waveformView?.layer.removeAllAnimations()
        for subview in waveformView?.subviews ?? [] {
            subview.layer.removeAllAnimations()
        }
        isAnimating = false
    }
}
