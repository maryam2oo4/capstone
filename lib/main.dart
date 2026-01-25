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
import '/screens/login.dart';
import '/screens/register.dart';

void main() {
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
      home: const LoginScreen(),
      routes: {'/register': (context) => const RegisterPage()},
      routes: {
        '/login': (_) => const LoginScreen(),
        '/main': (_) => const MainNavigation(),
      },
      home: const LoginScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    LetsPlayPage(),
    DonationCenterPage(),
    ContactUsPage(),
    ProfilePage(),
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
