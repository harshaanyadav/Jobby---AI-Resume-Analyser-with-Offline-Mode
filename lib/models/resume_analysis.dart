/// Unified structured resume analysis result.
/// Produced by BOTH the KeywordAnalysisEngine (best-effort mapping from
/// existing regex/keyword parsing) and the OpenRouterAnalysisEngine
/// (full structured JSON from the AI). The UI only ever consumes this model.
class ResumeAnalysis {
  final String name;
  final String email;
  final String phone;
  final String linkedin;
  final String degree;
  final String experienceYears;
  final String experienceSummary;
  final List<String> projects;
  final List<String> certifications;
  final List<String> technicalSkills;
  final List<String> softSkills;
  final List<String> frameworks;
  final List<String> tools;
  final List<String> cloud;
  final List<String> languages;
  final List<String> strengths;
  final List<String> weaknesses;
  final String careerLevel;
  final String industry;
  final String summary;

  const ResumeAnalysis({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.linkedin = '',
    this.degree = '',
    this.experienceYears = '',
    this.experienceSummary = '',
    this.projects = const [],
    this.certifications = const [],
    this.technicalSkills = const [],
    this.softSkills = const [],
    this.frameworks = const [],
    this.tools = const [],
    this.cloud = const [],
    this.languages = const [],
    this.strengths = const [],
    this.weaknesses = const [],
    this.careerLevel = '',
    this.industry = '',
    this.summary = '',
  });

  /// All technical-ish skills merged into one flat list — used for
  /// role-matching against assets/job_roles.json regardless of engine.
  List<String> get allSkills => [
        ...technicalSkills,
        ...frameworks,
        ...tools,
        ...cloud,
        ...softSkills,
      ];

  factory ResumeAnalysis.fromJson(Map<String, dynamic> json) {
    List<String> _list(dynamic v) {
      if (v == null) return const [];
      if (v is List) return v.map((e) => e.toString()).toList();
      return const [];
    }

    String _str(dynamic v) => v?.toString() ?? '';

    return ResumeAnalysis(
      name: _str(json['name']),
      email: _str(json['email']),
      phone: _str(json['phone']),
      linkedin: _str(json['linkedin']),
      degree: _str(json['degree']),
      experienceYears: _str(json['experience_years']),
      experienceSummary: _str(json['experience_summary']),
      projects: _list(json['projects']),
      certifications: _list(json['certifications']),
      technicalSkills: _list(json['technical_skills']),
      softSkills: _list(json['soft_skills']),
      frameworks: _list(json['frameworks']),
      tools: _list(json['tools']),
      cloud: _list(json['cloud']),
      languages: _list(json['languages']),
      strengths: _list(json['strengths']),
      weaknesses: _list(json['weaknesses']),
      careerLevel: _str(json['career_level']),
      industry: _str(json['industry']),
      summary: _str(json['summary']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'linkedin': linkedin,
        'degree': degree,
        'experience_years': experienceYears,
        'experience_summary': experienceSummary,
        'projects': projects,
        'certifications': certifications,
        'technical_skills': technicalSkills,
        'soft_skills': softSkills,
        'frameworks': frameworks,
        'tools': tools,
        'cloud': cloud,
        'languages': languages,
        'strengths': strengths,
        'weaknesses': weaknesses,
        'career_level': careerLevel,
        'industry': industry,
        'summary': summary,
      };
}
