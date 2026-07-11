import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/job_role.dart';

/// Loads job roles + their benchmark skills.
///
/// Tries the remote copy hosted on your Ubuntu VM first (so every device
/// — phone, another laptop, etc. — always sees the same, centrally
/// editable list). If the VM is unreachable (off, wrong network, VM IP
/// changed), it transparently falls back to the bundled
/// assets/job_roles.json so the app never breaks.
///
/// Configure the URL via .env: JOB_ROLES_URL=http://192.168.64.9/job_roles.json
/// If unset, it defaults to that same address.
class JobRoleService {
  JobRoleService._();
  static final JobRoleService instance = JobRoleService._();

  static const Duration _timeout = Duration(seconds: 5);

  List<JobRole> _roles = [];
  bool _loaded = false;

  /// True if the most recent load() came from the bundled asset instead
  /// of the remote VM — lets the UI show a small "offline copy" notice
  /// if you ever want one. Not required, just available.
  bool loadedFromFallback = false;

  String get _remoteUrl =>
      dotenv.env['JOB_ROLES_URL'] ?? 'http://192.168.64.9/job_roles.json';

  Future<void> load() async {
    if (_loaded) return;

    try {
      final response = await http.get(Uri.parse(_remoteUrl)).timeout(_timeout);

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      _parseAndStore(response.body);
      loadedFromFallback = false;
    } catch (_) {
      // VM unreachable, wrong network, timeout, bad JSON, etc.
      // Fall back to the copy bundled inside the app.
      final raw = await rootBundle.loadString('assets/job_roles.json');
      _parseAndStore(raw);
      loadedFromFallback = true;
    }

    _loaded = true;
  }

  /// Forces a fresh fetch on the next load() call — call this if you
  /// edit job_roles.json on the VM and want the running app to pick it
  /// up without a full restart.
  void reset() {
    _loaded = false;
  }

  void _parseAndStore(String rawJson) {
    final List<dynamic> decoded = jsonDecode(rawJson);
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
