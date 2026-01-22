import 'package:flutter/material.dart';

class AppointmentsPage extends StatelessWidget {
  const AppointmentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        elevation: 6,
        shadowColor: Colors.black45,
      ),
      body: const Center(child: Text('Appointments Page')),
    );
  }
}
