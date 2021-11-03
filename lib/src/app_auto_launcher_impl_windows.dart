import 'dart:io';

import 'app_auto_launcher.dart';

class AppAutoLauncherImplWindows extends AppAutoLauncher {
  AppAutoLauncherImplWindows({
    required String appName,
    required String appPath,
  }) : super(appName: appName, appPath: appPath);

  @override
  Future<bool> isEnabled() async {
    final ProcessResult result = await Process.run(
      'REG',
      [
        'QUERY',
        'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run',
        '/v',
        appName
      ],
    );
    return result.stdout.toString().contains(appName);
  }

  @override
  Future<bool> enable() async {
    final ProcessResult result = await Process.run(
      'REG',
      [
        'ADD',
        'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run',
        '/v',
        appName,
        '/t',
        'REG_SZ',
        '/d',
        '"$appPath"',
        '/f'
      ],
    );
    return result.stdout
        .toString()
        .contains('The operation completed successfully.');
  }

  @override
  Future<bool> disable() async {
    final ProcessResult result = await Process.run(
      'REG',
      [
        'DELETE',
        'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run',
        '/v',
        appName,
        '/f'
      ],
    );
    return result.stdout
        .toString()
        .contains('The operation completed successfully.');
  }
}
