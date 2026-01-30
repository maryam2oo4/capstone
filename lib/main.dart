import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/state/app_state.dart';
import '/screens/home.dart';
import '/screens/login.dart';
import '/screens/lets_play.dart';
import '/screens/donation_center.dart';
import '/screens/contact_us.dart';
import '/screens/profile.dart';
import '/widgets/custom_bottom_nav_bar.dart';
import '/screens/register.dart';
import 'core/network/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.setBaseUrl(
    // Laravel API routes are under /api (ApiClient also normalizes this).
    'https://lifelink-laravel-app-production.up.railway.app/api',
  );

  runApp(
    ChangeNotifierProvider(create: (_) => AppState(), child: const MainApp()),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFF01010),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 12,
          shadowColor: Colors.black38,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/main': (_) => const MainNavigation(),
      },
      home: const LoginScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final bool isAdmin;
  const MainNavigation({super.key, this.isAdmin = false});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
      const HomePage(isAdmin: true),
      const LetsPlayPage(),
      const DonationCenterPage(),
      const ContactUsPage(),
      const ProfilePage(),
    ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
