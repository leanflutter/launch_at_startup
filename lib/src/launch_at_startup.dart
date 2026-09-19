// ignore_for_file: deprecated_member_use_from_same_package

import 'package:nativeapi/nativeapi.dart' as nativeapi;

/// The pre-nativeapi `LaunchAtStartup`, a thin wrapper over
/// [nativeapi.LaunchAtLogin] for code that has not moved to the native API yet.
@Deprecated(
  'The 0.5.x compatible API will be removed in a future release. Use the native API from package:launch_at_startup/launch_at_startup.dart.',
)
class LaunchAtStartup {
  LaunchAtStartup._();

  /// The shared instance of [LaunchAtStartup].
  static final LaunchAtStartup instance = LaunchAtStartup._();

  String? _appName;
  String _appPath = '';
  List<String> _args = const [];
  nativeapi.LaunchAtLogin? _launchAtLogin;

  /// Records the app this instance manages.
  ///
  /// [appName] is the name the platform stores the entry under: the value name
  /// in `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` on Windows, the
  /// `~/.config/autostart/<appName>.desktop` file on Linux — the same places
  /// 0.5.x used, so an app that upgrades keeps the entry it already wrote.
  ///
  /// [appPath] and [args] name the program to start. macOS records them but
  /// starts the app bundle itself, without arguments, as 0.5.x did.
  ///
  /// [packageName] is accepted and ignored: nativeapi recognises an MSIX
  /// package by itself and writes a shortcut to the user's Startup folder
  /// there, because a packaged app sees a virtualized registry.
  void setup({
    required String appName,
    required String appPath,
    @Deprecated('MSIX is detected by nativeapi; this parameter is ignored.')
    String? packageName,
    List<String> args = const [],
  }) {
    _launchAtLogin?.dispose();
    _launchAtLogin = null;
    _appName = appName;
    _appPath = appPath;
    _args = args;
  }

  /// Sets your app to auto-launch at startup.
  Future<bool> enable() async => _ensureLaunchAtLogin('enable').enable();

  /// Disables your app from auto-launching at startup.
  Future<bool> disable() async => _ensureLaunchAtLogin('disable').disable();

  Future<bool> isEnabled() async => _ensureLaunchAtLogin('isEnabled').isEnabled;

  /// Created on first use so that [setup] cannot throw; every call before it
  /// throws `UnsupportedError`, as in 0.5.x.
  nativeapi.LaunchAtLogin _ensureLaunchAtLogin(String call) {
    final existing = _launchAtLogin;
    if (existing != null) {
      return existing;
    }
    final appName = _appName;
    if (appName == null) {
      throw UnsupportedError(call);
    }
    final launchAtLogin = nativeapi.LaunchAtLogin.createWithIdAndDisplayName(
      appName,
      appName,
    );
    if (launchAtLogin == null) {
      throw UnsupportedError(call);
    }
    launchAtLogin.setProgram(_appPath, _args);
    _launchAtLogin = launchAtLogin;
    return launchAtLogin;
  }
}

@Deprecated(
  'The 0.5.x compatible API will be removed in a future release. Use the native API from package:launch_at_startup/launch_at_startup.dart.',
)
final launchAtStartup = LaunchAtStartup.instance;
