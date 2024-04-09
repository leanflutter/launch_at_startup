import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:launch_at_startup/launch_at_startup.dart';

void main() {
  const MethodChannel channel = MethodChannel('launch_at_startup');
  final tester = TestDefaultBinaryMessengerBinding.instance;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    tester.defaultBinaryMessenger.setMockMethodCallHandler(channel,
        (MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    tester.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });
}
