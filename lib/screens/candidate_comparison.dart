// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import '../models/resume_data.dart';
import '../theme/app_theme.dart';
import '../widgets/charts_dashboard.dart';

class CandidateComparisonScreen extends StatelessWidget {
  final List<CandidateResult> candidates;
  final String jobRole;
  final List<String> benchmarkSkills;
  final bool isPremium;
  final bool aiUnavailable;

  const CandidateComparisonScreen({
    super.key,
    required this.candidates,
    required this.jobRole,
    required this.benchmarkSkills,
    this.isPremium = false,
    this.aiUnavailable = false,
  });

  @override
  Widget build(BuildContext context) {
    final avg = candidates.isEmpty
        ? 0.0
        : candidates.map((c) => c.matchPercentage).reduce((a, b) => a + b) /
            candidates.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Top Candidates — $jobRole'),
        backgroundColor: AppTheme.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    Icon(Icons.error_outline, color: AppTheme.red),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'AI was temporarily unavailable for one or more candidates. Showing fallback matching instead.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              )
            else if (isPremium)
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
                        'This comparison was generated using Premium AI.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                _StatCard(
                  label: 'Total Candidates',
                  value: '${candidates.length}',
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Average Match',
                  value: '${avg.toStringAsFixed(1)}%',
                ),
              ],
            ),
            if (candidates.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFC8E6C9)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: AppTheme.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Top Candidate: ${candidates.first.name} (${candidates.first.matchPercentage.toStringAsFixed(1)}%)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.green,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(
                          width: 36,
                          child: Text(
                            'Rank',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppTheme.blue,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            'Candidate',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppTheme.blue,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Match %',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppTheme.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Skills',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppTheme.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Readiness',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: AppTheme.blue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...candidates.asMap().entries.map((e) {
                    final i = e.key;
                    final c = e.value;
                    final matchColor = c.matchPercentage >= 75
                        ? Colors.green
                        : c.matchPercentage >= 50
                            ? Colors.orange
                            : Colors.red;
                    final matched = c.skills
                        .map((s) => s.toLowerCase())
                        .toSet()
                        .intersection(
                          benchmarkSkills.map((s) => s.toLowerCase()).toSet(),
                        )
                        .length;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color:
                            i.isEven ? Colors.white : const Color(0xFFF5F5F5),
                        borderRadius: i == candidates.length - 1
                            ? const BorderRadius.vertical(
                                bottom: Radius.circular(12),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 36,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              c.name,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${c.matchPercentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: matchColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '$matched/${benchmarkSkills.length}',
                              style: const TextStyle(fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${c.readinessScore.toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
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
                            title: const Text('Candidate Analytics'),
                            backgroundColor: AppTheme.blue,
                          ),
                          body: ChartsDashboard(
                            roleMatches: {
                              for (final c in candidates)
                                c.name: c.matchPercentage,
                            },
                            candidateSkills: candidates.isNotEmpty
                                ? candidates.first.skills
                                : [],
                            benchmarkSkills: benchmarkSkills,
                            readinessScore: candidates.isNotEmpty
                                ? candidates.first.readinessScore
                                : 0,
                          ),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.bar_chart),
                    label: const Text('View Analytics'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.blue,
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
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
