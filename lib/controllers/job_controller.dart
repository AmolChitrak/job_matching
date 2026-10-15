import 'package:get/get.dart';
import '../models/job_model.dart';
import '../services/mock_job_api.dart';
import '../services/storage_service.dart';

class JobController extends GetxController {
  final MockJobApiService apiService = Get.find<MockJobApiService>();
  final StorageService storageService = Get.find<StorageService>();


  final RxList<JobModel> jobs = <JobModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxBool isOffline = false.obs;
  final RxString selectedCountry = 'All'.obs;
  final RxSet<String> appliedJobIds = <String>{}.obs;

  int _currentPage = 1;
  bool _hasMore = true;

  final List<String> countries = ['All', 'UAE', 'Saudi Arabia', 'Qatar'];

  @override
  void onInit() {
    super.onInit();
    appliedJobIds.addAll(storageService.getAppliedJobIds());
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    isLoading.value = true;
    hasError.value = false;
    _currentPage = 1;

    try {
      final result = await apiService.getJobs(
        country: selectedCountry.value,
        page: 1,
      );

      final List<JobModel> list = result['jobs'] as List<JobModel>;
      _hasMore = result['hasMore'] as bool;

      jobs.value = list.map((j) => j.copyWith(isApplied: appliedJobIds.contains(j.id))).toList();
      isOffline.value = false;
      if (selectedCountry.value == 'All') {
        storageService.cacheJobs(jobs);
      }
    } catch (e) {
      final cached = storageService.getCachedJobs();
      if (cached.isNotEmpty) {
        isOffline.value = true;
        var filtered = cached;
        if (selectedCountry.value != 'All') {
          filtered = cached
              .where((j) => j.country.toLowerCase() == selectedCountry.value.toLowerCase())
              .toList();
        }
        jobs.value = filtered
            .map((j) => j.copyWith(isApplied: appliedJobIds.contains(j.id)))
            .toList();
      } else {
        hasError.value = true;
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !_hasMore || isOffline.value) return;

    isLoadingMore.value = true;
    final nextPage = _currentPage + 1;

    try {
      final result = await apiService.getJobs(
        country: selectedCountry.value,
        page: nextPage,
      );

      final List<JobModel> newJobs = result['jobs'] as List<JobModel>;
      _hasMore = result['hasMore'] as bool;
      _currentPage = nextPage;

      final mapped = newJobs
          .map((j) => j.copyWith(isApplied: appliedJobIds.contains(j.id)))
          .toList();

      jobs.addAll(mapped);
    } catch (_) {
    } finally {
      isLoadingMore.value = false;
    }
  }

  void selectCountry(String country) {
    if (selectedCountry.value == country) return;
    selectedCountry.value = country;
    fetchJobs();
  }

  Future<bool> applyToJob(String jobId) async {
    if (isOffline.value || apiService.isOffline) {
      if (Get.overlayContext != null) {
        Get.snackbar(
          'offline_banner'.tr,
          'offline_cant_apply'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
      }
      return false;
    }

    if (appliedJobIds.contains(jobId)) return true;

    appliedJobIds.add(jobId);
    _updateJobInList(jobId, true);

    try {
      await apiService.applyJob(jobId);

      await storageService.saveAppliedJobId(jobId);
      return true;
    } catch (e) {
      appliedJobIds.remove(jobId);
      _updateJobInList(jobId, false);

      if (Get.overlayContext != null) {
        Get.snackbar(
          'error_title'.tr,
          'apply_failed'.tr,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      }
      return false;
    }
  }

  void _updateJobInList(String jobId, bool isApplied) {
    final index = jobs.indexWhere((j) => j.id == jobId);
    if (index != -1) {
      jobs[index] = jobs[index].copyWith(isApplied: isApplied);
    }
  }

  bool isJobApplied(String jobId) => appliedJobIds.contains(jobId);

  void toggleOffline() {
    apiService.isOffline = !apiService.isOffline;
    isOffline.value = apiService.isOffline;

    if (isOffline.value) {

      final cached = storageService.getCachedJobs();
      if (cached.isNotEmpty) {
        jobs.value = cached
            .map((j) => j.copyWith(isApplied: appliedJobIds.contains(j.id)))
            .toList();
      }
    } else {
      fetchJobs();
    }
  }
}
