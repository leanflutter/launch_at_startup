import 'dart:async';
import 'dart:io';

import 'app_auto_launcher_impl_linux.dart';
import 'app_auto_launcher_impl_macos.dart';
import 'app_auto_launcher_impl_windows.dart';
import 'app_auto_launcher.dart';

class LaunchAtStartup {
  LaunchAtStartup._();

  /// The shared instance of [LaunchAtStartup].
  static final LaunchAtStartup instance = LaunchAtStartup._();

  late AppAutoLauncher _appAutoLauncher;

  void setup({
    required String appName,
    required String appPath,
  }) {
    if (Platform.isLinux) {
      _appAutoLauncher = AppAutoLauncherImplLinux(
        appName: appName,
        appPath: appPath,
      );
    } else if (Platform.isMacOS) {
      _appAutoLauncher = AppAutoLauncherImplMacOS(
        appName: appName,
        appPath: appPath,
      );
    } else if (Platform.isWindows) {
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
