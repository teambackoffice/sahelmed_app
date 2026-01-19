import 'package:flutter/material.dart';
import 'package:sahelmed_app/view/login_page.dart';
import 'package:sahelmed_app/view/service_engineer/homepage_se.dart';
import 'package:sahelmed_app/view/sales_person/homepage_sp.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SahelMed',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ServiceEngineerHomepage(),
    );
  }
}
