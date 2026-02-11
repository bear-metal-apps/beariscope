import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

const kMaxImageDimension = 512;
const kMaxFileSizeBytes = 500 * 1024;

const _initialQuality = 85;
const _minQuality = 60;
const _qualityStep = 5;

class ImageProcessor {
  ImageProcessor._();

  static bool validateImageSize(int sizeBytes, {int? maxSize}) {
    final limit = maxSize ?? kMaxFileSizeBytes;
    return sizeBytes <= limit;
  }

  static Future<Uint8List?> processProfileImage(Uint8List bytes) async {
    return compute(_processImageIsolate, bytes);
  }

  static Uint8List? _processImageIsolate(Uint8List bytes) {
    try {
      // Decode the image
      img.Image? image = img.decodeImage(bytes);
      if (image == null) {
        debugPrint('Failed to decode image');
        return null;
      }

      if (image.width > kMaxImageDimension ||
          image.height > kMaxImageDimension) {
        image = img.copyResize(
          image,
          width: image.width > image.height ? kMaxImageDimension : null,
          height: image.height >= image.width ? kMaxImageDimension : null,
          interpolation: img.Interpolation.average,
        );
      }

      int quality = _initialQuality;
      Uint8List? result;

      while (quality >= _minQuality) {
        result = Uint8List.fromList(img.encodeJpg(image, quality: quality));

        if (result.length <= kMaxFileSizeBytes) {
          debugPrint(
            'Image processed: ${image.width}x${image.height}, '
            '${result.length} bytes, quality: $quality',
          );
          return result;
        }

        quality -= _qualityStep;
      }

      if (result != null) {
        debugPrint(
          'Image processed at minimum quality: ${image.width}x${image.height}, '
          '${result.length} bytes',
        );
        return result;
      }

      return null;
    } catch (e) {
      debugPrint('Image processing error: $e');
      return null;
    }
  }

  static Future<Uint8List?> processCroppedImage(Uint8List croppedBytes) async {
    return processProfileImage(croppedBytes);
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  static Future<Uint8List?> convertToSupportedFormat(
    Uint8List bytes,
    String? mimeType,
  ) async {
    try {
      final needsConversion =
          mimeType != null &&
          (mimeType.toLowerCase().contains('heif') ||
              mimeType.toLowerCase().contains('heic'));

      if (!needsConversion) {
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          return bytes;
        }
      }

      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();

      return pngBytes;
    } catch (e) {
      return null;
    }
  }
}
