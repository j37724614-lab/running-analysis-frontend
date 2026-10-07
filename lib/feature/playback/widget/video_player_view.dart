import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/backend/video_playback_state_provider.dart';
import 'package:frontend/feature/playback/playback_provider.dart';
import 'package:frontend/feature/playback/shimmer/video_player_shimmer.dart';
import 'package:frontend/feature/playback/widget/video_player_controller.dart';
import 'package:frontend/feature/playback/widget/video_slider_item.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:frontend/widget/async_value_widget.dart';
import 'package:frontend/widget/processing_progress_widget.dart';
import 'package:frontend/widget/rounded_box_widget.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerView extends ConsumerStatefulWidget {
  const VideoPlayerView({super.key});

  @override
  ConsumerState<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends ConsumerState<VideoPlayerView> {
  @override
  Widget build(BuildContext context) {
    final selectedVideoId = ref.watch(playbackSelectedRunSessionIdProvider);

    if (selectedVideoId == null) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Theme.of(context).primaryColor,
        ),
        child: Center(child: Icon(Icons.ondemand_video_rounded, size: 64, color: Colors.white)),
      );
    }

    final videoInfo = ref.watch(videoInfoProvider(selectedVideoId));
    return AsyncValueWidget(
      value: videoInfo,
      loading: RoundedBoxWidget(
        child: Padding(padding: const EdgeInsets.all(12), child: const VideoPlayerShimmer()),
      ),
      data: (info) {
        if (info.status == 'failed') {
          return Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Theme.of(context).primaryColor,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                ),
                Container(
                  width: 300,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 40),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              context.l10n.noVideoData,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            context.l10n.statusFailed,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: const LinearProgressIndicator(
                          value: 1.0,
                          minHeight: 8,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        if (info.status == 'processing') {
          return RoundedBoxWidget(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const VideoPlayerShimmer(),
                  ProcessingProgressWidget(progress: info.progress),
                ],
              ),
            ),
          );
        }

        // 只有狀態不是 processing 時，才顯示真正的影片內容組件
        return _VideoContentPlayer(key: ValueKey(selectedVideoId), videoId: selectedVideoId);
      },
    );
  }
}

class _VideoContentPlayer extends ConsumerStatefulWidget {
  final String videoId;
  const _VideoContentPlayer({super.key, required this.videoId});

  @override
  ConsumerState<_VideoContentPlayer> createState() => _VideoContentPlayerState();
}

class _VideoContentPlayerState extends ConsumerState<_VideoContentPlayer> {
  VideoControllerManager? _manager;

  @override
  void initState() {
    super.initState();
    // 切換影片時重置播放狀態
    Future.microtask(() {
      ref.invalidate(videoPlaybackStateProvider);
    });
  }

  void _onVideoTick() {
    if (_manager == null) return;
    final notifier = ref.read(videoPlaybackStateProvider.notifier);
    final state = ref.read(videoPlaybackStateProvider);
    if (state.isDragging) return;

    notifier.setResult(
      state.copyWith(
        position: _manager!.controller.value.position.inMilliseconds,
        duration: _manager!.controller.value.duration.inMilliseconds,
      ),
    );
  }

  @override
  void dispose() {
    _manager?.controller.removeListener(_onVideoTick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final managerProvider = ref.watch(videoManagerProvider(widget.videoId));

    managerProvider.whenData((manager) {
      if (_manager != manager) {
        Future.microtask(() {
          if (!mounted) return;
          _manager?.controller.removeListener(_onVideoTick);
          _manager = manager;
          _manager!.controller.addListener(_onVideoTick);
          _onVideoTick();
        });
      }
    });

    return Column(
      children: [
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
            color: Theme.of(context).primaryColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: AsyncValueWidget(
                value: managerProvider,
                loading: const VideoPlayerShimmer(),
                error: (error, stack) {
                  return Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, size: 64, color: Colors.white.withValues(alpha: 0.8)),
                        Text(
                          videoPlaybackErrorMessage(error),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          onPressed: () => ref.invalidate(videoManagerProvider(widget.videoId)),
                          child: const Text('重新載入影片'),
                        ),
                      ],
                    ),
                  );
                },
                data: (manager) {
                  return GestureDetector(
                    onTap: () {
                      if (manager.controller.value.isPlaying) {
                        manager.pause();
                      } else {
                        manager.play();
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        AbsorbPointer(
                          child: AspectRatio(
                            aspectRatio: manager.controller.value.aspectRatio,
                            child: VideoPlayer(manager.controller),
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
                                size: 64,
                                color: Color.fromARGB(123, 255, 255, 255),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        VideoSliderView(
          onSeek: (position) {
            final manager = ref.read(videoManagerProvider(widget.videoId)).value;
            manager?.controller.seekTo(Duration(milliseconds: position));
          },
        ),
      ],
    );
  }
}
