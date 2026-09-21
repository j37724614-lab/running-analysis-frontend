import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/feature/guide/guide_steps_factory.dart';
import 'package:frontend/feature/record/record_controller.dart';
import 'package:frontend/feature/record/record_enums.dart';
import 'package:frontend/utils/locale_provider.dart';

// ── Anchor Colors & Coordinates ─────────────────────────────────

const _kAnchorColors = [
  Color(0xFF4FC3F7), // TL - 淺藍
  Color(0xFF81C784), // TR - 淺綠
  Color(0xFFFFB74D), // BR - 橘黃
  Color(0xFFE57373), // BL - 珊瑚紅
  Color(0xFFCE93D8), // TM - 淺紫
  Color(0xFFFFCC80), // BM - 淺橘
];

List<String> _getAnchorLabels(BuildContext context) {
  final l10n = context.l10n;
  return [l10n.point1, l10n.point2, l10n.point3, l10n.point4, l10n.point5, l10n.point6];
}

bool _isMobile(BuildContext context) {
  final isMobilePlatform =
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  final isShortScreen = MediaQuery.of(context).size.shortestSide < 600;
  return isMobilePlatform || isShortScreen;
}

/// 導覽專用相機預覽模擬視圖（使用真實跑道影像，不索取實體相機權限）
class RecordTourCameraPlaceholderView extends StatelessWidget {
  const RecordTourCameraPlaceholderView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 跑道真實底圖
            Image.asset('assets/mock_runner_frame.jpg', fit: BoxFit.cover),

            // 跑道錨點多邊形覆蓋
            CustomPaint(painter: _MockAnchorQuadPainter()),

            // 左上角：錨點狀態標籤
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFA5).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.my_location, size: 13, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      l10n.anchorSet,
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

            // 右上角：全螢幕校正按鈕
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Icon(Icons.fullscreen, color: Colors.white, size: 24),
              ),
            ),

            // 左側：變焦滑桿模擬
            Positioned(
              left: 14,
              bottom: 20,
              top: 40,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 100,
                    width: 32,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Container(
                        width: 4,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '1.0x',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 底部中央：更換鏡頭按鈕
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.switchLens,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.flip_camera_ios, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 導覽專用全螢幕跑道錨點校正模擬視窗
class RecordTourAnchorFullscreenDialog extends ConsumerStatefulWidget {
  const RecordTourAnchorFullscreenDialog({super.key});

  @override
  ConsumerState<RecordTourAnchorFullscreenDialog> createState() =>
      _RecordTourAnchorFullscreenDialogState();
}

class _RecordTourAnchorFullscreenDialogState
    extends ConsumerState<RecordTourAnchorFullscreenDialog> {
  // Ground-truth normalized anchor coordinates (0~1)
  final List<Offset> _pts = [
    const Offset(0.0914, 0.6612), // TL (Pt 1)
    const Offset(0.9147, 0.6504), // TR (Pt 2)
    const Offset(0.9706, 0.6598), // BR (Pt 3)
    const Offset(0.0386, 0.6709), // BL (Pt 4)
    const Offset(0.5037, 0.6558), // TM (Pt 5)
    const Offset(0.5036, 0.6654), // BM (Pt 6)
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = _getAnchorLabels(context);
    final stage = ref.watch(recordTourAnchorStageProvider);
    final demoRole = ref.watch(recordTourDemoRoleProvider);

    final isAnchorMode =
        stage == RecordTourAnchorStage.anchorMode || stage == RecordTourAnchorStage.distanceDialog;
    final isCalibrated = stage == RecordTourAnchorStage.calibratedFullscreen;

    return Positioned.fill(
      child: Material(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. 固定 16:9 比例置中影像區塊 ──
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  key: isAnchorMode ? GuideKeys.recordAnchorCanvasKey : null,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.05),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final w = constraints.maxWidth;
                      final h = constraints.maxHeight;

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          // 跑道底圖 (固定 16:9 完整呈現)
                          Image.asset(
                            'assets/mock_runner_frame.jpg',
                            fit: BoxFit.cover,
                            width: w,
                            height: h,
                          ),

                          // ── 錨點模式圖層（僅在校正中或設定距離時顯示） ──
                          if (isAnchorMode) ...[
                            // 錨點四邊形連線、中線與空間區域覆蓋面
                            CustomPaint(
                              size: Size(w, h),
                              painter: _FullscreenAnchorQuadPainter(pts: _pts),
                            ),

                            // 6 顆跑道錨點標記
                            ...List.generate(_pts.length, (i) {
                              final px = _pts[i].dx * w;
                              final py = _pts[i].dy * h;
                              return Positioned(
                                left: px - 16,
                                top: py - 16,
                                child: _AnchorMarkerBadge(
                                  index: i + 1,
                                  color: _kAnchorColors[i],
                                  label: labels[i],
                                ),
                              );
                            }),

                            // 16:9 內部右上角：重新拍照按鈕模擬
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.camera_alt_outlined, size: 14, color: Colors.white),
                                    SizedBox(width: 4),
                                    Text(
                                      '📷',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // 16:9 內部底部操作列 (包含行動裝置 6 顆錨點選擇按鈕)
                            Positioned(
                              bottom: 10,
                              left: 12,
                              right: 12,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isMobile(context)) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.55),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.white12),
                                      ),
                                      child: Row(
                                        children: List.generate(
                                          6,
                                          (i) => Expanded(
                                            child: Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 2),
                                              padding: const EdgeInsets.symmetric(vertical: 4),
                                              decoration: BoxDecoration(
                                                color: i == 0
                                                    ? _kAnchorColors[i].withValues(alpha: 0.35)
                                                    : _kAnchorColors[i].withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: i == 0
                                                      ? _kAnchorColors[i]
                                                      : _kAnchorColors[i].withValues(alpha: 0.5),
                                                  width: i == 0 ? 1.8 : 1.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 14,
                                                    height: 14,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: _kAnchorColors[i],
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 1.0,
                                                      ),
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: const Icon(
                                                      Icons.check,
                                                      size: 8,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Flexible(
                                                    child: Text(
                                                      labels[i],
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: i == 0
                                                            ? Colors.white
                                                            : Colors.white70,
                                                        fontSize: 9.5,
                                                        fontWeight: i == 0
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                  Row(
                                    children: [
                                      // 取消 (返回一般全螢幕預覽)
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          ref.read(recordTourAnchorStageProvider.notifier).state =
                                              RecordTourAnchorStage.normalFullscreen;
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white70,
                                          side: const BorderSide(color: Colors.white30),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.close, size: 14),
                                        label: Text(
                                          l10n.cancel,
                                          style: const TextStyle(fontSize: 11.5),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      // 復原
                                      OutlinedButton.icon(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white60,
                                          side: const BorderSide(color: Colors.white24),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.undo, size: 14),
                                        label: Text(
                                          l10n.undo,
                                          style: const TextStyle(fontSize: 11.5),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      // 重設
                                      OutlinedButton.icon(
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white38,
                                          side: const BorderSide(color: Colors.white12),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.refresh, size: 14),
                                        label: Text(
                                          l10n.clear,
                                          style: const TextStyle(fontSize: 11.5),
                                        ),
                                      ),
                                      const Spacer(),
                                      // 儲存錨點
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          ref.read(recordTourAnchorStageProvider.notifier).state =
                                              RecordTourAnchorStage.distanceDialog;
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF00BFA5),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        icon: const Icon(Icons.check_circle_outline, size: 15),
                                        label: Text(
                                          l10n.confirmAnchor,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // ── 一般/校正完成相機預覽圖層 (未在錨點校正畫布中，維持畫面乾淨無錨點) ──
                          if (!isAnchorMode) ...[
                            // 縮放拉桿模擬
                            Positioned(
                              left: 14,
                              top: 30,
                              bottom: 30,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.zoom_in, color: Colors.white, size: 16),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: 4,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: Colors.white30,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        '1.0x',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // 底部鏡頭切換
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        l10n.switchLens,
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.flip_camera_ios,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // 底部右側開始錄影按鈕 (僅主控端)
                            if (demoRole == RecordRole.master)
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: ElevatedButton.icon(
                                  key: GuideKeys.recordFullscreenRecordKey,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  onPressed: () {},
                                  icon: const Icon(Icons.fiber_manual_record, size: 14),
                                  label: Text(
                                    l10n.startRecording,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // ── 2. 頂部左側：設定錨點 / 錨點已設定 按鈕 ──
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: GestureDetector(
                  key:
                      (stage == RecordTourAnchorStage.normalFullscreen ||
                          stage == RecordTourAnchorStage.calibratedFullscreen)
                      ? GuideKeys.recordAnchorToggleKey
                      : null,
                  onTap: () {
                    if (isAnchorMode) {
                      ref.read(recordTourAnchorStageProvider.notifier).state =
                          RecordTourAnchorStage.normalFullscreen;
                    } else {
                      ref.read(recordTourAnchorStageProvider.notifier).state =
                          RecordTourAnchorStage.anchorMode;
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: (isCalibrated || isAnchorMode)
                          ? const Color(0xFF00BFA5).withValues(alpha: 0.9)
                          : Colors.black54,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: (isCalibrated || isAnchorMode)
                            ? const Color(0xFF00BFA5)
                            : Colors.white24,
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCalibrated
                              ? Icons.my_location
                              : (isAnchorMode ? Icons.my_location : Icons.location_off_outlined),
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isCalibrated
                              ? l10n.anchorSet
                              : (isAnchorMode ? '${l10n.anchorSet} (6 / 6)' : l10n.setAnchor),
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
            ),

            // ── 3. 頂部右側：離開全螢幕按鈕 ──
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: GestureDetector(
                  key: GuideKeys.recordExitFullscreenKey,
                  onTap: () {
                    ref.read(recordTourAnchorFullscreenOpenProvider.notifier).state = false;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 26),
                  ),
                ),
              ),
            ),

            // ── 4. 步驟 9：跑道實際長度輸入對話框 (Modal Overlay) ──
            if (stage == RecordTourAnchorStage.distanceDialog)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.6),
                  alignment: Alignment.center,
                  child: _buildDistanceModalDialog(context, l10n),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceModalDialog(BuildContext context, dynamic l10n) {
    return Container(
      key: GuideKeys.recordDistanceDialogKey,
      width: 360,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 24, spreadRadius: 4)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          const SizedBox(height: 8),
          Text(
            l10n.distanceDialogSubtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 12.5),
          ),
          const SizedBox(height: 16),
          // 頂部/左至中距離輸入欄位
          TextFormField(
            initialValue: '10.0',
            readOnly: true,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: l10n.distanceLeftToCenter,
              labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
              suffixText: 'm',
              suffixStyle: const TextStyle(color: Colors.white60),
              prefixIcon: const Icon(Icons.square, size: 12, color: Color(0xFF4FC3F7)),
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
          ),
          const SizedBox(height: 12),
          // 底部/中至右距離輸入欄位
          TextFormField(
            initialValue: '10.0',
            readOnly: true,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              labelText: l10n.distanceCenterToRight,
              labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
              suffixText: 'm',
              suffixStyle: const TextStyle(color: Colors.white60),
              prefixIcon: const Icon(Icons.square, size: 12, color: Color(0xFFCE93D8)),
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
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  ref.read(recordTourAnchorStageProvider.notifier).state =
                      RecordTourAnchorStage.anchorMode;
                },
                child: Text(l10n.cancel, style: const TextStyle(color: Colors.white60)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  ref.read(recordTourAnchorStageProvider.notifier).state =
                      RecordTourAnchorStage.calibratedFullscreen;
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(l10n.applyAndSave, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 錨點圖釘徽章
class _AnchorMarkerBadge extends StatelessWidget {
  final int index;
  final Color color;
  final String label;

  const _AnchorMarkerBadge({required this.index, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 2),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSansTC',
            ),
          ),
        ),
      ],
    );
  }
}

// ── Custom Painters ─────────────────────────────────────────────

class _MockAnchorQuadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final p1 = Offset(0.0914 * w, 0.6612 * h);
    final p2 = Offset(0.9147 * w, 0.6504 * h);
    final p3 = Offset(0.9706 * w, 0.6598 * h);
    final p4 = Offset(0.0386 * w, 0.6709 * h);

    final path = Path()
      ..moveTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..lineTo(p3.dx, p3.dy)
      ..lineTo(p4.dx, p4.dy)
      ..close();

    // 跑道覆蓋色
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2979FF).withValues(alpha: 0.15)
        ..style = PaintingStyle.fill,
    );

    // 邊線
    final linePaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.85)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, linePaint);

    // 點
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(p1, 4, dotPaint);
    canvas.drawCircle(p2, 4, dotPaint);
    canvas.drawCircle(p3, 4, dotPaint);
    canvas.drawCircle(p4, 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FullscreenAnchorQuadPainter extends CustomPainter {
  final List<Offset> pts;

  const _FullscreenAnchorQuadPainter({required this.pts});

  @override
  void paint(Canvas canvas, Size size) {
    if (pts.length < 6) return;
    final w = size.width;
    final h = size.height;

    final pTL = Offset(pts[0].dx * w, pts[0].dy * h); // Pt 1
    final pTR = Offset(pts[1].dx * w, pts[1].dy * h); // Pt 2
    final pBR = Offset(pts[2].dx * w, pts[2].dy * h); // Pt 3
    final pBL = Offset(pts[3].dx * w, pts[3].dy * h); // Pt 4
    final pTM = Offset(pts[4].dx * w, pts[4].dy * h); // Pt 5
    final pBM = Offset(pts[5].dx * w, pts[5].dy * h); // Pt 6

    final paint = Paint()
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    // 1. 跑道區域半透明覆蓋填充
    final path = Path()
      ..moveTo(pTL.dx, pTL.dy)
      ..lineTo(pTR.dx, pTR.dy)
      ..lineTo(pBR.dx, pBR.dy)
      ..lineTo(pBL.dx, pBL.dy)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF2979FF).withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );

    // 2. 繪製六點連線
    // 左邊界 (BL -> TL)
    paint.color = _kAnchorColors[3];
    canvas.drawLine(pBL, pTL, paint);

    // 右邊界 (TR -> BR)
    paint.color = _kAnchorColors[1];
    canvas.drawLine(pTR, pBR, paint);

    // 頂邊界 (TL -> TM -> TR)
    paint.color = _kAnchorColors[0];
    canvas.drawLine(pTL, pTM, paint);
    canvas.drawLine(pTM, pTR, paint);

    // 底邊界 (BR -> BM -> BL)
    paint.color = _kAnchorColors[2];
    canvas.drawLine(pBR, pBM, paint);
    canvas.drawLine(pBM, pBL, paint);

    // 中線 (TM -> BM)
    paint.color = _kAnchorColors[4];
    canvas.drawLine(pTM, pBM, paint);
  }

  @override
  bool shouldRepaint(covariant _FullscreenAnchorQuadPainter oldDelegate) => oldDelegate.pts != pts;
}
