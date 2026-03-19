//
//  MainViewController.swift
//  LSWaveformKitDemo
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    // MARK: - 属性

    private lazy var tableView: UITableView = {
        let tb = UITableView(frame: .zero, style: .grouped)
        tb.backgroundColor = UIColor_020120()
        tb.delegate = self
        tb.dataSource = self
        tb.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        return tb
    }()

    private lazy var dataSource: [DemoSection] = [
        DemoSection(title: "基础示例", items: [
            DemoItem(title: "简单录音", description: "最基础的录音功能", action: .simpleRecord),
            DemoItem(title: "音频播放", description: "播放音频并显示波形", action: .audioPlay),
            DemoItem(title: "波形可视化", description: "实时显示音频波形", action: .waveformVisual),
        ]),

        DemoSection(title: "高级示例", items: [
            DemoItem(title: "自定义配置", description: "完全自定义波形配置", action: .customConfig),
            DemoItem(title: "多种颜色模式", description: "展示所有颜色模式", action: .colorModes),
            DemoItem(title: "多种高度模式", description: "展示所有高度模式", action: .heightModes),
            DemoItem(title: "自定义间距", description: "自定义条纹间距", action: .customSpacing),
            DemoItem(title: "多个波形实例", description: "同时显示多个波形", action: .multipleWaveforms),
        ]),

        DemoSection(title: "音乐播放器风格", items: [
            DemoItem(title: "酷狗音乐", description: "彩色频谱光柱，7色彩虹", action: .kugou),
            DemoItem(title: "QQ音乐", description: "多彩渐变，发光阴影", action: .qqmusic),
            DemoItem(title: "酷我音乐", description: "炫彩渐变，律动光柱", action: .kuwo),
            DemoItem(title: "落雪", description: "柔和渐变，雪花飘落", action: .luoxue),
            DemoItem(title: "网易云音乐", description: "红色主题，优雅曲线", action: .netease),
            DemoItem(title: "Apple Music", description: "红色高光，弹跳动画", action: .applemusic),
            DemoItem(title: "Spotify", description: "绿色渐变，简洁现代", action: .spotify),
        ]),

        DemoSection(title: "音乐特效", items: [
            DemoItem(title: "歌词同步", description: "LRC 格式歌词同步波形", action: .lyricsSync),
            DemoItem(title: "节拍检测", description: "实时 BPM 检测与同步", action: .beatDetection),
            DemoItem(title: "频谱分析", description: "FFT 频谱分析可视化", action: .spectrumAnalysis),
        ]),
    ]

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "LSWaveformKit Demo"
        view.backgroundColor = UIColor_020120()

        addSubViews()
        addSubViewsLayout()
    }

    // MARK: - 设置

    private func addSubViews() {
        view.addSubview(tableView)
    }

    private func addSubViewsLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - 导航

    private func showDemo(_ action: DemoAction) {
        let viewController: UIViewController

        switch action {
        case .simpleRecord:
            viewController = SimpleRecordViewController()
        case .audioPlay:
            viewController = AudioPlayViewController()
        case .waveformVisual:
            viewController = WaveformVisualViewController()
        case .customConfig:
            viewController = CustomConfigViewController()
        case .colorModes:
            viewController = ColorModesViewController()
        case .heightModes:
            viewController = HeightModesViewController()
        case .customSpacing:
            viewController = CustomSpacingViewController()
        case .multipleWaveforms:
            viewController = MultipleWaveformsViewController()
        case .kugou:
            viewController = MusicPlayerStyleViewController(style: .kugou)
        case .qqmusic:
            viewController = MusicPlayerStyleViewController(style: .qqmusic)
        case .kuwo:
            viewController = MusicPlayerStyleViewController(style: .kuwo)
        case .luoxue:
            viewController = MusicPlayerStyleViewController(style: .luoxue)
        case .netease:
            viewController = MusicPlayerStyleViewController(style: .netease)
        case .applemusic:
            viewController = MusicPlayerStyleViewController(style: .applemusic)
        case .spotify:
            viewController = MusicPlayerStyleViewController(style: .spotify)
        case .lyricsSync:
            viewController = LyricsSyncViewController()
        case .beatDetection:
            viewController = BeatDetectionViewController()
        case .spectrumAnalysis:
            viewController = SpectrumAnalysisViewController()
        }

        viewController.title = dataSource.compactMap { section in
            section.items.first { $0.action == action }?.title
        }.first ?? "Demo"

        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = dataSource[indexPath.section].items[indexPath.row]

        cell.backgroundColor = UIColor_2C2C2C()
        cell.textLabel?.textColor = UIColor_FFFFFF()
        cell.textLabel?.font = PingFangSCRegular(size: 14)
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.textColor = UIColor_D1D6D9()
        cell.detailTextLabel?.font = PingFangSCRegular(size: 12)
        cell.detailTextLabel?.text = item.description
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource[section].title
    }
}

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = dataSource[indexPath.section].items[indexPath.row]
        showDemo(item.action)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - 数据模型

struct DemoSection {
    let title: String
    let items: [DemoItem]
}

struct DemoItem {
    let title: String
    let description: String
    let action: DemoAction
}

enum DemoAction {
    case simpleRecord
    case audioPlay
    case waveformVisual
    case customConfig
    case colorModes
    case heightModes
    case customSpacing
    case multipleWaveforms
    case kugou
    case qqmusic
    case kuwo
    case luoxue
    case netease
    case applemusic
    case spotify
    case lyricsSync
    case beatDetection
    case spectrumAnalysis
}
