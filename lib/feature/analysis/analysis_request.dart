import 'package:frontend/entities/upload_video_file.dart';
import 'package:frontend/feature/upload/widget/anchor_point_dialog.dart';

/// One camera's input video and the metadata the analysis needs about it
/// (規劃書 §4 "每支影片的 fps、方向與實際 frame size"). `file` is only read by
/// [ServerAnalysisAdapter]; a Local run (once Step 12's native bridge exists)
/// uses `path` instead so it never has to read a whole video into Dart heap
/// (規劃書 §6 Local 路徑 step 1 / §8 "避免 withData: true 將多支影片同時載入").
class AnalysisVideoInput {
  const AnalysisVideoInput({
    required this.cameraIndex,
    required this.fps,
    required this.rotationDegrees,
    required this.frameWidth,
    required this.frameHeight,
    this.file,
    this.path,
    this.tempVideoId,
    this.anchors,
  }) : assert(
         file != null || path != null,
         'AnalysisVideoInput needs either in-memory bytes (Server) or a file path (Local)',
       );

  final int cameraIndex;
  final double fps;
  final int rotationDegrees;
  final int frameWidth;
  final int frameHeight;
  final UploadVideoFile? file;
  final String? path;
  final String? tempVideoId;

  /// Per-camera homography calibration (規劃書 §4 "anchors / homography
  /// calibration"), matching `upload_all_view.dart`'s existing per-video
  /// anchor model - not a single request-wide value.
  final AnchorResult? anchors;
}

/// A single request to analyze one session, shared by every [AnalysisMode]
/// (規劃書 §4 "AnalysisRequest 至少包含"). Local/Compare's V1 scope is
/// "Upload All" only (規劃書 §1 第 5 點), so this mirrors that flow's existing
/// metadata rather than the separate per-camera "Upload Separate" shape.
class AnalysisRequest {
  const AnalysisRequest({
    this.schemaVersion = '1.0.0',
    this.requestId,
    this.comparisonGroupId,
    required this.runnerId,
    required this.date,
    required this.cameraCount,
    required this.videos,
    required this.fps,
    this.note = '',
    this.isLongJump = false,
    this.generateOverlay = true,
  }) : assert(
         videos.length == cameraCount,
         'videos must have exactly cameraCount entries, sorted by cameraIndex',
       );

  final String schemaVersion;
  final String? requestId;
  final String? comparisonGroupId;
  final String runnerId;
  final DateTime date;
  final int cameraCount;
  final List<AnalysisVideoInput> videos;
  final int fps;
  final String note;
  final bool isLongJump;

  /// Output policy (規劃書 §4): whether to produce a large overlay video.
  final bool generateOverlay;

  AnalysisRequest withRunIdentifiers({required String requestId, String? comparisonGroupId}) =>
      AnalysisRequest(
        schemaVersion: schemaVersion,
        requestId: requestId,
        comparisonGroupId: comparisonGroupId ?? this.comparisonGroupId,
        runnerId: runnerId,
        date: date,
        cameraCount: cameraCount,
        videos: videos,
        fps: fps,
        note: note,
        isLongJump: isLongJump,
        generateOverlay: generateOverlay,
      );
}
