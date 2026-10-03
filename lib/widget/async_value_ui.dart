import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

extension AsyncValueUI on AsyncValue {
  void showAlertDialogOnError(BuildContext context) {
    if (!isRefreshing && hasError) {
      toastification.show(
        context: context,
        title: const Text('Error', style: TextStyle(fontWeight: FontWeight.bold)),
        description: Text(error.toString()),
        type: ToastificationType.error,
        style: ToastificationStyle.minimal,
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 4),
      );
    }
  }
}
