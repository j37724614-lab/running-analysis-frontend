import 'package:flutter/material.dart';
import 'package:frontend/feature/playback/widget/video_player_controller.dart';
import 'package:video_player/video_player.dart';

// Fraction of native video height to keep (the runway/runner band); rows
// outside this range are cropped out entirely, not just scaled down.
//
// Tuned against a 1280x720 test clip: bottom pixel 550 (contact points
// ~461-500, plus room for the "S{n} L=...m" label core/overlay.py draws
// below each point -- label_y = contact_y + 43 or +70, see
// ankle_step_stride.py/overlay.py -- whose deepest point lands at ~543).
// Expressed as a *fraction* of native height (288/720 .. 550/720) and
// applied proportionally rather than as fixed pixels, so a differently
// framed/resolution source (e.g. a 1920x1080 clip, where those same rows
// sit at ~648-722px) keeps the same relative framing instead of having its
// landing points and labels fall entirely outside a fixed pixel band.
const double _kCropTopFraction = 288.0 / 720.0;
const double _kCropBottomFraction = 550.0 / 720.0;

class SingleCameraPanel extends StatefulWidget {
  final int cameraIndex;
  final VideoControllerManager manager;
  final bool isActive;
  final VoidCallback onTogglePlayback;
  // When stacking 2-3 cameras, each panel must stretch to fill its share of
  // the available height (that's the whole point of the flat crop ratio
  // above -- to waste as little of that fixed height budget as possible).
  // With only one camera there's no sibling competing for that height, so
  // stretching just paints a lot of extra black background around a
  // comparatively short, wide video. Set this false to size the panel to
  // the video's own aspect ratio instead and stop at that -- see
  // TripleVideoPanel for which case picks which.
  final bool fillAvailableHeight;

  const SingleCameraPanel({
    super.key,
    required this.cameraIndex,
    required this.manager,
    required this.isActive,
    required this.onTogglePlayback,
    this.fillAvailableHeight = true,
  });

  @override
  State<SingleCameraPanel> createState() => _SingleCameraPanelState();
}

class _SingleCameraPanelState extends State<SingleCameraPanel> {
  // Owns the pinch/scroll-to-zoom transform for this camera's magnifier
  // (item 2 of the professor's feedback -- see
  // docs/developer/trial_review_advanced_features_plan.md). A literal
  // floating loupe that duplicates the live video isn't practical: the
  // video is a browser <video> platform view, not a plain Flutter image, so
  // it can't be captured/redrawn a second time at a different scale the way
  // anchor_point_dialog.dart's static-frame magnifier does. InteractiveViewer
  // instead zooms/pans the video in place, which Flutter Web's platform-view
  // compositor does support (it's just an ancestor transform).
  final TransformationController _zoomController = TransformationController();

  @override
  void dispose() {
    _zoomController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    setState(() => _zoomController.value = Matrix4.identity());
  }

  int get cameraIndex => widget.cameraIndex;
  VideoControllerManager get manager => widget.manager;
  bool get isActive => widget.isActive;
  VoidCallback get onTogglePlayback => widget.onTogglePlayback;
  bool get fillAvailableHeight => widget.fillAvailableHeight;

  @override
  Widget build(BuildContext context) {
    final nativeWidth = manager.controller.value.size.width;
    final nativeHeight = manager.controller.value.size.height;
    final cropTop = nativeHeight > 0 ? nativeHeight * _kCropTopFraction : 0.0;
    final cropBottom = nativeHeight > 0 ? nativeHeight * _kCropBottomFraction : 0.0;
    final cropHeight = cropBottom - cropTop;
    final aspectRatio = nativeWidth <= 0 || cropHeight <= 0 ? 16 / 9 : nativeWidth / cropHeight;

    final videoBox = ColoredBox(
      color: Colors.black,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Proportional-band crop: keep only source rows [cropTop,
          // cropBottom) -- the runway/runner band -- at full native width,
          // discarding the sky/background above and below it. That cropped
          // rectangle (native width x cropHeight) is then uniformly scaled
          // (never distorted, since the AspectRatio box below shares its
          // exact ratio) to fill the slot. Being much flatter than the full
          // 16:9 frame, it fits a short stacked slot with far less
          // black-bar waste than showing the whole frame.
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _zoomController,
              minScale: 1.0,
              maxScale: 4.0,
              child: GestureDetector(
                onDoubleTap: _resetZoom,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: aspectRatio,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: SizedBox(
                        width: nativeWidth,
                        height: cropHeight,
                        child: ClipRect(
                          child: Transform.translate(
                            offset: Offset(0, -cropTop),
                            // OverflowBox forces the video to lay out at its
                            // true native size -- a plain SizedBox here
                            // would get clamped to the tight (native width x
                            // cropHeight) constraint from above before the
                            // translate/clip ever ran, which is what
                            // produced a blank frame.
                            child: OverflowBox(
                              alignment: Alignment.topLeft,
                              minWidth: nativeWidth,
                              maxWidth: nativeWidth,
                              minHeight: nativeHeight,
                              maxHeight: nativeHeight,
                              child: VideoPlayer(manager.controller),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Cam ${cameraIndex + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: manager.controller,
              builder: (context, value, _) {
                return IconButton.filledTonal(
                  iconSize: 18,
                  tooltip: value.isPlaying
                      ? '暫停 Cam ${cameraIndex + 1}'
                      : '播放 Cam ${cameraIndex + 1}',
                  onPressed: onTogglePlayback,
                  icon: Icon(
                    value.isPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline,
                  ),
                );
              },
            ),
          ),
          ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: manager.controller,
            builder: (context, value, _) {
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: value.isPlaying ? 0.0 : 1.0,
                child: const Icon(
                  Icons.play_arrow,
                  size: 40,
                  color: Color.fromARGB(150, 255, 255, 255),
                ),
              );
            },
          ),
          // Only shown once zoomed in, so it doesn't compete with the
          // play/pause button when the view is at rest.
          Positioned(
            bottom: 6,
            right: 6,
            child: ValueListenableBuilder<Matrix4>(
              valueListenable: _zoomController,
              builder: (context, matrix, _) {
                if (matrix.isIdentity()) return const SizedBox.shrink();
                return IconButton.filledTonal(
                  iconSize: 18,
                  tooltip: '還原縮放 Cam ${cameraIndex + 1}',
                  onPressed: _resetZoom,
                  icon: const Icon(Icons.zoom_out_map),
                );
              },
            ),
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Theme.of(context).primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: fillAvailableHeight ? MainAxisSize.max : MainAxisSize.min,
        children: [
          // Stacking 2-3 cameras: stretch to fill the fixed height budget
          // (the whole point of the flat crop ratio is to not waste it).
          // A single camera has no sibling competing for that height, so
          // instead of stretching a lot of extra black background, size the
          // panel to the video's own aspect ratio and stop there.
          fillAvailableHeight
              ? Expanded(child: videoBox)
              : AspectRatio(aspectRatio: aspectRatio, child: videoBox),
          _VideoSeekSlider(manager: manager),
        ],
      ),
    );
  }
}

class _VideoSeekSlider extends StatefulWidget {
  const _VideoSeekSlider({required this.manager});

  final VideoControllerManager manager;

  @override
  State<_VideoSeekSlider> createState() => _VideoSeekSliderState();
}

class _VideoSeekSliderState extends State<_VideoSeekSlider> {
  bool _isDragging = false;
  double _dragPosition = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: widget.manager.controller,
      builder: (context, value, _) {
        final duration = value.duration.inMilliseconds.toDouble();
        final max = duration > 0 ? duration : 1.0;
        final playbackPosition = value.position.inMilliseconds.toDouble();
        final position = (_isDragging ? _dragPosition : playbackPosition).clamp(0.0, max);

        return SizedBox(
          height: 26,
          child: ColoredBox(
            color: Theme.of(context).primaryColor,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              ),
              child: Slider(
                min: 0,
                max: max,
                value: position,
                thumbColor: Theme.of(context).primaryColorDark,
                activeColor: Theme.of(context).primaryColorDark,
                inactiveColor: Colors.white,
                onChangeStart: duration <= 0
                    ? null
                    : (position) {
                        setState(() {
                          _isDragging = true;
                          _dragPosition = position;
                        });
                      },
                onChanged: duration <= 0
                    ? null
                    : (position) {
                        setState(() => _dragPosition = position);
                      },
                onChangeEnd: duration <= 0
                    ? null
                    : (position) {
                        widget.manager.controller.seekTo(Duration(milliseconds: position.round()));
                        setState(() {
                          _isDragging = false;
                          _dragPosition = position;
                        });
                      },
              ),
            ),
          ),
        );
      },
    );
  }
}
