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

  @override
  Future<bool> isEnabled() async {
    String? value = _regKey.getValueAsString(appName);
    return value == _registryValue;
  }

  @override
  Future<bool> enable() async {
    _regKey.createValue(RegistryValue(
      appName,
      RegistryValueType.string,
      _registryValue,
    ));
    return true;
  }

  @override
  Future<bool> disable() async {
    if (await isEnabled()) {
      _regKey.deleteValue(appName);
    }
    return true;
  }
}
