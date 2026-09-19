// Guards the promise of package:launch_at_startup/legacy.dart: code written for
// launch_at_startup 0.5.x compiles unchanged. `_surface` names every public
// symbol of 0.5.1 with its old signature; it is compiled, never run, because
// running needs the native library. The tests below cover the parts that are
// plain Dart.
// ignore_for_file: unused_local_variable, unused_element, deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter_test/flutter_test.dart';
import 'package:launch_at_startup/legacy.dart';

Future<void> _surface() async {
  final LaunchAtStartup instance = LaunchAtStartup.instance;
  launchAtStartup.setup(appName: 'a', appPath: '/a');
  launchAtStartup.setup(
    appName: 'a',
    appPath: '/a',
    packageName: 'dev.example.a',
    args: const ['--minimized'],
  );
  final bool enabled = await launchAtStartup.enable();
  final bool disabled = await launchAtStartup.disable();
  final bool isEnabled = await launchAtStartup.isEnabled();
}

void main() {
  test('launchAtStartup is the shared instance', () {
    expect(launchAtStartup, same(LaunchAtStartup.instance));
  });

  test('every call throws before setup, as in 0.5.x', () {
    expect(LaunchAtStartup.instance.enable(), throwsUnsupportedError);
    expect(LaunchAtStartup.instance.disable(), throwsUnsupportedError);
    expect(LaunchAtStartup.instance.isEnabled(), throwsUnsupportedError);
  });
}
