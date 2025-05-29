import 'dart:io';

import 'package:launch_at_startup/src/app_auto_launcher.dart';

class AppAutoLauncherImplLinux extends AppAutoLauncher {
  AppAutoLauncherImplLinux({
    required super.appName,
    required super.appPath,
    super.args,
  });

  File get _desktopFile {
    return File(
      '${Platform.environment['HOME']}/.config/autostart/$appName.desktop',
    );
  }

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
Icon=$appName
Comment=$appName startup script
Exec=${args.isEmpty ? appPath : '$appPath ${args.join(' ')}'}
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
