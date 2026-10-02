import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/feature/trial_review/trial_review_provider.dart';
import 'package:frontend/utils/api.dart';
import 'package:video_player/video_player.dart';

/// Optional top-down (homography-rectified) replay, only available for
/// sessions that were 6-point calibrated and successfully exported a
/// review video (see routes/trial_review.py's
/// GET .../topdown_review/{camera_index}). Opens in a dialog rather than a
/// panel slot so it never displaces CAM1-3 when unavailable -- renders
/// nothing at all if no camera has one.
class TopdownReviewPanel extends ConsumerWidget {
  final String runSessionId;

  const TopdownReviewPanel({super.key, required this.runSessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicesAsync = ref.watch(
      topdownReviewCameraIndicesProvider(runSessionId),
    );
    final indices = indicesAsync.value ?? const <int>[];
    if (indices.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        icon: const Icon(Icons.view_in_ar_outlined),
        label: const Text('查看動態俯視回放'),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => _TopdownReviewDialog(
            runSessionId: runSessionId,
            cameraIndices: indices,
          ),
        ),
      ),
    );
  }
}

class _TopdownReviewDialog extends StatefulWidget {
  final String runSessionId;
  final List<int> cameraIndices;

  const _TopdownReviewDialog({
    required this.runSessionId,
    required this.cameraIndices,
  });

  @override
  State<_TopdownReviewDialog> createState() => _TopdownReviewDialogState();
}

class _TopdownReviewDialogState extends State<_TopdownReviewDialog> {
  static const _autoReplayDelay = Duration(milliseconds: 1500);

  late VideoPlayerController _controller;
  Timer? _autoReplayTimer;
  Object? _initializationError;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    final url = API.getTopdownReviewVideo(
      widget.runSessionId,
      widget.cameraIndices.first,
    );
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller.addListener(_handleVideoUpdate);
    _initializeAndPlay();
  }

  Future<void> _initializeAndPlay() async {
    try {
      await _controller.initialize();
      if (!mounted) return;
      setState(() {});
      await _controller.play();
    } catch (error) {
      if (!mounted) return;
      setState(() => _initializationError = error);
    }
  }

  void _handleVideoUpdate() {
    if (!mounted) return;
    final value = _controller.value;
    if (value.isCompleted && !_isCompleted) {
      _isCompleted = true;
      _autoReplayTimer?.cancel();
      _autoReplayTimer = Timer(_autoReplayDelay, _replay);
    }
    setState(() {});
  }

  Future<void> _togglePlayback() async {
    if (_isCompleted) {
      await _replay();
      return;
    }
    if (_controller.value.isPlaying) {
      await _controller.pause();
    } else {
      await _controller.play();
    }
  }

  Future<void> _replay() async {
    _autoReplayTimer?.cancel();
    if (!mounted || !_controller.value.isInitialized) return;
    setState(() => _isCompleted = false);
    await _controller.seekTo(Duration.zero);
    await _controller.play();
  }

  Future<void> _seekTo(double milliseconds) async {
    _autoReplayTimer?.cancel();
    if (_isCompleted) setState(() => _isCompleted = false);
    await _controller.seekTo(Duration(milliseconds: milliseconds.round()));
  }

  String _formatDuration(Duration value) {
    final minutes = value.inMinutes.toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _autoReplayTimer?.cancel();
    _controller.removeListener(_handleVideoUpdate);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.play_circle_outline),
                  SizedBox(width: 8),
                  Text(
                    '動態俯視回放',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AspectRatio(
                // Rectified top-down runway strips are very wide/flat --
                // 16:5 is a reasonable placeholder while the real video
                // hasn't reported its own size yet.
                aspectRatio: _controller.value.isInitialized
                    ? (_controller.value.aspectRatio == 0
                          ? 16 / 5
                          : _controller.value.aspectRatio)
                    : 16 / 5,
                child: _buildVideoArea(),
              ),
              const SizedBox(height: 8),
              if (_controller.value.isInitialized) _buildControls(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('關閉'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoArea() {
    if (_initializationError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(height: 8),
            const Text('俯視影片載入失敗'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() => _initializationError = null);
                _initializeAndPlay();
              },
              child: const Text('重試'),
            ),
          ],
        ),
      );
    }
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: _togglePlayback,
          child: VideoPlayer(_controller),
        ),
        if (_isCompleted)
          ColoredBox(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton.icon(
                    onPressed: _replay,
                    icon: const Icon(Icons.replay),
                    label: const Text('重新播放'),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1.5 秒後自動重播',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildControls() {
    final value = _controller.value;
    final durationMs = value.duration.inMilliseconds;
    final positionMs = value.position.inMilliseconds.clamp(0, durationMs);

    return Row(
      children: [
        IconButton(
          onPressed: _togglePlayback,
          tooltip: value.isPlaying ? '暫停' : '播放',
          icon: Icon(value.isPlaying ? Icons.pause : Icons.play_arrow),
        ),
        IconButton(
          onPressed: _replay,
          tooltip: '從頭播放',
          icon: const Icon(Icons.replay),
        ),
        Expanded(
          child: Slider(
            min: 0,
            max: durationMs > 0 ? durationMs.toDouble() : 1,
            value: durationMs > 0 ? positionMs.toDouble() : 0,
            onChanged: durationMs > 0 ? _seekTo : null,
          ),
        ),
        Text(
          '${_formatDuration(value.position)} / '
          '${_formatDuration(value.duration)}',
          style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
        ),
      ],
    );
  }
}
