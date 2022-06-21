class AppAutoLauncher {
  final String appName;
  final String appPath;
  final List<String> args;

  AppAutoLauncher({
    required this.appName,
    required this.appPath,
    this.args = const [],
  });

  Future<bool> isEnabled() {
    throw UnimplementedError();
  }

  Future<bool> enable() {
    throw UnimplementedError();
  }

  Future<bool> disable() {
    throw UnimplementedError();
  }
}
