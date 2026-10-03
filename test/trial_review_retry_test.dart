import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/utils/api_retry.dart';

void main() {
  group('apiRetry', () {
    test('recreates a failed provider after the API recovers', () async {
      var attempts = 0;
      final recovered = Completer<int>();
      final provider = FutureProvider<int>((ref) async {
        attempts++;
        if (attempts < 3) throw 'Not Found';
        return 42;
      }, retry: apiRetry);
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.listen(provider, (_, next) {
        if (next.hasValue && !recovered.isCompleted) {
          recovered.complete(next.requireValue);
        }
      }, fireImmediately: true);

      expect(await recovered.future.timeout(const Duration(seconds: 5)), 42);
      expect(attempts, 3);
    });

    test('keeps retrying transient failures with capped backoff', () {
      const expected = [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 4),
        Duration(seconds: 8),
        Duration(seconds: 15),
        Duration(seconds: 30),
        Duration(seconds: 30),
      ];

      for (var retryCount = 0; retryCount < expected.length; retryCount++) {
        expect(apiRetry(retryCount, 'Connection refused'), expected[retryCount]);
      }
    });

    test('retries a temporarily unavailable route', () {
      expect(apiRetry(12, 'Not Found'), const Duration(seconds: 30));
    });

    test('does not retry authentication or data-shape failures', () {
      expect(apiRetry(0, '401 Unauthorized'), isNull);
      expect(apiRetry(0, '403 Forbidden'), isNull);
      expect(apiRetry(0, const FormatException('bad payload')), isNull);
    });
  });
}
