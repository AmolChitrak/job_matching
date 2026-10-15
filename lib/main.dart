import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/job_controller.dart';
import 'controllers/language_controller.dart';
import 'services/mock_job_api.dart';
import 'services/storage_service.dart';
import 'utils/app_theme.dart';
import 'utils/app_translations.dart';
import 'views/job_list_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();
  Get.put<StorageService>(storageService);
  
  Get.put<MockJobApiService>(MockJobApiService());

   final langController = Get.put<LanguageController>(LanguageController());
  Get.put<JobController>(JobController());

  runApp(JobMatchingApp(initialLocale: langController.currentLocale));
}

class JobMatchingApp extends StatelessWidget {
  final Locale initialLocale;

  const JobMatchingApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Jobzshala GCC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('en', 'US'),
      home: const JobListView(),
    );
  }
}
