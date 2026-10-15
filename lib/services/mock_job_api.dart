import 'dart:math';
import '../models/job_model.dart';

class MockJobApiService {
  final Random _random = Random();
  late final List<JobModel> _jobs;

  bool isOffline = false;
  bool forceFail = false;

  MockJobApiService() {
    _jobs = _createMockJobs();
  }

  List<JobModel> _createMockJobs() {
    final titles = [
      'Heavy Truck Driver',
      'Electrician (Maintenance)',
      'MIG/TIG Welder',
      'Retail Sales Assistant',
      'Plumber & Pipefitter',
      'Warehouse Forklift Operator',
      'HVAC & AC Technician',
      'Tile & Marble Mason',
      'Bike Delivery Courier',
      'Security Guard (SIRA Certified)',
      'Diesel Engine Mechanic',
      'Furniture Carpenter',
      'Commercial Painter',
      'Steel Fixer & Rebar Worker',
      'Kitchen Helper & Steward',
      'Trailer Driver',
      'Substation Electrician',
      '6G Pipe Welder',
      'Supermarket Cashier',
      'Facility Maintenance Tech'
    ];

    final employers = [
      'Logistics Company, UAE',
      'Emirates Transport, UAE',
      'Gulf Engineering LLC, UAE',
      'Desert Star Contracting, Saudi Arabia',
      'Arabian Freight Co, Saudi Arabia',
      'Red Sea Facilities, Saudi Arabia',
      'Doha MEP Solutions, Qatar',
      'Al-Wakrah Trading, Qatar',
      'Lusail Construction, Qatar',
      'National Retail Hub, UAE'
    ];

    final countries = ['UAE', 'Saudi Arabia', 'Qatar'];
    final cities = {
      'UAE': ['Dubai', 'Abu Dhabi', 'Sharjah'],
      'Saudi Arabia': ['Riyadh', 'Jeddah', 'Dammam'],
      'Qatar': ['Doha', 'Al Rayyan', 'Lusail'],
    };

    final skillsMap = {
      'Driver': ['Heavy vehicle', 'GCC licence', 'Route planning'],
      'Electrician': ['Industrial wiring', 'Circuit testing', 'Blueprint reading'],
      'Welder': ['TIG welding', 'MIG welding', 'Pipe fitting'],
      'Retail': ['Customer service', 'POS billing', 'English & Hindi'],
      'Plumber': ['PVC piping', 'Sanitary installation', 'Leak repair'],
      'Forklift': ['Forklift licence', 'Pallet stacking', 'Warehouse safety'],
      'HVAC': ['Chiller repair', 'Gas charging', 'Duct installation'],
      'Mason': ['Tile cutting', 'Marble laying', 'Level balancing'],
      'Courier': ['Bike driving', 'GPS navigation', 'Parcel delivery'],
      'Security': ['SIRA license', 'Access control', 'Patrol inspection'],
      'Mechanic': ['Diesel engine', 'Brake repair', 'Diagnostics'],
      'Carpenter': ['Wood working', 'Interior fitout', 'Furniture assembly'],
    };

    final list = <JobModel>[];


    for (int i = 0; i < 200; i++) {
      final title = titles[i % titles.length];
      final employer = employers[i % employers.length];
      final country = countries[i % countries.length];
      final cityList = cities[country]!;
      final city = cityList[i % cityList.length];


      List<String> skills = ['Safety training', 'Teamwork', 'Hardworking'];
      for (final key in skillsMap.keys) {
        if (title.contains(key)) {
          skills = skillsMap[key]!;
          break;
        }
      }

      final minSalary = 2000 + ((i * 130) % 2500);
      final maxSalary = minSalary + 700 + ((i * 50) % 800);


      final matchScore = 98.0 - ((i * 1.3) % 27.0);

      list.add(JobModel(
        id: 'job_${1000 + i}',
        title: title,
        employerDisplay: employer,
        country: country,
        city: city,
        salaryMinAed: minSalary,
        salaryMaxAed: maxSalary,
        matchScore: double.parse(matchScore.toStringAsFixed(1)),
        matchReason: 'Matched profile for $title based on relevant trade experience and Gulf license.',
        skills: skills,
        benefits: JobBenefits(
          accommodation: (i % 3 != 0),
          food: (i % 2 == 0),
          visa: true,
        ),
        description:
            'Urgent requirement for $title in $city, $country. '
            'Company provides legal Gulf employment visa, medical insurance, and overtime benefits as per labor law.',
        requirements: [
          'Minimum 2-3 years experience in $title.',
          'Physical fitness and adherence to workplace safety regulations.',
          'Basic communication skills in Hindi or English.',
        ],
        postedAt: DateTime.now().subtract(Duration(days: i % 15)).toIso8601String(),
      ));
    }


    list.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return list;
  }

  Future<void> _simulateNetwork() async {
    if (isOffline) {
      throw Exception('Network error: You are currently offline');
    }

    final delay = 800 + _random.nextInt(700);
    await Future.delayed(Duration(milliseconds: delay));

    if (forceFail || _random.nextInt(5) == 0) {
      throw Exception('500 Internal Server Error');
    }
  }

  Future<Map<String, dynamic>> getJobs({
    String country = 'All',
    int page = 1,
    int limit = 20,
  }) async {
    await _simulateNetwork();

    var filtered = _jobs;
    if (country != 'All' && country.isNotEmpty) {
      filtered = filtered
          .where((j) => j.country.toLowerCase() == country.toLowerCase())
          .toList();
    }

    final startIndex = (page - 1) * limit;
    if (startIndex >= filtered.length) {
      return {'jobs': <JobModel>[], 'hasMore': false};
    }

    final endIndex = min(startIndex + limit, filtered.length);
    final pageJobs = filtered.sublist(startIndex, endIndex);

    return {
      'jobs': pageJobs,
      'hasMore': endIndex < filtered.length,
    };
  }

  Future<JobModel> getJobById(String id) async {
    await _simulateNetwork();
    return _jobs.firstWhere((j) => j.id == id);
  }

  Future<bool> applyJob(String id) async {
    await _simulateNetwork();
    return true;
  }
}
