import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'app_auto_launcher_impl_linux.dart';
import 'app_auto_launcher_impl_macos.dart';
import 'app_auto_launcher_impl_windows.dart'
    if (dart.library.html) 'app_auto_launcher_impl_windows_noop.dart';
import 'app_auto_launcher_impl_noop.dart';
import 'app_auto_launcher.dart';

class LaunchAtStartup {
  LaunchAtStartup._();

  /// The shared instance of [LaunchAtStartup].
  static final LaunchAtStartup instance = LaunchAtStartup._();

  AppAutoLauncher _appAutoLauncher = AppAutoLauncherImplNoop();

  void setup({
    required String appName,
    required String appPath,
  }) {
    if (!kIsWeb && Platform.isLinux) {
      _appAutoLauncher = AppAutoLauncherImplLinux(
        appName: appName,
        appPath: appPath,
      );
    } else if (!kIsWeb && Platform.isMacOS) {
      _appAutoLauncher = AppAutoLauncherImplMacOS(
        appName: appName,
        appPath: appPath,
      );
    } else if (!kIsWeb && Platform.isWindows) {
      _appAutoLauncher = AppAutoLauncherImplWindows(
        appName: appName,
        appPath: appPath,
      );
    }
  }

  /// Sets your app to auto-launch at startup
  Future<bool> enable() => _appAutoLauncher.enable();

  /// Disables your app from auto-launching at startup.
  Future<bool> disable() => _appAutoLauncher.disable();

  Future<bool> isEnabled() => _appAutoLauncher.isEnabled();
}

final launchAtStartup = LaunchAtStartup.instance;
