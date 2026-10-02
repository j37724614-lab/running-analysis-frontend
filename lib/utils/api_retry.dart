/// Retry policy for asynchronous API-backed providers.
///
/// Riverpod cancels the pending timer when a provider is disposed, so this can
/// keep retrying while a page is visible without leaving background timers
/// behind after navigation. The delay is capped to avoid hammering an API that
/// is offline for an extended period.
Duration? apiRetry(int retryCount, Object error) {
  final message = error.toString().toLowerCase();

  // Authentication failures need a new login, not repeated requests. Payload
  // shape failures are deterministic programming/data-contract errors.
  if (message.contains('401') ||
      message.contains('unauthorized') ||
      message.contains('403') ||
      message.contains('forbidden') ||
      error is FormatException ||
      error is TypeError ||
      error is StateError) {
    return null;
  }

  const delays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 15),
  ];
  if (retryCount < delays.length) return delays[retryCount];
  return const Duration(seconds: 30);
}
