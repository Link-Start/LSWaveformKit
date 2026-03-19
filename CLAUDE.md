# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

LSWaveformKit 是一个功能丰富的 iOS 音频波形可视化库，支持 UIKit 和 SwiftUI，提供多种预设风格和高度可配置的波形显示。项目采用 Swift Package Manager 构建。

## 构建和测试

### Swift Package Manager

```bash
# 构建库
swift build

# 运行测试（目前 Tests 目录为空，测试需要先创建）
swift test

# 在 Xcode 中打开项目
open Package.swift
```

### 运行示例项目

```bash
# iOS UIKit 示例（需要手动打开 Xcode 项目）
open Example/iOS/LSWaveformKitDemo.xcworkspace

# SwiftUI 示例
open Example/SwiftUI/LSWaveformKitSwiftUIDemo.xcworkspace
```

### 使用 CocoaPods（如果有 podspec）

```bash
pod install
```

## 核心架构

### 分层设计

代码库采用分层架构，核心逻辑与平台特定代码分离：

1. **Core 层** (`Sources/Core/`) - 所有平台共享的核心逻辑
   - `Audio/` - 音频处理（录音、播放、分析）
   - `Mathematics/` - 数学计算（波形计算、分贝转换）
   - `Animation/` - 动画系统
   - `Gesture/` - 手势识别
   - `Configuration/` - 配置枚举和协议
   - `Models/` - 数据模型

2. **UIKit 层** (`Sources/UIKit/`) - UIKit 特定实现
   - `Views/` - 波形视图
   - `Recording/` - 录音相关组件
   - `Utils/` - 渲染和辅助工具

3. **Presets 层** (`Sources/Presets/`) - 预设配置

### 核心配置系统

配置通过多个枚举类型实现：

- **LSBarHeightMode** - 12+ 种条纹高度模式（对称、随机、升序、降序等）
- **LSLayoutMode** - 7 种布局模式（对称、左右、水平、圆形、弧形、螺旋、网格）
- **LSBarColorMode** - 10+ 种颜色模式（单色、多色、渐变、基于音量、彩虹等）
- **LSSpacingMode** - 7 种间距模式（等间距、不等间距、渐变、自定义等）
- **LSWaveformStyle** - 15+ 种预设风格（QQ、微信、Spotify、Apple Music 等）

配置通过 `LSWaveformConfiguration` 协议和 `LSDefaultWaveformConfiguration` 实现类管理。

### 关键类关系

```
LSWaveformView (UIKit 视图)
├── LSWaveformAudioProcessor (音频处理)
├── LSWaveformGestureHandler (手势处理)
├── LSWaveformAnimator (动画)
└── [LSWaveformBar] (条纹视图数组)
```

### 音频处理流程

1. `LSWaveformAudioProcessor` 使用 AVAudioRecorder 进行录音
2. 通过 `updateMeters()` 获取音频功率（dB）
3. 使用 `normalizePower()` 将 dB 转换为 0.0-1.0 幅值
4. 通过代理回调传递给 `LSWaveformView`
5. `LSWaveformView` 根据 `barHeightMode` 更新条纹高度

### 锚点布局模式

`symmetricWithAnchor` 布局模式支持波形分布在锚点视图两侧：
- 使用 `placeholderView` 占据锚点位置
- 左侧波形在 `leftContainerView`，右侧在 `rightContainerView`
- 调用 `updateLayoutForAnchorLabel()` 当锚点内容变化时更新布局

## 常用开发任务

### 添加新的高度模式

1. 在 `LSBarHeightMode.swift` 中添加新的 case
2. 实现 `heightRatio(for:totalCount:)` 方法
3. 在 `LSWaveformView.calculateBarHeights()` 中添加处理分支（如需要）

### 添加新的预设风格

1. 在 `LSWaveformStyle.swift` 中添加枚举值
2. 在 `LSWaveformStylePresets.swift` 中实现静态方法
3. 在 `applyStyle(_:to:)` switch 中添加 case

### Swift 6 并发安全注意事项

使用 `swift6-concurrency-guide` skill 确保并发安全：
- 单例模式（如 `LSAudioSession.shared`）需要标记为 `@MainActor` 或使用 `nonisolated(unsafe)`
- 管理器类需要正确处理 Sendable
- AVFoundation 相关代码需要考虑线程安全

### 颜色扩展

项目使用自定义颜色扩展（如 `UIColor_00CBE0()`），定义在 `UIColor+LSWaveformKit.swift` 中。

## 约定和规范

1. **命名约定**：
   - 公开类使用 `LS` 前缀
   - 协议使用描述性名称，不以 `Protocol` 结尾
   - 枚举 case 使用小写开头

2. **代码组织**：
   - 使用 `// MARK:` 分组代码
   - 代理模式用于组件间通信
   - 闭包回调作为代理的补充

3. **权限配置**：
   - 需要在 `Info.plist` 中添加 `NSMicrophoneUsageDescription`

## 依赖系统框架

- AVFoundation - 音频录制和播放
- CoreAudio - 底层音频处理
- Accelerate - 数学运算加速
- Metal - GPU 渲染（可选）
- CoreHaptics - 触觉反馈（可选）

## 重要提示

- 项目当前使用 SnapKit 进行布局约束（代码中有 `.snp.` 调用），但 Package.swift 中未声明依赖
- 测试目录目前为空，需要添加测试覆盖
- SwiftUI 实现可能不完整，主要实现集中在 UIKit

## SnapKit 约束更新规则（关键）

**`snp.updateConstraints` 只能更新之前设置过的约束，否则会崩溃！**

正确用法示例：
```swift
// ✅ 正确：先设置，后更新
view.snp.makeConstraints { make in
    make.width.equalTo(60)
}

// 后续可以安全更新
view.snp.updateConstraints { make in
    make.width.equalTo(100)
}
```

错误用法示例：
```swift
// ❌ 错误：没有先设置就直接 update 会崩溃
view.snp.updateConstraints { make in
    make.width.equalTo(100)  // 崩溃！
}
```

### 项目中的解决方案

项目采用**约束引用模式**来安全更新约束：

1. **LSWaveformBar** 保存高度约束的引用：
   ```swift
   private var heightConstraint: Constraint?

   func setHeightConstraint(_ constraint: Constraint) {
       heightConstraint = constraint
   }
   ```

2. **LSWaveformView** 在创建约束时保存引用：
   ```swift
   var heightConstraint: Constraint?
   bar.snp.remakeConstraints { make in
       heightConstraint = make.height.equalTo(value).constraint
   }
   bar.setHeightConstraint(heightConstraint!)
   ```

3. **更新时直接使用约束引用**：
   ```swift
   heightConstraint?.constraint.update(offset: newValue)
   ```

### 修复记录

以下文件已修复 `snp.updateConstraints` 潜在崩溃问题：
- `Sources/Core/Models/LSWaveformBar.swift` - 添加约束引用管理
- `Sources/UIKit/Views/LSWaveformView.swift` - 保存约束引用
- `Sources/Core/Animation/LSWaveformAnimator.swift` - 使用 LSWaveformBar 的约束引用或 remakeConstraints
