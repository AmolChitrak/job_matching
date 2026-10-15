import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/job_controller.dart';
import '../controllers/language_controller.dart';
import '../models/job_model.dart';
import '../utils/app_theme.dart';
import 'widgets/apply_confirmation_dialog.dart';
import 'widgets/offline_banner.dart';

class JobDetailView extends StatelessWidget {
  final String jobId;

  const JobDetailView({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobController>();
    final langController = Get.find<LanguageController>();

    return Obx(() {
      final job = controller.jobs.firstWhere(
        (j) => j.id == jobId,
        orElse: () => JobModel(
          id: jobId,
          title: 'Job',
          employerDisplay: '',
          country: '',
          city: '',
          salaryMinAed: 0,
          salaryMaxAed: 0,
          matchScore: 0,
          matchReason: '',
          skills: [],
          benefits: const JobBenefits(),
          description: '',
          requirements: [],
          postedAt: '',
        ),
      );

      final isApplied = controller.isJobApplied(jobId);
      final isOffline = controller.isOffline.value;

      return Scaffold(
        appBar: AppBar(
          title: Text('job_details'.tr),
          actions: [
            TextButton(
              onPressed: langController.toggleLanguage,
              child: Text(
                'lang_btn'.tr,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            if (isOffline) const OfflineBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.employerDisplay,
                      style: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          '${job.city}, ${job.country}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.tealLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.payments_outlined, color: AppColors.teal),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'salary'.tr,
                                style: const TextStyle(fontSize: 11, color: AppColors.teal),
                              ),
                              Text(
                                job.formattedSalary,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.teal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                '${job.matchScorePercent} ${'match'.tr} • ${'why_matched'.tr}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            job.matchReason,
                            style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    Text(
                      'benefits'.tr,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildBenefitChip('accommodation'.tr, job.benefits.accommodation, Icons.hotel_outlined),
                        const SizedBox(width: 8),
                        _buildBenefitChip('food'.tr, job.benefits.food, Icons.restaurant_outlined),
                        const SizedBox(width: 8),
                        _buildBenefitChip('visa'.tr, job.benefits.visa, Icons.badge_outlined),
                      ],
                    ),
                    const SizedBox(height: 18),

                    if (job.skills.isNotEmpty) ...[
                      Text(
                        'skills'.tr,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: job.skills.map((s) {
                          return Chip(
                            label: Text(s, style: const TextStyle(fontSize: 12)),
                            backgroundColor: AppColors.background,
                            side: const BorderSide(color: AppColors.border),
                            padding: EdgeInsets.zero,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                    ],

                    Text(
                      'description'.tr,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      job.description,
                      style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.4),
                    ),
                    const SizedBox(height: 18),

                    if (job.requirements.isNotEmpty) ...[
                      Text(
                        'requirements'.tr,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      ...job.requirements.map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(r, style: const TextStyle(fontSize: 13, color: AppColors.textDark)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isOffline)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'offline_cant_apply'.tr,
                          style: const TextStyle(fontSize: 12, color: AppColors.orange, fontWeight: FontWeight.w600),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isApplied ? AppColors.green : AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: isApplied ? AppColors.green : Colors.grey.shade400,
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        onPressed: (isOffline || isApplied)
                            ? null
                            : () async {
                                ApplyConfirmationDialog.show(context, job);
                                await controller.applyToJob(job.id);
                              },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(isApplied ? Icons.check_circle : Icons.send, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              isApplied ? 'already_applied'.tr : 'apply_now'.tr,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBenefitChip(String label, bool isProvided, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isProvided ? AppColors.greenLight : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isProvided ? AppColors.green.withValues(alpha: 0.3) : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: isProvided ? AppColors.green : AppColors.textMuted),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isProvided ? AppColors.green : AppColors.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              isProvided ? 'provided'.tr : 'not_provided'.tr,
              style: TextStyle(
                fontSize: 10,
                color: isProvided ? AppColors.green : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
