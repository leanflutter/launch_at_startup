import 'dart:io';
import 'dart:typed_data';

import 'package:launch_at_startup/src/app_auto_launcher.dart';
import 'package:win32/win32.dart'
    show ERROR_FILE_NOT_FOUND, HRESULT_FROM_WIN32, WindowsException;
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

  RegistryKey get _regKey => Registry.openPath(
        RegistryHive.currentUser,
        path: r'Software\Microsoft\Windows\CurrentVersion\Run',
        desiredAccessRights: AccessRights.allAccess,
      );

  RegistryKey get _startupApprovedRegKey => Registry.openPath(
        RegistryHive.currentUser,
        path:
            r'Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run',
        desiredAccessRights: AccessRights.allAccess,
      );

  static const int _startupApprovedRegKeyBytesLength = 12;

  @override
  Future<bool> isEnabled() async {
    final String? value;
    try {
      value = _regKey.getStringValue(appName);
    } on WindowsException catch (e) {
      // The Run key may not exist yet on a fresh Windows install where no
      // application has registered for startup, which means auto-start is
      // not enabled. Rethrow anything else (for example access denied) so a
      // genuine failure is not silently masked.
      if (e.hr != HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND)) rethrow;
      return false;
    }

    return value == _registryValue && await _isStartupApproved();
  }

  @override
  Future<bool> enable() async {
    _regKey.createValue(
      RegistryValue.string(
        appName,
        _registryValue,
      ),
    );

    final bytes = Uint8List(_startupApprovedRegKeyBytesLength);
    // "2" as a first byte in this register means that the autostart is enabled
    bytes[0] = 2;

    _startupApprovedRegKey.createValue(RegistryValue.binary(appName, bytes));

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
    final Uint8List? value;
    try {
      value = _startupApprovedRegKey.getBinaryValue(appName);
    } on WindowsException catch (e) {
      // The StartupApproved\Run key is created lazily and is often absent on
      // a fresh install; a missing key is treated as approved by the null
      // check below. Rethrow anything else so a genuine failure surfaces.
      if (e.hr != HRESULT_FROM_WIN32(ERROR_FILE_NOT_FOUND)) rethrow;
      value = null;
    }

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
      key.deleteValue(value);
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
