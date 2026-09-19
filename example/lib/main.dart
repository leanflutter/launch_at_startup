// The example shows the deprecated 0.5.x compatible API on purpose.
// ignore_for_file: deprecated_member_use

import 'package:flutter/widgets.dart';
import 'package:launch_at_startup/launch_at_startup.dart';

import 'startup_controller.dart';
import 'widgets/event_footer.dart';
import 'widgets/option_chip.dart';
import 'widgets/palette.dart';

// launch_at_startup through its 0.5.x compatible API
// (package:launch_at_startup/legacy.dart): one `launchAtStartup.setup()`, then
// enable / disable / isEnabled.
//
//   startup_controller.dart   every launchAtStartup call and what it answered
//   widgets/                  the few widgets the window is made of (no Material)
//
// This is deliberately the small example. The full one — the native
// `LaunchAtLogin` with its identifier, display name, program and arguments —
// is nativeapi's launch_at_login_example:
// https://github.com/libnativeapi/nativeapi-flutter/tree/main/examples/launch_at_login_example

const kFullExampleUrl =
    'github.com/libnativeapi/nativeapi-flutter/tree/main/examples/launch_at_login_example';

void main() {
  runApp(const LaunchAtStartupExampleApp());
}

class LaunchAtStartupExampleApp extends StatelessWidget {
  const LaunchAtStartupExampleApp({
    super.key,
    this.shell = const Shell(),
    this.fontFamily,
  });

  final Widget shell;

  /// Null uses the platform's font; a test has to name one it has loaded.
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      title: 'launch_at_startup example',
      color: Palette.light.accent,
      debugShowCheckedModeBanner: false,
      builder: (context, _) {
        final palette = Palette.of(context);
        return DefaultTextStyle(
          style: TextStyle(
            fontFamily: fontFamily,
            fontSize: 12,
            height: 1.3,
            color: palette.text,
          ),
          child: shell,
        );
      },
    );
  }
}

/// State strip, one row per compatible API call, event footer.
class Shell extends StatefulWidget {
  const Shell({super.key, this.controller});

  final StartupController? controller;

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  late final StartupController _controller =
      widget.controller ?? StartupController();

  static const _argSets = <String, List<String>>{
    'None': <String>[],
    '--minimized': <String>['--minimized'],
    'Two args': <String>['--minimized', '--from=login'],
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = Palette.of(context);
    final c = _controller;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => ColoredBox(
        color: palette.background,
        child: Column(
          children: [
            _stateStrip(palette),
            Expanded(
              child: ListView(
                children: [
                  OptionRow(
                    label: 'Entry',
                    children: [
                      OptionChip(
                        label: 'Enable',
                        selected: c.isEnabled,
                        onTap: c.busy ? null : c.enable,
                      ),
                      OptionChip(
                        label: 'Disable',
                        selected: !c.isEnabled,
                        onTap: c.busy ? null : c.disable,
                      ),
                      OptionChip(
                        label: 'Read back',
                        onTap: c.busy ? null : c.refresh,
                      ),
                    ],
                  ),
                  OptionRow(
                    label: 'Arguments',
                    children: [
                      for (final entry in _argSets.entries)
                        OptionChip(
                          label: entry.key,
                          selected: _sameArgs(c.args, entry.value),
                          onTap: c.busy
                              ? null
                              : () => c.setup(args: entry.value),
                        ),
                      const Hint(
                        'macOS registers the app itself, without them',
                      ),
                    ],
                  ),
                  _detailBlock(palette),
                ],
              ),
            ),
            EventFooter(controller: c),
          ],
        ),
      ),
    );
  }

  Widget _stateStrip(Palette palette) {
    final c = _controller;
    final supported = LaunchAtLogin.isSupported();
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(bottom: BorderSide(color: palette.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              c.isEnabled ? 'Launches at startup' : 'Does not launch',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: c.isEnabled ? palette.success : palette.muted,
              ),
            ),
          ),
          Text(
            supported ? 'supported' : 'not supported here',
            style: TextStyle(
              fontSize: 11,
              color: supported ? palette.muted : palette.danger,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailBlock(Palette palette) {
    final c = _controller;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('appName: $kAppName', style: palette.mono),
          Text('appPath: ${c.appPath}', style: palette.mono),
          Text(
            'stored at: ${StartupController.entryLocation}',
            style: palette.mono,
          ),
          const SizedBox(height: 6),
          Text(
            'The full native example: $kFullExampleUrl',
            style: palette.mono,
          ),
        ],
      ),
    );
  }

  bool _sameArgs(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
