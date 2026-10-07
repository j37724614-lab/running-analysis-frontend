/// Owns durable input copies used by Local analysis.
///
/// iOS file pickers may return paths inside a File Provider or temporary
/// directory. Those paths can disappear while analysis or result playback is
/// still using them, so callers must use the path returned by [stage].
abstract interface class LocalVideoStager {
  Future<String> stage({required String sourcePath, required String filename});

  Future<void> remove(String stagedPath);
}
