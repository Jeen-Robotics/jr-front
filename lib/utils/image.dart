import 'dart:typed_data';
import 'dart:ui';

Future<Image> imageFromBytes(Uint8List bytes, int width, int height) async {
  final buffer = await ImmutableBuffer.fromUint8List(bytes);
  final codec = await ImageDescriptor.raw(
    buffer,
    width: width,
    height: height,
    pixelFormat: PixelFormat.rgba8888,
  ).instantiateCodec();

  final frame = await codec.getNextFrame();
  final image = frame.image;

  codec.dispose();
  buffer.dispose();

  return image;
}
