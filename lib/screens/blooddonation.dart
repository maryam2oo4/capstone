import 'package:flutter/material.dart';

class BloodDonationPage extends StatefulWidget {
  const BloodDonationPage({super.key});

  @override
  State<BloodDonationPage> createState() => _BloodDonationPage();
}

class _BloodDonationPage extends State<BloodDonationPage> {
  @override
  Widget build(BuildContext context) {
    return (
      Scaffold(
        appBar: AppBar(title: Text('Blood Donation'),),
      )
    );
  }
}
