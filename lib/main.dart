import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/github_trending_screen.dart';
import 'screens/prompt_hub_screen.dart';
import 'screens/devspace_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CodeGo Tech News',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF06B6D4), // Cyan accent
          secondary: Color(0xFF8B5CF6), // Purple AI
          surface: Color(0xFF161F30),
          background: Color(0xFF0B0F19),
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  @override
  void initState() {
    super.initState();
    // Initialize provider: reads local security tokens & triggers API fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(), // Disable swiping between tabs to keep bottom bar stable
          children: [
            DashboardScreen(),
            GitHubTrendingScreen(),
            PromptHubScreen(),
            DevSpaceScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161F30).withOpacity(0.85),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.06),
                    width: 0.8,
                  ),
                ),
              ),
              child: const TabBar(
                indicatorColor: Colors.transparent, // Hide default line indicator for custom premium look
                labelColor: Color(0xFF06B6D4),
                unselectedLabelColor: Colors.white60,
                labelPadding: EdgeInsets.symmetric(vertical: 4),
                tabs: [
                  Tab(
                    icon: Icon(Icons.feed_outlined, size: 20),
                    child: Text('TIN TỨC', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                  Tab(
                    icon: Icon(Icons.trending_up, size: 20),
                    child: Text('GITHUB', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                  Tab(
                    icon: Icon(Icons.bolt, size: 20),
                    child: Text('PROMPTS', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                  Tab(
                    icon: Icon(Icons.widgets_outlined, size: 20),
                    child: Text('DEVSPACE', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.2)),
                  ),
                  Tab(
                    icon: Icon(Icons.person_outline, size: 20),
                    child: Text('CÁ NHÂN', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
