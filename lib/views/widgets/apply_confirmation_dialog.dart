  import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/job_model.dart';
import '../../utils/app_theme.dart';

class ApplyConfirmationDialog extends StatelessWidget {
  final JobModel job;

  const ApplyConfirmationDialog({super.key, required this.job});

  static void show(BuildContext context, JobModel job) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ApplyConfirmationDialog(job: job),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.greenLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 36, color: AppColors.green),
          ),
          const SizedBox(height: 16),
          Text(
            'apply_success_title'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${job.title} • ${job.employerDisplay}',
            style: const TextStyle(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'apply_success_msg'.tr,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text('done'.tr),
            ),
          ),
        ],
      ),
    );
  }
}
