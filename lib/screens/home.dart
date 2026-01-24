import 'package:flutter/material.dart';
import 'donation.dart';
import 'app_drawer.dart';

class HomePage extends StatefulWidget {
  final bool isAdmin;
  const HomePage({super.key, this.isAdmin = false});

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  bool _showMoreHeroes = false;
  bool _donationButtonActive = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Image.asset("assets/images/logol.png", height: 40),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Background image included in scroll view
            Image.asset(
              "assets/images/image.png",
              fit: BoxFit.cover,
              width: double.infinity,
              height: MediaQuery.of(context).size.height, // full screen height
            ),

            // Second centered image and text/buttons
            Column(
              children: [
                const SizedBox(height: 100), // spacing from top / appbar
                Center(
                  child: Image.asset("assets/images/home.png", width: 350),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 0, left: 15, right: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "BE THE\nLINK THAT\nSAVES A LIFE",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: const Color.fromARGB(255, 42, 59, 68),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
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
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: BorderSide(
                                color: const Color.fromARGB(255, 204, 14, 1),
                                width: 2,
                              ),
                              shape: StadiumBorder(),
                              padding: EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              "Save Life",
                              style: TextStyle(
                                color: const Color.fromARGB(255, 196, 19, 7),
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                197,
                                19,
                                7,
                              ),
                              shape: StadiumBorder(),
                              padding: EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
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
