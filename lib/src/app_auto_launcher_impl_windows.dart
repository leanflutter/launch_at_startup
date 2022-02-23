import 'dart:ffi';

import 'package:ffi/ffi.dart' if (dart.library.html) 'noop_ffi.dart';
import 'package:win32/win32.dart' if (dart.library.html) 'noop_win32.dart';

import 'app_auto_launcher.dart';

final _kRegSubKey =
    r'Software\Microsoft\Windows\CurrentVersion\Run'.toNativeUtf16();
const _kRegValueMaxLength = 1024;

class AppAutoLauncherImplWindows extends AppAutoLauncher {
  AppAutoLauncherImplWindows({
    required String appName,
    required String appPath,
  }) : super(appName: appName, appPath: appPath);

  int _regOpenKey() {
    final phkResult = calloc<HANDLE>();
    try {
      RegOpenKeyEx(
        HKEY_CURRENT_USER,
        _kRegSubKey,
        0,
        KEY_ALL_ACCESS,
        phkResult,
      );
      return phkResult.value;
    } finally {
      free(phkResult);
    }
  }

  int _regCloseKey(int hKey) {
    return RegCloseKey(hKey);
  }

  @override
  Future<bool> isEnabled() async {
    int hKey = _regOpenKey();
    final lpData = calloc<BYTE>(_kRegValueMaxLength);
    final lpcbData = calloc<DWORD>()..value = _kRegValueMaxLength;

    RegQueryValueEx(
      hKey,
      appName.toNativeUtf16(),
      nullptr,
      nullptr,
      lpData,
      lpcbData,
    );
    String value = lpData.cast<Utf16>().toDartString();

    free(lpData);
    free(lpcbData);
    _regCloseKey(hKey);

    return value.trim().isNotEmpty;
  }

  @override
  Future<bool> enable() async {
    int hKey = _regOpenKey();
    RegSetKeyValue(
      hKey,
      ''.toNativeUtf16(),
      appName.toNativeUtf16(),
      REG_SZ,
      ('"' + appPath + '"').toNativeUtf16(),
      _kRegValueMaxLength,
    );
    _regCloseKey(hKey);
    return true;
  }

  @override
  Future<bool> disable() async {
    int hKey = _regOpenKey();
    RegDeleteValue(hKey, appName.toNativeUtf16());
    _regCloseKey(hKey);
    return true;
  }
}
