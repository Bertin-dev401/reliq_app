import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/routes.dart';
import 'theme/reliq_themes.dart';
import 'services/theme_service.dart';
import 'providers/auth_provider.dart';
import 'providers/community_provider.dart';
import 'providers/bible_provider.dart';
import 'providers/event_provider.dart';
import 'providers/marketplace_provider.dart';
import 'providers/streak_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Load saved theme — only apply if user has already chosen one at signup
  final prefs = await SharedPreferences.getInstance();
  final hasChosen = prefs.getBool('theme_chosen') ?? false;
  final savedTheme = hasChosen ? await ThemeService.getTheme() : 'white';

  runApp(ReliqApp(initialTheme: savedTheme));
}

class ReliqApp extends StatefulWidget {
  final String initialTheme;
  const ReliqApp({super.key, required this.initialTheme});

  static _ReliqAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_ReliqAppState>();

  @override
  State<ReliqApp> createState() => _ReliqAppState();
}

class _ReliqAppState extends State<ReliqApp> {
  late String _currentTheme;

  @override
  void initState() {
    super.initState();
    _currentTheme = widget.initialTheme;
  }

  void changeTheme(String themeKey) async {
    await ThemeService.saveTheme(themeKey);
    setState(() => _currentTheme = themeKey);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => BibleProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
        ChangeNotifierProvider(create: (_) => StreakProvider()),
      ],
      child: GetMaterialApp(
        title: 'Reliq',
        debugShowCheckedModeBanner: false,
        theme: ReliqThemes.getTheme(_currentTheme),
        initialRoute: '/splash',
        getPages: AppRoutes.routes,
      ),
    );
  }
}
