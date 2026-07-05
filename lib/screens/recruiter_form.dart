import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/app_banner.dart';
import '../theme/app_theme.dart';
import '../models/resume_data.dart';
import '../models/job_description.dart';
import '../services/resume_analysis_service.dart';
import '../services/job_role_service.dart';
import '../services/user_session.dart';
import 'candidate_comparison.dart';

class RecruiterFormScreen extends StatefulWidget {
  const RecruiterFormScreen({super.key});

  @override
  State<RecruiterFormScreen> createState() => _RecruiterFormScreenState();
}

class _RecruiterFormScreenState extends State<RecruiterFormScreen> {
  late String _selectedRole;
  bool _useCustomSkills = false;
  final _customSkillsController = TextEditingController();
  final List<PlatformFile> _files = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = JobRoleService.instance.roleNames.isNotEmpty
        ? JobRoleService.instance.roleNames.first
        : '';
  }

  Future<void> _addFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
      withData: true,
    );
    if (result != null) {
      setState(() {
        for (final f in result.files) {
          if (!_files.any((e) => e.name == f.name)) {
            _files.add(f);
          }
        }
      });
    }
  }

  void _removeFile(int index) => setState(() => _files.removeAt(index));

  Future<void> _analyze() async {
    if (_files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload at least one resume.'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    List<String> benchmarkSkills;
    if (_useCustomSkills && _customSkillsController.text.trim().isNotEmpty) {
      benchmarkSkills = _customSkillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    } else {
      benchmarkSkills = JobRoleService.instance.skillsFor(_selectedRole);
    }

    final jobDescription = JobDescription(
      title: _selectedRole,
      requiredSkills: benchmarkSkills,
    );

    setState(() => _isLoading = true);

    final isPremium = UserSession.instance.isPremium;
    final service = ResumeAnalysisService.instance;

    final parsedAnalyses =
        <dynamic>[]; // holds ResumeAnalysis, kept dynamic to avoid extra import churn
    final results = <CandidateResult>[];

    for (final file in _files) {
      try {
        if (file.bytes == null) continue;
        final analysis = await service.parseResume(
          file.bytes!,
          isPremium: isPremium,
        );
        final match = await service.matchResume(
          analysis,
          jobDescription,
          isPremium: isPremium,
        );

        final name = analysis.name.isNotEmpty
            ? analysis.name
            : file.name.replaceAll('.pdf', '');

        parsedAnalyses.add(analysis);
        results.add(
          CandidateResult(
            name: name,
            filePath: file.name,
            matchPercentage: match.matchPercentage,
            skills: analysis.allSkills,
            readinessScore: match.matchPercentage,
          ),
        );
      } catch (_) {
        // Skip files that fail to parse, same behavior as before.
      }
    }

    results.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    setState(() => _isLoading = false);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CandidateComparisonScreen(
          candidates: results,
          jobRole: _selectedRole,
          benchmarkSkills: benchmarkSkills,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppBanner(title: 'RECRUITER DASHBOARD', color: AppTheme.blue),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Job Requirements',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.blue,
                      ),
                    ),
                    const Divider(color: AppTheme.blueLight, thickness: 1.5),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue:
                                _selectedRole.isEmpty ? null : _selectedRole,
                            decoration: InputDecoration(
                              labelText: 'Select Job Role',
                              prefixIcon: const Icon(
                                Icons.work,
                                color: AppTheme.blue,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            items: JobRoleService.instance.roleNames
                                .map(
                                  (r) => DropdownMenuItem(
                                      value: r, child: Text(r)),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedRole = v!),
                          ),
                          const SizedBox(height: 16),
                          CheckboxListTile(
                            title: const Text(
                              'Use Custom Skills',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            value: _useCustomSkills,
                            activeColor: AppTheme.blue,
                            contentPadding: EdgeInsets.zero,
                            onChanged: (v) =>
                                setState(() => _useCustomSkills = v!),
                          ),
                          if (_useCustomSkills) ...[
                            TextField(
                              controller: _customSkillsController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Skills (comma separated)',
                                hintText: 'Python, SQL, Machine Learning...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Upload Candidate Resumes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.blue,
                      ),
                    ),
                    const Divider(color: AppTheme.blueLight, thickness: 1.5),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: Column(
                        children: [
                          if (_files.isEmpty)
                            Container(
                              height: 100,
                              alignment: Alignment.center,
                              child: Text(
                                'No resumes uploaded yet',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _files.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (_, i) => ListTile(
                                leading: const Icon(
                                  Icons.picture_as_pdf,
                                  color: AppTheme.red,
                                ),
                                title: Text(
                                  _files[i].name,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    color: Colors.grey,
                                    size: 18,
                                  ),
                                  onPressed: () => _removeFile(i),
                                ),
                                dense: true,
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              OutlinedButton.icon(
                                onPressed: _addFiles,
                                icon:
                                    const Icon(Icons.add, color: AppTheme.blue),
                                label: const Text(
                                  'Add Resumes',
                                  style: TextStyle(color: AppTheme.blue),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppTheme.blue),
                                ),
                              ),
                              if (_files.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '${_files.length} file(s)',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _analyze,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Analyze Candidates'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Back'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
