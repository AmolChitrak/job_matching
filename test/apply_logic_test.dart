import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_matching/controllers/job_controller.dart';
import 'package:job_matching/services/mock_job_api.dart';
import 'package:job_matching/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late MockJobApiService apiService;
  late JobController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();

    storageService = StorageService();
    await storageService.init();
    Get.put<StorageService>(storageService);

    apiService = MockJobApiService();
    Get.put<MockJobApiService>(apiService);

    controller = JobController();
    Get.put<JobController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  test('Initial state loads jobs sorted by match score highest first', () async {
    apiService.forceFail = false;
    await controller.fetchJobs();

    expect(controller.jobs.isNotEmpty, true);
    for (int i = 0; i < controller.jobs.length - 1; i++) {
      expect(
        controller.jobs[i].matchScore >= controller.jobs[i + 1].matchScore,
        true,
        reason: 'Jobs should be sorted descending by match score',
      );
    }
  });

  test('Filter by country returns only matching country jobs', () async {
    apiService.forceFail = false;
    await controller.fetchJobs();
    controller.selectCountry('UAE');
    await controller.fetchJobs();

    expect(controller.jobs.isNotEmpty, true);
    for (final job in controller.jobs) {
      expect(job.country, 'UAE');
    }
  });

  test('Optimistic Apply updates state immediately and persists on success', () async {
    apiService.forceFail = false;
    await controller.fetchJobs();

    final testJobId = controller.jobs.first.id;

    final success = await controller.applyToJob(testJobId);

    expect(success, true);
    expect(controller.isJobApplied(testJobId), true);
    expect(storageService.getAppliedJobIds().contains(testJobId), true);
  });

  test('Rollback occurs and reverts applied state if API call fails', () async {
    apiService.forceFail = false;
    await controller.fetchJobs();

    final testJobId = controller.jobs.first.id;

    // Simulate 500 error on apply
    apiService.forceFail = true;
    final success = await controller.applyToJob(testJobId);

    expect(success, false);
    // Should be rolled back to unapplied
    expect(controller.isJobApplied(testJobId), false);
    expect(storageService.getAppliedJobIds().contains(testJobId), false);
  });

  test('Apply is blocked when offline', () async {
    controller.isOffline.value = true;
    apiService.isOffline = true;

    final success = await controller.applyToJob('job_1001');

    expect(success, false);
    expect(controller.isJobApplied('job_1001'), false);
  });
}
