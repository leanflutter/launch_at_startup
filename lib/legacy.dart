// ignore_for_file: deprecated_member_use_from_same_package

/// The `launch_at_startup` API as it was before the move to nativeapi.
///
/// Existing apps keep working by importing this library instead of
/// `package:launch_at_startup/launch_at_startup.dart`. The changed import is
/// deliberate: this API is a bridge, its classes are deprecated, and it will be
/// removed in a future release. New code should use the native API exported
/// from `package:launch_at_startup/launch_at_startup.dart`.
library;

export 'src/launch_at_startup.dart';
