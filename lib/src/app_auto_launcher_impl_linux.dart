import 'dart:io';

import 'app_auto_launcher.dart';

class AppAutoLauncherImplLinux extends AppAutoLauncher {
  AppAutoLauncherImplLinux({
    required String appName,
    required String appPath,
  }) : super(appName: appName, appPath: appPath);

  File get _desktopFile => File(
      '${Platform.environment['HOME']}/.config/autostart/$appName.desktop');

  @override
  Future<bool> isEnabled() async {
    return _desktopFile.existsSync();
  }

  @override
  Future<bool> enable() async {
    String contents = '''
[Desktop Entry]
Type=Application
Name=$appName
Comment=$appName startup script
Exec=$appPath
StartupNotify=false
Terminal=false
''';
    if (!_desktopFile.parent.existsSync()) {
      _desktopFile.parent.createSync(recursive: true);
    }
    _desktopFile.writeAsStringSync(contents);
    return true;
  }

  @override
  Future<bool> disable() async {
    if (_desktopFile.existsSync()) {
      _desktopFile.deleteSync();
    }
    return true;
  }
}
