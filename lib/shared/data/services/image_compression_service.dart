import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// ImageCompressionService - Handles image compression to WebP format
///
/// Used by chat for image message compression.
class ImageCompressionService {
  static const _uuid = Uuid();

  static const int _fullPhotoMaxWidth = 1080;
  static const int _fullPhotoMaxHeight = 1920;
  static const int _fullPhotoQuality = 80;

  static const int _thumbnailSize = 200;
  static const int _thumbnailQuality = 60;

  /// Compress image to WebP for upload
  Future<CompressionResult> compressForUpload(File imageFile) async {
    final originalBytes = await imageFile.readAsBytes();
    final originalSize = originalBytes.length;

    final compressedBytes = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      format: CompressFormat.webp,
      quality: _fullPhotoQuality,
      minWidth: _fullPhotoMaxWidth,
      minHeight: _fullPhotoMaxHeight,
      keepExif: false,
    );

    if (compressedBytes == null) {
      throw CompressionException('Failed to compress image');
    }

    return CompressionResult(
      compressedBytes: compressedBytes,
      originalSize: originalSize,
      compressedSize: compressedBytes.length,
    );
  }

  /// Generate thumbnail for fast loading
  Future<Uint8List> generateThumbnail(File imageFile) async {
    final result = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      format: CompressFormat.webp,
      quality: _thumbnailQuality,
      minWidth: _thumbnailSize,
      minHeight: _thumbnailSize,
      keepExif: false,
    );

    if (result == null) {
      throw CompressionException('Failed to generate thumbnail');
    }

    return result;
  }

  /// Compress and save to temporary file
  Future<CompressedPhotoFiles> compressAndSaveToTemp(File imageFile) async {
    final tempDir = await getTemporaryDirectory();
    final photoId = _uuid.v4();

    final fullResult = await compressForUpload(imageFile);
    final fullPath = '${tempDir.path}/$photoId.webp';
    final fullFile = File(fullPath);
    await fullFile.writeAsBytes(fullResult.compressedBytes);

    final thumbnailBytes = await generateThumbnail(imageFile);
    final thumbPath = '${tempDir.path}/${photoId}_thumb.webp';
    final thumbFile = File(thumbPath);
    await thumbFile.writeAsBytes(thumbnailBytes);

    return CompressedPhotoFiles(
      fullPhoto: fullFile,
      thumbnail: thumbFile,
      fullPhotoBytes: fullResult.compressedBytes,
      thumbnailBytes: thumbnailBytes,
      originalSize: fullResult.originalSize,
      compressedSize: fullResult.compressedSize,
      thumbnailSize: thumbnailBytes.length,
    );
  }
}

/// CompressionResult - Result of image compression
class CompressionResult {
  CompressionResult({
    required this.compressedBytes,
    required this.originalSize,
    required this.compressedSize,
  });

  final Uint8List compressedBytes;
  final int originalSize;
  final int compressedSize;
}

/// CompressedPhotoFiles - Compressed photo and thumbnail files
class CompressedPhotoFiles {
  CompressedPhotoFiles({
    required this.fullPhoto,
    required this.thumbnail,
    required this.fullPhotoBytes,
    required this.thumbnailBytes,
    required this.originalSize,
    required this.compressedSize,
    required this.thumbnailSize,
  });

  final File fullPhoto;
  final File thumbnail;
  final Uint8List fullPhotoBytes;
  final Uint8List thumbnailBytes;
  final int originalSize;
  final int compressedSize;
  final int thumbnailSize;

  Future<void> cleanup() async {
    try {
      if (await fullPhoto.exists()) await fullPhoto.delete();
      if (await thumbnail.exists()) await thumbnail.delete();
    } catch (_) {}
  }
}

/// CompressionException - Thrown when compression fails
class CompressionException implements Exception {
  CompressionException(this.message);
  final String message;

  @override
  String toString() => 'CompressionException: $message';
}
