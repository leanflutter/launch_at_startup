> **launch_at_startup 基于 [nativeapi](https://github.com/libnativeapi/nativeapi-flutter) 构建**——它是统一的
> C++ 核心库（[libnativeapi/nativeapi](https://github.com/libnativeapi/nativeapi)）的 Flutter 绑定，macOS、Windows、Linux
> 共用同一套实现。从 0.5.x 升级？请看[从 0.5.x 升级](#从-05x-升级)。

# launch_at_startup

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url]

[pub-image]: https://img.shields.io/pub/v/launch_at_startup.svg
[pub-url]: https://pub.dev/packages/launch_at_startup
[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

这个包让 Flutter 桌面应用在用户登录时自动启动。

[English](./README.md) | 简体中文

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [平台支持](#%E5%B9%B3%E5%8F%B0%E6%94%AF%E6%8C%81)
- [自启动项写在哪里](#%E8%87%AA%E5%90%AF%E5%8A%A8%E9%A1%B9%E5%86%99%E5%9C%A8%E5%93%AA%E9%87%8C)
- [快速开始](#%E5%BF%AB%E9%80%9F%E5%BC%80%E5%A7%8B)
  - [安装](#%E5%AE%89%E8%A3%85)
    - [环境要求](#%E7%8E%AF%E5%A2%83%E8%A6%81%E6%B1%82)
  - [用法](#%E7%94%A8%E6%B3%95)
    - [从 0.5.x 升级](#%E4%BB%8E-05x-%E5%8D%87%E7%BA%A7)
    - [迁移到原生 API](#%E8%BF%81%E7%A7%BB%E5%88%B0%E5%8E%9F%E7%94%9F-api)
- [谁在使用它？](#%E8%B0%81%E5%9C%A8%E4%BD%BF%E7%94%A8%E5%AE%83)
- [API](#api)
  - [Native API](#native-api)
- [许可证](#%E8%AE%B8%E5%8F%AF%E8%AF%81)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## 平台支持

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|  ✔️   |  ✔️   |   ✔️    |

macOS 不再需要 0.5.x 要求的那套设置——不需要 `LaunchAtLogin` Swift 包，不需要在
`MainFlutterWindow.swift` 里写 platform channel，也不需要 "Copy Launch at Login Helper"
构建阶段。升级时把它们删掉即可。

## 自启动项写在哪里

| 平台 | 机制 |
| --- | --- |
| Windows | `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`，一个标识符一个值 |
| Linux | `$XDG_CONFIG_HOME/autostart/<标识符>.desktop`（通常是 `~/.config/autostart`） |
| macOS | `SMAppService`，显示在「系统设置 ▸ 通用 ▸ 登录项」 |

## 快速开始

### 安装

将此添加到你的软件包的 pubspec.yaml 文件：

```yaml
dependencies:
  launch_at_startup: ^0.6.0
```

或

```yaml
dependencies:
  launch_at_startup:
    git:
      url: https://github.com/leanflutter/launch_at_startup.git
      ref: main
```

#### 环境要求

- Flutter 3.47 / Dart 3.13 或更高版本，macOS 13 或更高版本（`SMAppService`）。
- Linux 构建机需要 GTK 3、X11 和 Xi 的开发文件。

```
sudo apt-get install libgtk-3-dev libx11-dev libxi-dev
```

### 用法

```dart
import 'package:launch_at_startup/launch_at_startup.dart';

// 由应用自身标识：macOS 用 bundle identifier，其他平台用可执行文件名，
// 启动的程序就是当前可执行文件。
final launchAtLogin = LaunchAtLogin.create()!;

if (LaunchAtLogin.isSupported()) {
  launchAtLogin.enable();
  print(launchAtLogin.isEnabled); // true
  launchAtLogin.disable();
}
```

Windows 和 Linux 可以自己指定标识符和启动命令：

```dart
final launchAtLogin = LaunchAtLogin.createWithIdAndDisplayName(
  'com.example.myapp',
  'My App',
)!;
launchAtLogin.setProgram(Platform.resolvedExecutable, ['--minimized']);
launchAtLogin.enable();
```

macOS 会记录 `setProgram` 的值但不使用它：`SMAppService` 注册的是应用自身的 bundle，
无法带参数启动任意可执行文件。

> 本插件的[示例应用](./example)演示的是 0.5.x 兼容 API。完整示例——标识符、显示名、程序、
> 参数、回读——见 nativeapi 的
> [launch_at_login_example](https://github.com/libnativeapi/nativeapi-flutter/tree/main/examples/launch_at_login_example)。

#### 从 0.5.x 升级

为 `launch_at_startup` 0.5.x 写的代码，把导入从
`package:launch_at_startup/launch_at_startup.dart` 换成
`package:launch_at_startup/legacy.dart` 就能继续工作。它在原生 API 之上提供旧的
`launchAtStartup`（`setup`、`enable`、`disable`、`isEnabled`），并且写到和以前一样的位置，
升级后的应用能找到自己之前写下的自启动项。

这个导入是故意要改的：`legacy.dart` 是过渡桥梁，不是这个包的未来。它的成员都标了
`@Deprecated`，**将在后续版本中移除**——能迁移时请迁移到上面的原生 API。

```dart
import 'package:launch_at_startup/legacy.dart';
import 'package:package_info_plus/package_info_plus.dart';

final packageInfo = await PackageInfo.fromPlatform();

launchAtStartup.setup(
  appName: packageInfo.appName,
  appPath: Platform.resolvedExecutable,
  // 设置 packageName 以支持 MSIX。
  packageName: 'dev.leanflutter.examples.launchatstartupexample',
);

await launchAtStartup.enable();
await launchAtStartup.disable();
final isEnabled = await launchAtStartup.isEnabled();
```

与 0.5.x 的差异：

- 需要 Flutter 3.47 / Dart 3.13 和 macOS 13（0.5.x 是 Flutter 3.3、macOS 10.13）。
- **macOS 不再需要任何自己的设置。** Swift `LaunchAtLogin` 包、`MainFlutterWindow.swift`
  里的 `FlutterMethodChannel`、复制 helper 的运行脚本阶段都不需要了；登录项就是应用自身的
  `SMAppService` 注册。在 macOS 13 及以上，那个 Swift 包用的也是同一套机制，所以它写下的
  登录项这一版能读到；通过 bundled helper 注册的（macOS 13 之前那条路径）需要重新启用一次。
- `enable()` 和 `disable()` 返回平台是否接受了这次修改，而不是总返回 `true`。在 macOS 上，
  如果用户在「系统设置 ▸ 通用 ▸ 登录项」里禁用了这个应用，它们返回 `false`，`isEnabled()`
  也会一直是 `false`。
- Windows：注册表里写的是正确加了引号的命令行，路径或参数中带空格也能用。`isEnabled()`
  只判断该值是否存在；0.5.x 还会比较它是否等于当前路径、并读取 `StartupApproved` 键，因此
  用户在任务管理器里禁用过的项现在会被报告为已启用，`enable()` 也不会重新批准它。
- Linux：`.desktop` 文件写在 `$XDG_CONFIG_HOME` 指向的位置（0.5.x 总是用 `$HOME/.config`），
  并带上 `X-GNOME-Autostart-enabled` 和 `Hidden=false`。
- MSIX 没有变化：设置了 `packageName` 且应用从 `WindowsApps` 运行时，自启动项仍然是用户
  启动文件夹里的快捷方式。
- 在 `setup` 之前调用 `enable`、`disable` 或 `isEnabled`，在所有平台上仍然抛
  `UnsupportedError`。

#### 迁移到原生 API

| 0.5.x（`legacy.dart`） | 原生 API（`launch_at_startup.dart`） |
| --- | --- |
| `launchAtStartup`（每个应用一个） | `LaunchAtLogin.create()`——自己持有对象，用完 `dispose()` |
| `setup(appName: 'MyApp', appPath: p)` | `LaunchAtLogin.createWithIdAndDisplayName('MyApp', 'My App')` 再 `setProgram(p)`；`create()` 让应用标识自己 |
| `setup(args: ['--minimized'])` | `launchAtLogin.setProgram(path, ['--minimized'])` |
| `await enable()` / `await disable()` | `launchAtLogin.enable()` / `launchAtLogin.disable()`——同步，返回值就是平台的结果 |
| `await isEnabled()` | `launchAtLogin.isEnabled` |
| — | `LaunchAtLogin.isSupported()`、`id`、`displayName`、`setDisplayName`、`executablePath`、`arguments` |
| `setup(packageName:)`（MSIX） | 未覆盖；MSIX 构建请继续用 `legacy.dart` |

用着 `LaunchAtLogin` 对象期间要自己持有它：被垃圾回收的包装对象会释放原生句柄。释放句柄
不会删除自启动项。

## 谁在使用它？

- [Biyi (比译)](https://biyidev.com/) - 一个便捷的翻译和词典应用。

## API

### Native API

`launch_at_startup` 重新导出了 `nativeapi` 的 `LaunchAtLogin`。只有仍在使用 0.5.x API 的
代码才需要导入 `package:launch_at_startup/legacy.dart`。

## 许可证

[MIT](./LICENSE)
