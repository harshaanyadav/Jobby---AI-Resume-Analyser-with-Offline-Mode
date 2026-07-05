/// Represents a job description regardless of its source:
/// a predefined role, pasted text, or an uploaded PDF.
class JobDescription {
  final String title;
  final String rawText;
  final List<String> requiredSkills;

  const JobDescription({
    required this.title,
    this.rawText = '',
    this.requiredSkills = const [],
  });
}
