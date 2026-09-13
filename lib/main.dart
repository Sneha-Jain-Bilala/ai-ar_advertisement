import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'providers/advertiser_provider.dart';
import 'providers/ar_view_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/campaign_provider.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env configuration (Groq API key)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('DotEnv load warning: $e');
  }

  // Initialize Firebase with generated Android options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialize warning: $e');
  }

  runApp(const ArAdVisionApp());
}

class ArAdVisionApp extends StatelessWidget {
  const ArAdVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CampaignProvider()),
        ChangeNotifierProvider(create: (_) => ArViewProvider()),
        ChangeNotifierProvider(create: (_) => AdvertiserProvider()),
      ],
      child: MaterialApp.router(
        title: 'AR-AdVision',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
