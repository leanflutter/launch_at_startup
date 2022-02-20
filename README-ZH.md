# launch_at_startup

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url]

[pub-image]: https://img.shields.io/pub/v/launch_at_startup.svg
[pub-url]: https://pub.dev/packages/launch_at_startup

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

这个插件允许 Flutter **桌面** 应用在启动/登录时自动启动。

---

[English](./README.md) | 简体中文

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [launch_at_startup](#launch_at_startup)
  - [平台支持](#平台支持)
  - [快速开始](#快速开始)
    - [安装](#安装)
    - [用法](#用法)
  - [谁在用使用它？](#谁在用使用它)
  - [许可证](#许可证)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 平台支持

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|   ✔️   |   ✔️   |    ✔️    |

> ⚠️ macOS 只支持非沙盒模式。

## 快速开始

### 安装

将此添加到你的软件包的 pubspec.yaml 文件：

```yaml
dependencies:
  launch_at_startup: ^0.1.5
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

## 谁在用使用它？

- [Biyi (比译)](https://biyidev.com/) - 一个便捷的翻译和词典应用程序。

## 许可证

[MIT](./LICENSE)
