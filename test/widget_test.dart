import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_matching/controllers/job_controller.dart';
import 'package:job_matching/controllers/language_controller.dart';
import 'package:job_matching/services/mock_job_api.dart';
import 'package:job_matching/services/storage_service.dart';
import 'package:job_matching/views/job_list_view.dart';
import 'package:job_matching/main.dart';

void main() {
  testWidgets('App renders JobListView with title and filters', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();

    final storage = StorageService();
    await storage.init();
    Get.put<StorageService>(storage);
    Get.put<MockJobApiService>(MockJobApiService());
    Get.put<LanguageController>(LanguageController());
    Get.put<JobController>(JobController());

    await tester.pumpWidget(const JobMatchingApp(initialLocale: Locale('en', 'US')));
    // Advance timers so mock network latency completes cleanly
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(JobListView), findsOneWidget);
  });
}
