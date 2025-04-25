import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ImagePainter extends CustomPainter {
  final ui.Image image;

  final BoxFit fit;

  const ImagePainter(this.image, {this.fit = BoxFit.contain});

  @override
  void paint(Canvas canvas, Size size) {
    double scale;
    double offsetX = 0;
    double offsetY = 0;
    
    final scaleX = size.width / image.width;
    final scaleY = size.height / image.height;

    switch (fit) {
      case BoxFit.contain:
        scale = scaleX < scaleY ? scaleX : scaleY;
        offsetX = (size.width - image.width * scale) / 2;
        offsetY = (size.height - image.height * scale) / 2;
        break;
      
      case BoxFit.cover:
        scale = scaleX > scaleY ? scaleX : scaleY;
        offsetX = (size.width - image.width * scale) / 2;
        offsetY = (size.height - image.height * scale) / 2;
        break;
        
      case BoxFit.fitWidth:
        scale = scaleX;
        offsetY = (size.height - image.height * scale) / 2;
        break;
        
      case BoxFit.fitHeight:
        scale = scaleY;
        offsetX = (size.width - image.width * scale) / 2;
        break;
        
      case BoxFit.fill:
        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
          Rect.fromLTWH(0, 0, size.width, size.height),
          Paint(),
        );
        return;
        
      case BoxFit.none:
        canvas.drawImage(image, Offset.zero, Paint());
        return;
        
      default:
        scale = 1.0;
    }

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(
        offsetX,
        offsetY,
        image.width * scale,
        image.height * scale,
      ),
      Paint(),
    );
  }

  @override
  bool shouldRepaint(covariant ImagePainter oldDelegate) {
    return oldDelegate.image != image;
  }
}
