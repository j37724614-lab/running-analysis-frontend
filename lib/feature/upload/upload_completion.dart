import 'package:flutter_riverpod/flutter_riverpod.dart';

class UploadCompletion {
  const UploadCompletion({required this.id, required this.runnerId, required this.runSessionId});

  final int id;
  final String runnerId;
  final String runSessionId;
}

class UploadCompletionNotifier extends Notifier<UploadCompletion?> {
  var _nextId = 0;

  @override
  UploadCompletion? build() => null;

  void publish({required String runnerId, required String runSessionId}) {
    state = UploadCompletion(id: _nextId++, runnerId: runnerId, runSessionId: runSessionId);
  }

  void consume(int id) {
    if (state?.id == id) state = null;
  }
}

final uploadCompletionProvider = NotifierProvider<UploadCompletionNotifier, UploadCompletion?>(
  UploadCompletionNotifier.new,
);
