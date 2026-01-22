import 'package:flutter/material.dart';

class OverallPage extends StatelessWidget {
  const OverallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overall'),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      body: const Center(child: Text('Overall Page')),
    );
  }
}
