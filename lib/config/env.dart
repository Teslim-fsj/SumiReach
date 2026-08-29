class Env {
  static const geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyBDwDZdqF1W22l5ncXcDy6DM5mtl505MEw',
  );

  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;
}