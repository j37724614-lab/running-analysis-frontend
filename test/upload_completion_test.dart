import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/feature/upload/upload_completion.dart';

void main() {
  test('publishes and consumes an upload completion', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(uploadCompletionProvider.notifier);
    notifier.publish(runnerId: 'runner-1', runSessionId: 'session-1');

    final completion = container.read(uploadCompletionProvider);
    expect(completion?.runnerId, 'runner-1');
    expect(completion?.runSessionId, 'session-1');

    notifier.consume(completion!.id);
    expect(container.read(uploadCompletionProvider), isNull);
  });

  test('does not consume a newer completion with an older id', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(uploadCompletionProvider.notifier);
    notifier.publish(runnerId: 'runner-1', runSessionId: 'session-1');
    final firstId = container.read(uploadCompletionProvider)!.id;

    notifier.publish(runnerId: 'runner-2', runSessionId: 'session-2');
    notifier.consume(firstId);

    expect(container.read(uploadCompletionProvider)?.runSessionId, 'session-2');
  });
}
