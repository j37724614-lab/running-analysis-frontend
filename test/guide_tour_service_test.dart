import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/feature/guide/guide_tour_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'token',
      '${GuideTourService.keyPrefix}${GuideTourService.tourPlayback}': true,
      '${GuideTourService.keyPrefix}${GuideTourService.tourUpload}': true,
    });
  });

  test('syncSeenTours replaces local flags with the server list', () async {
    await GuideTourService.syncSeenTours([GuideTourService.tourRecord]);

    expect(await GuideTourService.hasSeenTour(GuideTourService.tourRecord), isTrue);
    expect(await GuideTourService.hasSeenTour(GuideTourService.tourPlayback), isFalse);
    expect(await GuideTourService.hasSeenTour(GuideTourService.tourUpload), isFalse);
  });

  test('resetAllLocalTours clears only tour flags, not other preferences', () async {
    await GuideTourService.resetAllLocalTours();

    expect(await GuideTourService.hasSeenTour(GuideTourService.tourPlayback), isFalse);
    expect(await GuideTourService.hasSeenTour(GuideTourService.tourUpload), isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('auth_token'), 'token');
  });
}
