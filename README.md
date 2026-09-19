> **launch_at_startup is built on [nativeapi](https://github.com/libnativeapi/nativeapi-flutter)**, a
> Flutter binding of one C++ core library ([libnativeapi/nativeapi](https://github.com/libnativeapi/nativeapi))
> shared by macOS, Windows and Linux. Coming from 0.5.x? See [Upgrading from 0.5.x](#upgrading-from-05x).

# launch_at_startup

[![pub version][pub-image]][pub-url] [![][discord-image]][discord-url]

[pub-image]: https://img.shields.io/pub/v/launch_at_startup.svg
[pub-url]: https://pub.dev/packages/launch_at_startup
[discord-image]: https://img.shields.io/discord/884679008049037342.svg
[discord-url]: https://discord.gg/zPa6EZ2jqb

This package lets Flutter desktop apps start themselves when the user logs in.

English | [简体中文](./README-ZH.md)

---

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

- [Platform Support](#platform-support)
- [Where the entry is kept](#where-the-entry-is-kept)
- [Quick Start](#quick-start)
  - [Installation](#installation)
    - [Requirements](#requirements)
  - [Usage](#usage)
    - [Upgrading from 0.5.x](#upgrading-from-05x)
    - [Moving to the native API](#moving-to-the-native-api)
- [Who's using it?](#whos-using-it)
- [API](#api)
  - [Native API](#native-api)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Platform Support

| Linux | macOS | Windows |
| :---: | :---: | :-----: |
|  ✔️   |  ✔️   |   ✔️    |

macOS no longer needs the Swift setup 0.5.x asked for — no `LaunchAtLogin` Swift package,
no platform channel in `MainFlutterWindow.swift`, no "Copy Launch at Login Helper" build
phase. Delete them when you upgrade.

## Where the entry is kept

| Platform | Mechanism |
| --- | --- |
| Windows | `HKCU\Software\Microsoft\Windows\CurrentVersion\Run`, one value per identifier — or, inside an MSIX package, a shortcut in the user's Startup folder |
| Linux | `$XDG_CONFIG_HOME/autostart/<identifier>.desktop` (usually `~/.config/autostart`) |
| macOS | `SMAppService`, shown in System Settings ▸ General ▸ Login Items |

## Quick Start

### Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  launch_at_startup: ^0.6.0
```

Or

```yaml
dependencies:
  launch_at_startup:
    git:
      url: https://github.com/leanflutter/launch_at_startup.git
      ref: main
```

#### Requirements

- Flutter 3.47 / Dart 3.13 or later, macOS 13 or later (`SMAppService`).
- Linux build machines need GTK 3, X11 and Xi development files.

```
sudo apt-get install libgtk-3-dev libx11-dev libxi-dev
```

### Usage

```dart
import 'package:launch_at_startup/launch_at_startup.dart';

// Identified by the app itself: the bundle identifier on macOS, the executable
// name elsewhere, with the running executable as the program.
final launchAtLogin = LaunchAtLogin.create()!;

if (LaunchAtLogin.isSupported()) {
  launchAtLogin.enable();
  print(launchAtLogin.isEnabled); // true
  launchAtLogin.disable();
}
```

Windows and Linux can name the entry and the command themselves:

```dart
final launchAtLogin = LaunchAtLogin.createWithIdAndDisplayName(
  'com.example.myapp',
  'My App',
)!;
launchAtLogin.setProgram(Platform.resolvedExecutable, ['--minimized']);
launchAtLogin.enable();
```

On macOS `setProgram` naming the running app registers that app, whatever the identifier
says; the arguments are recorded but never delivered, because `SMAppService` starts the
app bundle and nothing else. Naming any other executable there makes `enable()` fail.

> The [example app](./example) of this plugin covers the 0.5.x compatible API. For the
> full example — identifier, display name, program, arguments, read-back — see nativeapi's
> [launch_at_login_example](https://github.com/libnativeapi/nativeapi-flutter/tree/main/examples/launch_at_login_example).

#### Upgrading from 0.5.x

Code written for `launch_at_startup` 0.5.x keeps working by importing
`package:launch_at_startup/legacy.dart` instead of
`package:launch_at_startup/launch_at_startup.dart`. It provides the old
`launchAtStartup` with `setup`, `enable`, `disable` and `isEnabled` on top of the native
API, and keeps writing to the same places, so an app that upgrades finds the entry it
already wrote.

The import has to change on purpose: `legacy.dart` is a bridge, not the future of this
package. Its members are marked `@Deprecated` and **will be removed in a later
release** — move to the native API above when you can.

```dart
import 'package:launch_at_startup/legacy.dart';
import 'package:package_info_plus/package_info_plus.dart';

final packageInfo = await PackageInfo.fromPlatform();

launchAtStartup.setup(
  appName: packageInfo.appName,
  appPath: Platform.resolvedExecutable,
);

await launchAtStartup.enable();
await launchAtStartup.disable();
final isEnabled = await launchAtStartup.isEnabled();
```

What differs from 0.5.x:

- Builds need Flutter 3.47 / Dart 3.13, and macOS 13 (0.5.x: Flutter 3.3, macOS 10.13).
- **macOS needs no setup of its own.** The Swift `LaunchAtLogin` package, the
  `FlutterMethodChannel` in `MainFlutterWindow.swift` and the run script phase that
  copied the helper are all gone; the login item is an `SMAppService` registration of
  the app itself. On macOS 13 and later the Swift package registered the same way, so an
  entry it wrote is the entry this version reads; an app that was registered through the
  bundled helper (the pre-13 path) has to be enabled once more.
- `enable()` and `disable()` answer whether the platform accepted the change instead of
  always answering `true`. On macOS they answer `false` when the user has denied the app
  in System Settings ▸ General ▸ Login Items — `isEnabled()` then stays `false`.
- Windows: the registry value is now a properly quoted command line written through the
  wide API, so a path, an argument or an app name with a space or a non-ASCII character
  works. `isEnabled()` answers whether the value exists and is still approved; 0.5.x also
  compared the value against the current path, so an entry written by an older version of
  the app from a different path now reads as enabled.
- Linux: the `.desktop` file is written where `$XDG_CONFIG_HOME` points (0.5.x always
  used `$HOME/.config`) and carries `X-GNOME-Autostart-enabled` and `Hidden=false`.
- MSIX still gets a shortcut in the user's Startup folder, but nativeapi recognises the
  package itself, so `packageName` is accepted and ignored. Pass it or not; the detection
  no longer depends on the executable path containing the name you passed.
- Calling `enable`, `disable` or `isEnabled` before `setup` still throws
  `UnsupportedError`, on every platform.

#### Moving to the native API

| 0.5.x (`legacy.dart`) | Native API (`launch_at_startup.dart`) |
| --- | --- |
| `launchAtStartup` (one per app) | `LaunchAtLogin.create()` — keep the object, `dispose()` it when done |
| `setup(appName: 'MyApp', appPath: p)` | `LaunchAtLogin.createWithIdAndDisplayName('MyApp', 'My App')` then `setProgram(p)`; `create()` identifies the app itself |
| `setup(args: ['--minimized'])` | `launchAtLogin.setProgram(path, ['--minimized'])` |
| `await enable()` / `await disable()` | `launchAtLogin.enable()` / `launchAtLogin.disable()` — synchronous, and the answer is the platform's |
| `await isEnabled()` | `launchAtLogin.isEnabled` |
| — | `LaunchAtLogin.isSupported()`, `id`, `displayName`, `setDisplayName`, `executablePath`, `arguments` |
| `setup(packageName:)` (MSIX) | nothing to do — `LaunchAtLogin` recognises the package itself |

Keep a reference to the `LaunchAtLogin` object while you use it: a wrapper that is
garbage-collected releases its native handle. Releasing it does not remove the entry.

## Who's using it?

- [Biyi (比译)](https://biyidev.com/) - A convenient translation and dictionary app.

## API

### Native API

`launch_at_startup` re-exports `LaunchAtLogin` from `nativeapi`. Import
`package:launch_at_startup/legacy.dart` only for code that still uses the 0.5.x API.

## License

[MIT](./LICENSE)
