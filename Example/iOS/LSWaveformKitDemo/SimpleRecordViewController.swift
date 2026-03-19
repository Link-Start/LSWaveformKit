//
//  SimpleRecordViewController.swift
//  LSWaveformKitDemo
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import UIKit
import LSWaveformKit

class SimpleRecordViewController: UIViewController {

    // MARK: - 属性

    private lazy var waveformView: LSWaveformView = {
        let view = LSWaveformView()
        view.backgroundColor = .clear
        view.configuration.numberOfBars = 30
        view.configuration.barWidth = 3
        view.configuration.barSpacing = 8
        view.configuration.barColorMode = .single(UIColor_00CBE0())
        view.configuration.barHeightMode = .symmetric
        return view
    }()

    private lazy var recordButton: UIButton = {
        var btn = UIButton(type: .custom)
        btn.adjustsImageWhenDisabled = false
        btn.adjustsImageWhenHighlighted = false

        btn.setTitle("按住 说话", for: .normal)
        btn.setTitle("松开 发送", for: .highlighted)
        btn.setTitleColor(UIColor_FFFFFF(), for: .normal)
        btn.titleLabel?.font = PingFangSCRegular(size: 16)
        btn.backgroundColor = UIColor_2F665C()

        btn.layer.cornerRadius = 22.5
        btn.layer.masksToBounds = true

        return btn
    }()

    private lazy var tipsLabel: UILabel = {
        var lab = UILabel()
        lab.font = PingFangSCRegular(size: 14)
        lab.textColor = UIColor_D1D6D9()
        lab.text = "长按按钮开始录音，向上滑动取消"
        lab.textAlignment = .center
        return lab
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "简单录音"
        view.backgroundColor = UIColor_020120()

        addSubViews()
        addSubViewsLayout()
        addSubViewsConfig()
    }

    // MARK: - 设置

    private func addSubViews() {
        view.addSubview(waveformView)
        view.addSubview(recordButton)
        view.addSubview(tipsLabel)
    }

    private func addSubViewsLayout() {
        waveformView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.height.equalTo(60)
        }

        recordButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
            make.width.equalTo(200)
            make.height.equalTo(45)
        }

        tipsLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(recordButton.snp.top).offset(-20)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
        }
    }

    private func addSubViewsConfig() {
        // 录音开始回调
        waveformView.onRecordingStart = { [weak self] in
            guard let self = self else { return }
            self.tipsLabel.text = "正在录音..."
        }

        // 录音停止回调
        waveformView.onRecordingStop = { [weak self] url, duration in
            guard let self = self else { return }
            self.tipsLabel.text = "录音完成，时长: \(String(format: "%.1f", duration))秒"

            if let url = url {
                print("录音文件保存路径: \(url.path)")
            }
        }

        // 录音取消回调
        waveformView.onRecordingCancel = { [weak self] in
            guard let self = self else { return }
            self.tipsLabel.text = "录音已取消"
        }

        // 长按手势
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        recordButton.addGestureRecognizer(longPress)
    }

    // MARK: - 按钮事件

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            waveformView.startRecording()
            recordButton.isSelected = true
            recordButton.backgroundColor = UIColor_F21F14()

        case .changed:
            let location = gesture.location(in: view)
            let cancelAreaY = view.bounds.height - 200

            if location.y < cancelAreaY {
                waveformView.cancelRecording()
                tipsLabel.text = "松开手指取消发送"
            } else {
                tipsLabel.text = "正在录音..."
            }

        case .ended:
            waveformView.stopRecording()
            recordButton.isSelected = false
            recordButton.backgroundColor = UIColor_2F665C()

        default:
            break
        }
    }
}
