# launch_at_startup

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url] ![][visits-count-image]

[pub-image]: https://img.shields.io/pub/v/launch_at_startup.svg
[pub-url]: https://pub.dev/packages/launch_at_startup

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

[visits-count-image]: https://img.shields.io/badge/dynamic/json?label=Visits%20Count&query=value&url=https://api.countapi.xyz/hit/leanflutter.launch_at_startup/visits

这个插件允许 Flutter 桌面应用在启动/登录时自动启动。

---

[English](./README.md) | 简体中文

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [launch\_at\_startup](#launch_at_startup)
  - [平台支持](#平台支持)
  - [快速开始](#快速开始)
    - [安装](#安装)
    - [用法](#用法)
  - [MacOS支持](#macos支持)
    - [设置](#设置)
    - [要求](#要求)
    - [安装](#安装-1)
    - [用法](#用法-1)
  - [谁在用使用它？](#谁在用使用它)
  - [许可证](#许可证)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 平台支持

| Linux | macOS* | Windows |
| :---: | :---: | :-----: |
|   ✔️   |   ✔️   |    ✔️    |

>*所需的MACOS支持安装说明

## 快速开始

### 安装

将此添加到你的软件包的 pubspec.yaml 文件：

```yaml
dependencies:
  launch_at_startup: ^0.2.2
```

或

```yaml
dependencies:
  launch_at_startup:
    git:
      url: https://github.com/leanflutter/launch_at_startup.git
      ref: main
```

### 用法

```dart
import 'dart:io';

import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  launchAtStartup.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
  );


  await launchAtStartup.enable();
  await launchAtStartup.disable();
  bool isEnabled = await launchAtStartup.isEnabled();

  runApp(const MyApp());
}

// ...

```

> 请看这个插件的示例应用，以了解完整的例子。



## MacOS支持

### 设置

将平台通道代码添加到您的`macos/runner/mainflutterwindow.swift`文件。

```swift
import Cocoa
import FlutterMacOS
// Add the LaunchAtLogin module
import LaunchAtLogin
//

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    // Add FlutterMethodChannel platform code
    FlutterMethodChannel(
      name: "launch_at_startup", binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    .setMethodCallHandler { (_ call: FlutterMethodCall, result: @escaping FlutterResult) in
      switch call.method {
      case "launchAtStartupIsEnabled":
        result(LaunchAtLogin.isEnabled)
      case "launchAtStartupSetEnabled":
        if let arguments = call.arguments as? [String: Any] {
          LaunchAtLogin.isEnabled = arguments["setEnabledValue"] as! Bool
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    //

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}

```
然后在Xcode中打开`macOS/`文件夹，然后执行以下操作：

> 引用的说明["LaunchAtLogin" 软件包存储库](https://github.com/sindresorhus/LaunchAtLogin). 阅读以获取更多详细信息和常见问题解答。

### 要求

macOS 10.13+

### 安装

添加 `https://github.com/sindresorhus/LaunchAtLogin` 在里面 [“Swift Package Manager” XCode中的选项卡](https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app).

### 用法

**如果您的应用程序将MACOS 13或更高版本定为目标，则跳过此步骤。**

添加一个新[“Run Script Phase”](http://stackoverflow.com/a/39633955/64949) **以下** （不进入）“Copy Bundle Resources” 在 “Build Phases” 与以下内容：

```sh
"${BUILT_PRODUCTS_DIR}/LaunchAtLogin_LaunchAtLogin.bundle/Contents/Resources/copy-helper-swiftpm.sh"
```

并取消选中“Based on dependency analysis”.

构建阶段无法运行"User Script Sandboxing"启用。使用XCode 15或默认情况下启用XCode 15，请禁用"User Script Sandboxing"在构建设置中。

*（它需要一些额外的作品才能让我们的脚本符合构建相位沙箱。）*
*(我会命名运行脚本`Copy “Launch at Login Helper”`)*


## 谁在用使用它？

- [Biyi (比译)](https://biyidev.com/) - 一个便捷的翻译和词典应用程序。

## 许可证

[MIT](./LICENSE)
