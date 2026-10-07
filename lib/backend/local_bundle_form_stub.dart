import 'package:dio/dio.dart';

Future<FormData> buildLocalBundleForm(
  String bundlePath,
  String idempotencyKey, {
  required List<String> inputVideoPaths,
}) {
  throw UnsupportedError('Local result bundle upload is only available on dart:io platforms');
}
