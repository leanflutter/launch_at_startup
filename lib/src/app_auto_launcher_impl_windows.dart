import 'dart:typed_data';

import 'package:launch_at_startup/src/app_auto_launcher.dart';
import 'package:win32_registry/win32_registry.dart'
    if (dart.library.html) 'noop.dart';

class AppAutoLauncherImplWindows extends AppAutoLauncher {
  AppAutoLauncherImplWindows({
    required String appName,
    required String appPath,
    List<String> args = const [],
  }) : super(appName: appName, appPath: appPath, args: args) {
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
    String? value = _regKey.getValueAsString(appName);

    return value == _registryValue && await _isStartupApproved();
  }

  @override
  Future<bool> enable() async {
    _regKey.createValue(RegistryValue(
      appName,
      RegistryValueType.string,
      _registryValue,
    ));

    final bytes = Uint8List(_startupApprovedRegKeyBytesLength);
    // "2" as a first byte in this register means that the autostart is enabled
    bytes[0] = 2;

    _startupApprovedRegKey
        .createValue(RegistryValue(appName, RegistryValueType.binary, bytes));

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
    final value = _startupApprovedRegKey.getValue(appName);

    if (value == null) {
      return true;
    }

    final data = value.data;

    if (data is! Uint8List || data.isEmpty) {
      return true;
    }

    return data[0].isEven;
  }

  void _removeValue(RegistryKey key, String value) {
    if (key.getValue(value) != null) {
      key.deleteValue(value);
    }
  }
}
