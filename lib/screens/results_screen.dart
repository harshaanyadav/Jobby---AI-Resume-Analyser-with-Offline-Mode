import 'package:flutter/material.dart';
import '../models/resume_analysis.dart';
import '../models/resume_review.dart';
import '../services/job_role_service.dart';
import '../services/analysis_service.dart';
import '../theme/app_theme.dart';
import '../widgets/charts_dashboard.dart';

class ResultsScreen extends StatelessWidget {
  final String name;
  final int age;
  final String gender;
  final ResumeAnalysis analysis;
  final ResumeReview review;
  final Map<String, double> roleMatches;
  final double readinessScore;
  final String selectedRole;
  final bool isPremium;
  final bool aiUnavailable;

  const ResultsScreen({
    super.key,
    required this.name,
    required this.age,
    required this.gender,
    required this.analysis,
    required this.review,
    required this.roleMatches,
    required this.readinessScore,
    required this.selectedRole,
    required this.isPremium,
    this.aiUnavailable = false,
  });

  @override
  Widget build(BuildContext context) {
    final sortedMatches = roleMatches.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sortedMatches.take(3).toList();
    final topRole = top3.isNotEmpty ? top3.first.key : selectedRole;
    final skills = analysis.allSkills;
    final missing = AnalysisService.getMissingSkills(skills, topRole);
    final benchmark = AnalysisService.getBenchmarkText(skills, topRole);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        backgroundColor: AppTheme.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPremium && !aiUnavailable)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.workspace_premium, color: Colors.amber.shade700),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'This analysis was generated using Premium AI.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            if (isPremium && aiUnavailable)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFCDD2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cloud_off, color: AppTheme.red),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Premium AI is temporarily unavailable right now. Showing free-tier analysis instead — please try again shortly.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            _SectionCard(
              title: 'Candidate Information',
              child: Column(
                children: [
                  _infoRow('Name', name),
                  _infoRow('Age', '$age'),
                  _infoRow('Gender', gender),
                  _infoRow('Contact',
                      analysis.phone.isNotEmpty ? analysis.phone : 'Not found'),
                  _infoRow('Email',
                      analysis.email.isNotEmpty ? analysis.email : 'Not found'),
                  _infoRow(
                      'Degree',
                      analysis.degree.isNotEmpty
                          ? analysis.degree
                          : 'Not found'),
                  _infoRow('Skills Found', '${skills.length} skills detected'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Top Job Matches',
              child: Column(
                children: top3.asMap().entries.map((e) {
                  final rank = e.key + 1;
                  final role = e.value.key;
                  final pct = e.value.value;
                  Color color = pct > 70
                      ? Colors.green
                      : pct > 50
                          ? Colors.orange
                          : Colors.red;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: color,
                          child: Text(
                            '$rank',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                role,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: pct / 100,
                                backgroundColor: Colors.grey.shade200,
                                color: color,
                                minHeight: 6,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${pct.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Candidate Analysis',
              child: Column(
                children: [
                  _analysisRow(
                    'Interview Readiness',
                    review.interviewReadiness.isNotEmpty
                        ? review.interviewReadiness
                        : '${readinessScore.toStringAsFixed(0)}%',
                    Icons.star,
                  ),
                  const Divider(),
                  _analysisRow(
                      'Industry Benchmark', benchmark, Icons.bar_chart),
                  const Divider(),
                  _analysisRow(
                    'Soft Skills',
                    analysis.softSkills.isNotEmpty
                        ? 'Shows strength in ${analysis.softSkills.join(', ')}.'
                        : AnalysisService.getSoftSkillsEvaluation(
                            analysis.experienceSummary),
                    Icons.psychology,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: isPremium && !aiUnavailable
                  ? 'AI Resume Review'
                  : 'Resume Review',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _analysisRow(
                    'ATS Score',
                    '${review.ats.atsScore.toStringAsFixed(0)}% — ${review.ats.resumeQuality}',
                    Icons.verified,
                  ),
                  const Divider(),
                  _analysisRow(
                      'Summary', review.resumeSummary, Icons.description),
                  const Divider(),
                  _analysisRow(
                      'Career Advice', review.careerAdvice, Icons.trending_up),
                  if (review.hiringRecommendation.isNotEmpty) ...[
                    const Divider(),
                    _analysisRow('Hiring Recommendation',
                        review.hiringRecommendation, Icons.thumb_up),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (missing.isNotEmpty)
              _SectionCard(
                title: 'Recommendations',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To improve your match for $topRole, develop skills in:',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: missing
                          .take(8)
                          .map(
                            (s) => Chip(
                              label: Text(
                                s,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: const Color(0xFFFFEBEE),
                              labelStyle: const TextStyle(color: AppTheme.red),
                              side: const BorderSide(color: Color(0xFFFFCDD2)),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            if (skills.isNotEmpty)
              _SectionCard(
                title: 'Detected Skills',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills
                      .map(
                        (s) => Chip(
                          label: Text(s, style: const TextStyle(fontSize: 12)),
                          backgroundColor: const Color(0xFFE8F5E9),
                          labelStyle: const TextStyle(color: AppTheme.green),
                          side: const BorderSide(color: Color(0xFFC8E6C9)),
                        ),
                      )
                      .toList(),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(
                            title: const Text('Analytics'),
                            backgroundColor: AppTheme.green,
                          ),
                          body: ChartsDashboard(
                            roleMatches: roleMatches,
                            candidateSkills: skills,
                            benchmarkSkills:
                                JobRoleService.instance.skillsFor(topRole),
                            readinessScore: readinessScore,
                          ),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('View Analytics'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green,
                      foregroundColor: Colors.white,
                    ),
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
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _analysisRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.green),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : 'Not available.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.green,
            ),
          ),
          const SizedBox(height: 4),
          const Divider(color: Color(0xFFE0E0E0)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
