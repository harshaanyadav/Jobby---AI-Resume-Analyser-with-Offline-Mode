class JobRole {
  final String name;
  final List<String> skills;

  const JobRole({required this.name, required this.skills});

  factory JobRole.fromJson(Map<String, dynamic> json) {
    return JobRole(
      name: json['name']?.toString() ?? '',
      skills: (json['skills'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
