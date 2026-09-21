import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frontend/utils/locale_provider.dart';

class ProcessingProgressWidget extends StatelessWidget {
  final int progress;
  const ProcessingProgressWidget({super.key, required this.progress});

  String _getStatusText(BuildContext context, int progress) {
    final l10n = context.l10n;
    if (progress >= 100) return l10n.progressSaved;
    if (progress >= 90) return l10n.progressPostProcessing;
    if (progress >= 80) return l10n.progressPose;
    if (progress >= 40) return l10n.progressTracking;
    if (progress >= 15) return l10n.progressTranscode;
    return l10n.statusProcessing;
  }

  @override
  Widget build(BuildContext context) {
    final statusText = _getStatusText(context, progress);
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        double width;
        if (constraints.maxWidth < 300) {
          width = constraints.maxWidth * 0.9;
        } else {
          width = 300;
        }
        return Container(
          width: width,
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SpinKitCircle(
                size: 60,
                itemBuilder: (context, index) {
                  final colors = [Colors.white, Theme.of(context).secondaryHeaderColor];
                  final color = colors[index % colors.length];
                  return DecoratedBox(decoration: BoxDecoration(color: color));
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      statusText,
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
                    '$progress%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
