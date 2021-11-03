import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:launch_at_startup/launch_at_startup.dart';

void main() {
  const MethodChannel channel = MethodChannel('launch_at_startup');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
