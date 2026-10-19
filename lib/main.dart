import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_shell.dart';
import 'screens/welcome_screen.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Firebase connected: ${Firebase.app().name}');
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final settings = SettingsService();
  final welcomeSeen = await settings.hasSeenWelcome();
  final userName = await settings.getUserName() ?? '';

  runApp(StudyMateApp(welcomeSeen: welcomeSeen, userName: userName));
}

class StudyMateApp extends StatelessWidget {
  final bool welcomeSeen;
  final String userName;

  const StudyMateApp({
    super.key,
    required this.welcomeSeen,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: welcomeSeen ? MainShell(userName: userName) : const WelcomeScreen(),
    );
  }
}
