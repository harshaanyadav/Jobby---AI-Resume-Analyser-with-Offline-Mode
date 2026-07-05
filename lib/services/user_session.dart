/// Minimal in-memory session holder for the premium/free flag.
/// Your existing project has no authentication system, so this is the
/// smallest possible addition that lets ResumeAnalysisService decide
/// which engine to use, as required by the hybrid architecture.
/// Wire this up to your real auth/subscription system whenever you add one —
/// nothing else in the app needs to change.
class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  bool isPremium = false;
}
