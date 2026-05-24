import 'dart:io';
import 'dart:typed_data';

import 'package:launch_at_startup/src/app_auto_launcher.dart';
import 'package:win32_registry/win32_registry.dart'
    if (dart.library.html) 'noop.dart';

bool isRunningInMsix(String packageName) {
  final String resolvedExecutable = Platform.resolvedExecutable;
  final bool isMsix = resolvedExecutable.contains('WindowsApps') &&
      resolvedExecutable.contains(packageName);
  return isMsix;
}

class AppAutoLauncherImplWindows extends AppAutoLauncher {
  AppAutoLauncherImplWindows({
    required super.appName,
    required String appPath,
    List<String> args = const [],
  }) : super(appPath: appPath, args: args) {
    _registryValue = args.isEmpty ? appPath : '$appPath ${args.join(' ')}';
  }

  late String _registryValue;

  RegistryKey get _regKey => CURRENT_USER.open(
    r'Software\Microsoft\Windows\CurrentVersion\Run',
    config: const RegistryOpenConfig(access: RegistryAccess.all),
  );

  RegistryKey get _startupApprovedRegKey => CURRENT_USER.open(
    r'Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run',
    config: const RegistryOpenConfig(access: RegistryAccess.all),
  );

  static const int _startupApprovedRegKeyBytesLength = 12;

  @override
  Future<bool> isEnabled() async {
    String? value = _regKey.getString(appName);

    return value == _registryValue && await _isStartupApproved();
  }

  @override
  Future<bool> enable() async {
    _regKey.setValue(
      appName,
      RegistryValue.string(_registryValue),
    );

    final bytes = Uint8List(_startupApprovedRegKeyBytesLength);
    // "2" as a first byte in this register means that the autostart is enabled
    bytes[0] = 2;

    _startupApprovedRegKey.setValue(
      appName,
      RegistryValue.binary(bytes),
    );

    return true;
  }

  @override
  Future<bool> disable() async {
    _removeValue(_regKey, appName);
    _removeValue(_startupApprovedRegKey, appName);
    return true;
  }

  // https://renenyffenegger.ch/notes/Windows/registry/tree/HKEY_CURRENT_USER/Software/Microsoft/Windows/CurrentVersion/Explorer/StartupApproved/Run/index
  // Odd first byte will prevent the app from autostarting
  // Empty or any other value will allow the app to autostart
  Future<bool> _isStartupApproved() async {
    final value = _startupApprovedRegKey.getBinary(appName);

    if (value == null) {
      return true;
    }

    if (value.isEmpty) {
      return true;
    }

    return value[0].isEven;
  }

  void _removeValue(RegistryKey key, String value) {
    if (key.getValue(value) != null) {
      key.removeValue(value);
    }
  }
}

class AppAutoLauncherImplWindowsMsix extends AppAutoLauncher {
  AppAutoLauncherImplWindowsMsix({
    required super.appName,
    required super.appPath,
    required this.packageName,
    super.args,
  });

  final String packageName;

  File get _shortcutFile {
    return File(
      '${Platform.environment['APPDATA']}\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\$appName.lnk',
    );
  }

  @override
  Future<bool> isEnabled() async {
    return _shortcutFile.existsSync();
  }

  @override
  Future<bool> enable() async {
    final String script = '''
    \$TargetPath = "$appPath"
    \$ShortcutFile = "\$env:APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\$appName.lnk"
    \$WScriptShell = New-Object -ComObject WScript.Shell
    \$Shortcut = \$WScriptShell.CreateShortcut(\$ShortcutFile)
    \$Shortcut.TargetPath = \$TargetPath
    \$Shortcut.Arguments = "${args.join(' ')}"
    \$Shortcut.Save()
  ''';
    final result = Process.runSync('powershell', ['-Command', script]);
    if (result.stderr != null && result.stderr!.isNotEmpty) {
      throw Exception('Failed to create shortcut: ${result.stderr}');
    }
    return _shortcutFile.existsSync();
  }

  @override
  Future<bool> disable() async {
    if (_shortcutFile.existsSync()) {
      final String script = '''
    Remove-Item -Path "\$env:APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\$appName.lnk"
  ''';
      final result = Process.runSync('powershell', ['-Command', script]);
      if (result.stderr != null && result.stderr!.isNotEmpty) {
        throw Exception('Failed to delete shortcut: ${result.stderr}');
      }
    }
    return !_shortcutFile.existsSync();
  }
}
