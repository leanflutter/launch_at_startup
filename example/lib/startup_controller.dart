// The example shows the deprecated 0.5.x compatible API on purpose.
// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:launch_at_startup/legacy.dart';

/// The name the entry is stored under: the `Run` value name on Windows, the
/// `<name>.desktop` file on Linux. macOS knows the app by its bundle id and
/// ignores it.
const kAppName = 'launch_at_startup_example';

/// Only Windows reads this; it selects the MSIX path when the running
/// executable comes from that package.
const kPackageName = 'dev.leanflutter.examples.launchatstartupexample';

/// Every `launchAtStartup` call of the 0.5.x compatible API, with the answer
/// each one gave.
class StartupController extends ChangeNotifier {
  StartupController() {
    setup();
    refresh();
  }

  List<String> _args = const [];
  bool _isEnabled = false;
  bool _busy = false;
  String _lastEvent = 'Ready';
  final List<String> _log = <String>[];

  List<String> get args => _args;
  bool get isEnabled => _isEnabled;
  bool get busy => _busy;
  String get lastEvent => _lastEvent;
  List<String> get log => List<String>.unmodifiable(_log);

  /// Where this platform keeps the entry, so it can be checked outside the app.
  String get entryLocation {
    if (Platform.isWindows) {
      return r'HKCU\Software\Microsoft\Windows\CurrentVersion\Run → '
          '$kAppName';
    }
    if (Platform.isLinux) {
      final config =
          Platform.environment['XDG_CONFIG_HOME'] ??
          '${Platform.environment['HOME']}/.config';
      return '$config/autostart/$kAppName.desktop';
    }
    if (Platform.isMacOS) {
      return 'SMAppService login item — System Settings ▸ General ▸ '
          'Login Items';
    }
    return 'unsupported platform';
  }

  String get appPath => Platform.resolvedExecutable;

  void setup({List<String> args = const []}) {
    _args = args;
    launchAtStartup.setup(
      appName: kAppName,
      appPath: Platform.resolvedExecutable,
      packageName: kPackageName,
      args: args,
    );
    _note('setup(args: ${args.isEmpty ? 'none' : args.join(' ')})');
  }

  Future<void> enable() => _call('enable', launchAtStartup.enable);

  Future<void> disable() => _call('disable', launchAtStartup.disable);

  Future<void> refresh() => _call('isEnabled', launchAtStartup.isEnabled);

  void clearLog() {
    _log.clear();
    _lastEvent = 'Ready';
    notifyListeners();
  }

  Future<void> _call(String name, Future<bool> Function() body) async {
    if (_busy) return;
    _busy = true;
    notifyListeners();
    try {
      final result = await body();
      // enable() and disable() answer whether the platform accepted the
      // change; only isEnabled() answers the state, so read it back.
      _isEnabled = name == 'isEnabled'
          ? result
          : await launchAtStartup.isEnabled();
      _note('$name() → $result, isEnabled: $_isEnabled');
    } catch (error) {
      _note('$name() threw $error');
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  void _note(String line) {
    _lastEvent = line;
    _log.insert(0, line);
    if (_log.length > 20) {
      _log.removeLast();
    }
    notifyListeners();
  }
}
