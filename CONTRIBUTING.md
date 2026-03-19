# 贡献指南

感谢您对 LSWaveformKit 的关注！我们欢迎任何形式的贡献。

## 如何贡献

### 报告问题

如果您发现了 bug 或有功能建议：

1. 在 [Issues](https://github.com/yourusername/LSWaveformKit/issues) 中搜索是否已有相关问题
2. 如果没有，创建新的 Issue，详细描述：
   - 问题描述
   - 复现步骤
   - 预期行为
   - 实际行为
   - 环境信息（iOS 版本、设备型号、Xcode 版本）

### 提交代码

#### 开发流程

1. **Fork 项目**
   ```bash
   # 在 GitHub 上点击 Fork 按钮
   ```

2. **克隆到本地**
   ```bash
   git clone https://github.com/yourusername/LSWaveformKit.git
   cd LSWaveformKit
   ```

3. **创建功能分支**
   ```bash
   git checkout -b feature/your-feature-name
   ```

4. **进行开发**
   - 遵循项目的代码规范
   - 添加必要的测试
   - 更新相关文档

5. **提交代码**
   ```bash
   git add .
   git commit -m "feat: 添加您的功能描述"
   ```

6. **推送到远程**
   ```bash
   git push origin feature/your-feature-name
   ```

7. **创建 Pull Request**
   - 在 GitHub 上创建 PR
   - 详细描述您的更改
   - 关联相关的 Issue

#### 提交信息规范

我们使用语义化提交信息：

- `feat:` 新功能
- `fix:` Bug 修复
- `docs:` 文档更新
- `style:` 代码格式调整（不影响功能）
- `refactor:` 重构（不是新功能也不是修复）
- `perf:` 性能优化
- `test:` 测试相关
- `chore:` 构建过程或工具变更

示例：
```
feat: 添加圆形波形布局支持
fix: 修复录音取消时的状态同步问题
docs: 更新 API 文档
```

#### 代码规范

##### Swift 代码规范

- 使用 4 空格缩进
- 行宽不超过 120 字符
- 使用 `// MARK:` 分组代码
- 所有公开 API 必须添加文档注释
- 使用 weak self 避免循环引用

```swift
/// 更新波形音量
/// - Parameter amplitude: 音量值（0.0 ~ 1.0）
public func updateAmplitude(_ amplitude: Float) {
    // 使用 weak self
    someAsyncOperation { [weak self] in
        guard let self = self else { return }
        self.doSomething()
    }
}
```

##### 命名规范

- 类名：大写字母开头，驼峰命名（如 `LSWaveformView`）
- 方法名：小写字母开头，驼峰命名（如 `updateAmplitude`）
- 变量名：小写字母开头，驼峰命名（如 `numberOfBars`）
- 常量：小写字母开头，驼峰命名（如 `defaultAnimationDuration`）

#### 测试规范

- 为所有新功能添加单元测试
- 测试文件命名：`ClassNameTests.swift`
- 测试覆盖率目标：80%+

```swift
import XCTest
@testable import LSWaveformKit

class LSWaveformViewTests: XCTestCase {
    func testUpdateAmplitude() {
        let view = LSWaveformView()
        view.updateAmplitude(0.5)
        XCTAssertEqual(view.currentAmplitude, 0.5)
    }
}
```

## 开发环境设置

### 安装依赖

```bash
# 安装 CocoaPods
sudo gem install cocoapods

# 安装依赖
pod install
```

### 运行示例项目

```bash
# 打开 iOS 示例
open Example/iOS/LSWaveformKitDemo/LSWaveformKitDemo.xcworkspace

# 打开 SwiftUI 示例
open Example/SwiftUI/LSWaveformKitSwiftUIDemo/LSWaveformKitSwiftUIDemo.xcworkspace
```

### 运行测试

```bash
# 运行所有测试
xcodebuild test -workspace LSWaveformKit.xcworkspace \
  -scheme LSWaveformKit \
  -destination 'platform=iOS Simulator,name=iPhone 14'

# 使用 CocoaPods 运行测试
pod lib lint LSWaveformKit.podspec
```

## 代码审查

所有 PR 都需要经过代码审查：

1. 至少一名维护者批准
2. 所有 CI 检查通过
3. 没有合并冲突
4. 代码符合项目规范

## 发布流程

维护者负责发布新版本：

1. 更新版本号（`LSWaveformKit.podspec`、`Package.swift`）
2. 更新 `CHANGELOG.md`
3. 创建 Git tag
4. 推送到 CocoaPods
5. 创建 GitHub Release

## 社区准则

- 尊重所有贡献者
- 友善交流，接受建设性批评
- 关注项目本身，而非个人

## 获取帮助

- 查看 [文档](Docs/)
- 搜索 [Issues](https://github.com/yourusername/LSWaveformKit/issues)
- 提问时提供清晰的问题描述和环境信息

再次感谢您的贡献！
