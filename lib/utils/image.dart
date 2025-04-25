import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';

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

Uint8List rgbaFromCameraImage(CameraImage image) {
  // Convert YUV to RGBA
  if (image.format.group == ImageFormatGroup.yuv420) {
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final int width = image.width;
    final int height = image.height;

    // Create output RGBA buffer
    final int rgbaStride = width * 4;
    final rgbaBytes = Uint8List(width * height * 4);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Calculate indices considering stride
        final int yPlaneBytesPerPixel = yPlane.bytesPerPixel ?? 1;
        final int uPlaneBytesPerPixel = uPlane.bytesPerPixel ?? 1;
        final int yIndex = y * yPlane.bytesPerRow + x * yPlaneBytesPerPixel;
        final int uvIndex =
            (y >> 1) * uPlane.bytesPerRow + (x >> 1) * uPlaneBytesPerPixel;

        // Get YUV values
        int Y = yPlane.bytes[yIndex];
        int U = uPlane.bytes[uvIndex] - 128; // Center U at 0
        int V = vPlane.bytes[uvIndex] - 128; // Center V at 0

        // BT.601 conversion matrix
        // R = Y + 1.402V
        // G = Y - 0.344U - 0.714V
        // B = Y + 1.772U
        int R = Y + (1436 * V >> 10); // 1.402 ~= 1436/1024
        int G = Y -
            (352 * U >> 10) -
            (731 * V >> 10); // 0.344 ~= 352/1024, 0.714 ~= 731/1024
        int B = Y + (1815 * U >> 10); // 1.772 ~= 1815/1024

        // Clamp values
        R = R.clamp(0, 255);
        G = G.clamp(0, 255);
        B = B.clamp(0, 255);

        // Write RGBA values
        final int rgbaIndex = y * rgbaStride + x * 4;
        rgbaBytes[rgbaIndex] = R;
        rgbaBytes[rgbaIndex + 1] = G;
        rgbaBytes[rgbaIndex + 2] = B;
        rgbaBytes[rgbaIndex + 3] = 255; // Alpha channel
      }
    }

    return rgbaBytes;
  } else {
    throw UnimplementedError("Image format not supported");
  }
}
