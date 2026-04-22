import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../widgets/app_banner.dart';
import '../theme/app_theme.dart';
import '../services/resume_parser.dart';
import '../services/analysis_service.dart';
import '../models/job_roles.dart';
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
  String _selectedRole = JobRoles.roleNames.first;
  String? _resumeFileName;
  PlatformFile? _resumeFile;
  bool _isLoading = false;

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
      final parser = ResumeParser();
      final data = await parser.parse(_resumeFile!.bytes!);
      final roleMatches = AnalysisService.getAllRoleMatches(data.skills);
      final readiness = AnalysisService.calculateReadiness(
        data.experience,
        data.certifications,
        data.skills,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultsScreen(
            name: _nameController.text.trim(),
            age: int.parse(_ageController.text.trim()),
            gender: _gender,
            resumeData: data,
            roleMatches: roleMatches,
            readinessScore: readiness,
            selectedRole: _selectedRole,
          ),
        ),
      );
    } catch (e) {
      _showError('Failed to parse resume. Make sure it is a valid PDF.\n$e');
    } finally {
      setState(() => _isLoading = false);
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
                  // ignore: deprecated_member_use
                  groupValue: _gender,
                  activeColor: AppTheme.green,
                  // ignore: deprecated_member_use
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
      initialValue: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Target Job Role',
        prefixIcon: const Icon(Icons.work, color: AppTheme.green),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: JobRoles.roleNames
          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
          .toList(),
      onChanged: (v) => setState(() => _selectedRole = v!),
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
