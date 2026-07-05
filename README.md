# Jobby – AI Resume Analyzer

Jobby is a cross-platform Flutter application that leverages Google's Gemini AI to analyze resumes, evaluate ATS compatibility, and provide personalized career insights. The application supports both job seekers and recruiters by automating resume parsing, skill matching, and candidate evaluation.

---

## Features

### For Job Seekers

- Upload resumes in PDF format
- AI-powered resume parsing using Gemini
- ATS compatibility score
- Resume quality analysis
- Skill gap identification
- Career recommendations
- Resume improvement suggestions
- Visual analytics with charts

### For Recruiters

- Upload multiple candidate resumes
- AI-based candidate ranking
- Resume-to-job description matching
- Skill extraction and comparison
- Automated candidate evaluation
- Recruiter dashboard

---

## Tech Stack

### Frontend

- Flutter
- Dart

### AI

- Google Gemini API

### PDF Processing

- Syncfusion PDF

### State Management

- Flutter Stateful Widgets

### Charts

- FL Chart

### Platforms

- Android
- iOS

---

## Project Architecture

```
lib/
├── models/
├── prompts/
├── screens/
├── services/
├── widgets/
└── main.dart
```

The application follows a modular architecture where:

- Models represent application data.
- Services handle AI communication and business logic.
- Prompt templates generate structured Gemini requests.
- Screens manage user interaction.

---

## AI Capabilities

The application uses Gemini for:

- Resume parsing
- ATS evaluation
- Skill extraction
- Resume scoring
- Candidate ranking
- Career guidance
- Job-role matching

---

## Installation

Clone the repository

```bash
git clone https://github.com/yourusername/Jobby.git
```

Navigate into the project

```bash
cd Jobby
```

Install dependencies

```bash
flutter pub get
```

Create a `.env` file in the project root

```env
GEMINI_API_KEY=YOUR_API_KEY
```

Run the application

```bash
flutter run
```

---

## Screens

- Home Screen
- Resume Upload
- Resume Analysis
- ATS Report
- Career Suggestions
- Recruiter Dashboard
- Candidate Ranking

---

## Key Functionalities

- AI Resume Parsing
- ATS Score Generation
- Skill Matching
- Resume Review
- Career Suggestions
- Candidate Ranking
- Interactive Charts
- Cross-platform Support

---

## Future Improvements

- Authentication
- Cloud Database Integration
- Resume History
- Interview Question Generation
- Job Portal Integration
- Export Analysis as PDF

---

## Disclaimer

Gemini-generated analysis is intended to assist users and should not replace professional recruitment or career advice.

---

## Author

**Harshaan Yadav**

LinkedIn: https://linkedin.com/in/harshaanyadav

GitHub: https://github.com/harshaanyadav
