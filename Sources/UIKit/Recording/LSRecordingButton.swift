//
//  LSRecordingButton.swift
//  LSWaveformKit
//
//  Created by Link on 2025-02-07.
//

import UIKit

/// 录音按钮状态
public enum LSRecordingButtonState {
    /// 空闲
    case idle
    /// 录音中
    case recording
    /// 即将取消
    case canceling
    /// 已锁定
    case locked
}

// MARK: - LSRecordingButton

/// 录音按钮 - 支持状态管理和动画效果
public class LSRecordingButton: UIButton {

    // MARK: - 属性

    /// 当前状态
    public private(set) var currentState: LSRecordingButtonState = .idle {
        didSet {
            updateAppearance()
        }
    }

    /// 空闲状态图标
    public var idleIcon: UIImage? {
        didSet {
            if currentState == .idle {
                setImage(idleIcon, for: .normal)
            }
        }
    }

    /// 录音状态图标
    public var recordingIcon: UIImage? {
        didSet {
            if currentState == .recording {
                setImage(recordingIcon, for: .normal)
            }
        }
    }

    /// 取消状态图标
    public var cancelingIcon: UIImage? {
        didSet {
            if currentState == .canceling {
                setImage(cancelingIcon, for: .normal)
            }
        }
    }

    /// 锁定状态图标
    public var lockedIcon: UIImage? {
        didSet {
            if currentState == .locked {
                setImage(lockedIcon, for: .normal)
            }
        }
    }

    /// 空闲状态背景色
    public var idleBackgroundColor: UIColor = UIColor_00CBE0()

    /// 录音状态背景色
    public var recordingBackgroundColor: UIColor = UIColor_FF3B30()

    /// 取消状态背景色
    public var cancelingBackgroundColor: UIColor = UIColor_FF9500()

    /// 锁定状态背景色
    public var lockedBackgroundColor: UIColor = UIColor_007AFF()

    /// 是否启用脉冲动画
    public var isPulseAnimationEnabled: Bool = true

    /// 脉冲动画视图
    private lazy var pulseView: UIView = {
        let v = UIView()
        v.backgroundColor = recordingBackgroundColor.withAlphaComponent(0.3)
        v.layer.cornerRadius = bounds.width / 2
        v.alpha = 0
        return v
    }()

    /// 取消进度 (0.0 ~ 1.0)
    public var cancelProgress: CGFloat = 0 {
        didSet {
            updateCancelProgress()
        }
    }

    // MARK: - 回调

    /// 状态变化回调
    public var onStateChange: ((LSRecordingButtonState) -> Void)?

    // MARK: - 初始化

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    deinit {
        // 停止所有动画
        stopPulseAnimation()

        // 移除 pulseView
        pulseView.removeFromSuperview()

        // 清理回调闭包
        onStateChange = nil
    }

    // MARK: - 设置

    private func setup() {
        adjustsImageWhenDisabled = false
        adjustsImageWhenHighlighted = false

        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        layer.masksToBounds = true

        backgroundColor = idleBackgroundColor
        imageView?.contentMode = .scaleAspectFit

        // 添加脉冲视图
        addSubview(pulseView)
        pulseView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pulseView.centerXAnchor.constraint(equalTo: centerXAnchor),
            pulseView.centerYAnchor.constraint(equalTo: centerYAnchor),
            pulseView.widthAnchor.constraint(equalTo: widthAnchor),
            pulseView.heightAnchor.constraint(equalTo: heightAnchor)
        ])

        updateAppearance()
    }

    // MARK: - 布局

    public override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = min(bounds.width, bounds.height) / 2
        pulseView.layer.cornerRadius = pulseView.bounds.width / 2
    }

    // MARK: - 公开方法

    /// 切换到指定状态
    /// - Parameter state: 目标状态
    public func transition(to state: LSRecordingButtonState) {
        let oldState = currentState
        currentState = state

        UIView.animate(withDuration: 0.2, animations: {
            self.updateAppearance()
        }) { _ in
            if state == .recording && oldState != .recording {
                self.startPulseAnimation()
            } else if oldState == .recording && state != .recording {
                self.stopPulseAnimation()
            }
        }

        onStateChange?(state)
    }

    /// 更新取消进度
    private func updateCancelProgress() {
        if currentState == .canceling {
            let scale = 1.0 + cancelProgress * 0.3
            transform = CGAffineTransform(scaleX: scale, y: scale)
            alpha = 1.0 - cancelProgress * 0.5
        } else {
            transform = .identity
            alpha = 1.0
        }
    }

    // MARK: - 私有方法

    private func updateAppearance() {
        switch currentState {
        case .idle:
            backgroundColor = idleBackgroundColor
            setImage(idleIcon, for: .normal)
            alpha = 1.0
            transform = .identity

        case .recording:
            backgroundColor = recordingBackgroundColor
            setImage(recordingIcon, for: .normal)
            alpha = 1.0
            transform = .identity

        case .canceling:
            backgroundColor = cancelingBackgroundColor
            setImage(cancelingIcon, for: .normal)
            updateCancelProgress()

        case .locked:
            backgroundColor = lockedBackgroundColor
            setImage(lockedIcon, for: .normal)
            alpha = 1.0
            transform = .identity
        }
    }

    // MARK: - 脉冲动画

    private func startPulseAnimation() {
        guard isPulseAnimationEnabled else { return }

        pulseView.alpha = 0
        pulseView.transform = .identity

        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.pulseView.alpha = 1
            let scale: CGFloat = 1.5
            self.pulseView.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
    }

    private func stopPulseAnimation() {
        pulseView.layer.removeAllAnimations()

        UIView.animate(withDuration: 0.2) {
            self.pulseView.alpha = 0
            self.pulseView.transform = .identity
        }
    }
}

// MARK: - Convenience Extensions

extension LSRecordingButton {

    /// 快速配置默认图标
    public func setDefaultIcons() {
        idleIcon = UIImage(systemName: "mic.fill")
        recordingIcon = UIImage(systemName: "stop.fill")
        cancelingIcon = UIImage(systemName: "trash.fill")
        lockedIcon = UIImage(systemName: "lock.fill")

        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .medium)
        idleIcon = idleIcon?.withConfiguration(config)
        recordingIcon = recordingIcon?.withConfiguration(config)
        cancelingIcon = cancelingIcon?.withConfiguration(config)
        lockedIcon = lockedIcon?.withConfiguration(config)

        tintColor = UIColor_FFFFFF()
        updateAppearance()
    }
}
