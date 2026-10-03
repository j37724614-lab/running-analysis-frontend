import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/backend/backend_provider.dart';
import 'package:frontend/entities/unanalyzed_run_session_info.dart';
import 'package:frontend/feature/upload/upload_controller.dart';
import 'package:frontend/feature/upload/upload_provider.dart';
import 'package:frontend/utils/locale_provider.dart';
import 'package:frontend/widget/async_value_widget.dart';
import 'package:frontend/feature/playback/shimmer/runner_history_shimmer.dart';
import 'package:frontend/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

/// Helper function to construct the share URL for an unanalyzed run session
String getSessionShareUrl(String runSessionId) {
  if (kIsWeb) {
    final base = Uri.base;
    final origin = '${base.scheme}://${base.host}${base.hasPort ? ':${base.port}' : ''}';
    var path = base.path;
    if (path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }
    if (path.contains('/running_analysis')) {
      path = '/running_analysis';
    } else if (path.isEmpty || path == '/record' || path == '/playback' || path == '/upload') {
      path = '';
    }
    return '$origin$path/upload?runSessionId=$runSessionId';
  } else {
    return 'https://catslab.ee.ncku.edu.tw/running_analysis/upload?runSessionId=$runSessionId';
  }
}

class UnanalyzedHistoryView extends ConsumerStatefulWidget {
  const UnanalyzedHistoryView({super.key, required this.onVideoSelected});

  final Function(UnanalyzedRunSessionInfo video) onVideoSelected;

  @override
  ConsumerState<UnanalyzedHistoryView> createState() => _UnanalyzedHistoryViewState();
}

class _UnanalyzedHistoryViewState extends ConsumerState<UnanalyzedHistoryView> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoadingCode = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  String _extractSessionId(String input) {
    input = input.trim();
    final uri = Uri.tryParse(input);
    if (uri != null && uri.queryParameters.containsKey('runSessionId')) {
      return uri.queryParameters['runSessionId']!;
    }
    final match = RegExp(
      r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
    ).firstMatch(input);
    if (match != null) {
      return match.group(0)!;
    }
    return input;
  }

  Future<void> _loadSessionByCode() async {
    final rawInput = _codeController.text.trim();
    if (rawInput.isEmpty) return;

    final sessionId = _extractSessionId(rawInput);
    final l10n = context.l10n;
    setState(() => _isLoadingCode = true);

    try {
      final session = await ref.read(backendProvider).getUnanalyzedRunSessionById(sessionId);
      if (mounted) {
        setState(() => _isLoadingCode = false);
        if (session != null) {
          var runners = ref.read(uploadRunnerListProvider).value;
          if (runners == null) {
            try {
              runners = await ref.read(backendProvider).getRunners();
            } catch (_) {
              runners = [];
            }
          }
          final isOwnRunner = runners.any((r) => r.id == session.runnerId);

          if (isOwnRunner) {
            ref.read(uploadExternalSessionInfoProvider.notifier).state = null;
            ref.read(uploadSelectedRunnerIdProvider.notifier).state = session.runnerId;
            ref.read(uploadSelectedRunSessionIdProvider.notifier).state = session.runSessionId;
          } else {
            ref.read(uploadExternalSessionInfoProvider.notifier).state = session;
            ref.read(uploadSelectedRunnerIdProvider.notifier).state = null;
            ref.read(uploadSelectedRunSessionIdProvider.notifier).state = session.runSessionId;
          }
          widget.onVideoSelected(session);
          _codeController.clear();
          if (mounted) {
            toastification.show(
              context: context,
              title: Text(l10n.loadSessionSuccess),
              type: ToastificationType.success,
              style: ToastificationStyle.minimal,
              alignment: Alignment.bottomCenter,
              autoCloseDuration: const Duration(seconds: 3),
            );
          }
        } else {
          toastification.show(
            context: context,
            title: Text(l10n.loadSessionFailed),
            type: ToastificationType.error,
            style: ToastificationStyle.minimal,
            alignment: Alignment.bottomCenter,
            autoCloseDuration: const Duration(seconds: 4),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingCode = false);
        toastification.show(
          context: context,
          title: Text(l10n.loadSessionFailed),
          type: ToastificationType.error,
          style: ToastificationStyle.minimal,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(seconds: 4),
        );
      }
    }
  }

  Widget _buildCodeSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 36,
              child: TextField(
                controller: _codeController,
                style: const TextStyle(fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: l10n.sessionCodeInputHint,
                  hintStyle: TextStyle(fontSize: 11.5, color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  prefixIcon: const Icon(Icons.link_rounded, size: 16, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).primaryColorDark),
                  ),
                ),
                onSubmitted: (_) => _loadSessionByCode(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _isLoadingCode ? null : _loadSessionByCode,
              child: _isLoadingCode
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      l10n.loadSession,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExternalSessionCard(
    UnanalyzedRunSessionInfo session,
    String? videoId,
    AppLocalizations l10n,
  ) {
    final isSelected = session.runSessionId == videoId;
    final missingCount = session.unuploadedCameraIndexes.length;
    final missingCamerasStr = session.unuploadedCameraIndexes.map((i) => "${i + 1}").join(', ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2A3E5C) : const Color(0xFFF0F4FA),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF2A3E5C) : Theme.of(context).primaryColorDark,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: () {
              ref.read(uploadSelectedRunSessionIdProvider.notifier).state = session.runSessionId;
              ref.read(uploadSelectedRunnerIdProvider.notifier).state = null;
              widget.onVideoSelected(session);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.2)
                          : Theme.of(context).primaryColor.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_download_rounded,
                      color: isSelected ? Colors.white : Theme.of(context).primaryColorDark,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Theme.of(context).primaryColorDark.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.sharedSessionBadge,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                session.runnerName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Wrap(
                          spacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(session.date),
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected ? Colors.white70 : Colors.grey.shade700,
                              ),
                            ),
                            if (missingCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected ? Colors.white30 : Colors.orange.shade200,
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  l10n.missingCameras(missingCamerasStr),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: isSelected ? Colors.white70 : Colors.grey,
                    ),
                    onPressed: () {
                      ref.read(uploadExternalSessionInfoProvider.notifier).state = null;
                      if (ref.read(uploadSelectedRunSessionIdProvider) == session.runSessionId) {
                        ref.read(uploadSelectedRunSessionIdProvider.notifier).state = null;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard({
    required UnanalyzedRunSessionInfo video,
    required bool isSelected,
    required AppLocalizations l10n,
  }) {
    final missingCount = video.unuploadedCameraIndexes.length;
    final missingCamerasStr = video.unuploadedCameraIndexes.map((i) => "${i + 1}").join(', ');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColorDark : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColorDark
                : Theme.of(context).primaryColor.withValues(alpha: 0.35),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(9),
            onTap: () {
              ref.read(uploadSelectedRunSessionIdProvider.notifier).state = video.runSessionId;
              ref.read(uploadSelectedRunnerIdProvider.notifier).state = video.runnerId;
              widget.onVideoSelected(video);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  // Left Icon
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.15)
                          : Theme.of(context).primaryColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.directions_run,
                      color: isSelected ? Colors.white : Theme.of(context).primaryColorDark,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Middle Column: Combined Single Line Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Main Information Row (Date + Cameras + Missing Tag)
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 2,
                          children: [
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(video.date),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.videocam_outlined,
                                  size: 13,
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  "${video.cameraCount} ${l10n.cameras}",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.8)
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                            if (missingCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.2)
                                      : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isSelected ? Colors.white30 : Colors.orange.shade200,
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  l10n.missingCameras(missingCamerasStr),
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : Colors.orange.shade800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (video.note.trim().isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            video.note,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontStyle: FontStyle.italic,
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: l10n.copySessionLink,
                    icon: Icon(
                      Icons.share_outlined,
                      size: 16,
                      color: isSelected ? Colors.white70 : Colors.grey.shade600,
                    ),
                    onPressed: () {
                      final shareUrl = getSessionShareUrl(video.runSessionId);
                      Clipboard.setData(ClipboardData(text: shareUrl));
                      toastification.show(
                        context: context,
                        title: Text(l10n.sessionLinkCopied),
                        type: ToastificationType.success,
                        style: ToastificationStyle.minimal,
                        alignment: Alignment.bottomCenter,
                        autoCloseDuration: const Duration(seconds: 3),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final runnerId = ref.watch(uploadSelectedRunnerIdProvider);
    final videoId = ref.watch(uploadSelectedRunSessionIdProvider);
    final externalSession = ref.watch(uploadExternalSessionInfoProvider);

    // If no runner is selected and no external session loaded, show code search bar and blurred skeleton placeholder cards
    if (runnerId == null && externalSession == null) {
      return _UnanalyzedHistoryPanelWrapper(
        title: l10n.pleaseSelectRecordToUpload,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCodeSearchBar(l10n),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 2),
                itemCount: 2,
                itemBuilder: (context, index) {
                  return const _OneUnanalyzedHistoryPlaceholder();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline_rounded, size: 13, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      l10n.selectRunnerOrEnterCodePrompt,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (runnerId == null && externalSession != null) {
      return _UnanalyzedHistoryPanelWrapper(
        title: l10n.pleaseSelectRecordToUpload,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCodeSearchBar(l10n),
            _buildExternalSessionCard(externalSession, videoId, l10n),
          ],
        ),
      );
    }

    final runnerHistory = ref.watch(runnerUnanalyzedHistoryProvider(runnerId!));
    return AsyncValueWidget(
      value: runnerHistory,
      loading: const _UnanalyzedHistoryPanelWrapper(child: RunnerHistoryShimmer()),
      data: (List<UnanalyzedRunSessionInfo> videos) {
        final hasVideos = videos.isNotEmpty || externalSession != null;

        return _UnanalyzedHistoryPanelWrapper(
          title: l10n.pleaseSelectRecordToUpload,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCodeSearchBar(l10n),
              if (externalSession != null &&
                  !videos.any((v) => v.runSessionId == externalSession.runSessionId))
                _buildExternalSessionCard(externalSession, videoId, l10n),
              if (!hasVideos)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history_toggle_off_outlined, size: 28, color: Colors.grey),
                        const SizedBox(height: 6),
                        Text(
                          l10n.noUnanalyzedRecords,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      itemCount: videos.length,
                      itemBuilder: (context, index) {
                        final video = videos[index];
                        final isSelected = video.runSessionId == videoId;
                        return _buildRecordCard(video: video, isSelected: isSelected, l10n: l10n);
                      },
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _UnanalyzedHistoryPanelWrapper extends StatelessWidget {
  final Widget child;
  final String? title;

  const _UnanalyzedHistoryPanelWrapper({required this.child, this.title});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return LayoutBuilder(
      builder: (context, constraints) {
        final panelWidth = constraints.maxWidth < 600 ? constraints.maxWidth : 500.0;
        return Container(
          width: panelWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                  children: [
                    Icon(
                      Icons.pending_actions_rounded,
                      size: 16,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        title ?? l10n.uncompletedRecordsPlaceholder,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
              child,
            ],
          ),
        );
      },
    );
  }
}

class _OneUnanalyzedHistoryPlaceholder extends StatelessWidget {
  const _OneUnanalyzedHistoryPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          children: [
            // Left Icon skeleton
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_run,
                color: Theme.of(context).primaryColorDark.withValues(alpha: 0.4),
                size: 16,
              ),
            ),
            const SizedBox(width: 10),
            // Middle Column skeleton
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Date skeleton bar
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Camera count skeleton bar
                      Container(
                        width: 45,
                        height: 11,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Missing tag skeleton badge
                      Container(
                        width: 55,
                        height: 13,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  // Note skeleton bar
                  Container(
                    width: 130,
                    height: 9,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Right Status Badge skeleton
            Container(
              width: 36,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
