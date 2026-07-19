import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/community_provider.dart';
import 'providers/bible_provider.dart';
import 'providers/event_provider.dart';
import 'providers/marketplace_provider.dart';
import 'providers/streak_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Keeps Firestore-backed screens useful when the device is offline.
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ReliqApp());
}

class ReliqApp extends StatelessWidget {
  const ReliqApp({super.key});

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
        theme: ReliqTheme.light,
        darkTheme: ReliqTheme.dark,
        // Follows system dark/light mode automatically
        themeMode: ThemeMode.system,
        initialRoute: '/splash',
        getPages: AppRoutes.routes,
      ),
    );
  }
}
