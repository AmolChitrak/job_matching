import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/storage_service.dart';

class LanguageController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  final RxString currentLanguage = 'en'.obs;

  @override
  void onInit() {
    super.onInit();
    final saved = _storage.getLanguage();
    currentLanguage.value = saved;
  }

  Locale get currentLocale {
    if (currentLanguage.value == 'hi') {
      return const Locale('hi', 'IN');
    }
    return const Locale('en', 'US');
  }

  bool get isHindi => currentLanguage.value == 'hi';

  void toggleLanguage() {
    if (isHindi) {
      setLanguage('en');
    } else {
      setLanguage('hi');
    }
  }

  void setLanguage(String langCode) {
    currentLanguage.value = langCode;
    _storage.saveLanguage(langCode);

    if (langCode == 'hi') {
      Get.updateLocale(const Locale('hi', 'IN'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
  }
}
