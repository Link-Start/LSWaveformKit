//
//  LSWaveformGestureHandler.swift
//  LSWaveformKit
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import UIKit

// MARK: - State Enum

/// 手势状态
public enum LSWaveformGestureHandlerState {
    /// 空闲
    case idle

    /// 录音中
    case recording

    /// 取消中（手指滑动到取消区域）
    case canceling

    /// 锁定（忽略手势）
    case locked
}

// MARK: - Gesture Configuration

/// 手势配置
public struct LSWaveformGestureConfiguration {
    /// 是否启用长按录音
    public var isLongPressEnabled: Bool = true

    /// 是否启用点击录音
    public var isTapEnabled: Bool = false

    /// 是否启用滑动取消
    public var isPanToCancelEnabled: Bool = true

    /// 滑动取消阈值（像素）
    public var cancelThreshold: CGFloat = 100

    /// 最小长按时长
    public var minimumPressDuration: TimeInterval = 0.3

    /// 允许的滑动距离
    public var allowableMovement: CGFloat = 10

    /// 取消区域（CGRect）
    public var cancelArea: CGRect = .zero

    public init() {}
}

// MARK: - Delegate Protocol

/// 手势处理器代理协议
public protocol LSWaveformGestureHandlerDelegate: AnyObject {
    /// 开始录音
    func gestureHandlerDidBeginRecording(_ handler: LSWaveformGestureHandler)

    /// 结束录音
    func gestureHandlerDidEndRecording(_ handler: LSWaveformGestureHandler)

    /// 取消录音
    func gestureHandlerDidCancelRecording(_ handler: LSWaveformGestureHandler)

    /// 即将取消（手指进入取消区域）
    func gestureHandlerWillCancelRecording(_ handler: LSWaveformGestureHandler)

    /// 取消进度更新（0.0 ~ 1.0）
    func gestureHandler(_ handler: LSWaveformGestureHandler, updateCancelProgress progress: CGFloat)
}

// MARK: - Gesture Handler Class

/// 波形手势处理器 - 管理录音相关的所有手势操作
public class LSWaveformGestureHandler: NSObject {

    // MARK: - Properties

    /// 代理
    public weak var delegate: LSWaveformGestureHandlerDelegate?

    /// 当前状态
    public private(set) var state: LSWaveformGestureHandlerState = .idle

    /// 手势配置
    public var configuration = LSWaveformGestureConfiguration()

    /// 关联的视图
    public weak var attachedView: UIView?

    // 手势识别器
    private var longPressGesture: UILongPressGestureRecognizer?
    private var tapGesture: UITapGestureRecognizer?
    private var panGesture: UIPanGestureRecognizer?

    // 初始触摸位置
    private var initialTouchLocation: CGPoint = .zero

    // MARK: - Initialization

    public init(view: UIView? = nil) {
        super.init()
        attach(to: view)
    }

    deinit {
        detach()
    }

    // MARK: - Attach/Detach

    /// 附加手势到视图
    /// - Parameter view: 目标视图
    public func attach(to view: UIView?) {
        detach()

        guard let view = view else { return }

        attachedView = view

        if configuration.isLongPressEnabled {
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPress.minimumPressDuration = configuration.minimumPressDuration
            longPress.allowableMovement = configuration.allowableMovement
            view.addGestureRecognizer(longPress)
            longPressGesture = longPress
        }

        if configuration.isTapEnabled {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            view.addGestureRecognizer(tap)
            tapGesture = tap
        }

        if configuration.isPanToCancelEnabled {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            view.addGestureRecognizer(pan)
            panGesture = pan
        }
    }

    /// 分离手势
    public func detach() {
        if let longPress = longPressGesture {
            longPress.view?.removeGestureRecognizer(longPress)
        }
        if let tap = tapGesture {
            tap.view?.removeGestureRecognizer(tap)
        }
        if let pan = panGesture {
            pan.view?.removeGestureRecognizer(pan)
        }

        longPressGesture = nil
        tapGesture = nil
        panGesture = nil
        attachedView = nil
        delegate = nil  // 清理代理引用
    }

    // MARK: - Gesture Handlers

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            state = .recording
            initialTouchLocation = gesture.location(in: gesture.view)
            delegate?.gestureHandlerDidBeginRecording(self)

        case .changed:
            handleGestureMove(gesture)

        case .ended:
            if state == .canceling {
                delegate?.gestureHandlerDidCancelRecording(self)
            } else {
                delegate?.gestureHandlerDidEndRecording(self)
            }
            state = .idle

        case .cancelled:
            state = .idle
            delegate?.gestureHandlerDidCancelRecording(self)

        default:
            break
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        switch state {
        case .idle:
            state = .recording
            delegate?.gestureHandlerDidBeginRecording(self)

        case .recording:
            state = .idle
            delegate?.gestureHandlerDidEndRecording(self)

        default:
            break
        }
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard state == .recording else { return }

        let location = gesture.location(in: gesture.view)
        let translation = gesture.translation(in: gesture.view)

        if configuration.isPanToCancelEnabled {
            // 检查是否在取消区域
            let isInCancelArea = isInCancelArea(location)

            if isInCancelArea && state != .canceling {
                state = .canceling
                delegate?.gestureHandlerWillCancelRecording(self)
            } else if !isInCancelArea && state == .canceling {
                state = .recording
            }

            // 计算取消进度
            let progress = cancelProgress(for: location)
            delegate?.gestureHandler(self, updateCancelProgress: progress)
        }
    }

    // MARK: - Helper Methods

    private func handleGestureMove(_ gesture: UILongPressGestureRecognizer) {
        guard configuration.isPanToCancelEnabled else { return }

        let location = gesture.location(in: gesture.view)

        if isInCancelArea(location) {
            if state != .canceling {
                state = .canceling
                delegate?.gestureHandlerWillCancelRecording(self)
            }
        } else {
            if state == .canceling {
                state = .recording
            }
        }

        // 计算取消进度
        let progress = cancelProgress(for: location)
        delegate?.gestureHandler(self, updateCancelProgress: progress)
    }

    private func isInCancelArea(_ location: CGPoint) -> Bool {
        // 使用自定义取消区域
        if !configuration.cancelArea.equalTo(.zero) {
            return configuration.cancelArea.contains(location)
        }

        // 默认：向上滑动超过阈值即为取消区域
        guard let view = attachedView else { return false }
        let cancelY = view.bounds.height - configuration.cancelThreshold
        return location.y < cancelY
    }

    private func cancelProgress(for location: CGPoint) -> CGFloat {
        guard let view = attachedView else { return 0 }

        let cancelY = view.bounds.height - configuration.cancelThreshold
        let progress = 1.0 - (location.y / cancelY)

        return max(0, min(1, progress))
    }

    // MARK: - Public Methods

    /// 锁定手势（忽略所有手势输入）
    public func lock() {
        state = .locked
    }

    /// 解锁手势
    public func unlock() {
        state = .idle
    }

    /// 重置手势
    public func reset() {
        state = .idle
        initialTouchLocation = .zero
    }
}
