import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/job_controller.dart';
import '../controllers/language_controller.dart';
import '../utils/app_theme.dart';
import 'widgets/filter_chips_bar.dart';
import 'widgets/job_card.dart';
import 'widgets/offline_banner.dart';

class JobListView extends StatefulWidget {
  const JobListView({super.key});

  @override
  State<JobListView> createState() => _JobListViewState();
}

class _JobListViewState extends State<JobListView> {
  final JobController controller = Get.find<JobController>();
  final LanguageController langController = Get.find<LanguageController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr),
        actions: [
          TextButton(
            onPressed: langController.toggleLanguage,
            child: Text(
              'lang_btn'.tr,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          Obx(() => IconButton(
                icon: Icon(controller.isOffline.value ? Icons.wifi_off : Icons.wifi),
                tooltip: 'Toggle Offline',
                onPressed: controller.toggleOffline,
              )),
        ],
      ),
      body: Column(
        children: [
          Obx(() {
            if (controller.isOffline.value) {
              return const OfflineBanner();
            }
            return const SizedBox.shrink();
          }),

          const FilterChipsBar(),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.hasError.value && controller.jobs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.red),
                        const SizedBox(height: 12),
                        Text(
                          'error_title'.tr,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text('error_sub'.tr, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.fetchJobs,
                          child: Text('retry'.tr),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (controller.jobs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'no_matches'.tr,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text('no_matches_sub'.tr, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () => controller.selectCountry('All'),
                          child: Text('show_all'.tr),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchJobs,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: controller.jobs.length + (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.jobs.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }
                    return JobCard(job: controller.jobs[index]);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
