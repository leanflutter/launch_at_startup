import 'package:launch_at_startup/src/app_auto_launcher_impl_noop.dart';

class AppAutoLauncherImplWindows extends AppAutoLauncherImplNoop {
  AppAutoLauncherImplWindows({
    required String appName,
    required String appPath,
    List<String> args = const [],
  }) : super();
}
