// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:io';

import 'package:nativeapi/nativeapi.dart' as nativeapi;

/// The pre-nativeapi `LaunchAtStartup` on top of [nativeapi.LaunchAtLogin],
/// for code that has not moved to the native API yet.
@Deprecated(
  'The 0.5.x compatible API will be removed in a future release. Use the native API from package:launch_at_startup/launch_at_startup.dart.',
)
class LaunchAtStartup {
  LaunchAtStartup._();

  /// The shared instance of [LaunchAtStartup].
  static final LaunchAtStartup instance = LaunchAtStartup._();

  _AutoLauncher _autoLauncher = const _UnconfiguredAutoLauncher();

  /// Records the app this instance manages.
  ///
  /// [appName] is the name the platform stores the entry under: the value name
  /// in `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` on Windows, the
  /// `~/.config/autostart/<appName>.desktop` file on Linux — the same places
  /// 0.5.x used, so an app that upgrades keeps the entry it already wrote.
  ///
  /// [appPath] and [args] name the program to start. macOS registers the
  /// running app itself through `SMAppService` and ignores both, as 0.5.x did.
  ///
  /// [packageName] enables the MSIX path on Windows: inside an MSIX container
  /// the registry is virtualized, so the entry is a shortcut in the user's
  /// Startup folder instead.
  void setup({
    required String appName,
    required String appPath,
    String? packageName,
    List<String> args = const [],
  }) {
    _autoLauncher.dispose();
    if (Platform.isWindows &&
        packageName != null &&
        isRunningInMsix(packageName)) {
      _autoLauncher = _MsixAutoLauncher(
        appName: appName,
        appPath: appPath,
        args: args,
      );
      return;
    }
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      _autoLauncher = _NativeAutoLauncher(
        appName: appName,
        appPath: appPath,
        args: args,
      );
      return;
    }
    _autoLauncher = const _UnconfiguredAutoLauncher();
  }

  /// Sets your app to auto-launch at startup.
  Future<bool> enable() => _autoLauncher.enable();

  /// Disables your app from auto-launching at startup.
  Future<bool> disable() => _autoLauncher.disable();

  Future<bool> isEnabled() => _autoLauncher.isEnabled();
}

@Deprecated(
  'The 0.5.x compatible API will be removed in a future release. Use the native API from package:launch_at_startup/launch_at_startup.dart.',
)
final launchAtStartup = LaunchAtStartup.instance;

/// Whether the running executable is the MSIX install of [packageName].
@Deprecated(
  'The 0.5.x compatible API will be removed in a future release. Use the native API from package:launch_at_startup/launch_at_startup.dart.',
)
bool isRunningInMsix(String packageName) {
  final resolvedExecutable = Platform.resolvedExecutable;
  return resolvedExecutable.contains('WindowsApps') &&
      resolvedExecutable.contains(packageName);
}

abstract class _AutoLauncher {
  const _AutoLauncher();

  Future<bool> isEnabled();

  Future<bool> enable();

  Future<bool> disable();

  void dispose() {}
}

/// What every call answers before [LaunchAtStartup.setup], and on a platform
/// that has no startup entry at all — as in 0.5.x.
class _UnconfiguredAutoLauncher extends _AutoLauncher {
  const _UnconfiguredAutoLauncher();

  @override
  Future<bool> isEnabled() async => throw UnsupportedError('isEnabled');

  @override
  Future<bool> enable() async => throw UnsupportedError('enable');

  @override
  Future<bool> disable() async => throw UnsupportedError('disable');
}

/// The Windows registry key, the Linux `.desktop` file and the macOS login
/// item, all through nativeapi's `LaunchAtLogin`.
class _NativeAutoLauncher extends _AutoLauncher {
  _NativeAutoLauncher({
    required this.appName,
    required this.appPath,
    required this.args,
  });

  final String appName;
  final String appPath;
  final List<String> args;

  nativeapi.LaunchAtLogin? _launchAtLogin;

  /// Created on first use so that `setup()` cannot throw.
  nativeapi.LaunchAtLogin get _ensureLaunchAtLogin {
    final existing = _launchAtLogin;
    if (existing != null) {
      return existing;
    }
    // macOS registers the main app through SMAppService, which knows it by its
    // bundle identifier; an app name would name a bundled helper that does not
    // exist. The program and arguments are the running app's own there too.
    final launchAtLogin = Platform.isMacOS
        ? nativeapi.LaunchAtLogin.create()
        : nativeapi.LaunchAtLogin.createWithIdAndDisplayName(appName, appName);
    if (launchAtLogin == null) {
      throw StateError('Unable to create the launch-at-login entry');
    }
    if (!Platform.isMacOS) {
      launchAtLogin.setProgram(appPath, args);
    }
    _launchAtLogin = launchAtLogin;
    return launchAtLogin;
  }

  @override
  Future<bool> isEnabled() async => _ensureLaunchAtLogin.isEnabled;

  @override
  Future<bool> enable() async => _ensureLaunchAtLogin.enable();

  @override
  Future<bool> disable() async => _ensureLaunchAtLogin.disable();

  @override
  void dispose() {
    _launchAtLogin?.dispose();
    _launchAtLogin = null;
  }
}

/// A shortcut in the user's Startup folder, for an app running from an MSIX
/// container where the `Run` registry key is virtualized away. Unchanged from
/// 0.5.x: nativeapi writes the registry key, which an MSIX install cannot use.
class _MsixAutoLauncher extends _AutoLauncher {
  _MsixAutoLauncher({
    required this.appName,
    required this.appPath,
    required this.args,
  });

  final String appName;
  final String appPath;
  final List<String> args;

  File get _shortcutFile {
    return File(
      '${Platform.environment['APPDATA']}\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\$appName.lnk',
    );
  }

  @override
  Future<bool> isEnabled() async => _shortcutFile.existsSync();

  @override
  Future<bool> enable() async {
    final script =
        '''
    \$TargetPath = "$appPath"
    \$ShortcutFile = "\$env:APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\$appName.lnk"
    \$WScriptShell = New-Object -ComObject WScript.Shell
    \$Shortcut = \$WScriptShell.CreateShortcut(\$ShortcutFile)
    \$Shortcut.TargetPath = \$TargetPath
    \$Shortcut.Arguments = "${args.join(' ')}"
    \$Shortcut.Save()
  ''';
    final result = Process.runSync('powershell', ['-Command', script]);
    final stderr = result.stderr;
    if (stderr is String && stderr.isNotEmpty) {
      throw Exception('Failed to create shortcut: $stderr');
    }
    return _shortcutFile.existsSync();
  }

  @override
  Future<bool> disable() async {
    if (_shortcutFile.existsSync()) {
      final script =
          'Remove-Item -Path '
          '"\$env:APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\$appName.lnk"';
      final result = Process.runSync('powershell', ['-Command', script]);
      final stderr = result.stderr;
      if (stderr is String && stderr.isNotEmpty) {
        throw Exception('Failed to delete shortcut: $stderr');
      }
    }
    return !_shortcutFile.existsSync();
  }
}
