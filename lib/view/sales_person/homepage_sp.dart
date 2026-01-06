import 'package:flutter/material.dart';

class SalesPersonHomepage extends StatelessWidget {
  const SalesPersonHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Sales Person Homepage',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
