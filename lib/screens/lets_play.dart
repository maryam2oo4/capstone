import 'package:flutter/material.dart';
import 'lets_play_webview.dart';

class LetsPlayPage extends StatelessWidget {
  const LetsPlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Let's Play"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2D124D), Color(0xFFB71C1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Top image (replace with your asset)
              SizedBox(
                height: width * 0.5,
                child: Image.asset(
                  'assets/images/game.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              // Phrase
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Engage',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'LifeLink Challenge',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Test your knowledge about blood donation, organ donation, and health safety',
                      style: TextStyle(color: Colors.white70, fontSize: 15),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Start button
              SizedBox(
                width: 120,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LetsPlayWebViewPage(
                          url:
                              'https://life-link-react-app.vercel.app/quizlit/welcome',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF1744),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Start',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
