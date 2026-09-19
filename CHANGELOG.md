## 0.6.0

launch_at_startup is now built on [nativeapi](https://pub.dev/packages/nativeapi): the
per-platform Dart implementations are gone, and one C++ core drives macOS, Windows and
Linux.

* **Breaking:** `package:launch_at_startup/launch_at_startup.dart` exports the native API —
  `LaunchAtLogin`, with an identifier, a display name, a program with arguments, and
  synchronous `enable` / `disable` / `isEnabled` that answer what the platform did.
* The 0.5.x API moved to `package:launch_at_startup/legacy.dart`: `launchAtStartup` with
  `setup`, `enable`, `disable` and `isEnabled`, writing to the same registry value and the
  same `.desktop` file as before. Existing apps change one import. It is a bridge:
  everything in it is `@Deprecated` and will be removed in a later release. The README
  lists the behaviour differences and maps each old call to the native API.
* **Breaking:** requires Flutter 3.47 / Dart 3.13 and macOS 13, and depends on
  nativeapi ^0.3.1. CI builds and the publish workflow pin Flutter 3.47.5.
* **macOS needs no setup of its own.** The `LaunchAtLogin` Swift package, the
  `FlutterMethodChannel` in `MainFlutterWindow.swift` and the run script phase that copied
  the login helper are all gone; the login item is an `SMAppService` registration of the
  app itself.
* Windows: the registry value is a properly quoted command line written through the wide
  API, so a path, an argument or an app name with a space or a non-ASCII character works.
  `isEnabled()` answers whether the value exists and is still approved, instead of also
  comparing it against the current path.
* Linux: the `.desktop` file follows `$XDG_CONFIG_HOME` and carries
  `X-GNOME-Autostart-enabled` and `Hidden=false`.
* MSIX still gets a shortcut in the user's Startup folder, but nativeapi recognises the
  package itself, so `setup(packageName:)` is accepted and ignored.
* `win32_registry` is no longer a dependency.
* New example on `package:flutter/widgets.dart` alone; the full one is nativeapi's
  [launch_at_login_example](https://github.com/libnativeapi/nativeapi-flutter/tree/main/examples/launch_at_login_example).

## 0.5.1

- MSIX support args #37

## 0.4.0

- Update plugin to use win32_registry version 2.0.0 #33

## 0.3.1

- fix: web build error.

## 0.3.0

* [windows] Add MSIX app support
* [windows] fix: detect disabled/enabled register (#26)
* [macos] macOS support API change to allow App Sandbox mode #27

## 0.2.2

* add startup args for linux (#19)

## 0.2.1

* feat: add interactive process type to MacOS #16

## 0.2.0

- fix: web compile error #14

## 0.1.9

- bump win32_registry to 1.0.2 #12

## 0.1.8

- [windows] Fix incorrect setting/checking of registry value #10

## 0.1.7

- [windows] Replace `win32` with `win32_registry`

## 0.1.6

- [windows] fix: use correct max length of registry key #

## 0.1.5

- [linux] Fixed wrong app name when writing .desktop file. #4

## 0.1.4

- `pubspec.yaml` adds platforms field.

## 0.1.3

- #3 Fix  No such file or directory error.

## 0.1.2

- #2 Fixed build web error.

## 0.1.1

- Supported `linux` platform.

## 0.1.0

- First release.
