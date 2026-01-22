import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'donation_center.dart';

class HomePage extends StatefulWidget {
  final bool isAdmin;
  const HomePage({super.key, this.isAdmin = false});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Image.asset("assets/images/logol.png", height: 40),
        centerTitle: true,
        elevation: 12,
        shadowColor: Colors.black38,
        backgroundColor: const Color(0xFFF5F5F5),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background image included in scroll view
            Image.asset(
              "assets/images/image.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
            ),

            // Second centered image and text/buttons
            Column(
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Image.asset("assets/images/home.png", width: 350),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 0, left: 15, right: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "BE THE\nLINK THAT\nSAVES A LIFE",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color.fromARGB(255, 42, 59, 68),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const SizedBox(
                        width: 280,
                        child: Text(
                          "Join LifeLink in connecting donors, hospitals and patients to save lives through blood, organ and financial donations.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DonationCenterPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                color: Color.fromARGB(255, 204, 14, 1),
                                width: 2,
                              ),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Save Life",
                              style: TextStyle(
                                color: Color.fromARGB(255, 196, 19, 7),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DonationCenterPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                197,
                                19,
                                7,
                              ),
                              shape: const StadiumBorder(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              "Donate Blood",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
