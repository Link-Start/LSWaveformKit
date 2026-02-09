Pod::Spec.new do |s|
  s.name             = 'LSWaveformKit'
  s.version          = '1.0.0'
  s.summary          = '一个功能强大、高度可定制的音频波形可视化框架，专为 iOS 应用设计'
  s.description      = <<-DESC
LSWaveformKit 是一个功能强大、高度可定制的音频波形可视化框架，专为 iOS 应用设计。

主要特性：
- 支持 7 种波形布局模式（对称、左右、锚点、水平、圆形、弧形等）
- 15+ 精美的预设风格，开箱即用
- 完全自定义的条纹颜色、间距、圆角、阴影等属性
- 流畅的波形动画效果
- 支持点击、滑动、长停等手势交互
- 内置音频录制和播放功能
- 支持从音频文件生成静态波形图像
- 基于 Accelerate 框架优化，性能卓越

适用于音乐播放器、录音应用、语音助手、播客应用等场景。
                   DESC

  s.homepage         = 'https://github.com/Link-Start/LSWaveformKit'
  s.screenshots     = 'https://github.com/Link-Start/LSWaveformKit/blob/main/Assets/Demo.png'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Link' => 'github@link-start.dev' }
  s.source           = { :git => 'https://github.com/Link-Start/LSWaveformKit.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '13.0'
  s.swift_version = '6.0'
  
  s.source_files = 'Sources/**/*.swift'
  s.frameworks = 'UIKit', 'Foundation', 'AVFoundation', 'Accelerate'
  
  s.subspec 'Core' do |sp|
    sp.source_files = 'Sources/Core/**/*.swift'
  end
  
  s.subspec 'UIKit' do |sp|
    sp.source_files = 'Sources/UIKit/**/*.swift'
    sp.dependency 'LSWaveformKit/Core'
  end
  
  s.subspec 'Presets' do |sp|
    sp.source_files = 'Sources/Presets/**/*.swift'
    sp.dependency 'LSWaveformKit/UIKit'
  end
  
  s.default_subspecs = 'Core', 'UIKit', 'Presets'
end
