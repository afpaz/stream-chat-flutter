import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:stream_chat_flutter/src/utils/device_segmentation.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:thumblr/thumblr.dart' as thumblr;

///
// ignore: prefer-match-file-name
class _IVideoService {
  _IVideoService._();

  /// Singleton instance of [_IVideoService]
  static final _IVideoService instance = _IVideoService._();

  /// Generates a thumbnail image data in memory as UInt8List.
  ///
  /// The video source can be a local video file or a URL.
  ///
  /// Thumbnails are not supported on Web at this time.
  ///
  /// If no [video] path is supplied, or if a thumbnail cannot be generated,
  /// returns [generatePlaceholderThumbnail]. A stock placeholder image.
  ///
  /// For desktop, you can specify the position of the video to generate
  /// the thumbnail.
  ///
  /// For mobile, you can specify the maximum height or width for the thumbnail
  /// or 0 for same resolution as the original video. The lower quality value
  /// creates lower quality of the thumbnail image, but it gets ignored for
  /// PNG format.
  Future<Uint8List?> generateVideoThumbnail({
    String? video,
    Map<String, String>? headers,
    ImageFormat imageFormat = ImageFormat.PNG,
    int maxHeight = 0,
    int maxWidth = 0,
    int timeMs = 0,
    int quality = 10,
  }) async {
    // If the video path is not supplied, return a placeholder image.
    if (video == null) return generatePlaceholderThumbnail();

    try {
      // If the device is a desktop, use thumblr to generate the thumbnail.
      if (isDesktopDevice) {
        final thumbnail = await thumblr.generateThumbnail(filePath: video);
        final byteData = await thumbnail.image.toByteData(
          format: ui.ImageByteFormat.png,
        );

        final bytesList = byteData?.buffer.asUint8List();
        if (bytesList != null && bytesList.isNotEmpty) {
          return bytesList;
        }

        return await generatePlaceholderThumbnail();
      }

      // Otherwise, use the VideoThumbnail package to generate the thumbnail.
      return await VideoThumbnail.thumbnailData(
        video: video,
        headers: headers,
        imageFormat: imageFormat,
        maxHeight: maxHeight,
        maxWidth: maxWidth,
        timeMs: timeMs,
        quality: quality,
      );
    } catch (_) {
      // If the thumbnail generation fails, return a placeholder image.
      return generatePlaceholderThumbnail();
    }
  }

  /// Generates a placeholder thumbnail by loading placeholder.png from assets.
  Future<Uint8List> generatePlaceholderThumbnail() async {
    final placeholder = await rootBundle.load(
      'packages/stream_chat_flutter/lib/assets/images/placeholder.png',
    );

    return placeholder.buffer.asUint8List();
  }
}

/// Get instance of [_IVideoService]
// ignore: non_constant_identifier_names
_IVideoService get StreamVideoService => _IVideoService.instance;
