import 'dart:ffi';
import 'dart:io' show Platform;

DynamicLibrary? dlopen(String libraryName) {
  try {
    if (Platform.isWindows) {
      return DynamicLibrary.open('$libraryName.dll');
    } else if (Platform.isLinux || Platform.isAndroid) {
      return DynamicLibrary.open('lib$libraryName.so');
    } else if (Platform.isMacOS || Platform.isIOS) {
      return DynamicLibrary.open('lib$libraryName.dylib');
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  } catch (e) {
    print('Error loading dynamic library: $e');
    return null;
  }
}
