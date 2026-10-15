class JobBenefits {
  final bool accommodation;
  final bool food;
  final bool visa;

  const JobBenefits({
    this.accommodation = false,
    this.food = false,
    this.visa = false,
  });

  factory JobBenefits.fromJson(Map<String, dynamic> json) {
    return JobBenefits(
      accommodation: json['accommodation'] as bool? ?? false,
      food: json['food'] as bool? ?? false,
      visa: json['visa'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accommodation': accommodation,
      'food': food,
      'visa': visa,
    };
  }
}

class JobModel {
  final String id;
  final String title;
  final String employerDisplay;
  final String country;
  final String city;
  final int salaryMinAed;
  final int salaryMaxAed;
  final double matchScore;
  final String matchReason;
  final List<String> skills;
  final JobBenefits benefits;
  final String description;
  final List<String> requirements;
  final String postedAt;
  final bool isApplied;

  const JobModel({
    required this.id,
    required this.title,
    required this.employerDisplay,
    required this.country,
    required this.city,
    required this.salaryMinAed,
    required this.salaryMaxAed,
    required this.matchScore,
    required this.matchReason,
    required this.skills,
    required this.benefits,
    required this.description,
    required this.requirements,
    required this.postedAt,
    this.isApplied = false,
  });

  factory JobModel.fromJson(Map<String, dynamic> json, {bool isApplied = false}) {
    return JobModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      employerDisplay: json['employer_display'] as String? ?? '',
      country: json['country'] as String? ?? '',
      city: json['city'] as String? ?? '',
      salaryMinAed: (json['salary_min_aed'] as num?)?.toInt() ?? 0,
      salaryMaxAed: (json['salary_max_aed'] as num?)?.toInt() ?? 0,
      matchScore: (json['match_score'] as num?)?.toDouble() ?? 0.0,
      matchReason: json['match_reason'] as String? ?? '',
      skills: (json['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      benefits: json['benefits'] != null
          ? JobBenefits.fromJson(json['benefits'] as Map<String, dynamic>)
          : const JobBenefits(),
      description: json['description'] as String? ?? '',
      requirements: (json['requirements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      postedAt: json['posted_at'] as String? ?? '',
      isApplied: isApplied,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'employer_display': employerDisplay,
      'country': country,
      'city': city,
      'salary_min_aed': salaryMinAed,
      'salary_max_aed': salaryMaxAed,
      'match_score': matchScore,
      'match_reason': matchReason,
      'skills': skills,
      'benefits': benefits.toJson(),
      'description': description,
      'requirements': requirements,
      'posted_at': postedAt,
    };
  }

  JobModel copyWith({
    bool? isApplied,
  }) {
    return JobModel(
      id: id,
      title: title,
      employerDisplay: employerDisplay,
      country: country,
      city: city,
      salaryMinAed: salaryMinAed,
      salaryMaxAed: salaryMaxAed,
      matchScore: matchScore,
      matchReason: matchReason,
      skills: skills,
      benefits: benefits,
      description: description,
      requirements: requirements,
      postedAt: postedAt,
      isApplied: isApplied ?? this.isApplied,
    );
  }

  String get formattedSalary {
    return 'AED $salaryMinAed - $salaryMaxAed/mo';
  }

  String get matchScorePercent {
    return '${matchScore.toStringAsFixed(0)}%';
  }
}
