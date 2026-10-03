import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/feature/guide/guide_steps_factory.dart';
import 'package:frontend/utils/locale_provider.dart';

class RecordTourInquiryDialog extends StatefulWidget {
  final RecordTourChoice initialChoice;

  const RecordTourInquiryDialog({super.key, this.initialChoice = RecordTourChoice.both});

  static Future<RecordTourChoice?> show(
    BuildContext context, {
    RecordTourChoice initialChoice = RecordTourChoice.both,
  }) {
    return showDialog<RecordTourChoice>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => RecordTourInquiryDialog(initialChoice: initialChoice),
    );
  }

  @override
  State<RecordTourInquiryDialog> createState() => _RecordTourInquiryDialogState();
}

class _RecordTourInquiryDialogState extends State<RecordTourInquiryDialog> {
  late RecordTourChoice _selectedChoice;

  @override
  void initState() {
    super.initState();
    _selectedChoice = widget.initialChoice;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                    blurRadius: 40,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00E5FF), Color(0xFF3B82F6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.videocam_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.tourRecordInquiryTitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              l10n.tourRecordInquirySubtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 12.5,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Option 1: 兩者皆看 (Explore Both)
                  _buildOptionCard(
                    choice: RecordTourChoice.both,
                    title: l10n.tourRecordInquiryBothTitle,
                    desc: l10n.tourRecordInquiryBothDesc,
                    stepPill: l10n.tourRecordInquiryBothSteps,
                    icon: Icons.all_inclusive_rounded,
                    accentColor: const Color(0xFF00E5FF),
                  ),

                  const SizedBox(height: 10),

                  // Option 2: 主控端 (Master Host)
                  _buildOptionCard(
                    choice: RecordTourChoice.masterOnly,
                    title: l10n.tourRecordInquiryMasterTitle,
                    desc: l10n.tourRecordInquiryMasterDesc,
                    stepPill: l10n.tourRecordInquiryMasterSteps,
                    icon: Icons.stars_rounded,
                    accentColor: const Color(0xFFFFB300),
                  ),

                  const SizedBox(height: 10),

                  // Option 3: 從機端 (Slave Device)
                  _buildOptionCard(
                    choice: RecordTourChoice.slaveOnly,
                    title: l10n.tourRecordInquirySlaveTitle,
                    desc: l10n.tourRecordInquirySlaveDesc,
                    stepPill: l10n.tourRecordInquirySlaveSteps,
                    icon: Icons.phonelink_rounded,
                    accentColor: const Color(0xFF00E676),
                  ),

                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(null),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white60,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(l10n.tourSkip, style: const TextStyle(fontSize: 14)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(_selectedChoice),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00E5FF),
                          foregroundColor: Colors.black,
                          elevation: 6,
                          shadowColor: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.tourRecordInquiryStartButton,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required RecordTourChoice choice,
    required String title,
    required String desc,
    required String stepPill,
    required IconData icon,
    required Color accentColor,
  }) {
    final isSelected = _selectedChoice == choice;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedChoice = choice;
          });
        },
        onDoubleTap: () {
          setState(() {
            _selectedChoice = choice;
          });
          Navigator.of(context).pop(choice);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? accentColor.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.15),
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio indicator
              Container(
                margin: const EdgeInsets.only(top: 2),
                child: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 20,
                  color: isSelected ? accentColor : Colors.white38,
                ),
              ),
              const SizedBox(width: 12),

              // Icon badge
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: accentColor),
              ),
              const SizedBox(width: 12),

              // Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.9),
                              fontSize: 14.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1),
                          ),
                          child: Text(
                            stepPill,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: TextStyle(
                        color: isSelected ? Colors.white.withValues(alpha: 0.85) : Colors.white60,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
