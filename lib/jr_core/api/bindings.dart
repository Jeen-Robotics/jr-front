// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

/// Jeen Robotics API
class JRApi {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
      _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  JRApi(ffi.DynamicLibrary dynamicLibrary) : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  JRApi.fromLookup(
      ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
          lookup)
      : _lookup = lookup;

  void jr_image_destroy(
    ffi.Pointer<jr_image_t> image,
  ) {
    return _jr_image_destroy(
      image,
    );
  }

  late final _jr_image_destroyPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<jr_image_t>)>>(
          'jr_image_destroy');
  late final _jr_image_destroy =
      _jr_image_destroyPtr.asFunction<void Function(ffi.Pointer<jr_image_t>)>();

  void jr_plane_destroy(
    ffi.Pointer<jr_plane_t> plane,
  ) {
    return _jr_plane_destroy(
      plane,
    );
  }

  late final _jr_plane_destroyPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<jr_plane_t>)>>(
          'jr_plane_destroy');
  late final _jr_plane_destroy =
      _jr_plane_destroyPtr.asFunction<void Function(ffi.Pointer<jr_plane_t>)>();

  void jr_planar_image_destroy(
    ffi.Pointer<jr_planar_image_t> planar_image,
  ) {
    return _jr_planar_image_destroy(
      planar_image,
    );
  }

  late final _jr_planar_image_destroyPtr = _lookup<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<jr_planar_image_t>)>>(
      'jr_planar_image_destroy');
  late final _jr_planar_image_destroy = _jr_planar_image_destroyPtr
      .asFunction<void Function(ffi.Pointer<jr_planar_image_t>)>();

  ffi.Pointer<jr_camera_device_t> jr_camera_device_create() {
    return _jr_camera_device_create();
  }

  late final _jr_camera_device_createPtr =
      _lookup<ffi.NativeFunction<ffi.Pointer<jr_camera_device_t> Function()>>(
          'jr_camera_device_create');
  late final _jr_camera_device_create = _jr_camera_device_createPtr
      .asFunction<ffi.Pointer<jr_camera_device_t> Function()>();

  void jr_camera_device_destroy(
    ffi.Pointer<jr_camera_device_t> device,
  ) {
    return _jr_camera_device_destroy(
      device,
    );
  }

  late final _jr_camera_device_destroyPtr = _lookup<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<jr_camera_device_t>)>>(
      'jr_camera_device_destroy');
  late final _jr_camera_device_destroy = _jr_camera_device_destroyPtr
      .asFunction<void Function(ffi.Pointer<jr_camera_device_t>)>();

  int jr_camera_device_get_number_of_cameras(
    ffi.Pointer<jr_camera_device_t> device,
  ) {
    return _jr_camera_device_get_number_of_cameras(
      device,
    );
  }

  late final _jr_camera_device_get_number_of_camerasPtr = _lookup<
          ffi
          .NativeFunction<ffi.Int Function(ffi.Pointer<jr_camera_device_t>)>>(
      'jr_camera_device_get_number_of_cameras');
  late final _jr_camera_device_get_number_of_cameras =
      _jr_camera_device_get_number_of_camerasPtr
          .asFunction<int Function(ffi.Pointer<jr_camera_device_t>)>();

  bool jr_camera_device_open(
    ffi.Pointer<jr_camera_device_t> device,
    int width,
    int height,
    int camera_idx,
  ) {
    return _jr_camera_device_open(
      device,
      width,
      height,
      camera_idx,
    );
  }

  late final _jr_camera_device_openPtr = _lookup<
      ffi.NativeFunction<
          ffi.Bool Function(ffi.Pointer<jr_camera_device_t>, ffi.Int32,
              ffi.Int32, ffi.Int32)>>('jr_camera_device_open');
  late final _jr_camera_device_open = _jr_camera_device_openPtr.asFunction<
      bool Function(ffi.Pointer<jr_camera_device_t>, int, int, int)>();

  void jr_camera_device_close(
    ffi.Pointer<jr_camera_device_t> device,
  ) {
    return _jr_camera_device_close(
      device,
    );
  }

  late final _jr_camera_device_closePtr = _lookup<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<jr_camera_device_t>)>>(
      'jr_camera_device_close');
  late final _jr_camera_device_close = _jr_camera_device_closePtr
      .asFunction<void Function(ffi.Pointer<jr_camera_device_t>)>();

  bool jr_camera_device_start_streaming(
    ffi.Pointer<jr_camera_device_t> device,
  ) {
    return _jr_camera_device_start_streaming(
      device,
    );
  }

  late final _jr_camera_device_start_streamingPtr = _lookup<
          ffi
          .NativeFunction<ffi.Bool Function(ffi.Pointer<jr_camera_device_t>)>>(
      'jr_camera_device_start_streaming');
  late final _jr_camera_device_start_streaming =
      _jr_camera_device_start_streamingPtr
          .asFunction<bool Function(ffi.Pointer<jr_camera_device_t>)>();

  void jr_camera_device_stop_streaming(
    ffi.Pointer<jr_camera_device_t> device,
  ) {
    return _jr_camera_device_stop_streaming(
      device,
    );
  }

  late final _jr_camera_device_stop_streamingPtr = _lookup<
          ffi
          .NativeFunction<ffi.Void Function(ffi.Pointer<jr_camera_device_t>)>>(
      'jr_camera_device_stop_streaming');
  late final _jr_camera_device_stop_streaming =
      _jr_camera_device_stop_streamingPtr
          .asFunction<void Function(ffi.Pointer<jr_camera_device_t>)>();

  void jr_camera_device_set_frame_callback(
    ffi.Pointer<jr_camera_device_t> device,
    jr_camera_device_frame_callback_t callback,
    ffi.Pointer<ffi.Void> user_data,
  ) {
    return _jr_camera_device_set_frame_callback(
      device,
      callback,
      user_data,
    );
  }

  late final _jr_camera_device_set_frame_callbackPtr = _lookup<
      ffi.NativeFunction<
          ffi.Void Function(
              ffi.Pointer<jr_camera_device_t>,
              jr_camera_device_frame_callback_t,
              ffi.Pointer<ffi.Void>)>>('jr_camera_device_set_frame_callback');
  late final _jr_camera_device_set_frame_callback =
      _jr_camera_device_set_frame_callbackPtr.asFunction<
          void Function(ffi.Pointer<jr_camera_device_t>,
              jr_camera_device_frame_callback_t, ffi.Pointer<ffi.Void>)>();

  void jr_camera_device_set_session_ready_callback(
    ffi.Pointer<jr_camera_device_t> device,
    jr_camera_device_void_callback_t callback,
  ) {
    return _jr_camera_device_set_session_ready_callback(
      device,
      callback,
    );
  }

  late final _jr_camera_device_set_session_ready_callbackPtr = _lookup<
          ffi.NativeFunction<
              ffi.Void Function(ffi.Pointer<jr_camera_device_t>,
                  jr_camera_device_void_callback_t)>>(
      'jr_camera_device_set_session_ready_callback');
  late final _jr_camera_device_set_session_ready_callback =
      _jr_camera_device_set_session_ready_callbackPtr.asFunction<
          void Function(ffi.Pointer<jr_camera_device_t>,
              jr_camera_device_void_callback_t)>();
}

final class jr_image_t extends ffi.Struct {
  @ffi.Int32()
  external int width;

  @ffi.Int32()
  external int height;

  @ffi.Int32()
  external int channels;

  external ffi.Pointer<ffi.Uint8> data;
}

final class jr_plane_t extends ffi.Struct {
  external ffi.Pointer<ffi.Uint8> data;

  @ffi.Int32()
  external int row_stride;

  @ffi.Int32()
  external int pixel_stride;
}

final class jr_planar_image_t extends ffi.Struct {
  @ffi.Int32()
  external int width;

  @ffi.Int32()
  external int height;

  @ffi.Int32()
  external int num_planes;

  external ffi.Pointer<jr_plane_t> planes;
}

final class jr_camera_device extends ffi.Opaque {}

typedef jr_camera_device_t = jr_camera_device;
typedef jr_camera_device_frame_callback_tFunction = ffi.Void Function(
    jr_image_t image, ffi.Pointer<ffi.Void> user_data);
typedef Dartjr_camera_device_frame_callback_tFunction = void Function(
    jr_image_t image, ffi.Pointer<ffi.Void> user_data);
typedef jr_camera_device_frame_callback_t = ffi
    .Pointer<ffi.NativeFunction<jr_camera_device_frame_callback_tFunction>>;
typedef jr_camera_device_void_callback_tFunction = ffi.Void Function();
typedef Dartjr_camera_device_void_callback_tFunction = void Function();
typedef jr_camera_device_void_callback_t
    = ffi.Pointer<ffi.NativeFunction<jr_camera_device_void_callback_tFunction>>;
