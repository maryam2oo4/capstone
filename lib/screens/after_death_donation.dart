import 'package:flutter/material.dart';

class AfterDeathDonationPage extends StatelessWidget {
  const AfterDeathDonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('After Death Donation'),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      body: Center(child: Text('After Death Donation Page')),
    );
  }
}
