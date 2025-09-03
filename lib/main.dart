import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'route_helper.dart';
import 'services/auth_provider.dart';
import 'services/auth_service.dart';
import 'test_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize auth service with persistence
  await AuthService().initialize();

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // App resumed from background - refresh auth state
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.refreshUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GateEase',
      debugShowCheckedModeBanner: false,
      routes: RouteHelper.getRoutes(context),
      onGenerateRoute: RouteHelper.generateRoute,
      initialRoute: '/login', // Start directly with login to bypass splash screen
    );
  }
}
