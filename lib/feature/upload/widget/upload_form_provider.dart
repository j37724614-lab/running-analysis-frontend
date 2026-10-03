import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:frontend/feature/upload/widget/upload_enums.dart';

class UploadFormData {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int fps;
  final String note;
  final bool isLongJump;

  UploadFormData({
    required this.selectedDate,
    required this.selectedTime,
    required this.fps,
    required this.note,
    required this.isLongJump,
  });

  UploadFormData copyWith({
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    int? fps,
    String? note,
    bool? isLongJump,
  }) {
    return UploadFormData(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      fps: fps ?? this.fps,
      note: note ?? this.note,
      isLongJump: isLongJump ?? this.isLongJump,
    );
  }

  factory UploadFormData.initial() => UploadFormData(
    selectedDate: DateTime.now(),
    selectedTime: TimeOfDay.now(),
    fps: 60,
    note: '',
    isLongJump: false,
  );
}

final uploadAllFormProvider = StateProvider.autoDispose<UploadFormData>(
  (ref) => UploadFormData.initial(),
);

final uploadSeperatelyFormProvider = StateProvider.autoDispose<UploadFormData>(
  (ref) => UploadFormData.initial(),
);

final uploadTypeProvider = StateProvider.autoDispose<UploadType>((ref) {
  return UploadType.all;
});

final runnerSourceProvider = StateProvider.autoDispose<RunnerSource>((ref) {
  return RunnerSource.select;
});

final runnerNameInputProvider = StateProvider.autoDispose<String>((ref) {
  return '';
});

final uploadSeparatelyTypeProvider = StateProvider.autoDispose<SperatedType>((ref) {
  return SperatedType.newOne;
});
