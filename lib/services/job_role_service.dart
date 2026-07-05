import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/job_role.dart';

/// Loads job roles + their benchmark skills from assets/job_roles.json.
/// Adding a new role only requires editing that JSON file.
class JobRoleService {
  JobRoleService._();
  static final JobRoleService instance = JobRoleService._();

  List<JobRole> _roles = [];
  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/job_roles.json');
    final List<dynamic> decoded = jsonDecode(raw);
    _roles = decoded
        .map((e) => JobRole.fromJson(e as Map<String, dynamic>))
        .toList();
    _loaded = true;
  }

  List<JobRole> get roles => _roles;

  List<String> get roleNames => _roles.map((r) => r.name).toList();

  List<String> skillsFor(String roleName) {
    return _roles
        .firstWhere(
          (r) => r.name == roleName,
          orElse: () => const JobRole(name: '', skills: []),
        )
        .skills;
  }

  Map<String, List<String>> get roleSkillMap => {
        for (final r in _roles) r.name: r.skills,
      };
}
