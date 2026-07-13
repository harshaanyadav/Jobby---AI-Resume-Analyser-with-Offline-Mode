import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/job_role.dart';

/// Loads job roles + their benchmark skills.
///
/// Tries the network URL configured via JOB_ROLES_URL in .env first, so
/// roles can be updated on the VM without rebuilding the app. Falls back
/// to the bundled assets/job_roles.json if the fetch fails for ANY reason
/// (VM offline, wrong/changed IP, no .env entry, cleartext blocked on
/// Android, phone not on the same network, timeout, etc). This mirrors
/// the AI engine's premium/free fallback — never crash, always degrade.
class JobRoleService {
  JobRoleService._();
  static final JobRoleService instance = JobRoleService._();

  static const Duration _timeout = Duration(seconds: 5);

  List<JobRole> _roles = [];
  bool _loaded = false;

  /// True if the most recent load() came from the bundled asset because
  /// the network fetch failed or JOB_ROLES_URL wasn't set. Exposed in
  /// case the UI ever wants to surface an "offline job roles" indicator.
  bool loadedFromFallback = false;

  Future<void> load() async {
    if (_loaded) return;

    final url = dotenv.env['JOB_ROLES_URL'];

    if (url != null && url.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(url)).timeout(_timeout);
        if (response.statusCode == 200) {
          _parseAndStore(response.body);
          loadedFromFallback = false;
          _loaded = true;
          return;
        }
      } catch (_) {
        // VM unreachable, wrong IP, network security blocked it, etc.
        // Fall through to the bundled asset below instead of crashing.
      }
    }

    final raw = await rootBundle.loadString('assets/job_roles.json');
    _parseAndStore(raw);
    loadedFromFallback = true;
    _loaded = true;
  }

  void _parseAndStore(String raw) {
    final List<dynamic> decoded = jsonDecode(raw);
    _roles = decoded
        .map((e) => JobRole.fromJson(e as Map<String, dynamic>))
        .toList();
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
