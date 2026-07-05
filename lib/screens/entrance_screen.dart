// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/user_session.dart';
import 'job_seeker_form.dart';
import 'recruiter_form.dart';

class EntranceScreen extends StatefulWidget {
  const EntranceScreen({super.key});

  @override
  State<EntranceScreen> createState() => _EntranceScreenState();
}

class _EntranceScreenState extends State<EntranceScreen> {
  bool _isPremium = UserSession.instance.isPremium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppTheme.green,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.greenLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('J',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24)),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('JOBBY',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
                const SizedBox(height: 8),
                Text('Resume Analyzer & Job Matcher',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85), fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Select Your Role',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Choose how you want to use Jobby',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600)),
                    const SizedBox(height: 40),
                    _RoleCard(
                      title: 'Student / Job Seeker',
                      subtitle:
                          'Analyze your resume and find matching job roles',
                      color: AppTheme.green,
                      icon: Icons.person_search,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const JobSeekerFormScreen()),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _RoleCard(
                      title: 'Recruiter / HR',
                      subtitle: 'Compare multiple candidates for a job role',
                      color: AppTheme.blue,
                      icon: Icons.groups,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RecruiterFormScreen()),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _PremiumToggle(
                      isPremium: _isPremium,
                      onChanged: (v) {
                        setState(() => _isPremium = v);
                        UserSession.instance.isPremium = v;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small, dismissible-in-spirit widget so you can test both tiers.
/// Replace this with your real subscription/auth check whenever ready —
/// nothing else in the app depends on how isPremium is set.
class _PremiumToggle extends StatelessWidget {
  final bool isPremium;
  final ValueChanged<bool> onChanged;

  const _PremiumToggle({required this.isPremium, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPremium ? Icons.workspace_premium : Icons.lock_outline,
            size: 18,
            color: isPremium ? Colors.amber.shade700 : Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            isPremium ? 'Premium (AI) mode' : 'Free (offline) mode',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 10),
          Switch(value: isPremium, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
