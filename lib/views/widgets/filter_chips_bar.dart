import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/job_controller.dart';
import '../../utils/app_theme.dart';

class FilterChipsBar extends StatelessWidget {
  const FilterChipsBar({super.key});

  String _getCountryLabel(String country) {
    switch (country) {
      case 'All':
        return 'filter_all'.tr;
      case 'UAE':
        return 'filter_uae'.tr;
      case 'Saudi Arabia':
        return 'filter_saudi'.tr;
      case 'Qatar':
        return 'filter_qatar'.tr;
      default:
        return country;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<JobController>();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.countries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final country = controller.countries[index];
          return Obx(() {
            final isSelected = controller.selectedCountry.value == country;
            return FilterChip(
              label: Text(
                _getCountryLabel(country),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textDark,
                ),
              ),
              selected: isSelected,
              showCheckmark: false,
              backgroundColor: AppColors.background,
              selectedColor: AppColors.primary,
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              onSelected: (_) => controller.selectCountry(country),
            );
          });
        },
      ),
    );
  }
}
