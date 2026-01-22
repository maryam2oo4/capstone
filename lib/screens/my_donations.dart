import 'package:flutter/material.dart';

class MyDonationsPage extends StatelessWidget {
  const MyDonationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donations'),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      body: const Center(child: Text('My Donations Page')),
    );
  }
}
