# launch_at_startup

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url]

[pub-image]: https://img.shields.io/pub/v/launch_at_startup.svg
[pub-url]: https://pub.dev/packages/launch_at_startup

[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

This plugin allows Flutter **desktop** apps to Auto launch on startup / login.

---

English | [简体中文](./README-ZH.md)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [launch_at_startup](#launch_at_startup)
  - [Platform Support](#platform-support)
  - [Quick Start](#quick-start)
    - [Installation](#installation)
    - [Usage](#usage)
  - [Who's using it?](#whos-using-it)
  - [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|   ✔️   |   ✔️   |    ✔️    |

> ⚠️ macOS only supports non-sandbox mode.

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  launch_at_startup: ^0.1.2
```

Or

```yaml
dependencies:
  launch_at_startup:
    git:
      url: https://github.com/leanflutter/launch_at_startup.git
      ref: main
```

### Usage

```dart
import 'dart:io';

import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  LaunchAtStartup.instance.setup(
    appName: packageInfo.appName,
    appPath: Platform.resolvedExecutable,
  );

  
  await LaunchAtStartup.instance.enable();
  await LaunchAtStartup.instance.disable();
  bool isEnabled = await LaunchAtStartup.instance.isEnabled();

  runApp(const MyApp());
}

// ...

```

> Please see the example app of this plugin for a full example.

## Who's using it?

- [Biyi (比译)](https://biyidev.com/) - A convenient translation and dictionary app.

## License

[MIT](./LICENSE)
