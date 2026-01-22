import 'package:flutter/material.dart';

class AliveOrganDonationPage extends StatelessWidget {
  const AliveOrganDonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Living Donor'),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      body: Center(child: Text('Living Organ Donation Page')),
    );
  }
}
