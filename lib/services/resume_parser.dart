import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/resume_data.dart';

class ResumeParser {
  static const List<String> _skillKeywords = [
    "Python",
    "SQL",
    "Machine Learning",
    "Deep Learning",
    "Data Science",
    "Data Analysis",
    "Natural Language Processing",
    "Statistics",
    "TensorFlow",
    "Keras",
    "PyTorch",
    "Pandas",
    "NumPy",
    "Scikit-learn",
    "Matplotlib",
    "Seaborn",
    "Big Data",
    "Hadoop",
    "Spark",
    "Data Visualization",
    "Power BI",
    "Tableau",
    "MATLAB",
    "SAS",
    "Cloud Computing",
    "AWS",
    "Azure",
    "Google Cloud",
    "Docker",
    "Kubernetes",
    "Git",
    "GitHub",
    "CI/CD",
    "Linux",
    "Unix",
    "Data Engineering",
    "ETL",
    "PostgreSQL",
    "NoSQL",
    "MongoDB",
    "REST API",
    "ML Ops",
    "Team Management",
    "Communication",
    "Project Management",
    "Agile",
    "Scrum",
    "Kanban",
    "Business Analysis",
    "Process Improvement",
    "Change Management",
    "Risk Management",
    "Strategic Planning",
    "Digital Marketing",
    "Social Media Marketing",
    "Content Marketing",
    "Email Marketing",
    "Google Analytics",
    "Market Research",
    "Graphic Design",
    "UI/UX Design",
    "Photoshop",
    "Illustrator",
    "Figma",
    "Sketch",
    "Adobe XD",
    "3D Modeling",
    "Video Editing",
    "Excel",
    "Power Pivot",
    "VBA",
    "Stata",
    "Data Mining",
    "Predictive Analytics",
    "Business Intelligence",
    "A/B Testing",
    "Leadership",
    "Critical Thinking",
    "Problem Solving",
    "Adaptability",
    "Time Management",
    "Decision Making",
    "Collaboration",
    "Active Listening",
    "Creativity",
    "Attention to Detail",
    "Public Speaking",
    "Presentation Skills",
    "Teamwork",
    "MS Office",
    "Microsoft Excel",
    "Microsoft Word",
    "Microsoft PowerPoint",
    "Trello",
    "Slack",
    "Notion",
    "Web Development",
    "Mobile Development",
    "Quality Assurance",
    "Lean Six Sigma",
    "Sales",
    "SAP ERP",
    "Human Resources",
    "Recruiting",
    "Legal Research",
    "Healthcare Management",
    "Clinical Research",
    "R",
    "Bash",
    "Terraform",
    "Jenkins",
    "Automation",
    "Scripting",
    "Copywriting",
    "Branding",
    "Content Creation",
    "SEO",
    "Budgeting",
    "Forecasting",
    "Financial Analysis",
    "Accounting",
    "Salesforce",
    "HubSpot",
    "CRM",
    "Negotiation",
    "Kubernetes",
    "Feature Engineering",
    "Model Deployment",
    "Dimensionality Reduction",
    "PCA",
    "Hyperparameter Tuning",
  ];

  static const List<String> _certKeywords = [
    "Certifications",
    "Certificates",
    "Achievements",
    "Awards",
    "Honors",
  ];

  static const List<String> _expKeywords = [
    "Experience",
    "Work Experience",
    "Professional Experience",
    "Role",
    "Position",
  ];

  Future<ResumeData> parse(Uint8List bytes) async {
    final document = PdfDocument(inputBytes: bytes);
    final extractor = PdfTextExtractor(document);
    String text = '';

    for (int i = 0; i < document.pages.count; i++) {
      text += '${extractor.extractText(startPageIndex: i, endPageIndex: i)}\n';
    }
    document.dispose();

    return _parseText(text);
  }

  ResumeData _parseText(String text) {
    final lower = text.toLowerCase();

    // Email
    final emailRegex = RegExp(
      r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    );
    final emailMatch = emailRegex.firstMatch(text);

    // Phone
    final phoneRegex = RegExp(r'\b\d{10}\b');
    final phoneMatch = phoneRegex.firstMatch(text);

    // Skills
    final skills = _skillKeywords
        .where((s) => lower.contains(s.toLowerCase()))
        .toList();

    // Degree
    String degree = 'Not found';
    if (text.contains('B.Tech') || lower.contains('bachelor')) {
      degree = "Bachelor's Degree";
    } else if (text.contains('M.Tech') || lower.contains('master')) {
      degree = "Master's Degree";
    } else if (lower.contains('phd') || lower.contains('doctorate')) {
      degree = "Doctorate";
    }

    // Certifications
    String certifications = 'No certifications found';
    for (final kw in _certKeywords) {
      final idx = lower.indexOf(kw.toLowerCase());
      if (idx != -1) {
        final end = idx + 300;
        certifications = text.substring(idx, end.clamp(0, text.length)).trim();
        break;
      }
    }

    // Experience
    String experience = 'No experience details found';
    for (final kw in _expKeywords) {
      final idx = lower.indexOf(kw.toLowerCase());
      if (idx != -1) {
        final end = idx + 500;
        experience = text.substring(idx, end.clamp(0, text.length)).trim();
        break;
      }
    }

    // LinkedIn
    final linkedInRegex = RegExp(r'https?://[^\s]*linkedin\.com[^\s]*');
    final linkedInMatch = linkedInRegex.firstMatch(text);

    return ResumeData(
      email: emailMatch?.group(0) ?? 'Not found',
      mobileNumber: phoneMatch?.group(0) ?? 'Not found',
      skills: skills,
      degree: degree,
      certifications: certifications,
      experience: experience,
      linkedIn: linkedInMatch?.group(0),
    );
  }
}
