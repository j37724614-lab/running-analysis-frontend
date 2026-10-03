import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/upload_video_file.dart';
import 'package:frontend/feature/record/record_controller.dart';
import 'package:frontend/feature/record/record_enums.dart';
import 'package:frontend/feature/upload/widget/anchor_point_dialog.dart';
import 'package:frontend/widget/loading_icon.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:mime/mime.dart';
import 'package:toastification/toastification.dart';
import 'package:shimmer/shimmer.dart';

class RecordCameraView extends ConsumerStatefulWidget {
  const RecordCameraView({super.key});

  @override
  ConsumerState<RecordCameraView> createState() => _RecordCameraViewState();
}

class _RecordCameraViewState extends ConsumerState<RecordCameraView> with ChangeNotifier {
  CameraController? _controller;
  bool _isInitialized = false;
  XFile? _recordedFile;
  bool _isUploading = false;
  bool _isShowingFullscreen = false;

  List<CameraDescription> _allBackCameras = [];
  int _currentBackCameraIndex = 0;

  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;

  // Timer? _previewTimer;
  // bool _previewTimerStarted = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      if (kDebugMode) print('正在獲取可用相機...');
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (kDebugMode) print('找不到任何相機');
        return;
      }

      // 找出所有後置鏡頭項目
      _allBackCameras = cameras
          .where((camera) => camera.lensDirection == CameraLensDirection.back)
          .toList();

      // 優先選擇邏輯鏡頭 (通常包含 Triple 或 Dual 字樣)，這種鏡頭支援更多縮放範圍 (0.5x - 10x)
      // 若是第一次初始化，才執行自動選擇邏輯
      if (_allBackCameras.isNotEmpty && _controller == null) {
        int bestIndex = 0;
        for (var i = 0; i < _allBackCameras.length; i++) {
          final name = _allBackCameras[i].name.toLowerCase();
          if (name.contains('triple') || name.contains('dual')) {
            bestIndex = i;
            break;
          }
        }
        _currentBackCameraIndex = bestIndex;
      }

      final selectedCamera = _allBackCameras.isNotEmpty
          ? _allBackCameras[_currentBackCameraIndex]
          : cameras.first;

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.veryHigh, // 1080p
        fps: 60,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();

      // 取得縮放範圍並更新狀態
      try {
        _minZoom = await _controller!.getMinZoomLevel();
        _maxZoom = min(await _controller!.getMaxZoomLevel(), 10.0);

        // 嘗試設定目標倍率，如果是第一次切換，盡量接近 0.5 或之前的值
        if (_currentZoom < _minZoom) _currentZoom = _minZoom;
        if (_currentZoom > _maxZoom) _currentZoom = _maxZoom;

        if (_maxZoom > _minZoom) {
          await _controller!.setZoomLevel(_currentZoom);
        }
      } catch (e) {
        if (kDebugMode) print('此裝置不支援縮放功能: $e');
        // 發生錯誤時保留預設值 (1.0)，並確保不中斷初始化程序
        _minZoom = 1.0;
        _maxZoom = 1.0;
        _currentZoom = 1.0;
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('相機初始化失敗: $e');
      }
      if (mounted) {
        toastification.show(
          context: context,
          title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
          description: Text('無法存取相機: $e'),
          type: ToastificationType.error,
          style: ToastificationStyle.minimal,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(seconds: 4),
        );
      }
    }
  }

  Future<void> _switchLens() async {
    if (_allBackCameras.length <= 1) return;

    setState(() {
      _isInitialized = false;
    });

    _currentBackCameraIndex = (_currentBackCameraIndex + 1) % _allBackCameras.length;
    await _controller?.dispose();
    await _initializeCamera();
    notifyListeners();
  }

  void _listenToRecordingStatus() {
    ref.listen(recordControllerProvider.select((s) => s.status), (prev, next) async {
      if (next == RecordStatus.recording) {
        if (mounted) {
          setState(() {
            _recordedFile = null;
            _isUploading = false;
          });
        }
        if (_controller != null &&
            _controller!.value.isInitialized &&
            !_controller!.value.isRecordingVideo) {
          try {
            await _controller!.startVideoRecording();
          } catch (e) {
            if (kDebugMode) print('錄影啟動失敗: $e');
          }
        }
      } else if (next == RecordStatus.uploading) {
        if (_controller != null &&
            _controller!.value.isInitialized &&
            _controller!.value.isRecordingVideo) {
          try {
            final file = await _controller!.stopVideoRecording();
            if (mounted) {
              setState(() {
                _recordedFile = file;
              });
            }
            _processUpload();
          } catch (e) {
            if (kDebugMode) print('錄影停止失敗: $e');
          }
        }
      }
    });
  }

  Future<void> _processUpload() async {
    if (_recordedFile == null || _isUploading) return;

    final backend = ref.read(backendProvider);
    final controller = ref.read(recordControllerProvider.notifier);

    if (mounted) {
      setState(() {
        _isUploading = true;
      });
    }

    try {
      final initialState = ref.read(recordControllerProvider);
      if (kDebugMode) {
        print(
          '開始處理自動上傳: 相機 ${initialState.myCameraIndex != null ? initialState.myCameraIndex! + 1 : '未知'}',
        );
      }

      final bytes = await _recordedFile!.readAsBytes();

      String filename = _recordedFile!.name;
      String mimeType =
          lookupMimeType(filename) ?? _recordedFile!.mimeType ?? 'video/webm'; // Fallback

      // 若檔名沒有副檔名，根據 mimeType 自動補上正確的副檔名
      if (!filename.contains('.')) {
        final ext = extensionFromMime(mimeType);
        if (ext != null) {
          filename = '$filename.$ext';
        } else {
          // 若無法從 mime 判斷，根據常見格式做最後的 fallback
          if (mimeType.contains('mp4')) {
            filename = '$filename.mp4';
          } else {
            filename = '$filename.webm';
          }
        }
      }

      final uploadFile = UploadVideoFile(bytes: bytes, filename: filename, mimeType: mimeType);

      // 所有設備先平行上傳影片檔，取得各自的 tempVideoId。
      final tempVideoId = await backend.uploadVideo(initialState.myCameraIndex ?? 0, uploadFile);

      // temp upload 完成後再判斷由哪一台相機建立 run session。
      final currentState = ref.read(recordControllerProvider);
      final recordingMembers =
          currentState.members.where((member) => member.cameraIndex != null).toList()
            ..sort((a, b) => a.cameraIndex!.compareTo(b.cameraIndex!));
      final minCameraIndex = recordingMembers.isNotEmpty ? recordingMembers.first.cameraIndex : 0;
      final isLeader = currentState.myCameraIndex == minCameraIndex;

      if (isLeader) {
        String? actualRunnerId = currentState.runnerId;
        if (actualRunnerId == null && currentState.runnerName != null) {
          actualRunnerId = await backend.addRunner(currentState.runnerName!);
          if (kDebugMode) print('建立新選手: $actualRunnerId');
        }

        if (actualRunnerId == null) {
          throw Exception('未指定選手');
        }

        final status = await backend.uploadSeperatelyNew(
          actualRunnerId,
          DateTime.now(),
          currentState.expectedCameraCount,
          currentState.fps,
          currentState.note,
          currentState.isLongJump,
          currentState.myCameraIndex!,
          tempVideoId,
          currentState.anchorResult,
        );
        controller.notifyUploadComplete(
          status.runSessionId,
          runnerId: actualRunnerId,
          isAllUploaded: status.isAllUploaded,
        );
      } else {
        // Slave 已完成 temp upload，只等待 Leader 建立 session（最多 30 秒）。
        String? runSessionId = ref.read(recordControllerProvider).sharedRunSessionId;
        if (runSessionId == null) {
          for (var i = 0; i < 60; i++) {
            if (!mounted) return;
            await Future.delayed(const Duration(milliseconds: 500));
            runSessionId = ref.read(recordControllerProvider).sharedRunSessionId;
            if (runSessionId != null) break;
          }
        }

        if (runSessionId == null) {
          throw Exception('等待主相機建立 Session 超時');
        }

        var currentRunnerId = ref.read(recordControllerProvider).runnerId;
        if (currentRunnerId == null && currentState.runnerName != null) {
          currentRunnerId = await backend.addRunner(currentState.runnerName!);
        }
        if (currentRunnerId == null) {
          throw Exception('未指定選手');
        }

        final status = await backend.uploadSeperatelySelect(
          currentRunnerId,
          runSessionId,
          currentState.myCameraIndex!,
          tempVideoId,
          currentState.anchorResult,
        );

        if (status.isAllUploaded) {
          controller.notifyUploadComplete(
            status.runSessionId,
            runnerId: currentRunnerId,
            isAllUploaded: true,
          );
        }
      }

      if (kDebugMode) {
        print(
          '自動上傳完成: 相機 ${currentState.myCameraIndex != null ? currentState.myCameraIndex! + 1 : '未知'}',
        );
      }

      final finalState = ref.read(recordControllerProvider);
      controller.updateReadyStatus(finalState.isPhysicallyReady && finalState.anchorIsSet);

      if (mounted) {
        setState(() {
          _isUploading = false;
          _recordedFile = null; // Prevent re-uploading
        });
      }
    } catch (e) {
      if (kDebugMode) print('上傳過程發生錯誤: $e');
      if (mounted) {
        setState(() {
          _isUploading = false;
          _recordedFile = null;
        });
        toastification.show(
          context: context,
          title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
          description: Text('上傳失敗: $e'),
          type: ToastificationType.error,
          style: ToastificationStyle.minimal,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(seconds: 4),
        );
      }
    }
  }

  @override
  void dispose() {
    // _previewTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _listenToRecordingStatus();

    // final state = ref.watch(recordControllerProvider);
    // if (state.role == RecordRole.slave && !_previewTimerStarted) {
    //   _previewTimerStarted = true;
    //   _startPreviewTimer();
    // } else if (state.role != RecordRole.slave && _previewTimerStarted) {
    //   _previewTimerStarted = false;
    //   _previewTimer?.cancel();
    // }

    if (!_isInitialized || _controller == null || !_controller!.value.isInitialized) {
      return const _CameraLoadingShimmer();
    }

    if (_isShowingFullscreen) {
      // 在進入全螢幕模式時，原位留白或顯示 Shimmer，避免兩個 CameraPreview 同時渲染
      return const _CameraLoadingShimmer();
    }

    return _buildCameraPreviewStack(isFullscreen: false);
  }

  void _enterFullscreen() async {
    if (_controller == null) return;

    // Flutter Web: CameraPreview is an HtmlElementView (<video> element).
    // Detaching it from the widget tree breaks the stream connection.
    // Re-initializing the controller before showing fullscreen ensures the
    // fullscreen dialog gets a fresh, properly attached video element.
    setState(() {
      _isShowingFullscreen = true;
      _isInitialized = false; // show shimmer while re-initing
    });
    await _controller?.dispose();
    await _initializeCamera(); // sets _isInitialized = true when done

    if (!mounted) return;

    // 使用 rootNavigator: true 以確保對話框覆蓋整個 App（包括主頁的 AppBar 與 Sidebar）
    await Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (context) => _FullScreenCameraDialog(cameraViewState: this)));

    if (mounted) {
      // Re-initialize again so the normal view also gets a fresh camera element.
      setState(() {
        _isShowingFullscreen = false;
        _isInitialized = false;
      });
      await _controller?.dispose();
      await _initializeCamera();
    }
  }

  Widget _buildCameraPreviewStack({
    required bool isFullscreen,
    bool isAnchorMode = false,
    Widget? anchorOverlay,
    Uint8List? snapshotBytes,
  }) {
    final state = ref.watch(recordControllerProvider);
    final controller = ref.read(recordControllerProvider.notifier);

    // 錄影前的驗證邏輯
    final connectedCameraIndexes = state.members.map((m) => m.cameraIndex).whereType<int>().toSet();
    final areAllCamerasConnected =
        state.expectedCameraCount > 0 &&
        List.generate(
          state.expectedCameraCount,
          (i) => i,
        ).every((i) => connectedCameraIndexes.contains(i));

    final participatingMembers = state.members.where((m) => m.cameraIndex != null);
    final areAllParticipatingReady = participatingMembers.every((m) => m.isReady);

    // 強制橫式顯示邏輯
    double rawRatio = _controller!.value.aspectRatio;
    double containerAspectRatio = rawRatio;
    int quarterTurns = 0;

    final orientation = MediaQuery.of(context).orientation;

    // 1. 確保外框容器永遠是橫式比例 (> 1)
    if (containerAspectRatio < 1) {
      containerAspectRatio = 1 / containerAspectRatio;
    }

    // 2. 決定是否旋轉內容
    if (orientation == Orientation.portrait && rawRatio < 1) {
      quarterTurns = 3; // 逆時針轉 90 度
    }

    Widget content = Stack(
      children: [
        AspectRatio(
          aspectRatio: containerAspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              RotatedBox(quarterTurns: quarterTurns, child: CameraPreview(_controller!)),
              if (isAnchorMode && snapshotBytes != null)
                Positioned.fill(
                  child: RotatedBox(
                    quarterTurns: quarterTurns,
                    child: Image.memory(snapshotBytes, fit: BoxFit.cover),
                  ),
                ),
              // 如果有錨點層，直接放在這裡，確保座標與影像 1:1 對應
              if (anchorOverlay != null) anchorOverlay,
            ],
          ),
        ),
        // 縮放控制拉桿（錨點模式時隱藏）
        if (!isAnchorMode && _maxZoom > _minZoom)
          Positioned(
            left: 16,
            bottom: 24,
            top: 24,
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: SizedBox(
                        width: 200,
                        child: Slider(
                          value: _currentZoom,
                          min: _minZoom,
                          max: _maxZoom,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white30,
                          onChanged: (value) async {
                            setState(() {
                              _currentZoom = value;
                            });
                            notifyListeners();
                            try {
                              await _controller?.setZoomLevel(value);
                            } catch (e) {
                              if (kDebugMode) print('無法設定縮放倍率: $e');
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentZoom.toStringAsFixed(1)}x',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        // 底部更換鏡頭按鈕（錨點模式時隱藏）
        if (!isAnchorMode && _allBackCameras.length > 1)
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: GestureDetector(
                  onTap: _switchLens,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.switchLens,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.flip_camera_ios, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // 右上角縮放按鈕（錨點模式時隱藏）
        if (!isAnchorMode)
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: isFullscreen
                  ? () => Navigator.of(context, rootNavigator: true).pop()
                  : _enterFullscreen,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: Icon(
                  isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        // 全螢幕模式下的主控端開始/結束錄影按鈕（錨點模式時隱藏）
        if (!isAnchorMode && isFullscreen && state.role == RecordRole.master)
          Positioned(
            bottom: 24,
            right: 24,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: state.status == RecordStatus.recording ? Colors.black : Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                if (state.status == RecordStatus.recording) {
                  controller.stopRecording();
                } else {
                  // 開始錄影前的檢查
                  if (state.runnerId == null) {
                    toastification.show(
                      context: context,
                      title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
                      description: Text(context.l10n.pleaseSelectRunnerToRecord),
                      type: ToastificationType.error,
                      style: ToastificationStyle.minimal,
                      alignment: Alignment.bottomCenter,
                      autoCloseDuration: const Duration(seconds: 4),
                    );
                    return;
                  }
                  if (!areAllCamerasConnected) {
                    toastification.show(
                      context: context,
                      title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
                      description: Text(
                        context.l10n.camerasNotAllConnected(
                          connectedCameraIndexes.length,
                          state.expectedCameraCount,
                        ),
                      ),
                      type: ToastificationType.error,
                      style: ToastificationStyle.minimal,
                      alignment: Alignment.bottomCenter,
                      autoCloseDuration: const Duration(seconds: 4),
                    );
                    return;
                  }

                  if (!areAllParticipatingReady) {
                    toastification.show(
                      context: context,
                      title: const Text('Warning', style: TextStyle(fontWeight: FontWeight.bold)),
                      description: Text(context.l10n.camerasNotAllReady),
                      type: ToastificationType.warning,
                      style: ToastificationStyle.minimal,
                      alignment: Alignment.bottomCenter,
                      autoCloseDuration: const Duration(seconds: 4),
                    );
                    return;
                  }

                  controller.startRecording();
                }
                notifyListeners();
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    state.status == RecordStatus.recording ? Icons.stop : Icons.fiber_manual_record,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.status == RecordStatus.recording
                        ? context.l10n.stopRecording
                        : context.l10n.startRecording,
                  ),
                ],
              ),
            ),
          ),
        if (_isUploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: isFullscreen ? BorderRadius.zero : BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 8),
                  Text(context.l10n.autoUploading, style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ),
        if (orientation == Orientation.portrait)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: isFullscreen ? BorderRadius.zero : BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.screen_rotation, color: Colors.white, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.pleaseHoldDeviceHorizontally,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black, offset: Offset(0, 2))],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // 錨點狀態 badge（僅非全螢幕）
        if (!isFullscreen)
          Positioned(
            top: 8,
            left: 8,
            child: GestureDetector(
              onTap: _enterFullscreen, // 引導進入全螢幕設定
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: state.anchorIsSet
                      ? const Color(0xFF00BFA5).withValues(alpha: 0.88)
                      : Colors.deepOrange.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: state.anchorIsSet ? const Color(0xFF00BFA5) : Colors.deepOrangeAccent,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      state.anchorIsSet ? Icons.my_location : Icons.warning_amber_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      state.anchorIsSet
                          ? context.l10n.anchorSet
                          : context.l10n.pleaseSetAnchorFullscreen,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSansTC',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );

    if (isFullscreen) {
      return content;
    }

    return ClipRRect(borderRadius: BorderRadius.circular(16), child: content);
  }
}

class _FullScreenCameraDialog extends ConsumerStatefulWidget {
  final _RecordCameraViewState cameraViewState;

  const _FullScreenCameraDialog({required this.cameraViewState});

  @override
  ConsumerState<_FullScreenCameraDialog> createState() => _FullScreenCameraDialogState();
}

// ── Anchor overlay constants ────────────────────────────────────
List<String> _getAnchorLabels(BuildContext context) {
  final l10n = context.l10n;
  return [l10n.point1, l10n.point2, l10n.point3, l10n.point4, l10n.point5, l10n.point6];
}

const _kAnchorColors = [
  Color(0xFF4FC3F7),
  Color(0xFF81C784),
  Color(0xFFFFB74D),
  Color(0xFFE57373),
  Color(0xFFCE93D8),
  Color(0xFFFFCC80),
];
const _kAnchorHitRadius = 12.0;
const _kAnchorMagRadius = 60.0;
const _kAnchorMagZoom = 2.8;

class _FullScreenCameraDialogState extends ConsumerState<_FullScreenCameraDialog> {
  // ── Camera state listener ───────────────────────────────────
  void _handleStateChange() {
    if (mounted) setState(() {});
  }

  // ── Anchor mode state ───────────────────────────────────────
  bool _anchorMode = false;
  final List<Offset> _pts = []; // normalised 0–1
  double _t5 = 0.5;
  double _t6 = 0.5;
  int? _draggingIdx;
  Offset? _magPos;
  Offset? _pendingTapNorm;
  int? _selectedActivePointIdx;
  Offset? _panStartTouchNorm;
  Offset? _panStartAnchorPos;

  // Cached image size (set in LayoutBuilder inside the anchor overlay)
  double _imgW = 1.0;
  double _imgH = 1.0;

  // Distance text controllers
  final _topCtrl = TextEditingController();
  final _botCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();

  // Snapshot taken when entering anchor mode (for magnifier)
  Uint8List? _snapshotBytes;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    widget.cameraViewState.addListener(_handleStateChange);

    // Pre-load existing anchor if already set
    final existing = ref.read(recordControllerProvider).anchorResult;
    if (existing != null) {
      _pts.addAll(existing.points.map((p) => Offset(p.x, p.y)));
      _topCtrl.text = existing.leftToMidDistanceM.toString();
      _botCtrl.text = existing.midToRightDistanceM.toString();
      _widthCtrl.text = existing.runwayWidthM.toString();
      _selectedActivePointIdx = null;

      if (_pts.length == 6) {
        final A5 = _pts[0];
        final B5 = _pts[1];
        final P5 = _pts[4];
        final AB5 = B5 - A5;
        final AP5 = P5 - A5;
        final lenSq5 = AB5.dx * AB5.dx + AB5.dy * AB5.dy;
        _t5 = lenSq5 > 0 ? ((AP5.dx * AB5.dx + AP5.dy * AB5.dy) / lenSq5).clamp(0.0, 1.0) : 0.5;

        final A6 = _pts[3];
        final B6 = _pts[2];
        final P6 = _pts[5];
        final AB6 = B6 - A6;
        final AP6 = P6 - A6;
        final lenSq6 = AB6.dx * AB6.dx + AB6.dy * AB6.dy;
        _t6 = lenSq6 > 0 ? ((AP6.dx * AB6.dx + AP6.dy * AB6.dy) / lenSq6).clamp(0.0, 1.0) : 0.5;
      } else if (_pts.length == 4) {
        final tm = Offset((_pts[0].dx + _pts[1].dx) / 2, (_pts[0].dy + _pts[1].dy) / 2);
        final bm = Offset((_pts[2].dx + _pts[3].dx) / 2, (_pts[2].dy + _pts[3].dy) / 2);
        _pts.add(tm);
        _pts.add(bm);
        _t5 = 0.5;
        _t6 = 0.5;
      }
    }
  }

  @override
  void dispose() {
    widget.cameraViewState.removeListener(_handleStateChange);
    _topCtrl.dispose();
    _botCtrl.dispose();
    _widthCtrl.dispose();
    final controller = widget.cameraViewState._controller;
    if (controller != null && controller.value.isInitialized) {
      try {
        controller.resumePreview();
      } catch (e) {
        if (kDebugMode) print('無法恢復相機預覽: $e');
      }
    }
    super.dispose();
  }

  // ── Anchor helpers ──────────────────────────────────────────
  bool get _full => _pts.length >= 4;
  int get _nextIdx => _pts.length;

  Offset _norm(Offset local) =>
      Offset((local.dx / _imgW).clamp(0.0, 1.0), (local.dy / _imgH).clamp(0.0, 1.0));

  bool _isMobile(BuildContext context) {
    final isMobilePlatform =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    final isShortScreen = MediaQuery.of(context).size.shortestSide < 600;
    return isMobilePlatform || isShortScreen;
  }

  void _updatePointPosition(int idx, Offset norm) {
    if (idx < 4) {
      if (idx < _pts.length) {
        _pts[idx] = norm;
      } else {
        while (_pts.length < idx) {
          _pts.add(norm);
        }
        _pts.add(norm);
      }
      if (_pts.length == 4) {
        final tm = Offset((_pts[0].dx + _pts[1].dx) / 2, (_pts[0].dy + _pts[1].dy) / 2);
        final bm = Offset((_pts[2].dx + _pts[3].dx) / 2, (_pts[2].dy + _pts[3].dy) / 2);
        _pts.add(tm);
        _pts.add(bm);
        _t5 = 0.5;
        _t6 = 0.5;
      } else if (_pts.length == 6) {
        _pts[4] = _pts[0] + (_pts[1] - _pts[0]) * _t5;
        _pts[5] = _pts[3] + (_pts[2] - _pts[3]) * _t6;
      }
    } else if (idx == 4 && _pts.length == 6) {
      final A = _pts[0];
      final B = _pts[1];
      final AB = B - A;
      final AP = norm - A;
      final abLenSq = AB.dx * AB.dx + AB.dy * AB.dy;
      double t = 0.5;
      if (abLenSq > 0) {
        t = (AP.dx * AB.dx + AP.dy * AB.dy) / abLenSq;
        t = t.clamp(0.0, 1.0);
      }
      _t5 = t;
      _pts[4] = A + AB * t;
    } else if (idx == 5 && _pts.length == 6) {
      final A = _pts[3];
      final B = _pts[2];
      final AB = B - A;
      final AP = norm - A;
      final abLenSq = AB.dx * AB.dx + AB.dy * AB.dy;
      double t = 0.5;
      if (abLenSq > 0) {
        t = (AP.dx * AB.dx + AP.dy * AB.dy) / abLenSq;
        t = t.clamp(0.0, 1.0);
      }
      _t6 = t;
      _pts[5] = A + AB * t;
    }
  }

  int? _nearestIdx(Offset normPos) {
    int? best;
    double bestDist = double.infinity;
    for (int i = 0; i < _pts.length; i++) {
      final dx = (normPos.dx - _pts[i].dx) * _imgW;
      final dy = (normPos.dy - _pts[i].dy) * _imgH;
      final d = dx * dx + dy * dy;
      if (d < _kAnchorHitRadius * _kAnchorHitRadius && d < bestDist) {
        bestDist = d;
        best = i;
      }
    }
    return best;
  }

  bool get _canConfirm => _full;

  Future<void> _showDistanceInputDialog(BuildContext context) async {
    final l10n = context.l10n;
    final formKey = GlobalKey<FormState>();
    final topTextCtrl = TextEditingController(
      text: _topCtrl.text.isNotEmpty ? _topCtrl.text : '10.0',
    );
    final botTextCtrl = TextEditingController(
      text: _botCtrl.text.isNotEmpty ? _botCtrl.text : '10.0',
    );
    final widthTextCtrl = TextEditingController(text: _widthCtrl.text);

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white12),
          ),
          title: Row(
            children: [
              const Icon(Icons.straighten, color: Color(0xFF00BFA5), size: 22),
              const SizedBox(width: 8),
              Text(
                l10n.distanceDialogTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.distanceDialogSubtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  // Left-to-Mid
                  TextFormField(
                    controller: topTextCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: l10n.distanceLeftToCenter,
                      labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                      suffixText: 'm',
                      suffixStyle: const TextStyle(color: Colors.white60),
                      prefixIcon: Icon(Icons.square, size: 12, color: _kAnchorColors[0]),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF00BFA5)),
                      ),
                    ),
                    validator: (val) {
                      final n = double.tryParse(val?.trim() ?? '');
                      if (n == null || n <= 0) return l10n.distanceInvalidPrompt;
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  // Mid-to-Right
                  TextFormField(
                    controller: botTextCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: l10n.distanceCenterToRight,
                      labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                      suffixText: 'm',
                      suffixStyle: const TextStyle(color: Colors.white60),
                      prefixIcon: Icon(Icons.square, size: 12, color: _kAnchorColors[4]),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF00BFA5)),
                      ),
                    ),
                    validator: (val) {
                      final n = double.tryParse(val?.trim() ?? '');
                      if (n == null || n <= 0) return l10n.distanceInvalidPrompt;
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: widthTextCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: l10n.runwayWidth,
                      labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                      suffixText: 'm',
                      suffixStyle: const TextStyle(color: Colors.white60),
                      prefixIcon: const Icon(
                        Icons.compare_arrows,
                        size: 18,
                        color: Color(0xFF81C784),
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF00BFA5)),
                      ),
                    ),
                    validator: (val) {
                      final n = double.tryParse(val?.trim() ?? '');
                      if (n == null || n <= 0) {
                        return l10n.distanceInvalidPrompt;
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: Text(l10n.cancel, style: const TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  _topCtrl.text = topTextCtrl.text.trim();
                  _botCtrl.text = botTextCtrl.text.trim();
                  _widthCtrl.text = widthTextCtrl.text.trim();
                  Navigator.of(dialogCtx).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BFA5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(l10n.applyAndSave, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    topTextCtrl.dispose();
    botTextCtrl.dispose();
    widthTextCtrl.dispose();

    if (confirmed == true) {
      _saveAnchorResult();
    }
  }

  void _saveAnchorResult() {
    final result = AnchorResult(
      points: _pts.map((o) => AnchorPoint(o.dx, o.dy)).toList(),
      leftToMidDistanceM: double.parse(_topCtrl.text),
      midToRightDistanceM: double.parse(_botCtrl.text),
      runwayWidthM: double.parse(_widthCtrl.text),
    );
    ref.read(recordControllerProvider.notifier).setAnchor(result);
    setState(() => _anchorMode = false);
    final controller = widget.cameraViewState._controller;
    if (controller != null && controller.value.isInitialized) {
      try {
        controller.resumePreview();
      } catch (e) {
        if (kDebugMode) print('無法恢復相機預覽: $e');
      }
    }
  }

  void _confirmAnchor() {
    _showDistanceInputDialog(context);
  }

  void _enterAnchorMode() async {
    if (_isCapturing) return;

    // Pre-load current anchor if any
    final existing = ref.read(recordControllerProvider).anchorResult;

    setState(() => _isCapturing = true);

    try {
      // 1. Take a snapshot of the current view for the magnifier
      final xFile = await widget.cameraViewState._controller?.takePicture();
      final bytes = await xFile?.readAsBytes();

      if (mounted) {
        setState(() {
          _pts.clear();
          if (existing != null) {
            _pts.addAll(existing.points.map((p) => Offset(p.x, p.y)));
            _topCtrl.text = existing.leftToMidDistanceM.toString();
            _botCtrl.text = existing.midToRightDistanceM.toString();
            _widthCtrl.text = existing.runwayWidthM.toString();
          } else {
            _topCtrl.clear();
            _botCtrl.clear();
            _widthCtrl.clear();
          }
          _snapshotBytes = bytes;
          _anchorMode = true;
          _isCapturing = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('擷取設定錨點預覽圖失敗: $e');
      if (mounted) {
        setState(() {
          _anchorMode = true; // Still enter mode even if snapshot fails
          _isCapturing = false;
        });
      }
    }
  }

  void _recaptureSnapshot() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      final xFile = await widget.cameraViewState._controller?.takePicture();
      final bytes = await xFile?.readAsBytes();
      if (mounted && bytes != null) {
        setState(() {
          _snapshotBytes = bytes;
          _isCapturing = false;
        });
      }
    } catch (e) {
      if (kDebugMode) print('重新擷取設定錨點預覽圖失敗: $e');
      if (mounted) {
        setState(() => _isCapturing = false);
      }
    }
  }

  // ── Gesture handlers ────────────────────────────────────────
  void _onTapDown(TapDownDetails d) {
    _pendingTapNorm = _norm(d.localPosition);
  }

  void _onTap() {
    final pos = _pendingTapNorm;
    _pendingTapNorm = null;
    if (pos == null) return;

    if (_isMobile(context) && _selectedActivePointIdx != null) {
      setState(() {
        final idx = _selectedActivePointIdx!;
        _updatePointPosition(idx, pos);
        if (_pts.length < 4) {
          _selectedActivePointIdx = _pts.length;
        }
      });
    } else {
      if (_full) return;
      if (_nearestIdx(pos) != null) return;
      setState(() {
        _pts.add(pos);
        if (_pts.length == 4) {
          final tm = Offset((_pts[0].dx + _pts[1].dx) / 2, (_pts[0].dy + _pts[1].dy) / 2);
          final bm = Offset((_pts[2].dx + _pts[3].dx) / 2, (_pts[2].dy + _pts[3].dy) / 2);
          _pts.add(tm);
          _pts.add(bm);
          _t5 = 0.5;
          _t6 = 0.5;
        }
      });
    }
  }

  void _onPanStart(DragStartDetails d) {
    if (_pts.isEmpty && !_isMobile(context)) return;
    final touchNorm = _norm(d.localPosition);
    _panStartTouchNorm = touchNorm;

    if (_isMobile(context) && _selectedActivePointIdx != null) {
      final idx = _selectedActivePointIdx!;
      setState(() {
        if (idx < _pts.length) {
          _panStartAnchorPos = _pts[idx];
          _draggingIdx = idx;
          _magPos = _pts[idx];
        } else {
          _updatePointPosition(idx, touchNorm);
          _panStartAnchorPos = _pts[idx];
          _draggingIdx = idx;
          _magPos = _pts[idx];
        }
      });
    } else {
      final idx = _nearestIdx(touchNorm);
      if (idx != null) {
        setState(() {
          _panStartAnchorPos = _pts[idx];
          _draggingIdx = idx;
          _magPos = _pts[idx];
          if (_isMobile(context)) {
            _selectedActivePointIdx = idx;
          }
        });
      }
    }
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_draggingIdx == null || _panStartTouchNorm == null || _panStartAnchorPos == null) return;
    final currentTouch = _norm(d.localPosition);
    final delta = currentTouch - _panStartTouchNorm!;
    final newPos = Offset(
      (_panStartAnchorPos!.dx + delta.dx).clamp(0.0, 1.0),
      (_panStartAnchorPos!.dy + delta.dy).clamp(0.0, 1.0),
    );
    setState(() {
      _updatePointPosition(_draggingIdx!, newPos);
      _magPos = _pts[_draggingIdx!];
    });
  }

  void _onPanEnd(DragEndDetails _) {
    setState(() {
      _draggingIdx = null;
      _magPos = null;
      _panStartTouchNorm = null;
      _panStartAnchorPos = null;
    });
  }

  // ── Build ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    ref.listen(recordControllerProvider.select((s) => s.status), (prev, next) {
      if (next == RecordStatus.idle || next == RecordStatus.connecting) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });

    ref.listen(recordControllerProvider.select((s) => s.roomId), (prev, next) {
      if (next == null) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }
    });

    ref.watch(recordControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 影像本體
          Center(
            child: RepaintBoundary(
              child: widget.cameraViewState._buildCameraPreviewStack(
                isFullscreen: true,
                isAnchorMode: _anchorMode,
                anchorOverlay: _anchorMode ? _buildAnchorOverlay() : null,
                snapshotBytes: _snapshotBytes,
              ),
            ),
          ),

          // 切換按鈕（當不在錨點模式時顯示）
          if (!_anchorMode)
            _isCapturing
                ? const Positioned(
                    top: 16,
                    left: 16,
                    child: SafeArea(child: CircularProgressIndicator(color: Colors.white)),
                  )
                : _buildAnchorToggleButton(),
        ],
      ),
    );
  }

  Widget _buildAnchorToggleButton() {
    final l10n = context.l10n;
    final isSet = ref.watch(recordControllerProvider.select((s) => s.anchorIsSet));
    return Positioned(
      top: 16,
      left: 16,
      child: SafeArea(
        child: GestureDetector(
          onTap: _enterAnchorMode,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSet ? const Color(0xFF00BFA5).withValues(alpha: 0.85) : Colors.black54,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSet ? const Color(0xFF00BFA5) : Colors.white24,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSet ? Icons.my_location : Icons.location_off_outlined,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  isSet ? l10n.anchorSet : l10n.setAnchor,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnchorOverlay() {
    final labels = _getAnchorLabels(context);
    return Positioned.fill(
      child: LayoutBuilder(
        builder: (_, constraints) {
          _imgW = constraints.maxWidth;
          _imgH = constraints.maxHeight;

          return GestureDetector(
            onTapDown: _onTapDown,
            onTap: _onTap,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Container(
              color: Colors.black.withValues(alpha: 0.35),
              child: Stack(
                children: [
                  // ── Quadrilateral ──────────────────────────
                  if (_pts.length >= 2)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _AnchorQuadPainter(
                          points: _pts,
                          width: _imgW,
                          height: _imgH,
                          draggingIdx: _draggingIdx,
                        ),
                      ),
                    ),

                  // ── Anchor markers ─────────────────────────
                  ..._pts.asMap().entries.map((e) {
                    final i = e.key;
                    final pt = e.value;
                    final isDragging = i == _draggingIdx;
                    final isActive = _isMobile(context) && i == _selectedActivePointIdx;
                    return Positioned(
                      left: pt.dx * _imgW,
                      top: pt.dy * _imgH,
                      child: _AnchorMarkerOverlay(
                        label: labels[i],
                        color: _kAnchorColors[i],
                        index: i + 1,
                        isDragging: isDragging,
                        isActive: isActive,
                      ),
                    );
                  }),

                  // ── Next-point badge（獨立 widget 持有動畫，不影響父層 build）
                  if (!_full && _draggingIdx == null)
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: _PulsingBadge(
                          color: _kAnchorColors[_nextIdx],
                          label: labels[_nextIdx],
                        ),
                      ),
                    ),

                  // ── Re-capture snapshot button (top right) ────────
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IgnorePointer(
                      ignoring: _draggingIdx != null,
                      child: AnimatedOpacity(
                        opacity: _draggingIdx != null ? 0.08 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: SafeArea(
                          child: InkWell(
                            onTap: _isCapturing ? null : _recaptureSnapshot,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _isCapturing
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 15,
                                          color: Colors.white,
                                        ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _isCapturing ? '...' : '📷',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Magnifier ──────────────────────────────
                  if (_draggingIdx != null && _magPos != null) _buildMagnifier(),

                  // ── Action bar & Anchor point buttons (bottom) ────────────────────
                  Positioned(
                    bottom: 16,
                    left: 12,
                    right: 12,
                    child: IgnorePointer(
                      ignoring: _draggingIdx != null,
                      child: AnimatedOpacity(
                        opacity: _draggingIdx != null ? 0.08 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isMobile(context)) ...[
                              _buildAnchorPointButtons(),
                              const SizedBox(height: 8),
                            ],
                            _buildActionBar(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMagnifier() {
    final norm = _magPos!;
    final cx = norm.dx * _imgW;
    final cy = norm.dy * _imgH;
    const r = _kAnchorMagRadius;
    const zoom = _kAnchorMagZoom;

    double left = cx - r;
    double top = cy - r * 2.4 - 10;
    left = left.clamp(0.0, _imgW - r * 2);
    top = top.clamp(0.0, _imgH - r * 2);

    final tx = r - cx * zoom;
    final ty = r - cy * zoom;
    final dragColor = _kAnchorColors[_draggingIdx!];

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: r * 2,
        height: r * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: dragColor, width: 2.5),
          boxShadow: [
            BoxShadow(color: dragColor.withValues(alpha: 0.45), blurRadius: 14, spreadRadius: 3),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // ── Background snapshot ────────────────────────
            if (_snapshotBytes != null)
              Positioned(
                left: tx,
                top: ty,
                width: _imgW * zoom,
                height: _imgH * zoom,
                child: Image.memory(
                  _snapshotBytes!,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                ),
              )
            else
              Container(color: Colors.black87),

            // ── Crosshair and markers ──────────────────────
            Positioned.fill(
              child: CustomPaint(
                painter: _LiveMagnifierPainter(
                  normPos: norm,
                  imgW: _imgW,
                  imgH: _imgH,
                  zoom: zoom,
                  tx: tx,
                  ty: ty,
                  points: _pts,
                  draggingIdx: _draggingIdx!,
                  color: dragColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    final l10n = context.l10n;
    return Row(
      children: [
        // Cancel
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _anchorMode = false;
              _draggingIdx = null;
              _magPos = null;
            });
            final controller = widget.cameraViewState._controller;
            if (controller != null && controller.value.isInitialized) {
              try {
                controller.resumePreview();
              } catch (e) {
                if (kDebugMode) print('無法恢復相機預覽: $e');
              }
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white70,
            side: const BorderSide(color: Colors.white30),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.close, size: 14),
          label: Text(l10n.cancel, style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 6),
        // Undo
        OutlinedButton.icon(
          onPressed: _pts.isEmpty
              ? null
              : () => setState(() {
                  if (_pts.length == 6) {
                    _pts.removeRange(3, 6);
                  } else {
                    _pts.removeLast();
                  }
                  _selectedActivePointIdx = _pts.length;
                }),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white60,
            side: const BorderSide(color: Colors.white24),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.undo, size: 14),
          label: Text(l10n.undo, style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: 6),
        // Reset
        OutlinedButton.icon(
          onPressed: _pts.isEmpty
              ? null
              : () => setState(() {
                  _pts.clear();
                  _selectedActivePointIdx = 0;
                }),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white38,
            side: const BorderSide(color: Colors.white12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.refresh, size: 14),
          label: Text(l10n.clear, style: const TextStyle(fontSize: 12)),
        ),
        const Spacer(),
        // Confirm
        AnimatedOpacity(
          opacity: _canConfirm ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: ElevatedButton.icon(
            onPressed: _canConfirm ? _confirmAnchor : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.check_circle_outline, size: 16),
            label: Text(
              l10n.confirmAnchor,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnchorPointButton(int i) {
    final labels = _getAnchorLabels(context);
    final isSet = i < _pts.length;
    final isActive = _selectedActivePointIdx == i;
    final color = _kAnchorColors[i];
    final isAvailable = i < 4 || _pts.length == 6;

    return Opacity(
      opacity: isAvailable ? 1.0 : 0.35,
      child: InkWell(
        onTap: isAvailable
            ? () {
                setState(() {
                  _selectedActivePointIdx = i;
                });
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: isActive
                ? color.withValues(alpha: 0.35)
                : (isSet ? color.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? color : (isSet ? color.withValues(alpha: 0.5) : Colors.white12),
              width: isActive ? 1.8 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSet ? color : Colors.transparent,
                  border: Border.all(
                    color: isSet ? Colors.white : color.withValues(alpha: 0.7),
                    width: 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: isSet
                    ? const Icon(Icons.check, size: 8, color: Colors.white)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  labels[i],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isActive ? Colors.white : (isSet ? Colors.white70 : Colors.white38),
                    fontSize: 10.5,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnchorPointButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        spacing: 4,
        children: List.generate(6, (i) => Expanded(child: _buildAnchorPointButton(i))),
      ),
    );
  }
}

class _CameraLoadingShimmer extends StatelessWidget {
  const _CameraLoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9, // 使用普遍的橫向比例，與初始化後的預期比例一致
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Shimmer.fromColors(
              baseColor: Theme.of(context).primaryColorDark.withValues(alpha: 0.3),
              highlightColor: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            LoadingIcon(),
          ],
        ),
      ),
    );
  }
}

// ── Anchor marker overlay ─────────────────────────────────────

class _AnchorMarkerOverlay extends StatelessWidget {
  final String label;
  final Color color;
  final int index;
  final bool isDragging;
  final bool isActive;

  const _AnchorMarkerOverlay({
    required this.label,
    required this.color,
    required this.index,
    this.isDragging = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = isDragging || isActive;
    final size = highlight ? 36.0 : 30.0;

    return Transform.translate(
      offset: Offset(0, -size / 2),
      child: FractionalTranslation(
        translation: const Offset(-0.5, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: Border.all(
                  color: highlight ? Colors.white : Colors.white70,
                  width: highlight ? 2.5 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: highlight ? 0.85 : 0.55),
                    blurRadius: highlight ? 16 : 8,
                    spreadRadius: highlight ? 3 : 1,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '$index',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: highlight ? 15 : 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: highlight ? 1.0 : 0.85),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansTC',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quad painter for live overlay ────────────────────────────

class _AnchorQuadPainter extends CustomPainter {
  final List<Offset> points;
  final double width;
  final double height;
  final int? draggingIdx;

  const _AnchorQuadPainter({
    required this.points,
    required this.width,
    required this.height,
    this.draggingIdx,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final pts = points.map((p) => Offset(p.dx * width, p.dy * height)).toList();

    final paint = Paint()
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    if (pts.length == 6) {
      final drawLine = (int pA, int pB, Color color) {
        final isDragEdge = draggingIdx != null && (draggingIdx == pA || draggingIdx == pB);
        paint
          ..color = color.withValues(alpha: isDragEdge ? 1.0 : 0.8)
          ..strokeWidth = isDragEdge ? 2.8 : 2.2;
        canvas.drawLine(pts[pA], pts[pB], paint);
      };

      // Left boundary (BL - TL)
      drawLine(3, 0, _kAnchorColors[3]);
      // Right boundary (TR - BR)
      drawLine(1, 2, _kAnchorColors[1]);
      // Top boundary segment 1 (TL - TM)
      drawLine(0, 4, _kAnchorColors[0]);
      // Top boundary segment 2 (TM - TR)
      drawLine(4, 1, _kAnchorColors[0]);
      // Bottom boundary segment 1 (BR - BM)
      drawLine(2, 5, _kAnchorColors[2]);
      // Bottom boundary segment 2 (BM - BL)
      drawLine(5, 3, _kAnchorColors[2]);
      // Middle line (TM - BM)
      drawLine(4, 5, _kAnchorColors[4]);

      // Semi-transparent fill of the entire quad area
      final path = Path()..addPolygon([pts[0], pts[1], pts[2], pts[3]], true);
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF2979FF).withValues(alpha: 0.10)
          ..style = PaintingStyle.fill,
      );
    } else {
      // Legacy / intermediate drawing (less than 6 points)
      for (int i = 0; i < pts.length - 1; i++) {
        final isDragEdge = draggingIdx != null && (i == draggingIdx || i + 1 == draggingIdx);
        paint
          ..color = _kAnchorColors[i].withValues(alpha: isDragEdge ? 1.0 : 0.8)
          ..strokeWidth = isDragEdge ? 2.8 : 2.2;
        canvas.drawLine(pts[i], pts[i + 1], paint);
      }

      if (pts.length == 4) {
        final isDragEdge = draggingIdx != null && (draggingIdx == 3 || draggingIdx == 0);
        paint
          ..color = _kAnchorColors[3].withValues(alpha: isDragEdge ? 1.0 : 0.8)
          ..strokeWidth = isDragEdge ? 2.8 : 2.2;
        canvas.drawLine(pts[3], pts[0], paint);

        final path = Path()..addPolygon(pts, true);
        canvas.drawPath(
          path,
          Paint()
            ..color = const Color(0xFF2979FF).withValues(alpha: 0.12)
            ..style = PaintingStyle.fill,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_AnchorQuadPainter old) =>
      old.points != points ||
      old.width != width ||
      old.height != height ||
      old.draggingIdx != draggingIdx;
}

// ── Live magnifier painter ────────────────────────────────────
// Since we cannot clone the CameraPreview texture, we draw the anchor
// positions at zoom scale inside the magnifier circle so the user can
// at least see where the crosshair lands relative to the other points.

class _LiveMagnifierPainter extends CustomPainter {
  final Offset normPos;
  final double imgW;
  final double imgH;
  final double zoom;
  final double tx;
  final double ty;
  final List<Offset> points;
  final int draggingIdx;
  final Color color;

  const _LiveMagnifierPainter({
    required this.normPos,
    required this.imgW,
    required this.imgH,
    required this.zoom,
    required this.tx,
    required this.ty,
    required this.points,
    required this.draggingIdx,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Draw other anchor point dots at zoomed positions
    for (int i = 0; i < points.length; i++) {
      if (i == draggingIdx) continue;
      final px = points[i].dx * imgW * zoom + tx;
      final py = points[i].dy * imgH * zoom + ty;
      canvas.drawCircle(
        Offset(px, py),
        5,
        Paint()..color = _kAnchorColors[i].withValues(alpha: 0.8),
      );
    }

    // Crosshair lines (gap + line)
    const gap = 6.0;
    const lineLen = 16.0;
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(cx - gap - lineLen, cy), Offset(cx - gap, cy), linePaint);
    canvas.drawLine(Offset(cx + gap, cy), Offset(cx + gap + lineLen, cy), linePaint);
    canvas.drawLine(Offset(cx, cy - gap - lineLen), Offset(cx, cy - gap), linePaint);
    canvas.drawLine(Offset(cx, cy + gap), Offset(cx, cy + gap + lineLen), linePaint);

    // Center dot
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = color);
    canvas.drawCircle(
      Offset(cx, cy),
      4,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_LiveMagnifierPainter old) => true;
}

// ── Pulsing badge ─────────────────────────────────────────────
// Owns its own AnimationController so parent doesn't rebuild on every tick.

class _PulsingBadge extends StatefulWidget {
  final Color color;
  final String label;

  const _PulsingBadge({required this.color, required this.label});

  @override
  State<_PulsingBadge> createState() => _PulsingBadgeState();
}

class _PulsingBadgeState extends State<_PulsingBadge> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.85,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.scale(
        scale: _anim.value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSansTC',
            ),
          ),
        ),
      ),
    );
  }
}
