import 'dart:ffi';
import 'dart:typed_data';

import 'bindings.dart';

final class JRImage {
  final jr_image_t _image;

  JRImage(this._image);

  int get width => _image.width;
  int get height => _image.height;
  int get channels => _image.channels;
  int get size => width * height * channels;
  Uint8List get data => _image.data.asTypedList(size);
  bool get isEmpty => size == 0;
}
