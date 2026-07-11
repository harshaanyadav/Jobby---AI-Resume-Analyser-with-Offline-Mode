import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/app_banner.dart';
import '../theme/app_theme.dart';
import '../services/resume_analysis_service.dart';
import '../services/analysis_service.dart';
import '../services/job_role_service.dart';
import '../services/user_session.dart';
import 'results_screen.dart';

class JobSeekerFormScreen extends StatefulWidget {
  const JobSeekerFormScreen({super.key});

  @override
  State<JobSeekerFormScreen> createState() => _JobSeekerFormScreenState();
}

class _JobSeekerFormScreenState extends State<JobSeekerFormScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Male';
  late String _selectedRole;
  String? _resumeFileName;
  PlatformFile? _resumeFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = JobRoleService.instance.roleNames.isNotEmpty
        ? JobRoleService.instance.roleNames.first
        : '';
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _resumeFile = result.files.first;
        _resumeFileName = _resumeFile!.name;
      });
    }
  }

  Future<void> _analyze() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your name.');
      return;
    }
    if (_ageController.text.trim().isEmpty) {
      _showError('Please enter your age.');
      return;
    }
    if (int.tryParse(_ageController.text.trim()) == null) {
      _showError('Please enter a valid age.');
      return;
    }
    if (_resumeFile == null || _resumeFile!.bytes == null) {
      _showError('Please upload your resume (PDF).');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isPremium = UserSession.instance.isPremium;

      final analysis = await ResumeAnalysisService.instance.parseResume(
        _resumeFile!.bytes!,
        isPremium: isPremium,
      );

      final skills = analysis.allSkills;
      final roleMatches = AnalysisService.getAllRoleMatches(skills);
      final readiness = AnalysisService.calculateReadiness(
        analysis.experienceSummary.isEmpty
            ? 'No experience details found'
            : analysis.experienceSummary,
        analysis.certifications.isEmpty
            ? 'No certifications found'
            : analysis.certifications.join(', '),
        skills,
      );

      final review = await ResumeAnalysisService.instance.reviewResume(
        analysis,
        isPremium: isPremium,
      );

      // Read this right after the LAST premium-capable call in the
      // sequence (reviewResume), so it reflects whether AI actually
      // succeeded for this run.
      final aiUnavailable = ResumeAnalysisService.instance.premiumFellBack;

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            name: _nameController.text.trim(),
            age: int.parse(_ageController.text.trim()),
            gender: _gender,
            analysis: analysis,
            review: review,
            roleMatches: roleMatches,
            readinessScore: readiness,
            selectedRole: _selectedRole,
            isPremium: isPremium,
            aiUnavailable: aiUnavailable,
          ),
        ),
      );
    } catch (e) {
      _showError('Failed to analyze resume. Make sure it is a valid PDF.\n$e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppTheme.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppBanner(title: 'JOB SEEKER DASHBOARD'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Your Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.green,
                      ),
                    ),
                    const Divider(color: AppTheme.greenLight, thickness: 1.5),
                    const SizedBox(height: 16),
                    _FormCard(
                      child: Column(
                        children: [
                          _buildTextField(
                            'Full Name',
                            _nameController,
                            Icons.person,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'Age',
                            _ageController,
                            Icons.cake,
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 16),
                          _buildGenderRow(),
                          const SizedBox(height: 16),
                          _buildDropdown(),
                          const SizedBox(height: 16),
                          _buildFilePicker(),
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
                              backgroundColor: AppTheme.green,
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
                                : const Text('Analyze Resume'),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppTheme.green, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildGenderRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
          ),
        ),
        Row(
          children: ['Male', 'Female', 'Other'].map((g) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Radio<String>(
                  value: g,
                  groupValue: _gender,
                  activeColor: AppTheme.green,
                  onChanged: (v) => setState(() => _gender = v!),
                ),
                Text(g),
                const SizedBox(width: 12),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: _selectedRole.isEmpty ? null : _selectedRole,
      decoration: InputDecoration(
        labelText: 'Target Job Role',
        prefixIcon: const Icon(Icons.work, color: AppTheme.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      selectedItemBuilder: (BuildContext context) {
        return JobRoleService.instance.roleNames.map((role) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              role,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList();
      },
      items: JobRoleService.instance.roleNames.map((role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(
            role,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedRole = value);
        }
      },
    );
  }

  Widget _buildFilePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Resume (PDF)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBBDEFB)),
            ),
            child: Row(
              children: [
                const Icon(Icons.upload_file, color: AppTheme.blue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _resumeFileName ?? 'Tap to browse files',
                    style: TextStyle(
                      color: _resumeFileName != null
                          ? AppTheme.textDark
                          : AppTheme.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_resumeFileName != null)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: child,
    );
  }
}
