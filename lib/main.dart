import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sahelmed_app/providers/create_lead_provider.dart';
import 'package:sahelmed_app/providers/create_mr_provider.dart';
import 'package:sahelmed_app/providers/create_quotation_provider.dart';
import 'package:sahelmed_app/providers/employee_check_in_provider.dart';
import 'package:sahelmed_app/providers/get_customer_provider.dart';
import 'package:sahelmed_app/providers/get_item_list_provider.dart';
import 'package:sahelmed_app/providers/get_leads_provider.dart';
import 'package:sahelmed_app/providers/get_machine_service_certi_provider.dart';
import 'package:sahelmed_app/providers/get_material_request_provider.dart';
import 'package:sahelmed_app/providers/get_mv_provider.dart';
import 'package:sahelmed_app/providers/get_quotation_provider.dart';
import 'package:sahelmed_app/providers/get_warehouse_provider.dart';
import 'package:sahelmed_app/providers/login_provider.dart';
import 'package:sahelmed_app/providers/logout_provider.dart';
import 'package:sahelmed_app/providers/post_mv_status_provider.dart';
import 'package:sahelmed_app/services/get_leads_service.dart';
import 'package:sahelmed_app/services/get_quotation_service.dart';
import 'package:sahelmed_app/services/login_service.dart';
import 'package:sahelmed_app/view/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => LeadController()),
        ChangeNotifierProvider(create: (_) => GetQuotationController()),
        ChangeNotifierProvider(create: (_) => LogoutController()),
        ChangeNotifierProvider(create: (_) => GetMachineRequestController()),
        ChangeNotifierProvider(create: (_) => CreateLeadProvider()),
        ChangeNotifierProvider(create: (_) => CreateQuotationController()),
        ChangeNotifierProvider(create: (_) => GetCustomerProvider()),
        ChangeNotifierProvider(create: (_) => ItemsProvider()),
        ChangeNotifierProvider(create: (_) => GetMachineServiceProvider()),
        ChangeNotifierProvider(
          create: (_) => GetMaintenanceRequestController(),
        ),
        ChangeNotifierProvider(create: (_) => UpdateVisitStatusController()),
        ChangeNotifierProvider(create: (_) => EmployeeCheckinController()),
        ChangeNotifierProvider(create: (_) => GetWarehouseProvider()),
        ChangeNotifierProvider(create: (_) => CreateMaterialRequestProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sahelmed App',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const SplashScreen(),
      ),
    );
  }
}
