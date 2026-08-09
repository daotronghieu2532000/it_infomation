import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
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
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Inter',
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF0A84FF), // Apple Blue
          secondary: Color(0xFFBF5AF2), // Apple Purple
          surface: Color(0xFF1C1C1E), // Apple SystemGrey6
          background: Colors.black,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().init();
      _initTracking();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initTracking() async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      debugPrint("ATT request failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(), // Disable swiping between tabs to keep bottom bar stable
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
                    color: Colors.black.withOpacity(0.85),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                        width: 0.5,
                      ),
                    ),
                  ),
                  height: 68,
                  child: TabBar(
                    indicatorColor: Colors.transparent, // Hide default line indicator for custom premium look
                    labelColor: const Color(0xFF0A84FF),
                    unselectedLabelColor: Colors.white54,
                    labelPadding: EdgeInsets.zero,
                    tabs: [
                      _buildTabItem(context, 'assets/news.png', context.tr('TIN TỨC', 'NEWS'), showDivider: true),
                      _buildTabItem(context, 'assets/github.png', context.tr('GITHUB', 'GITHUB'), showDivider: true),
                      _buildTabItem(context, 'assets/terminal.png', context.tr('PROMPTS', 'PROMPTS'), showDivider: true),
                      _buildTabItem(context, 'assets/visual-basic.png', context.tr('DEVSPACE', 'DEVSPACE'), showDivider: true),
                      _buildTabItem(context, 'assets/hacker.png', context.tr('CÁ NHÂN', 'PROFILE'), showDivider: false),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, String assetPath, String label, {required bool showDivider}) {
    return Tab(
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(
                  right: BorderSide(
                    color: Colors.white12,
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              assetPath,
              width: 30,
              height: 30,
              color: assetPath == 'assets/github.png' ? Colors.white : null,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
