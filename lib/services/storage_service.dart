import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_model.dart';

class StorageService {
  static const String _appliedJobsKey = 'applied_job_ids';
  static const String _cachedJobsKey = 'cached_jobs_list';
  static const String _languageKey = 'app_language_code';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Set<String> getAppliedJobIds() {
    final list = _prefs.getStringList(_appliedJobsKey) ?? [];
    return list.toSet();
  }

  Future<void> saveAppliedJobId(String jobId) async {
    final current = getAppliedJobIds();
    current.add(jobId);
    await _prefs.setStringList(_appliedJobsKey, current.toList());
  }

  Future<void> removeAppliedJobId(String jobId) async {
    final current = getAppliedJobIds();
    current.remove(jobId);
    await _prefs.setStringList(_appliedJobsKey, current.toList());
  }

  Future<void> cacheJobs(List<JobModel> jobs) async {
    try {
      final jsonList = jobs.map((j) => j.toJson()).toList();
      await _prefs.setString(_cachedJobsKey, jsonEncode(jsonList));
    } catch (_) {
    }
  }

  List<JobModel> getCachedJobs() {
    try {
      final raw = _prefs.getString(_cachedJobsKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => JobModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }


  String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> saveLanguage(String langCode) async {
    await _prefs.setString(_languageKey, langCode);
  }
}
