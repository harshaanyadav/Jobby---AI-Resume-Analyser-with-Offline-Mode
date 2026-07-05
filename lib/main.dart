import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'screens/entrance_screen.dart';
import 'services/job_role_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load OpenRouter key + config. Missing .env is tolerated so the app
  // still runs in Free mode if a developer forgot to set it up.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // No .env found — Premium/AI calls will fail gracefully and the app
    // will fall back to the free keyword engine automatically.
  }

  await JobRoleService.instance.load();

  runApp(const JobbyApp());
}

class JobbyApp extends StatelessWidget {
  const JobbyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jobby',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const EntranceScreen(),
    );
  }
}
