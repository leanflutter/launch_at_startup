import 'dart:io';

import 'app_auto_launcher.dart';

class AppAutoLauncherImplMacOS extends AppAutoLauncher {
  AppAutoLauncherImplMacOS({
    required String appName,
    required String appPath,
  }) : super(appName: appName, appPath: appPath);

  File get _plistFile => File(
      '${Platform.environment['HOME']}/Library/LaunchAgents/$appName.plist');

  @override
  Future<bool> isEnabled() async {
    return _plistFile.existsSync();
  }

  @override
  Future<bool> enable() async {
    String contents = '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>$appName</string>
    <key>ProgramArguments</key>
    <array>
      <string>$appPath</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
  </dict>
</plist>
''';
    _plistFile.writeAsStringSync(contents);
    return true;
  }

  @override
  Future<bool> disable() async {
    if (_plistFile.existsSync()) {
      _plistFile.deleteSync();
    }
    return true;
  }
}
