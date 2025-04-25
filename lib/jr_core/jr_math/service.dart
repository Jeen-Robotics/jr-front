import 'dart:async';
import 'dart:ffi';
import 'bindings.dart';
import 'package:jr_front/utils/dlopen.dart';

final class JRMathService {
  static Completer<double>? _completer;
  static NativeCallable<AsyncCallbackFunction>? _callback;

  late final DynamicLibrary _lib;
  late final JRMath _bindings;

  JRMathService._(this._lib, this._bindings);

  static JRMathService? init() {
    final lib = dlopen('jr_math');
    if (lib == null) {
      return null;
    }
    final bindings = JRMath(lib);
    return JRMathService._(lib, bindings);
  }

  double add(double a, double b) => _bindings.add(a, b);
  double subtract(double a, double b) => _bindings.subtract(a, b);
  double multiply(double a, double b) => _bindings.multiply(a, b);
  double divide(double a, double b) => _bindings.divide(a, b);

  // Static callback function
  static void _asyncCallback(double result) {
    _completer?.complete(result);
  }

  // Async operation
  Future<double> asyncAdd(double a, double b) {
    _completer = Completer<double>();

    // Create a new NativeCallable if one doesn't exist
    _callback ??=
        NativeCallable<AsyncCallbackFunction>.listener(_asyncCallback);
    _bindings.async_add(a, b, _callback!.nativeFunction);
    return _completer!.future;
  }

  // Cleanup method to dispose of the NativeCallable when no longer needed
  void dispose() {
    _callback?.close();
    _callback = null;

    _lib.close();
  }
}
