class AppAutoLauncher {
  final String appName;
  final String appPath;

  AppAutoLauncher({
    required this.appName,
    required this.appPath,
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
