import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/backend/local_bundle_form_io.dart';
import 'package:frontend/feature/playback/widget/video_player_controller.dart';

void main() {
  test('local result upload includes each original input video', () async {
    final temp = await Directory.systemTemp.createTemp('local-bundle-video-test');
    addTearDown(() => temp.delete(recursive: true));
    final bundle = Directory('${temp.path}/bundle')..createSync();
    File('${bundle.path}/manifest.json').writeAsStringSync(jsonEncode({'artifacts': <Object>[]}));
    final source = File('${temp.path}/IMG_0085.MOV')..writeAsBytesSync([1, 2, 3]);

    final form = await buildLocalBundleForm(
      bundle.path,
      'request-1',
      inputVideoPaths: [source.path],
    );

    final videos = form.files.where((entry) => entry.key == 'input_videos').toList();
    expect(videos, hasLength(1));
    expect(videos.single.value.filename, 'IMG_0085.MOV');
  });

  test('video playback retry stops instead of retrying forever', () {
    expect(videoPlaybackRetry(0, '404 Analysis video not found'), isNull);
    expect(videoPlaybackRetry(3, 'Connection reset'), isNull);
  });
}
