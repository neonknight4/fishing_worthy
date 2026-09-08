import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/section_prefs.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';
import 'screens/app_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  themeController.load();
  // Sklopljene sekcije se čitaju pre prvog kadra, da Collapsible može
  // sinhrono da zna svoje stanje i ne trepne pri otvaranju ekrana.
  await SectionPrefs.load();
  runApp(const FishingWorthyApp());
}

class FishingWorthyApp extends StatelessWidget {
  const FishingWorthyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) => MaterialApp(
        title: 'Upecaj!',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeController.mode,
        home: const AppShell(),
      ),
    );
  }
}
