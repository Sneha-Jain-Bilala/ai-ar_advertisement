import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class GroqService {
  static final GroqService _instance = GroqService._internal();
  factory GroqService() => _instance;
  GroqService._internal();

  String? get apiKey {
    return dotenv.env['groq'] ?? dotenv.env['GROQ_API_KEY'];
  }

  bool get isConfigured => apiKey != null && apiKey!.trim().isNotEmpty;

  /// Generate AI Product Summary / Highlights
  Future<String> generateProductSummary({
    required String productName,
    required String brand,
    required String category,
    required String description,
    required Map<String, String> specs,
  }) async {
    if (!isConfigured) {
      return 'AI Summary unavailable. Please check your Groq API key in .env';
    }

    final prompt = '''
You are an expert consumer tech and lifestyle product analyst for an AR advertising platform.
Create a concise, punchy 3-bullet insight summary (maximum 60 words total) for this product:
Product: $productName by $brand
Category: $category
Description: $description
Specs: ${specs.entries.map((e) => '${e.key}: ${e.value}').join(', ')}

Format:
• [Highlight 1 - key selling point]
• [Highlight 2 - best use case or audience]
• [Highlight 3 - buyer tip or value verdict]
No extra preamble or intro.
''';

    try {
      final response = await _callGroq(prompt);
      return response;
    } catch (e) {
      debugPrint('GroqService error: $e');
      return '• Engineered for high durability and performance\n• Best suited for enthusiasts and daily use\n• Top-rated in its class for value and ergonomics';
    }
  }

  /// Generate Campaign Ad Copy & Slogan for Advertisers
  Future<Map<String, String>> generateCampaignCopy({
    required String productName,
    required String brand,
    required String campaignGoal,
  }) async {
    if (!isConfigured) {
      return {
        'headline': 'Discover $productName in Augmented Reality',
        'subheading': 'Step into the future of shopping with 3D interactive preview.',
        'cta': 'Experience in 3D',
      };
    }

    final prompt = '''
Generate high-converting AR advertising copy for:
Product: $productName by $brand
Campaign Objective: $campaignGoal

Respond ONLY with valid JSON in this exact structure:
{
  "headline": "punchy 5-8 word headline",
  "subheading": "compelling 12-18 word description highlighting the 3D AR experience",
  "cta": "3-4 word call to action button label"
}
''';

    try {
      final text = await _callGroq(prompt, temperature: 0.7);
      final cleanJson = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final decoded = jsonDecode(cleanJson) as Map<String, dynamic>;
      return {
        'headline': decoded['headline']?.toString() ?? 'Discover $productName',
        'subheading': decoded['subheading']?.toString() ?? 'Experience in interactive 3D AR today.',
        'cta': decoded['cta']?.toString() ?? 'View in AR',
      };
    } catch (e) {
      debugPrint('Groq campaign copy error: $e');
      return {
        'headline': 'Experience $productName in 3D AR',
        'subheading': 'Scan to view true-to-life dimensions and exclusive limited offers.',
        'cta': 'Unlock AR Experience',
      };
    }
  }

  /// Ask interactive questions about a product (AI Assistant in Product Detail screen)
  Future<String> askProductQuestion({
    required String productName,
    required String brand,
    required String description,
    required Map<String, String> specs,
    required String question,
  }) async {
    if (!isConfigured) {
      return 'I cannot answer right now as the AI service is offline. Please verify the Groq API configuration.';
    }

    final prompt = '''
You are the AR-AdVision AI Shopping Assistant. A customer looking at the $productName by $brand in AR is asking:
"$question"

Product details:
Description: $description
Specs: ${specs.entries.map((e) => '${e.key}: ${e.value}').join(', ')}

Provide a friendly, helpful, concise answer (under 50 words) directly answering their question based on the product specs.
''';

    try {
      final answer = await _callGroq(prompt, temperature: 0.5);
      return answer;
    } catch (e) {
      debugPrint('Groq ask question error: $e');
      return 'The $productName is crafted with premium materials and engineered for optimal everyday performance and longevity.';
    }
  }

  Future<String> _callGroq(String prompt, {double temperature = 0.5}) async {
    final key = apiKey;
    if (key == null || key.isEmpty) {
      throw Exception('Missing Groq API key in .env');
    }

    final response = await http.post(
      Uri.parse(ApiConstants.groqBaseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $key',
      },
      body: jsonEncode({
        'model': ApiConstants.groqModel,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': temperature,
        'max_tokens': 300,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = data['choices'] as List?;
      if (choices != null && choices.isNotEmpty) {
        final message = choices[0]['message'] as Map<String, dynamic>?;
        final content = message?['content'] as String?;
        if (content != null) {
          return content.trim();
        }
      }
    }

    // Attempt fallback model if 70b hits rate limits
    if (response.statusCode != 200) {
      final fallbackResponse = await http.post(
        Uri.parse(ApiConstants.groqBaseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $key',
        },
        body: jsonEncode({
          'model': ApiConstants.groqFallbackModel,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': temperature,
          'max_tokens': 300,
        }),
      );

      if (fallbackResponse.statusCode == 200) {
        final data = jsonDecode(fallbackResponse.body) as Map<String, dynamic>;
        final choices = data['choices'] as List?;
        if (choices != null && choices.isNotEmpty) {
          final message = choices[0]['message'] as Map<String, dynamic>?;
          final content = message?['content'] as String?;
          if (content != null) {
            return content.trim();
          }
        }
      }
      throw Exception('Groq API error (${response.statusCode}): ${response.body}');
    }

    throw Exception('Empty response from Groq');
  }
}
