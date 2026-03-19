//
//  ContentView.swift
//  LSWaveformKitSwiftUIDemo
//
//  Created by Link on 2024/01/XX.
//  Copyright © 2024 Link. All rights reserved.
//

import SwiftUI
import LSWaveformKit

struct ContentView: View {
    // MARK: - 属性

    @State private var selectedTab = 0
    @State private var isRecording = false

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedTab) {
            BasicExamplesView()
                .tabItem {
                    Label("基础", systemImage: "waveform.path")
                }
                .tag(0)

            AdvancedExamplesView()
                .tabItem {
                    Label("高级", systemImage: "slider.horizontal.3")
                }
                .tag(1)

            MusicPlayerStylesView()
                .tabItem {
                    Label("音乐风格", systemImage: "music.note")
                }
                .tag(2)

            AboutView()
                .tabItem {
                    Label("关于", systemImage: "info.circle")
                }
                .tag(3)
        }
        .accentColor(Color(hex: "00CBE0"))
    }
}

// MARK: - 基础示例视图

struct BasicExamplesView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("录音功能")) {
                    NavigationLink("简单录音", destination: SimpleRecordView())
                    NavigationLink("长按录音", destination: LongPressRecordView())
                }

                Section(header: Text("播放功能")) {
                    NavigationLink("音频播放", destination: AudioPlayView())
                }

                Section(header: Text("波形类型")) {
                    NavigationLink("对称波形", destination: SymmetricWaveformView())
                    NavigationLink("水平波形", destination: HorizontalWaveformView())
                    NavigationLink("圆形波形", destination: CircularWaveformView())
                }
            }
            .navigationTitle("基础示例")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

// MARK: - 高级示例视图

struct AdvancedExamplesView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("配置选项")) {
                    NavigationLink("自定义配置", destination: CustomConfigView())
                    NavigationLink("颜色模式", destination: ColorModesView())
                    NavigationLink("高度模式", destination: HeightModesView())
                    NavigationLink("间距模式", destination: SpacingModesView())
                }

                Section(header: Text("高级功能")) {
                    NavigationLink("多个波形", destination: MultipleWaveformsView())
                    NavigationLink("手势交互", destination: GestureInteractionView())
                }
            }
            .navigationTitle("高级示例")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

// MARK: - 音乐播放器风格视图

struct MusicPlayerStylesView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("国内音乐播放器")) {
                    NavigationLink("酷狗音乐", destination: MusicPlayerStyleView(style: .kugou))
                    NavigationLink("QQ音乐", destination: MusicPlayerStyleView(style: .qqmusic))
                    NavigationLink("酷我音乐", destination: MusicPlayerStyleView(style: .kuwo))
                    NavigationLink("落雪", destination: MusicPlayerStyleView(style: .luoxue))
                    NavigationLink("网易云音乐", destination: MusicPlayerStyleView(style: .netease))
                    NavigationLink("虾米音乐", destination: MusicPlayerStyleView(style: .xiami))
                }

                Section(header: Text("国际音乐播放器")) {
                    NavigationLink("Apple Music", destination: MusicPlayerStyleView(style: .applemusic))
                    NavigationLink("Spotify", destination: MusicPlayerStyleView(style: .spotify))
                    NavigationLink("YouTube Music", destination: MusicPlayerStyleView(style: .youtubemusic))
                }

                Section(header: Text("特效风格")) {
                    NavigationLink("霓虹", destination: MusicPlayerStyleView(style: .neon))
                    NavigationLink("极简", destination: MusicPlayerStyleView(style: .minimal))
                    NavigationLink("复古", destination: MusicPlayerStyleView(style: .retro))
                    NavigationLink("玻璃拟态", destination: MusicPlayerStyleView(style: .glassmorphism))
                }
            }
            .navigationTitle("音乐风格")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

// MARK: - 简单录音视图 (SwiftUI)

struct SimpleRecordView: View {
    @StateObject private var waveformViewModel = WaveformViewModel()

    var body: some View {
        VStack(spacing: 30) {
            Text("简单录音")
                .font(.title)
                .foregroundColor(.white)

            WaveformViewRepresentable(waveformViewModel: waveformViewModel)
                .frame(height: 100)

            Button(action: {
                if waveformViewModel.isRecording {
                    waveformViewModel.stopRecording()
                } else {
                    waveformViewModel.startRecording()
                }
            }) {
                Text(waveformViewModel.isRecording ? "停止录音" : "开始录音")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(waveformViewModel.isRecording ? Color.red : Color.blue)
                    .cornerRadius(25)
            }

            if let duration = waveformViewModel.recordingDuration {
                Text("录音时长: \(String(format: "%.1f", duration))秒")
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(hex: "020120"))
        .navigationBarHidden(true)
    }
}

// MARK: - 关于视图

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform.path")
                .font(.system(size: 80))
                .foregroundColor(Color(hex: "00CBE0"))

            Text("LSWaveformKit")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("功能丰富的 iOS 音频波形可视化库")
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 10) {
                FeatureRow(icon: "paintbrush", title: "多样化波形风格", description: "12+ 高度模式，10+ 颜色模式")
                FeatureRow(icon: "music.note", title: "音乐播放器特效", description: "歌词同步、节拍检测、频谱分析")
                FeatureRow(icon: "hand.tap", title: "手势交互", description: "长按录音、滑动取消")
                FeatureRow(icon: "square.stack.3d.up", title: "多平台支持", description: "UIKit、SwiftUI、Objective-C")
            }
            .padding()

            Spacer()

            Text("Version 1.0.0")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .background(Color(hex: "020120"))
        .navigationTitle("关于")
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(Color(hex: "00CBE0"))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)

                Text(description)
                    .foregroundColor(.gray)
                    .font(.caption)
            }

            Spacer()
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
