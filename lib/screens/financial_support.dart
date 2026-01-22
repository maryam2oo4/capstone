import 'package:flutter/material.dart';

class FinancialSupportPage extends StatelessWidget {
  const FinancialSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Financial Support'),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      body: Center(child: Text('Financial Support Page')),
    );
  }
}
